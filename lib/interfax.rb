require 'time'
require "soap/wsdlDriver"

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'interfax/fax_item'
require 'interfax/base'
require 'interfax/incoming'
