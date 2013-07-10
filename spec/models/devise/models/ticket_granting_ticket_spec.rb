require 'spec_helper'

describe Devise::Models::TicketGrantingTicket do
  it "has a valid factory" do
    FactoryGirl.build(:ticket_granting_ticket).should be_valid
  end

  it "fails without ticket" do
    FactoryGirl.build(:ticket_granting_ticket, ticket: nil).should_not be_valid
  end

  it "fails without client_hostname" do
    FactoryGirl.build(:ticket_granting_ticket, client_hostname: nil).should_not be_valid
  end

  it "fails without username" do
    FactoryGirl.build(:ticket_granting_ticket, username: nil).should_not be_valid
  end

  it "returns ticket with to_s" do
    ticket = FactoryGirl.build(:ticket_granting_ticket)
    ticket.to_s.should eq ticket.ticket
  end

  it "validates ticket" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate(ticket.ticket,
      ticket.client_hostname)
    result.status.should eq 200
    result.error.should eq nil
    result.granting_ticket.should eq ticket
  end

  it "fails validate with nil ticket" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate(nil,
      ticket.client_hostname)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with nil client" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate(ticket.ticket,
      nil)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid ticket and client" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate("randomticket",
      "randomclient")
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid ticket" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate("randomticket",
      ticket.client_hostname)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid client" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate(ticket.ticket, "randomclient")
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with expired ticket" do
    ticket = FactoryGirl.create(:ticket_granting_ticket, created_at: 1.year.ago)
    result = Devise::Models::TicketGrantingTicket.validate(ticket.ticket, ticket.client_hostname)
    result.status.should eq 500
    result.error.should_not eq nil
  end

  it "fails validate with invalid client" do
    ticket = FactoryGirl.create(:ticket_granting_ticket)
    result = Devise::Models::TicketGrantingTicket.validate(ticket.ticket, "randomclient")
    result.status.should eq 500
    result.error.should_not eq nil
  end

end
