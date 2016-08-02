class InterFAX::Files
  def initialize client
    @client = client
  end

  def create data, options = {}
    InterFAX::File.new(@client, data, options)
  end
end
