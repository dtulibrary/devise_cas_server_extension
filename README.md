Devise CAS server extension
===========================

This extension enables a devise setup to respond to the CAS protocol.

The code is based on rubycas server, but instead of a stand alone
implementation, this works within a devise setup.

This gem should not be used in standalone projects.

CAS is a single-sign-on system, and therefore intended for use in system where
there is a central user registration.


Installation
------------

Add it to the gemfile along with devise.

gem 'devise'
gem 'devise_cas_server_extension'

Run the installation generator:
  rails generate devise_cas_server_extension:install

The generator adds configuration definitions to config/initializers/devise.rb
Modify it, or add a another initializers to customize your setup.

The generator also adds migrations for 3 new tables. Create the new tables by
running.
  rake db:migrate

And last the generator copies to the default message to the config/locales
catalog.

