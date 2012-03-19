
module Interfax

  class Base
    
    # Class methods
    
    class << self
      attr_accessor :username, :password

      def query(verb,verbdata,limit=-1)
        result = SOAP::WSDLDriverFactory.new("https://ws.interfax.net/dfs.asmx?WSDL").create_rpc_driver.FaxQuery(
          :Username => self.username,
          :Password => self.password,
          :Verb => verb,
          :VerbData => verbdata,
          :MaxItems => limit,
          :ResultCode => 0
        )
        return [] if result.nil? || !defined?(result.faxQueryResult)
        [*result.faxQueryResult.faxItemEx].map do |f| 
          FaxItem.new(
            f.transactionID,
            Time.parse(f.submitTime),
            Time.parse(f.postponeTime),
            f.destinationFax,
            f.duration,
            f.remoteCSID,
            f.pagesSent,
            f.status,
            f.subject,
            f.pagesSubmitted)
        end  
      end
      
      def find(*args)
        query("IN", args.join(','))
      end

      def last(limit=1)
        query("LE","999999999",limit)
      end
      
      def all()
        query("LE","999999999")
      end

    end

    # Instance methods

    def initialize(type="HTML",content=nil)
      @username = self.class.username
      @password = self.class.password
      @type = type.to_s.upcase
      @content = content
      @at = Time.now
      @recipients = nil
      @subject = "Change me"
      @retries = "0"
      @csid = nil
    end
    
    def contains(content)
      @content = content
      self
    end
    
    def to(recipients)
      @recipients = [*recipients].join(";")
      self
    end
    
    def subject(subject)
      @subject = subject
      self
    end
    
    def retries(count)
      @retries = count.to_s
      self
    end
    
    def at(time)
      @at = time
      self
    end
    

    #Sender CSID (up to 20 characters). If not provided, user's default CSID is used.
    def csid=(csid_string)
        @csid = csid_string.to_s[0,20]
    end
    
    def summary
      { 
        :fax_numbers => @recipients, 
        :content => @content,
        :at => @at,
        :retries => @retries,
        :subject => @subject,
        :username => @username
      }
    end
    
    def deliver

      options = {
        :Username => @username,
        :Password => @password,
        :FileTypes => @type,
        :Postpone => @at,
        :RetriesToPerform => @retries,
        :FaxNumbers=> @recipients,
        :FilesData => @content,
        :FileSizes => @content.size,
        :Subject => @subject,
        :PageSize => 'A4',
        :PageOrientation => 'Portrait',
        :IsHighResolution => 'true',
        :IsFineRendering => 'false'
      }

        
      #option settings
      options[:CSID] = @csid if @csid

      result = SOAP::WSDLDriverFactory.new("https://ws.interfax.net/dfs.asmx?WSDL").create_rpc_driver.SendfaxEx_2(options)

      result ? result.sendfaxEx_2Result : nil
    end
    
  end

end
