ActionDispatch::Routing::Mapper.class_eval do

  protected

  # route for verifying cas service tickets
  def devise_cas_server(mapping, controllers)
    # Add specific cas server routes
    # "Default" routes are create in the "normal" devise session configuration
    resource :session, :only => [], :controller =>
      controllers[:cas_server_sessions], :path => '' do
      #get :new, :path => mapping.path_names[:sign_in], :as => "new"
      #post :create, :path => mapping.path_names[:sign_in], :as => "create"
      #match :destroy, :path => mapping.path_names[:sign_out], :as => "destroy"
      get "serviceValidate",
        :to => "#{controllers[:sessions]}#service_validate"
      get "proxyValidate",
        :to => "#{controllers[:sessions]}#service_validate"
    end

  end
end
