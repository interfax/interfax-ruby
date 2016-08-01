require_relative '../test_helper'

describe 'InterFAX::Outbound::Fax' do

  before do
    client = InterFAX::Client.new username: 'johndoe', password: 'test123'
    @outbound = Minitest::Mock.new
    client.outbound = @outbound

    @fax = InterFAX::Outbound::Fax.new client: client, id: 123
  end

  describe '.image' do
    it "should delegate to outbound client" do
      @outbound.expect :image, nil, [123]
      @fax.image
      @outbound.verify
    end
  end

  describe '.cancel' do
    it "should delegate to outbound client" do
      @outbound.expect :cancel, nil, [123]
      @fax.cancel
      @outbound.verify
    end
  end

  describe '.reload' do
    it "should delegate to the outbound client" do
      @outbound.expect :find, nil, [123]
      @fax.reload
      @outbound.verify
    end
  end
end
