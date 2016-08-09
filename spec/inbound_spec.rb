require_relative './test_helper'

describe 'InterFAX::Inbound' do
  before do
    @client = Minitest::Mock.new
    @inbound = InterFAX::Inbound.new(@client)
  end

  describe '.all' do
    it "should call the client" do
      response = [{id: '123'}]
      @client.expect :get, response, ['/inbound/faxes', {}, [:unreadOnly, :limit, :lastId, :allUsers]]
      result = @inbound.all
      result.first.id.must_equal '123'
      result.first.must_be_kind_of InterFAX::Inbound::Fax
      @client.verify
    end
  end

  describe '.find' do
    it "should call the client" do
      response = { id: '123' }
      @client.expect :get, response, ['/inbound/faxes/123']
      result = @inbound.find 123
      result.must_be_kind_of InterFAX::Inbound::Fax
      result.id.must_equal '123'
      @client.verify
    end
  end

  describe '.image' do
    it "should call the client" do
      response = 'abc123'
      @client.expect :get, response, ['/inbound/faxes/123/image']
      result = @inbound.image 123
      result.must_be_kind_of InterFAX::Image
      result.data.must_equal 'abc123'
      @client.verify
    end
  end

  describe '.emails' do
    it "should call the client" do
      response = [{ email: 'foo@bar.com' }]
      @client.expect :get, response, ['/inbound/faxes/123/emails']
      result = @inbound.emails 123
      result.first.must_be_kind_of InterFAX::ForwardingEmail
      result.first.email.must_equal 'foo@bar.com'
      @client.verify
    end
  end

  describe '.mark' do
    it "should call the client" do
      @client.expect :post, nil, ['/inbound/faxes/123/mark', { unread: true }, [:unread]]
      result = @inbound.mark 123, read: false
      result.must_equal true
      @client.verify
    end

    it "should work without a boolean" do
      @client.expect :post, nil, ['/inbound/faxes/123/mark', { unread: false }, [:unread]]
      result = @inbound.mark 123
      result.must_equal true
      @client.verify
    end
  end

  describe '.resend' do
    it "should call the client" do
      @client.expect :post, nil, ['/inbound/faxes/123/resend', { email: 'foo@example.com' }, [:email]]
      result = @inbound.resend 123, email: 'foo@example.com'
      result.must_equal true
      @client.verify
    end

    it "should work without an email" do
      @client.expect :post, nil, ['/inbound/faxes/123/resend', {}, [:email]]
      result = @inbound.resend 123
      result.must_equal true
      @client.verify
    end
  end
end
