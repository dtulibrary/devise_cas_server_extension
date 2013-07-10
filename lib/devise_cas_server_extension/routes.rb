ActionDispatch::Routing::Mapper.class_eval do
# module ActionDispatch::Routing
#  class Mapper

    protected

    # route for verifying cas service tickets
    def devise_cas_server(mapping, controllers)
      get "serviceValidate",
        :to => "#{controllers[:sessions]}#service_validate"
    end

  #end
end
