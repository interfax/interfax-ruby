require_relative './test_helper'

describe 'InterFAX::Account' do

  describe '.balance' do
    it "should return if succesful" do
      @client = Minitest::Mock.new
      @account = InterFAX::Account.new @client

      @client.expect :get, '6.54000', ['/accounts/self/ppcards/balance']
      @account.balance.must_equal 6.54
      @client.verify
    end
  end
end
