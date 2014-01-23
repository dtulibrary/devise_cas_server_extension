require 'uri'
require 'devise_cas_server_extension/models/consumable'
require 'devise_cas_server_extension/models/ticket'
require 'devise_cas_server_extension/models/ticket_response'

module Devise
  module Models
    class ServiceTicket < ActiveRecord::Base
      include Ticket
      include Consumable

      attr_accessible :consumed, :ticket, :service, :ticket_granting_ticket_id

      belongs_to :ticket_granting_ticket

      validates_presence_of :ticket, :service, :ticket_granting_ticket

      def initialize(*args)
        super
        self.ticket = "ST-" + random_string
      end

      def self.validate(ticket, service)
        logger.debug "Validating service/proxy ticket '#{ticket}' for service '#{service}'"
        tr = TicketResponse.new
        tr.ticket = ticket
        tr.service = service

        #logger.info "Config #{config.inspect}"
        #logger.info "Time #{config.cas_server_maximum_unused_service_ticket_lifetime}"
        if service.nil? or ticket.nil?
          tr.set_error 500, 'service_ticket_incorrect_request'
          logger.info "Ticket or service parameter was missing in the request."
        elsif st = find_by_ticket(ticket)
          if st.consumed?
            tr.set_error 500, 'service_ticket_already_used'
            logger.info "Ticket '#{ticket}' has already been used up."
          elsif Time.now - st.created_at > Devise.cas_server_maximum_unused_service_ticket_lifetime
            tr.set_error 500, 'service_ticket_expired'
            logger.info "Ticket '#{ticket}' has expired."
          elsif !st.matches_service? service
            tr.set_error 500, 'service_ticket_no_match'
            logger.info "The ticket '#{ticket}' belonging to user "+
              "'#{st.ticket_granting_ticket.username}' is valid, but the requested service "+
              "'#{service}' does not match the service '#{st.service}'"+
              " associated with this ticket."
          else
            logger.info("Ticket '#{ticket}' for service '#{service}' for user '#{st.ticket_granting_ticket.username}' successfully validated.")
            tr.service_ticket = st
          end
        else
          tr.set_error  500, 'service_ticket_invalid'
          logger.info "Ticket '#{ticket}' not recognized."
        end

        st.consume! if st && !st.consumed?

        tr
      end

      def matches_service?(service)
        self.class.clean_service_url(self.service) ==
        self.class.clean_service_url(service)
      end

      def self.clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        clean_service = dirty_service.dup
        ['service', 'ticket', 'gateway', 'renew'].each do |p|
          clean_service.sub!(Regexp.new("&?#{p}=[^&]*"), '')
        end

        clean_service.gsub!(/[\/\?&]$/, '') # remove trailing ?, /, or &
        clean_service.gsub!('?&', '?')
        clean_service.gsub!(' ', '+')

        logger.debug("Cleaned dirty service URL #{dirty_service.inspect} to #{clean_service.inspect}") if
          dirty_service != clean_service

        return clean_service
      end

      def with_uri(uri)
        # This will choke with a URI::InvalidURIError if service URI is not
        # properly URI-escaped...
        # This exception is handled further upstream (i.e. in the controller).
        service_uri = URI.parse(uri)

        if uri.include? "?"
          if service_uri.query.empty?
            query_separator = ""
          else
            query_separator = "&"
          end
        else
          query_separator = "?"
        end

        uri + query_separator + "ticket=" + self.ticket
      end

#      ::Devise.config(self,
#        :cas_server_maximum_unused_service_ticket_lifetime,
#      )
      module ClassMethods
        ::Devise::Models.config(self,
          :cas_server_maximum_unused_service_ticket_lifetime,
        )
      end
    end
  end
end
