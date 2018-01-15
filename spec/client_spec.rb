require_relative './test_helper'

describe 'InterFAX::Client' do
  before do
    @client = InterFAX::Client.new(username: 'johndoe', password: 'password')
  end

  describe '.initialize' do
    it "should return successful with the right params" do
      client = InterFAX::Client.new(username: 'johndoe', password: 'password')
      client.must_be_instance_of InterFAX::Client
      client.username.must_equal 'johndoe'
      client.password.must_equal 'password'
    end

    it "should return successful with the ENV variables set" do
      ENV['INTERFAX_USERNAME'] = 'johndoe'
      ENV['INTERFAX_PASSWORD'] = 'password'

      client = InterFAX::Client.new
      client.must_be_instance_of InterFAX::Client
      client.username.must_equal 'johndoe'
      client.password.must_equal 'password'

      ENV.delete('INTERFAX_USERNAME')
      ENV.delete('INTERFAX_PASSWORD')
    end

    it "should raise without the right params" do
      assert_raises KeyError do
        InterFAX::Client.new
      end
    end

    it "should allow for setting a custom hostname" do
      client = InterFAX::Client.new(
        username: 'johndoe',
        password: 'password',
        host: 'test.example.com'
      )
      client.host.must_equal 'test.example.com'
    end
  end

  describe '.deliver' do
    it "should delegate to InterFAX::Outbound" do
      @outbound = Minitest::Mock.new
      @client.outbound = @outbound
      @outbound.expect :deliver, nil, [{ faxNumber: '11111', file: 'test.pdf' }]
      @client.deliver faxNumber: '11111', file: 'test.pdf'
      @outbound.verify
    end
  end

  describe '.account' do
    it "should return a InterFAX::Account object" do
      @client.account.must_be_instance_of InterFAX::Account
    end
  end

  describe '.outbound' do
    it "should return a InterFAX::Outbound" do
      @client.outbound.must_be_instance_of InterFAX::Outbound
    end
  end

  describe '.inbound' do
    it "should return a InterFAX::Inbound" do
      @client.inbound.must_be_instance_of InterFAX::Inbound
    end
  end

  describe '.documents' do
    it "should return a InterFAX::Documents" do
      @client.documents.must_be_instance_of InterFAX::Documents
    end
  end

  describe '.get' do
    it "should return the json on success" do
      stub_request(:get, /rest.interfax.net\/accounts\/self\/ppcards\/balance/).
        to_return(:status => 200, :body => '{"balance" : "123"}', :headers => { 'Content-Type' =>  'text/json'})

      result = @client.get('/accounts/self/ppcards/balance')
      result['balance'].must_equal '123'
    end

    it "should use the correct hostname" do
      @client = InterFAX::Client.new(
        username: 'johndoe',
        password: 'password',
        host: 'test.example.com'
      )

      stub_request(:get, /test.example.com\/accounts\/self\/ppcards\/balance/).
        to_return(:status => 200, :body => '{"balance" : "123"}', :headers => { 'Content-Type' =>  'text/json'})

      result = @client.get('/accounts/self/ppcards/balance')
      result['balance'].must_equal '123'
    end

    it "should return image data if tiff or pdf" do
      stub_request(:get, /rest.interfax.net\/outbound\/faxes\/123123\/image/).
        to_return(:status => 200, :body => 'data', :headers => { 'Content-Type' =>  'application/pdf'})

      result = @client.get('/rest.interfax.net/outbound/faxes/123123/image/')
      result[0].must_equal 'data'
      result[1].must_equal 'application/pdf'
    end

    it "should raise on 401" do
      stub_request(:get, /rest.interfax.net\/accounts\/self\/ppcards\/balance/).
        to_return(:status => 401)

      assert_raises InterFAX::Client::UnauthorizedError do
        @client.get('/accounts/self/ppcards/balance')
      end
    end

    it "should raise on 404" do
      stub_request(:get, /rest.interfax.net\/accounts\/self\/ppcards\/balance/).
        to_return(:status => 404)

      assert_raises InterFAX::Client::NotFoundError do
        @client.get('/accounts/self/ppcards/balance')
      end
    end

    it "should filter invalid keys" do
      assert_raises ArgumentError do
        @client.get('/foobar', { id: 123, invalidKey: '123'}, [:id])
      end
    end
  end

  describe '.post' do
    it "should return the json on success" do
      stub_request(:post, /rest.interfax.net\/accounts\/self\/ppcards\/balance/).
        to_return(:status => 200, :body => '{"balance" : "123"}', :headers => { 'Content-Type' =>  'text/json'})

      result = @client.post('/accounts/self/ppcards/balance')
      result['balance'].must_equal '123'
    end

    it "should handle a bad request" do
      stub_request(:post, /rest.interfax.net\/accounts\/self\/ppcards\/balance/).
        to_return(:status => 400)

        assert_raises InterFAX::Client::BadRequestError do
          @client.post('/accounts/self/ppcards/balance')
        end
    end

    it "should filter invalid keys" do
      assert_raises ArgumentError do
        @client.post('/foobar', { id: 123, invalidKey: '123'}, [:id])
      end
    end
  end

end
