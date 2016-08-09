class InterFAX::Object < OpenStruct
  def attributes
    hash = to_h
    hash.delete(:client)
    hash
  end

  def inspect
    _client = client
    self.delete_field('client')
    result = super
    self.client = _client
    result
  end
end
