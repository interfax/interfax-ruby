class InterFAX::Outbound

  def initialize client
    @client = client
  end

  def all params = {}
    valid_keys = [:limit, :lastId, :sortOrder, :userId]
    @client.get('/outbound/faxes', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::OutboundFax.new(fax)
    end
  end

  def completed ids = []
    params = { ids: ids }
    valid_keys = [:ids]
    @client.get('/outbound/faxes/completed', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::OutboundFax.new(fax)
    end
  end

  def find id
    fax = @client.get("/outbound/faxes/#{id}")
    fax[:client] = @client
    InterFAX::OutboundFax.new(fax)
  end

  def image fax_id
    image = @client.get("/outbound/faxes/#{fax_id}/image")
    image[:client] = @client
    InterFAX::Image.new(image)
  end

  def cancel fax_id
    fax = @client.get("/outbound/faxes/#{fax_id}/cancel")
    fax[:client] = @client
    InterFAX::OutboundFax.new(fax)
  end

  def search params = {}
    valid_keys = [:ids, :reference, :dateFrom, :dateTo, :status, :userId, :faxNumber, :limit, :offset]
    @client.get('/outbound/search', params, valid_keys).map do |fax|
      fax[:client] = @client
      InterFAX::OutboundFax.new(fax)
    end
  end
end
