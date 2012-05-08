require 'prawn'
require 'active_support/all'

require 'linguistics'
Linguistics::use( :en )

dir = File.dirname(__FILE__) + '/check_writer'
MICR_FONT = "#{dir}/../../vendor/GnuMICR-0.30/GnuMICR.ttf"
require "#{dir}/attribute_formatting"
require "#{dir}/check"
