require_relative './test_helper'

describe 'InterFAX::File' do
  describe '.initialize' do
    it "should process binary files" do
      file = InterFAX::File.new(File.open('./spec/test.pdf', 'rb').read, mime_type: 'application/pdf')
      file.header.must_equal 'Content-Type: application/pdf'
      assert file.body.length == 9147
    end

    it "should process urls" do
      file = InterFAX::File.new('http://foobar.com/test.pdf')
      file.header.must_equal 'Content-Location: http://foobar.com/test.pdf'
      file.body.must_equal nil
    end

    it "should process paths" do
      file = InterFAX::File.new('./spec/test.pdf')
      file.header.must_equal 'Content-Type: application/pdf'
      assert file.body.length == 9147
    end
  end
end
