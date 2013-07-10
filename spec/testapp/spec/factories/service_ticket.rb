FactoryGirl.define do
  factory :service_ticket, :class => Devise::Models::ServiceTicket do |f|
    f.sequence(:ticket) { |n| "LT-ticket-#{n}" }
    f.association :ticket_granting_ticket
    f.service "http://localhost/service"
  end
end
