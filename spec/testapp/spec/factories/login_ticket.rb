FactoryGirl.define do
  factory :login_ticket, :class => Devise::Models::LoginTicket do |f|
    f.sequence(:ticket) { |n| "LT-ticket-#{n}" }
    f.client_hostname "127.0.0.1"
  end
end
