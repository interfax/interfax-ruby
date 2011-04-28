require 'spec_helper'
include IncomingHelper

describe Interfax::Incoming do
  
  before(:each) do
    @client_mock = mock("SoapClient",
                        :GetList => true,
                        :GetImageChunk => true)
    
    Interfax::Incoming.stub!(:soap_client).and_return(@client_mock)
  end

  context "querying for incoming faxes" do

    it "should query for all messages" do
      Interfax::Incoming.should_receive(:query).with('AllMessages', anything())
      Interfax::Incoming.all
    end

    it "should query for unread messages" do
      Interfax::Incoming.should_receive(:query).with('NewMessages', anything())
      Interfax::Incoming.unread
    end

    it "should query for all users' unread messages" do
      Interfax::Incoming.should_receive(:query).with('AccountNewMessages', anything())
      Interfax::Incoming.account_unread
    end

    it "should query for all users' messages" do
      Interfax::Incoming.should_receive(:query).with('AccountAllMessages', anything())
      Interfax::Incoming.account_all
    end

    it "should respect the :limit argument over a class-defined limit" do
      @client_mock.should_receive(:GetList).with(hash_including(:MaxItems => 24))
      Interfax::Incoming.limit = 50
      Interfax::Incoming.all(:limit => 24)
    end

    it "should use the class-specified limit over the default" do
      @client_mock.should_receive(:GetList).with(hash_including(:MaxItems => 50))
      Interfax::Incoming.limit = 50
      Interfax::Incoming.all
    end

    it "should respect the :mark_as_read argument over the class-defined value" do
      @client_mock.should_receive(:GetList).with(hash_including(:MarkAsRead => true))
      Interfax::Incoming.mark_as_read = false
      Interfax::Incoming.all(:mark_as_read => true)
    end

    it "should use the class-specified mark_as_read over the default" do
      @client_mock.should_receive(:GetList).with(hash_including(:MarkAsRead => true))
      Interfax::Incoming.mark_as_read = true
      Interfax::Incoming.all
    end


    it "should return instances of the base class when called on the base class" do
      @client_mock.stub!(:GetList).and_return(mock_getlist_response)
      Interfax::Incoming.all[0].class.should == Interfax::Incoming
    end

    it "should return instances of the subclass when called on a subclass" do
      class TestFax < Interfax::Incoming; end

      @client_mock.
        stub!(:GetList).
        and_return(mock_getlist_response)
      TestFax.stub!(:soap_client).and_return(@client_mock)

      TestFax.all[0].class.should == TestFax
    end
    
  end

  context "fetching images" do

    before(:each) do 
      @fax = Interfax::Incoming.new('message_id', '200000')
    end

    it "should fetch the image when asked" do
      @client_mock.should_receive(:GetImageChunk).at_least(:once)
      @fax.image
    end

    it "should cache the image once received" do
      @client_mock.should_receive(:GetImageChunk).at_least(:once)
      @fax.image
      @client_mock.should_not_receive(:GetImageChunk)
      @fax.image
    end

    it "should respect the class-defined mark_as_read option" do
      Interfax::Incoming.mark_as_read = true
      @client_mock.should_receive(:GetImageChunk).with(hash_including(:MarkAsRead => true))
      @fax.image
    end

    
  end
  
end

