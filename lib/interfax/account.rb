class InterFAX::Account

  def initialize client
    @client = client
  end

  def balance
    @client.get('/accounts/self/ppcards/balance').to_f
  end
end
