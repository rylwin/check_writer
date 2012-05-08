$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'check_writer'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

TEST_ASSETS = File.expand_path("assets", File.dirname(__FILE__)).to_s

# Helper to provide asset path given the "base name" of the file.
# For example, if +file+ is "default_render", asset_path returns
# "/path/to/prawnto/spec/assets/default_render-#{prawn version}.pdf"
def asset_path(file)
  prawn_version = Gem.loaded_specs["prawn"].version.to_s.inspect
  TEST_ASSETS + "/#{file}-#{prawn_version.gsub('"','')}.pdf"
end

def assert_data_matches_file_content(file, data)
  data.bytes.to_a.should == File.open(asset_path(file)).read.bytes.to_a
end

def write_content_to_file(file, content)
  f = File.new(asset_path(file), 'w')
  f.write content
  f.close
  true
end
