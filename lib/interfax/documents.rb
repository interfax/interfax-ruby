class InterFAX::Documents

  def initialize client
    @client = client
  end

  def create name, size, options = {}
    options[:name] = name
    options[:size] = size

    valid_keys = [:name, :size, :disposition, :shared]
    
    uri = @client.post("/outbound/documents", options, valid_keys)
    InterFAX::Document.new(uri: uri, client: @client)
  end

  def upload document_id, range_start, range_end, chunk
    headers = { 'Range' => "bytes=#{range_start}-#{range_end}" }
    @client.post("/outbound/documents/#{document_id}", {}, {}, headers, chunk)
    true
  end

  def all options = {}
    valid_keys = [:limit, :offset]
    @client.get("/outbound/documents", options, valid_keys).map do |document|
      document[:client] = @client
      InterFAX::Document.new(document)
    end
  end

  def find document_id
    document = @client.get("/outbound/documents/#{document_id}")
    document[:client] = @client
    InterFAX::Document.new(document)
  end

  def cancel document_id
    @client.delete("/outbound/documents/#{document_id}")
    true
  end

end
