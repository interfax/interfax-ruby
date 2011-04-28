module IncomingHelper
  
  class MockInterfaxResponse < Struct.new(:objMessageItem); end
  class ObjMessageItem < Struct.new(:messageItem); end
  class MessageItem < Struct.new(:messageID, :messageSize); end
  

  def mock_getlist_response(count = 1)
    MockInterfaxResponse.new(ObjMessageItem.new([MessageItem.new('messageid', '200000')] * count))
  end
end
