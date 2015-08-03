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
      :payee_name => 'John Smith with a Really Really, Really Really Long Name',
      :payee_address => payee_address,
      :payor_name => 'Payor Company Name',
      :payor_address => payor_address,
      :bank_name => 'Bank of America',
      :bank_address => bank_address,
      :bank_fraction => '12-9876/1234',
      :routing_number => '123456768',
      :account_number => '123456789',
      :amount => '1000003.23',
      :memo => 'Memo: Void after 60 days'
    )
  end

  it "knows how many dollars and cents" do
    @check.dollars.should == 1_000_003
    @check.cents.should == 23
  end

  it "can format the amount as currency" do
    @check.formatted_amount.should == "$1,000,003.23"
  end

  context "a check for an amount with 0 cents" do
    before(:each) do
      @check.amount = 410.0
    end
    it "should includes two zeros in the cents" do
      @check.formatted_amount.should == "$410.00"
    end
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

  context "void" do
    before(:each) do
      @check.void = true
      @data = @check.to_pdf
    end

    it "generates a pdf with VOID on the check stub" do
      # Use this line to re-write the PDF we test against
      # write_content_to_file('void', @data)

      assert_data_matches_file_content('void', @data)
    end
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

    context "blank" do
      before(:each) do
        @check.blank = true
        @data = @check.to_pdf
      end

      it "generates a pdf with VOID on the check stub" do
        # Use this line to re-write the PDF we test against
        # write_content_to_file('blank', @data)

        assert_data_matches_file_content('blank', @data)
      end
    end
  end

  it "raises exception when stub_format invalid" do
    expect { @check.stub_format = :wrong }.to raise_error
    expect { @check.stub_format = :two_thirds }.to_not raise_error
  end

  context "with two-thirds stub" do
    before(:each) do
      @check.stub_format = :two_thirds
      @check.with_stubs = true
      @data = @check.to_pdf
    end

    it "generates a pdf with check stubs stroked and some basic info" do
      # Use this line to re-write the PDF we test against
      # write_content_to_file('with_two_thirds_stub', @data)

      assert_data_matches_file_content('with_two_thirds_stub', @data)
    end
  end

  context "with stub table data" do
    before(:each) do
      @stub_table_data = [
        ['Name', 'Acct No', 'Invoice', 'Date', 'Notes', 'Amount'], # header
        ['Box Company LLC', '89982376', '1978612', '1/1/2000', 'For boxes delivered', '$1,000.00'],
        ['Box Company LLC', '89982376', '1978612', '1/1/2000', 'For boxes delivered', '$1,000.00']
      ]
      @check.stub_table_data = @stub_table_data
      @check.stub_table_options = {:row_colors => ['ff0000', 'ffffff']}
      @check.stub_table_lambda = lambda { |t|
        t.cells.column(5).align = :right
      }
      @check.with_stubs = true
      @data = @check.to_pdf
    end

    it "generates a pdf with stub table data" do
      # Use this line to re-write the PDF we test against
      # write_content_to_file('with_stub_table_data', @data)

      assert_data_matches_file_content('with_stub_table_data', @data)
    end
  end

  context "with second signature line" do
    before(:each) do
      @check.second_signature_line = true
      @data = @check.to_pdf
    end
    it "generates a pdf with a second signature line" do
      # Use this line to re-write the PDF we test against
      # write_content_to_file('with_second_signature_line', @data)

      assert_data_matches_file_content('with_second_signature_line', @data)
    end
  end

  context "with signature image" do
    before(:each) do
      @check.signature_image_file = TEST_ASSETS + "/sample-signature.png"
      @data = @check.to_pdf
    end

    it "generates a pdf with the signature image on the signature line" do
      # Use this line to re-write the PDF we test against
      # write_content_to_file('with_signature_image', @data)

      assert_data_matches_file_content('with_signature_image', @data)
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
