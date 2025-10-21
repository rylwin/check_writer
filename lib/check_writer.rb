# encoding: utf-8

# Set default encoding to UTF-8 for Ruby 3 compatibility with linguistics gem
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'prawn'
require 'prawn/table'
require 'active_support/all'

require 'linguistics'
Linguistics::use( :en )

dir = File.dirname(__FILE__) + '/check_writer'
MICR_FONT = "#{dir}/../../vendor/GnuMICR-0.30/GnuMICR.ttf"
require "#{dir}/attribute_formatting"
require "#{dir}/check"
