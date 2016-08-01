class InterFAX::File
  attr_accessor :header, :body

  def initialize location, options = {}
    if options[:mime_type]
      initialize_binary(location, options[:mime_type])
    elsif location.start_with?('http://') || location.start_with?('https://')
      initialize_url(location)
    else
      initialize_path(location)
    end
  end

  def initialize_binary(data, mime_type)
    self.header = "Content-Type: #{mime_type}"
    self.body = data
  end

  def initialize_url(url)
    self.header = "Content-Location: #{url}"
    self.body = nil
  end

  def initialize_path(path)
    file = File.open(path)
    mime_type = MimeMagic.by_magic(file)

    self.header = "Content-Type: #{mime_type}"
    self.body = File.open(path, 'rb').read
  end
end
