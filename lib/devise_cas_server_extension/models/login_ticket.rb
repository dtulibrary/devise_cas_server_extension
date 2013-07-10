require 'devise_cas_server_extension/models/consumable'
require 'devise_cas_server_extension/models/ticket'
require 'devise_cas_server_extension/models/ticket_response'

module Devise
  module Models
    class LoginTicket < ActiveRecord::Base
      include Ticket
      include Consumable

      attr_accessible :client_hostname, :consumed, :ticket

      validates_presence_of :ticket, :client_hostname

      def initialize(*args)
        super
        self.ticket = "LT-" + random_string
      end

      def self.validate(ticket)
        logger.debug("Validating login ticket '#{ticket}'")
        tr = TicketResponse.new
        tr.ticket = ticket

        if ticket.nil?
          tr.set_error 500, 'no_login_ticket'
        elsif lt = find_by_ticket(ticket)
          if lt.consumed?
            tr.set_error 500, 'login_ticket_already_used'
            logger.warn "Login ticket '#{ticket}' previously used up"
          elsif Time.now - lt.created_at < Devise.cas_server_maximum_unused_login_ticket_lifetime
            logger.info "Login ticket '#{ticket}' successfully validated"
          else
            tr.set_error 500, 'login_ticket_expired'
            logger.warn "Expired login ticket '#{ticket}'"
          end
        else
          tr.set_error 500, 'login_ticket_invalid'
          logger.warn "Invalid login ticket '#{ticket}'"
        end
        lt.consume! if lt && !lt.consumed?
        tr
      end

#      module ClassMethods
#        ::Devise::Models.config(Devise::Models::LoginTicket,
#          :cas_server_maximum_unused_login_ticket_lifetime,
#        )
#      end

    end
  end
end
