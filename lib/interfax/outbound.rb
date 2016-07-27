class InterFAX::Outbound

  def initialize client
    @client = client
  end

  def deliver params = {}
    location = InterFAX::Outbound::Delivery.new(@client, params).execute
    id = location.split("/").last
    InterFAX::Outbound::Fax.new(id: id, client: @client)
  end

  def all params = {}
    valid_keys = [:limit, :lastId, :sortOrder, :userId]
    @client.get('/outbound/faxes', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::Outbound::Fax.new(fax)
    end
  end

  def completed ids = []
    params = { ids: ids }
    valid_keys = [:ids]
    @client.get('/outbound/faxes/completed', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::Outbound::Fax.new(fax)
    end
  end

  def find id
    fax = @client.get("/outbound/faxes/#{id}")
    fax[:client] = @client
    InterFAX::Outbound::Fax.new(fax)
  end

  def image fax_id
    data = @client.get("/outbound/faxes/#{fax_id}/image")
    InterFAX::Image.new(data: data, client: @client)
  end

  def cancel fax_id
    fax = @client.get("/outbound/faxes/#{fax_id}/cancel")
    fax[:client] = @client
    InterFAX::Outbound::Fax.new(fax)
  end

  def search params = {}
    valid_keys = [:ids, :reference, :dateFrom, :dateTo, :status, :userId, :faxNumber, :limit, :offset]
    @client.get('/outbound/search', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::Outbound::Fax.new(fax)
    end
  end
end
