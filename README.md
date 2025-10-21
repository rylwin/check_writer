# check_writer

[![Build Status](https://semaphoreci.com/api/v1/projects/b3c72c98-d73f-47f4-9fce-6ef029975969/573898/badge.svg)](https://semaphoreci.com/rylwin/check_writer)

A ruby gem to help generate checks in PDF format.

It generates PDF checks that look something
[like this](https://github.com/rylwin/check_writer/raw/master/spec/assets/test-0.12.0.pdf).
Print that PDF on check stock using magnetic ink and you've got yourself a real check.

Note: This project is being written/maintained using Ruby 1.9.3.
Other versions of Ruby have not been tested.

## Project Status

A version of this code has been used in a production application for a couple of years
and we are finally getting around to extracting the check writing code. As we go through this
process, there may be significant changes to the API. You've been warned.

Currently the only check stock format that is supported is the 1/3 bottom check.
You can get some check stock at
[Amazon](http://www.amazon.com/gp/product/B002HIV1KQ/ref=as_li_qf_sp_asn_il_tl?ie=UTF8&tag=checkwriter-20&linkCode=as2&camp=1789&creative=9325&creativeASIN=B002HIV1KQ),
amongst other places.

## GnuMICR

check_writer uses GnuMICR (http://www.sandeen.net/GnuMICR) to print the MICR numbers at the
bottom of the check. Please read the notes on the GnuMICR site. We have not
had any issues using this font (2+ years now), but that is no guarantee.

## Example

```ruby
@check = CheckWriter::Check.new(
  :number => '12345',                               # the check number
  :date => Date.yesterday,                          # Default: today

  :payee_name => 'John Smith',
  :payee_address => ['Line 1', 'City, State, Zip'], # Array of as many lines as desired

  :payor_name => 'Payor Name',
  :payor_address => ['Line 1', 'City, State, Zip'],

  :bank_name => 'Bank of America',
  :bank_address => ['Line 1', 'City, State, Zip'],
  :bank_fraction => '12-9876/1234',

  :routing_number => '1234567689',
  :account_number => '123456789',

  :amount => '1003.23',
  :memo => 'Memo: Void after 60 days'
)

check.to_pdf # returns PDF file data
```

If you set the `with_stubs` option to `true` you'll get a bit of formatting
and information displayed in the top and middle check stub.
[Here's an example](https://github.com/rylwin/check_writer/raw/master/spec/assets/with_stubs-0.12.0.pdf).

It is also possible to include additional data in the stubs in the form of a table. If `with_stubs` is true,
then passing a 2D array to `stub_table_data` will generate a table within each stub. To pass options to Prawn's
`#table` method, set `stub_table_options` with a hash of options. You can also use `stub_table_lambda` to provide a block that is sent to the `#table` method.
[Example here](https://github.com/rylwin/check_writer/raw/master/spec/assets/with_stub_table_data-0.12.0.pdf).

Instead of just returning a PDF, you can access the Prawn PDF writer object
(Prawn::Document), which you can use to further customize the check or even
include multiple checks on the same PDF:

```ruby
pdf = check1.to_prawn
pdf.start_new_page # this is a prawn method
pdf = check2.to_prawn(pdf)
pdf.render # returns the PDF data for a PDF w/ two checks on two pages
```

## Signatures

Signatures can be included on the checks by setting the `:signature_image_file` option, which should
reference a JPG or PNG image. The recommended dimensions for a signature image are 175px x 40px.

If you need a second signature line on the check, `:second_signature_line` to true.

## Void and Blank Checks

There are times where you may want to print a check that is clearly marked as a
void check. Setting `void` to a truish value will place "void" in place of the
amount, check number, and the signature line.

If you want the PDF to include everything except the lower one-third of the
page (the actual check part), set `blank` to a truish value.

## Contributing to check_writer

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Font: The GnuMICR font is distributed under GPL, but please note the additional comments from
the font creator in the
[GnuMICR README](https://github.com/rylwin/check_writer/tree/master/vendor/GnuMICR-0.30).

Copyright (c) 2012 Ryan Winograd. See LICENSE.txt for
further details.
