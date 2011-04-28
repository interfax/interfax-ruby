$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'interfax'
require 'spec'
require 'spec/autorun'
require 'incoming_helper'

Spec::Runner.configure do |config|
  
end
