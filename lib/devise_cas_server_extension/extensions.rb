module DeviseCasServerExtension
  module Extensions
    autoload :SessionsControllerCasServer, 'devise_cas_server_extension/extensions/sessions_controller_cas_server'

    class << self
      def apply
        Devise::SessionsController.send(:include, Extensions::SessionsControllerCasServer)
      end
    end
  end
end

