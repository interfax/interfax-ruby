require_relative './test_helper'

describe 'InterFAX::File' do
  before do
    @client = Minitest::Mock.new
  end

  describe '.initialize' do
    it "should process binary files" do
      file = InterFAX::File.new(@client, File.open('./spec/test.pdf', 'rb').read, mime_type: 'application/pdf')
      file.header.must_equal 'Content-Type: application/pdf'
      assert file.body.length == 9147
    end

    it "should process urls" do
      file = InterFAX::File.new(@client, 'http://foobar.com/test.pdf')
      file.header.must_equal 'Content-Location: http://foobar.com/test.pdf'
      file.body.must_equal nil
    end

    it "should process paths" do
      file = InterFAX::File.new(@client, './spec/test.pdf')
      file.header.must_equal 'Content-Type: application/pdf'
      assert file.body.length == 9147
    end

    it "should auto upload large files" do
      stub_request(:post, /rest.interfax.net\/outbound\/documents/).
        to_return(:status => 200, :body => "http://foobar.com/test.pdf", :headers => {})

      client = InterFAX::Client.new(username: 'username', password: 'password')
      file = InterFAX::File.new(client, './spec/test.pdf', chunk_size: 5000)
      file.header.must_equal 'Content-Location: http://foobar.com/test.pdf'
      file.body.must_equal nil
    end
  end
end
