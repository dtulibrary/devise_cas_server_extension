require 'spec_helper'

describe Devise::Models::ServiceTicket do
  it "has a valid factory" do
    FactoryGirl.build(:service_ticket).should be_valid
  end

  it "fails without ticket" do
    FactoryGirl.build(:service_ticket, ticket: nil).should_not be_valid
  end

  it "fails without service" do
    FactoryGirl.build(:service_ticket, service: nil).should_not be_valid
  end

  it "validate consumes ticket" do
    ticket = FactoryGirl.create(:service_ticket)
    result = Devise::Models::ServiceTicket.validate(ticket.ticket, ticket.service)
    Devise::Models::ServiceTicket.find_by_ticket(ticket.ticket).consumed?.should be true
    result.status.should eq 200
    result.error.should eq nil
  end

  it "remove ticket from service" do
    ticket = FactoryGirl.create(:service_ticket)
    result = Devise::Models::ServiceTicket.validate(ticket.ticket, ticket.service+"?ticket="+ticket.ticket)
    result.status.should eq 200
    result.error.should eq nil
  end

  it "fails validate with consumed ticket" do
    ticket = FactoryGirl.create(:service_ticket)
    ticket.consume!
    result = Devise::Models::ServiceTicket.validate(ticket.ticket, ticket.service)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid ticket" do
    ticket = FactoryGirl.create(:service_ticket)
    result = Devise::Models::ServiceTicket.validate("randomticket",
      ticket.service)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid service" do
    ticket = FactoryGirl.create(:service_ticket)
    result = Devise::Models::ServiceTicket.validate(ticket.ticket,
      "randomservice")
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with expired ticket" do
    ticket = FactoryGirl.create(:service_ticket, created_at: 1.year.ago)
    result = Devise::Models::ServiceTicket.validate(ticket.ticket,
      ticket.service)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with nil ticket and service" do
    result = Devise::Models::ServiceTicket.validate(nil, nil)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with nil ticket" do
    ticket = FactoryGirl.create(:service_ticket)
    result = Devise::Models::ServiceTicket.validate(nil, ticket.service)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with nil service" do
    ticket = FactoryGirl.create(:service_ticket)
    result = Devise::Models::ServiceTicket.validate(ticket.ticket, nil)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "adds uri without parameters" do
    ticket = FactoryGirl.create(:service_ticket)
    ticket.with_uri("http://localhost").should eq "http://localhost?ticket="+
      ticket.ticket
  end

  it "adds uri without real parameters" do
    ticket = FactoryGirl.create(:service_ticket)
    ticket.with_uri("http://localhost?").should eq "http://localhost?ticket="+
      ticket.ticket
  end

  it "adds uri with parameters" do
    ticket = FactoryGirl.create(:service_ticket)
    ticket.with_uri("http://localhost?p=1").should eq "http://localhost?p=1"+
      "&ticket="+ticket.ticket
  end

end
