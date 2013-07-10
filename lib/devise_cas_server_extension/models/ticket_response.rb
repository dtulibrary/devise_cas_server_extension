require 'builder'

class TicketResponse < Object

  def initialize
    super
    @ticket = nil
    @service = nil
    @error_code = 200
    @error_handle = nil
    @service_ticket = nil
    @granting_ticket = nil
  end

  def status
    @error_code
  end

  def set_error(code, handle)
    @error_code = code
    @error_handle = handle
  end

  def service_ticket=(st)
    @service_ticket = st
  end

  def service_ticket
    @service_ticket
  end

  def service=(service)
    @service = service
  end

  def error
    @error_handle
  end

  def ticket=(ticket)
    @ticket = ticket
  end

  def granting_ticket=(ticket)
    @granting_ticket = ticket
  end

  def granting_ticket
    @granting_ticket
  end

  def to_xml(options = nil)
    xml = Builder::XmlMarkup.new
    xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
    Rails.logger.info "TicketResponse "+@service_ticket.inspect
    if @error_code == 200
      username = @service_ticket.ticket_granting_ticket.username.to_s
      extra_attributes = @service_ticket.ticket_granting_ticket.extra_attributes
      xml.cas :serviceResponse, 'xmlns:cas' => "http://www.yale.edu/tp/cas" do |xml|
        xml.cas :authenticationSuccess do |xml|
          xml.cas :user, username
          if extra_attributes
            xml.cas :attributes do |xml|
              extra_attributes.each do |key, value|
                xml.cas key.to_sym, value
              end
            end
          end
        end
      end
    else
      xml.cas(:serviceResponse, 'xmlns:cas' => "http://www.yale.edu/tp/cas") do |xml|
        xml.cas :authenticationFailure, {:code => @error_code},
          I18n.t(@error_handle, :scope => 'devise.sessions.cas_server')
      end
    end
    xml.to_s
  end
end
