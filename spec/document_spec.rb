require_relative './test_helper'

describe 'InterFAX::Document' do

  before do
    client = InterFAX::Client.new username: 'johndoe', password: 'test123'
    @documents = Minitest::Mock.new
    client.documents = @documents

    @document = InterFAX::Document.new uri: 'https://foobar.com/123456', client: client
  end

  describe '.upload' do
    it "should delegate to documents client" do
      @documents.expect :upload, nil, ['123456', 0, 9999 , 'data']
      @document.upload 0, 9999, 'data'
      @documents.verify
    end
  end

  describe '.cancel' do
    it "should delegate to documents client" do
      @documents.expect :cancel, nil, ['123456']
      @document.cancel
      @documents.verify
    end
  end

  describe '.reload' do
    it "should delegate to the documents client" do
      @documents.expect :find, nil, ['123456']
      @document.reload
      @documents.verify
    end
  end

  describe '.id' do
    it "should extract the ID from the URI" do
      @document.id.must_equal '123456'
    end
  end
end
