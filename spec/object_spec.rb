require_relative './test_helper'

describe 'InterFAX::Object' do

  describe '.inspect' do
    it "should truncate the data to make the output more readable" do
      @client = Minitest::Mock.new
      @image = InterFAX::Object.new client: @client

      assert !@image.inspect.include?('client')
    end
  end

  describe '.attributes' do
    it "should truncate the data to make the output more readable" do
      @client = Minitest::Mock.new
      @image = InterFAX::Object.new client: @client

      assert !@image.attributes.include?('client')
    end
  end
end
