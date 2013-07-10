require 'securerandom'

module Devise
  module Models
    module Ticket

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      def to_s
        ticket
      end

      def random_string(length = 29)
        str = "#{Time.now.to_i}r#{SecureRandom.urlsafe_base64(length)}"
        str.gsub!('_','-')
        str[0..(length - 1)]
      end

      module ClassMethods
        def cleanup_lifetime(max_lifetime)
          transaction do
            conditions = ["created_at < ?", Time.now - max_lifetime]
            expired_tickets_count = count(:conditions => conditions)

            logger.debug("Destroying #{expired_tickets_count} expired #{self.name.demodulize}"+
              "#{'s' if expired_tickets_count > 1}.") if expired_tickets_count > 0

            destroy_all(conditions)
          end
        end
      end
    end
  end
end
