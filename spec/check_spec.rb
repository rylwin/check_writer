require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "CheckWriter::Check" do

  before(:each) do
    payee_address = [
       '123 Payee St',
       'Payeesville, TX 77000'
    ]
    payor_address = [
       '123 Payor St',
       'Payorsville, TX 77000'
    ]
    bank_address = [
       '123 Bank St',
       'Banksville, TX 77000'
    ]

    @check = CheckWriter::Check.new(
      :date => Date.parse('5/7/2012'),
      :number => '12345',
      :payee_name => 'John Smith',
      :payee_address => payee_address,
      :payor_name => 'Payor Company Name',
      :payor_address => payor_address,
      :bank_name => 'Bank of America',
      :bank_address => bank_address,
      :bank_fraction => '12-9876/1234',
      :routing_number => '1234567689',
      :account_number => '123456789',
      :amount => '1003.23',
      :memo => 'Memo: Void after 60 days'
    )
  end

  it "knows how many dollars and cents" do
    @check.dollars.should == 1003
    @check.cents.should == 23
  end

  it "can format the amount as currency" do
    @check.formatted_amount.should == "$1,003.23"
  end

  it "assigns the number" do
    @check.number.should == '12345'
  end

  it "generates pdf correctly" do
    data = @check.to_pdf
    
    # Use this line to re-write the PDF we test against
    # write_content_to_file('test', data)

    assert_data_matches_file_content('test', data)
  end

  context "with stubs" do
    before(:each) do
      @check.with_stubs = true
      @data = @check.to_pdf
    end

    it "generates a pdf with check stubs stroked and some basic info" do
      # Use this line to re-write the PDF we test against
      # write_content_to_file('with_stubs', @data)

      assert_data_matches_file_content('with_stubs', @data)
    end
  end

  context "#to_prawn" do
    it "returns a prawn object" do
      @check.to_prawn.should be_a_kind_of(Prawn::Document)
    end

    it "can be used to print multiple checks" do
      pdf = @check.to_prawn
      pdf.start_new_page
      pdf = @check.to_prawn(pdf)
      @data = pdf.render

      # Use this line to re-write the PDF we test against
      # write_content_to_file('two_in_one', @data)

      assert_data_matches_file_content('two_in_one', @data)
    end
  end

end
