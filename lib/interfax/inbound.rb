class InterFAX::Inbound
  def initialize client
    @client = client
  end

  def all params = {}
    valid_keys = [:unreadOnly, :limit, :lastId, :allUsers]
    @client.get('/inbound/faxes', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::Inbound::Fax.new(fax)
    end
  end

  def find id
    fax = @client.get("/inbound/faxes/#{id}")
    fax[:client] = @client
    InterFAX::Inbound::Fax.new(fax)
  end

  def image fax_id
    data = @client.get("/inbound/faxes/#{fax_id}/image")
    InterFAX::Image.new(data: data, client: @client)
  end

  def mark fax_id, options = {}
    read = options.fetch(:read, true)
    valid_keys = [:unread]
    @client.post("/inbound/faxes/#{fax_id}/mark", {unread: !read}, valid_keys)
    true
  end

  def resend fax_id, options = {}
    options = options.delete_if {|k,v| k != :email }
    valid_keys = [:email]
    @client.post("/inbound/faxes/#{fax_id}/resend", options, valid_keys)
    true
  end

  def emails fax_id
    @client.get("/inbound/faxes/#{fax_id}/emails").map do |email|
      email[:client] = @client
      InterFAX::ForwardingEmail.new(email)
    end
  end
end
