require 'net/https'

module DeviseCasServerExtension
  module Extensions
    module SessionsControllerCasServer
      extend ActiveSupport::Concern

      included do
        prepend_before_filter :renew_session, :only => [:new]
        before_filter :handle_cas_login_ticket, :only => [:new]
        before_filter :verify_cas_login_ticket, :only => [:create]
      end

      def renew_session
        logger.info "Check renew session"
        @renew = params['renew']
      end

      def after_sign_in_path_for(resource)
        tgt = nil
        if tgc = request.cookies['tgt']
          tr = Devise::Models::TicketGrantingTicket.validate(
            tgc, request.remote_ip)
          tgt = tr.granting_ticket
        end
        unless tgt
          tgt = Devise::Models::TicketGrantingTicket.create(
            { username: resource.id,
              client_hostname: request.remote_ip })
          response.set_cookie('tgt', tgt.to_s)
        end
        if params['service']
          session['cas_server_service'] =
            Devise::Models::ServiceTicket.clean_service_url(params['service'])
        end

        url = nil
        if session['cas_server_service'].blank?
          logger.info("Successfully authenticated user '#{tgt.username}' at '#{tgt.client_hostname}'. No service param was given, so we will not redirect.")
        else
          url = create_service_url(tgt)
        end
        url || stored_location_for(resource) || signed_in_root_path(resource)
      end

      def create_service_url(tgt)
        @st = Devise::Models::ServiceTicket.create(
          { service: session['cas_server_service'],
            ticket_granting_ticket_id: tgt.id })

        if !@st.persisted?
          logger.info "Service Ticket not persisted "+@st.inspect
          return nil
        end

        begin
          return @st.with_uri(session['cas_server_service'])
        rescue URI::InvalidURIError
          logger.error("The service '#{@session['cas_server_service']}' is not a valid URI!")
          set_flash_message(:alert, 'cas_server.invalid_target_service')
        end
        nil
      end

      def handle_cas_login_ticket
        session['cas_server_service'] = Devise::Models::ServiceTicket.clean_service_url(params['service'])
        @gateway = params['gateway'] == 'true' || params['gateway'] == '1'

        if tgc = request.cookies['tgt']
          tr = Devise::Models::TicketGrantingTicket.validate(
            tgc, request.remote_ip)
          if tr.granting_ticket
            set_flash_message(:notice, 'cas_server.logged_in_as',
              :username => tr.granting_ticket.username)
            # TODO: Sign in user
            # TODO: Redirect no authentication needed
          end
        end


        # TODO: Can we capture a redirection loop?
        if session['cas_server_service']
          if tr.granting_ticket
            logger.debug("Valid ticket granting ticket detected.")
            url = create_service_url(tr.granting_ticket)
            logger.info("User '#{tgt.username}' authenticated based on ticket granting cookie. Redirecting to service '#{session['cas_server_service']}'.")
            # response code 303 means "See Other"
            # (see Appendix B in CAS Protocol spec)
            redirect_to url, :status => 303 if url
            logger.error("The service '#{session['server_cas_service']}' is not a valid URI!")
            set_flash_message(:alert, 'cas_server.invalid_target_service')
          elsif @gateway
            logger.info("Redirecting unauthenticated gateway request to service '#{session['cas_server_service']}'.")
            redirect_to session['cas_server_service'], :status => 303
          else
            logger.info("Proceeding with CAS login for service #{session['cas_server_service'].inspect}.")
          end
        elsif @gateway
          logger.error("This is a gateway request but no service parameter was given!")
          set_flash_message(:alert, 'cas_server.no_service_parameter_given')
        else
          logger.info("Proceeding with CAS login without a target service.")
        end

        set_login_ticket
      end

      def verify_cas_login_ticket
        lt = params['lt'] || session['lt']
        # generate another login ticket to allow for re-submitting the form
        set_login_ticket
        response = Devise::Models::LoginTicket.validate(lt)
        if response.status != 200
          set_flash_message(:notice, response.error)
          throw(:warden)
        end
      end

      def service_validate
        # TODO: Force xml response
        @response = Devise::Models::ServiceTicket.validate(params['ticket'],
          Devise::Models::ServiceTicket.clean_service_url(params['service'])
          )

         render :template => 'devise/sessions/service_validate.builder', :layout => false
      end

      def set_login_ticket
        session['lt'] = Devise::Models::LoginTicket.create(
          :client_hostname => request.remote_ip)
        @lt = session['lt']
      end

      # TODO: Single Sign Out

      # Takes an existing ServiceTicket object (presumably pulled from the
      # database) and sends a POST with logout information to the service
      # that the ticket was generated for.
      #
      # This makes possible the "single sign-out" functionality added in CAS 3.1.
      # See http://www.ja-sig.org/wiki/display/CASUM/Single+Sign+Out
      def send_logout_notification_for_service_ticket(st)
        uri = URI.parse(st.service)
        uri.path = '/' if uri.path.empty?
        time = Time.now
        rand = random_string
        path = uri.path
        req = Net::HTTP::Post.new(path)
        req.set_form_data('logoutRequest' => %{<samlp:LogoutRequest xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="#{rand}" Version="2.0" IssueInstant="#{time.rfc2822}">
     <saml:NameID></saml:NameID>
     <samlp:SessionIndex>#{st.ticket}</samlp:SessionIndex>
     </samlp:LogoutRequest>})

        begin
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme =='https'

          http.start do |conn|
            response = conn.request(req)
            if response.kind_of? Net::HTTPSuccess
              logger.info "Logout notification successfully posted to #{st.service.inspect}."
              return true
            else
              logger.error "Service #{st.service.inspect} responed to logout notification with code '#{response.code}'!"
              return false
            end
          end
        rescue StandardError => e
          logger.error "Failed to send logout notification to service #{st.service.inspect} due to #{e}"
          return false
        end
      end
    end
  end
end
