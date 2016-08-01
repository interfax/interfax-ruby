require_relative './test_helper'

describe 'InterFAX::Image' do

  describe '.inspect' do
    it "should truncate the data to make the output more readable" do
      @client = Minitest::Mock.new
      @image = InterFAX::Image.new client: @client, data: '123456789012345678901234567890'

      assert @image.inspect.length <= 50
      assert !@image.inspect.include?('client')
    end
  end
end
