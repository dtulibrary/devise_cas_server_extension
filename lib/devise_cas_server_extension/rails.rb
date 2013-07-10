module DeviseCasServerExtension
  class Engine < ::Rails::Engine
    ActionDispatch::Callbacks.to_prepare do
      DeviseCasServerExtension::Extensions.apply
    end

  end
end
