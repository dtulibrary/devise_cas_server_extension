# Encoding: UTF-8
require 'rake'
Gem::Specification.new do |spec|
  spec.name = 'devise_cas_server_extension'
  spec.authors = [ 'Morten Rønne' ]
  spec.add_runtime_dependency ('devise')
  spec.add_development_dependency('rspec')
  spec.summary = 'Devise CAS server extension'
  spec.description = <<-DESC
    This extension enables a devise setup to respond to the CAS protocol.
    The code is based on rubycas server, but instead of a stand alone 
    implementation, this works within a devise setup.
DESC
  spec.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'spec/**/*'].to_a
  spec.has_rdoc = false
  spec.license = 'GPL-2'
  spec.required_ruby_version = '>= 1.9.2'
  spec.version = '1.0.0'
end
