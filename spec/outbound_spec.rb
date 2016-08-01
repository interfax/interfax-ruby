require_relative './test_helper'

describe 'InterFAX::Client::Outbound' do
  before do
    @client = Minitest::Mock.new
    @outbound = InterFAX::Outbound.new(@client)
  end

  describe '.deliver' do
    it "should delegate to InterFAX::Outbound::Deliver" do
      @delivery = Minitest::Mock.new
      @outbound.delivery = @delivery
      @delivery.expect :deliver, nil, [{ faxNumber: '11111', file: 'test.pdf' }]
      @outbound.deliver faxNumber: '11111', file: 'test.pdf'
      @delivery.verify
    end
  end

  describe '.all' do
    it "should call the client" do
      response = [{id: '123'}]
      @client.expect :get, response, ['/outbound/faxes', {}, [:limit, :lastId, :sortOrder, :userId]]
      result = @outbound.all
      result.first.id.must_equal '123'
      result.first.must_be_kind_of InterFAX::Outbound::Fax
      @client.verify
    end
  end

  describe '.completed' do
    it "should call the client" do
      response = [{id: '123'}]
      @client.expect :get, response, ['/outbound/faxes/completed', {ids: [123]}, [:ids]]
      result = @outbound.completed 123
      result.first.id.must_equal '123'
      result.first.must_be_kind_of InterFAX::Outbound::Fax
      @client.verify
    end

    it "should work with multiple ids" do
      response = [{id: '123'}]
      @client.expect :get, response, ['/outbound/faxes/completed', {ids: [123, 234]}, [:ids]]
      result = @outbound.completed 123, 234
      result.first.id.must_equal '123'
      @client.verify
    end

    it "should work with multiple ids as an array" do
      response = [{id: '123'}]
      @client.expect :get, response, ['/outbound/faxes/completed', {ids: [123, 234]}, [:ids]]
      result = @outbound.completed [123, 234]
      result.first.id.must_equal '123'
      @client.verify
    end
  end

  describe '.find' do
    it "should call the client" do
      response = { id: '123' }
      @client.expect :get, response, ['/outbound/faxes/123']
      result = @outbound.find 123
      result.must_be_kind_of InterFAX::Outbound::Fax
      result.id.must_equal '123'
      @client.verify
    end
  end

  describe '.image' do
    it "should call the client" do
      response = 'abc123'
      @client.expect :get, response, ['/outbound/faxes/123/image']
      result = @outbound.image 123
      result.must_be_kind_of InterFAX::Image
      result.data.must_equal 'abc123'
      @client.verify
    end
  end

  describe '.cancel' do
    it "should call the client" do
      response = { id: '123' }
      @client.expect :get, response, ['/outbound/faxes/123/cancel']
      result = @outbound.cancel 123
      result.must_be_kind_of InterFAX::Outbound::Fax
      result.id.must_equal '123'
      @client.verify
    end
  end

  describe '.search' do
    it "should call the client" do
      response = [{ id: '123' }]
      @client.expect :get, response, ['/outbound/search', {faxNumber: '+1230002305555'}, [:ids, :reference, :dateFrom, :dateTo, :status, :userId, :faxNumber, :limit, :offset]]
      result = @outbound.search(faxNumber: '+1230002305555')
      result.first.must_be_kind_of InterFAX::Outbound::Fax
      result.first.id.must_equal '123'
      @client.verify
    end
  end
end
