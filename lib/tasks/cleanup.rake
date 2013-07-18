require 'devise_cas_server_extension/models/login_ticket'
require 'devise_cas_server_extension/models/service_ticket'
require 'devise_cas_server_extension/models/ticket_granting_ticket'

namespace :cas_server do
  desc "Cleanup login tickets"
  task :cleanup_login_tickets => :environment do
    login_ticket_cleanup
  end

  desc "Cleanup service tickets"
  task :cleanup_service_tickets => :environment do
    service_ticket_cleanup
  end

  desc "Cleanup granting tickets"
  task :cleanup_granting_tickets => :environment do
    granting_ticket_cleanup
  end

  desc "Cleanup tickets"
  task :cleanup => :environment do
    login_ticket_cleanup
    service_ticket_cleanup
    granting_ticket_cleanup
  end

  def login_ticket_cleanup
    Devise::Models::LoginTicket.cleanup_lifetime(
      Devise.cas_server_maximum_unused_login_ticket_lifetime
    )
  end

  def service_ticket_cleanup
    Devise::Models::ServiceTicket.cleanup_lifetime(
      Devise.cas_server_maximum_unused_service_ticket_lifetime
    )
  end

  def granting_ticket_cleanup
    Devise::Models::TicketGrantingTicket.cleanup_lifetime(
      Devise.cas_server_maximum_session_lifetime
    )
  end

end

