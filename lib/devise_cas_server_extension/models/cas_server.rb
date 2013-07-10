
module Devise
  module Models
    module CasServer
      extend ActiveSupport::Concern

      module ClassMethods
        ::Devise::Models.config(self,
          :cas_server_maximum_unused_login_ticket_lifetime,
          :cas_server_maximum_session_lifetime,
          :cas_server_maximum_unused_service_ticket_lifetime,
        )
      end
    end
  end
end
