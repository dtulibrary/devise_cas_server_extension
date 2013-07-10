require 'spec_helper'

describe Devise::Models::LoginTicket do
  it "has a valid factory" do
    FactoryGirl.build(:login_ticket).should be_valid
  end

  it "fails without ticket" do
    FactoryGirl.build(:login_ticket, ticket: nil).should_not be_valid
  end

  it "fails without client_hostname" do
    FactoryGirl.build(:login_ticket, client_hostname: nil).should_not be_valid
  end

  it "validate consumes ticket" do
    ticket = FactoryGirl.create(:login_ticket)
    result = Devise::Models::LoginTicket.validate(ticket.ticket)
    Devise::Models::LoginTicket.find_by_ticket(ticket.ticket).consumed?.should be true
    result.status.should eq 200
    result.error.should eq nil
  end

  it "fails validate with consumed ticket" do
    ticket = FactoryGirl.create(:login_ticket)
    ticket.consume!
    result = Devise::Models::LoginTicket.validate(ticket.ticket)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid ticket" do
    ticket = FactoryGirl.create(:login_ticket)
    result = Devise::Models::LoginTicket.validate("randomticket")
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with expired ticket" do
    ticket = FactoryGirl.create(:login_ticket, created_at: 1.year.ago)
    result = Devise::Models::LoginTicket.validate(ticket.ticket)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with nil ticket" do
    result = Devise::Models::LoginTicket.validate(nil)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "cleans up unconsumed tickets" do
    FactoryGirl.create(:login_ticket, :created_at => 121.seconds.ago)
    Devise::Models::LoginTicket.cleanup_unconsumed(120)
    Devise::Models::LoginTicket.all.count.should eq 0
  end

  it "cleans up consumed tickets" do
    ticket = FactoryGirl.create(:login_ticket, :created_at => 121.seconds.ago)
    ticket.consume!
    Devise::Models::LoginTicket.cleanup_lifetime(120)
    Devise::Models::LoginTicket.all.count.should eq 0
  end

  it "leaves current tickets" do
    FactoryGirl.create(:login_ticket)
    Devise::Models::LoginTicket.cleanup_lifetime(120)
    Devise::Models::LoginTicket.all.count.should eq 1
  end

  it "leaves current tickets" do
    FactoryGirl.create(:login_ticket)
    Devise::Models::LoginTicket.cleanup_unconsumed(120)
    Devise::Models::LoginTicket.all.count.should eq 1
  end
end
