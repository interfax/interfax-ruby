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

  describe '.save' do
    it 'should save the tiff to file' do
      data = '123456789012345678901234567890'
      @client = Minitest::Mock.new
      @image = InterFAX::Image.new client: @client, data: data

      FakeFS.activate!
      @image.save('test.pdf')
      File.read('test.pdf').must_equal data
      FakeFS.deactivate!
    end
  end
end
