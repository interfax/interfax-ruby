require_relative '../test_helper'

describe 'InterFAX::Outbound::Delivery' do
  before do
    @client = Minitest::Mock.new
    @delivery = InterFAX::Outbound::Delivery.new(@client)
  end

  it "should call the client" do
    response = {id: '123'}
    @client.expect :post, response do |path, params, valid_keys, headers, body|
      path == '/outbound/faxes' &&
      params == {faxNumber: '11111'} &&
      valid_keys == InterFAX::Outbound::Delivery::VALID_KEYS &&
      headers == InterFAX::Outbound::Delivery::HEADERS &&
      body.include?(InterFAX::Outbound::Delivery::BOUNDARY)
    end
    result = @delivery.deliver faxNumber: '11111', file: './spec/test.pdf'
    result.id.must_equal '123'
    result.must_be_kind_of InterFAX::Outbound::Fax
    @client.verify
  end

  it "should set mixed headers" do
    InterFAX::Outbound::Delivery::HEADERS['Content-Type'].must_include("multipart/mixed")
  end
end
