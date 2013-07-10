FactoryGirl.define do
  factory :ticket_granting_ticket, :class => Devise::Models::TicketGrantingTicket do |f|
    f.sequence(:ticket) { |n| "TGC-ticket-#{n}" }
    f.sequence(:username) { |n| "user#{n}" }
    f.client_hostname "127.0.0.1"
  end
end
