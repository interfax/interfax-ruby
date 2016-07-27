class InterFAX::Image < InterFAX::Object
  def inspect
    _data = data
    self.data = "#{data[0..20]}..."
    result = super
    self.data = _data
    result
  end
end
