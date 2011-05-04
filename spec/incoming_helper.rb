module IncomingHelper

  INTERFAX_RESPONSE = {:messageID => '2011', 
    :phoneNumber => '6145551212',
    :remoteCSID => '923459129349',
    :messageStatus => "0",
    :pages => '1',
    :messageSize => '58800',
    :messageType => "1",
    :receiveTime => "2011-01-01T09:08:11",
    :callerID => '8005556666',
    :messageRecordingDuration => "60"}
    

  
  class MockInterfaxResponse < Struct.new(:objMessageItem); end
  class ObjMessageItem < Struct.new(:messageItem); end
  class MessageItem < Struct.new(*INTERFAX_RESPONSE.keys); end

  def mock_getlist_response(count = 1)
    MockInterfaxResponse.new(ObjMessageItem.new([MessageItem.new(*INTERFAX_RESPONSE.values)]* count))
  end
end
