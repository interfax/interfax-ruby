class InterFAX::Outbound::Delivery
  attr_accessor :client, :params, :files, :fax_number

  VALID_KEYS = [:faxNumber, :contact, :postponeTime, :retriesToPerform, :csid, :pageHeader, :reference, :replyAddress, :pageSize, :fitToPage, :pageOrientation, :resolution, :rendering]
  BOUNDARY = "265001916915724"

  def initialize client, params
    self.client = client
    self.params = params
  end

  def execute
    validate_params

    headers = generate_headers
    files = generate_files
    body = body_for(files)

    client.post('/outbound/faxes', params, VALID_KEYS, headers, body)
  end

  private

  def validate_params
    self.fax_number = params[:faxNumber] || raise(ArgumentError.new('Missing argument: faxNumber'))
    self.files = [params[:file] || params[:files] || raise(ArgumentError.new('Missing argument: file or files'))].flatten

    params.delete(:fax_number)
    params.delete(:file)
    params.delete(:files)
  end

  def generate_headers
    {
      "Content-Type" => "multipart/mixed; boundary=#{BOUNDARY}"
    }
  end

  def generate_files
    files.map do |file|
      if file.kind_of?(String)
        InterFAX::File.new(file)
      elsif file.kind_of?(InterFAX::File)
        file
      end
    end
  end

  def body_for(files)
    files.map do |file|
      "--#{BOUNDARY}\r\n#{file.header}\r\n#{file.body}\r\n"
    end.join + "--#{BOUNDARY}\r\n"
  end
end
