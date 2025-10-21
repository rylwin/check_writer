$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'check_writer'
require 'mini_magick'
require 'chunky_png'
require 'tempfile'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|

end

TEST_ASSETS = File.expand_path("assets", File.dirname(__FILE__)).to_s

# Helper to provide asset path given the "base name" of the file.
# For example, if +file+ is "default_render", asset_path returns
# "/path/to/prawnto/spec/assets/default_render-#{prawn version}.png"
def asset_path(file, extension = 'png')
  prawn_version = Gem.loaded_specs["prawn"].version.to_s.inspect
  TEST_ASSETS + "/#{file}-#{prawn_version.gsub('"','')}.#{extension}"
end

# Convert PDF data to PNG image using ImageMagick
def pdf_to_png(pdf_data)
  Tempfile.create(['check', '.pdf']) do |pdf_file|
    pdf_file.binmode
    pdf_file.write(pdf_data)
    pdf_file.close

    Tempfile.create(['check', '.png']) do |png_file|
      # Convert PDF to PNG using ImageMagick with high quality settings
      # Use -append to combine multi-page PDFs into a single vertical image
      system("convert -density 300 -quality 100 #{pdf_file.path} -append #{png_file.path}")

      ChunkyPNG::Image.from_file(png_file.path)
    end
  end
end

# Compare two ChunkyPNG images pixel by pixel
def images_match?(image1, image2, tolerance = 0)
  return false unless image1.width == image2.width && image1.height == image2.height

  differences = 0
  image1.height.times do |y|
    image1.width.times do |x|
      pixel1 = image1[x, y]
      pixel2 = image2[x, y]
      differences += 1 if pixel1 != pixel2
    end
  end

  # Allow for a small tolerance in case of minor rendering differences
  total_pixels = image1.width * image1.height
  difference_percentage = (differences.to_f / total_pixels) * 100

  difference_percentage <= tolerance
end

# Assert that PDF data matches the reference image file
def assert_data_matches_file_content(file, data)
  reference_path = asset_path(file, 'png')

  # Convert the generated PDF to PNG
  generated_image = pdf_to_png(data)

  # Load the reference PNG
  reference_image = ChunkyPNG::Image.from_file(reference_path)

  # Compare with a small tolerance (0.1%) for minor rendering differences
  images_match?(generated_image, reference_image, 0.1).should == true
end

# Write PNG reference image from PDF content
def write_content_to_file(file, content)
  puts "*" * 80
  puts "WARNING: Writing asset file"
  puts "*" * 80

  # Generate PNG from PDF
  png_image = pdf_to_png(content)
  png_path = asset_path(file, 'png')

  png_image.save(png_path)
  puts "Saved reference image to: #{png_path}"
  true
end
