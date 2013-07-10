module Devise
  module Models
    module Consumable

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      def consume!
        self.consumed = Time.now
        self.save!
      end

      module ClassMethods
        def cleanup_unconsumed(max_unconsumed_lifetime)
          transaction do
            conditions = ["consumed IS NULL AND created_at < ?",
                            Time.now - max_unconsumed_lifetime]

            expired_tickets_count = count(:conditions => conditions)

            logger.debug("Destroying #{expired_tickets_count} unconsumed #{self.name.demodulize}"+
              "#{'s' if expired_tickets_count > 1}.") if expired_tickets_count > 0

            destroy_all(conditions)
          end
        end
      end
    end
  end
end
