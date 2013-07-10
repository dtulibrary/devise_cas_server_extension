require 'devise_cas_server_extension/models/ticket'

module Devise
  module Models
    class TicketGrantingTicket < ActiveRecord::Base
      include Ticket

      attr_accessible :client_hostname, :ticket, :username, :extra_attributes

      has_many :service_tickets, :dependent => :destroy

      validates_presence_of :ticket, :client_hostname, :username

      serialize :extra_attributes

      def initialize(*args)
        super
        self.ticket = "TGC-" + random_string
      end

      def self.validate(ticket, client)
        tr = TicketResponse.new
        tr.ticket = ticket
        if ticket.nil? or client.nil?
          tr.set_error 500, 'granting_ticket_invalid_request'
        elsif tgt = find_by_ticket(ticket)
          if Devise.cas_server_maximum_session_lifetime &&
             Time.now - tgt.created_at > Devise.cas_server_maximum_session_lifetime
             tgt.destroy
            tr.set_error 500, 'granting_ticket_expired'
          elsif !tgt.matches_client_hostname?(client)
            tr.set_error 500, 'granting_ticket_client_error'
          else
            tr.granting_ticket = tgt
          end
        else
          tr.set_error 500, 'granting_ticket_invalid'
        end
        tr
      end

      def matches_client_hostname?(client_hostname)
        self.client_hostname == client_hostname
      end

    end
  end
end
