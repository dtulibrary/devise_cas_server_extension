require 'active_support/concern'
require 'devise'

module Devise
  # How long is a login ticket valid (seconds)
  mattr_accessor :cas_server_maximum_unused_login_ticket_lifetime
  @@cas_server_maximum_unused_login_ticket_lifetime = 300

  # How long is a ticket granting ticket (session) valid (seconds)
  mattr_accessor :cas_server_maximum_session_lifetime
  @@cas_server_maximum_session_lifetime = 86400

  # How long is a service ticket valid (seconds)
  mattr_accessor :cas_server_maximum_unused_service_ticket_lifetime
  @@cas_server_maximum_unused_service_ticket_lifetime = 120
end

Devise.add_module(:cas_server,
  :controller => :devise_cas_server_sessions,
  :route => :cas_server,
  :model => 'devise_cas_server_extension/models/cas_server')

require 'devise_cas_server_extension/routes'
require 'devise_cas_server_extension/rails'
require 'devise_cas_server_extension/models/login_ticket'
require 'devise_cas_server_extension/models/ticket_granting_ticket'
require 'devise_cas_server_extension/models/service_ticket'
