require 'rails/generators/active_record/migration'

module DeviseCasServerExtension
  module Generators
    # Install Generator
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("../../templates", __FILE__)

      desc "Install the devise cas server extension"

      def add_configs
        inject_into_file "config/initializers/devise.rb",
          "\n  # => Cas Server Extension\n" +
          "  # How long is a login ticket valid (seconds)\n" +
          "  # cas_server_maximum_unused_login_ticket_lifetime\n" +
          "  #   should not exceed 5 minutes (default 2 minutes)\n" +
          "  #config.cas_server_maximum_session_lifetime = 120\n\n" +
          "  # How long is a service ticket valid (seconds)\n" +
          "  # cas_server_maximum_unused_service_ticket_lifetime\n" +
          "  #   should not exceed 5 minutes (default 2 minutes)\n" +
          "  #config.cas_server_maximum_unused_service_ticket_lifetime = 120\n\n" +
          "  # How long is a ticket granting ticket (session) valid for (seconds)\n" +
          "  # cas_server_maximum_session_lifetime (default 1 day)\n" +
          "  #config.cas_server_maximum_session_lifetime = 86400\n",
          :before => /end[ |\n|]+\Z/
      end

      def copy_locale
        copy_file "../../../config/locales/en.yml", "config/locales/devise_cas_server_extension.en.yml"
      end

      def migration
        migration_template 'login_ticket_migration.rb',
          'db/migrate/create_login_ticket.rb'
        migration_template 'ticket_granting_ticket_migration.rb',
          'db/migrate/create_ticket_granting_ticket.rb'
        migration_template 'service_ticket_migration.rb',
          'db/migrate/create_service_ticket.rb'
      end

      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

    end
  end
end
