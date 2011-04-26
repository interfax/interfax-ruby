require 'soap/wsdlDriver'

module Interfax

  class Incoming

    class << self
      attr_accessor :username, :password, :mark_as_read, :limit

      def query(type, opts = {})
   
        result = SOAP::WSDLDriverFactory.new("https://ws.interfax.net/inbound.asmx?WSDL").create_rpc_driver.GetList(
          :Username => self.username,
          :Password => self.password,
          :MaxItems => opts[:MaxItems] || self.limit || 100,
          :MarkAsRead => opts[:MarkAsRead] || self.mark_as_read || false,
          :LType => type
        )
        return [] if result.nil? || !defined?(result.objMessageItem)
        result.objMessageItem.messageItem
      end

      def all(opts = {})
        query('AllMessages', opts)
      end

      def new(opts = {})
        query('NewMessages', opts)
      end

      def account_all(opts = {})
        query('AccountAllMessages', opts)
      end

      def account_new(opts = {})
        query('AccountNewMessages', opts)
      end

    end

  end

end
