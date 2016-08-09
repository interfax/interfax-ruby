require_relative './test_helper'

describe 'InterFAX::Documents' do
  before do
    @client = Minitest::Mock.new
    @documents = InterFAX::Documents.new(@client)
  end

  describe '.all' do
    it "should call the client" do
      response = [{uri: 'https://foobar.com/123'}]
      @client.expect :get, response, ['/outbound/documents', {}, [:limit, :offset]]
      result = @documents.all
      result.first.id.must_equal '123'
      result.first.must_be_kind_of InterFAX::Document
      @client.verify
    end
  end

  describe '.find' do
    it "should call the client" do
      response = {uri: 'https://foobar.com/123'}
      @client.expect :get, response, ['/outbound/documents/123']
      result = @documents.find 123
      result.must_be_kind_of InterFAX::Document
      result.id.must_equal '123'
      @client.verify
    end
  end

  describe '.cancel' do
    it "should call the client" do
      @client.expect :delete, nil, ['/outbound/documents/123']
      result = @documents.cancel 123
      result.must_equal true
      @client.verify
    end
  end

  describe '.create' do
    it "should call the client" do
      response = "https://foobar.com/123"
      @client.expect :post, response, ['/outbound/documents', {name: 'test.pdf', size: 9999}, [:name, :size, :disposition, :shared]]
      result = @documents.create 'test.pdf', 9999
      result.must_be_kind_of InterFAX::Document
      result.id.must_equal '123'
      @client.verify
    end
  end

  describe '.upload' do
    it "should call the client" do
      @client.expect :post, nil, ['/outbound/documents/123', {}, {}, {"Range"=>"bytes=0-999"}, 'data']
      result = @documents.upload '123', 0, 999, 'data'
      result.must_equal true
      @client.verify
    end
  end
end
