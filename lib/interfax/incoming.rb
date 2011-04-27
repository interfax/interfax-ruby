require 'soap/wsdlDriver'
require 'Base64'

module Interfax
  
  class Incoming
    
    class << self
      attr_accessor :username, :password, :mark_as_read, :limit
      
      def query(type, opts = {})
        result = SOAP::WSDLDriverFactory.
          new("https://ws.interfax.net/inbound.asmx?WSDL").
          create_rpc_driver.
          GetList(:Username => self.username,
                  :Password => self.password,
                  :MaxItems => opts[:MaxItems] || self.limit || 100,
                  :MarkAsRead => opts[:MarkAsRead] || self.mark_as_read || false,
                  :LType => type
                  )
        
        return [] if result.nil? || !defined?(result.objMessageItem)
        [*result.objMessageItem.messageItem].map do |fax|
          self.new(fax.messageID, fax.messageSize)
        end
      end
      
      def all(opts = {})
        query('AllMessages', opts)
      end
      
      def unread(opts = {})
        query('NewMessages', opts)
      end
      
      def account_all(opts = {})
        query('AccountAllMessages', opts)
      end
      
      def account_unread(opts = {})
        query('AccountNewMessages', opts)
      end
      
    end



    # instance methods

    attr_accessor :username, :password, :mark_as_read, :chunk_size, :message_id, :message_size, :image
    
    def initialize(message_id, message_size)
      @username = self.class.username
      @password = self.class.password
      @mark_as_read = self.class.mark_as_read || false
      @chunk_size = 100000
      @message_id = message_id
      @message_size = message_size.to_i
      @image = nil
    end

    def image
      @image || fetch_image
    end
    
    def fetch_image #:nodoc:
      @image = ""
      downloaded_size = 0
      while downloaded_size < @message_size
        result = SOAP::WSDLDriverFactory.new("https://ws.interfax.net/inbound.asmx?WSDL").
          create_rpc_driver.
          GetImageChunk(:Username => @username,
                        :Password => @password,
                        :MessageID => @message_id,
                        :MarkAsRead => @mark_as_read,
                        :ChunkSize => @chunk_size,
                        :From => downloaded_size)

        @image << Base64.decode64(result.image)
        downloaded_size += @chunk_size
      end
      @image
    end

  end

end
