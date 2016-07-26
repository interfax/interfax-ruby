class InterFAX::Object < OpenStruct
  def to_h
    hash = super
    hash.delete(:client)
    hash
  end
end
