module CheckWriter

  class Check

    attr_accessor :number, :date,
      :payee_name, :payor_name,
      :payee_address, :payor_address, 
      :bank_name, :bank_address, :bank_fraction,
      :routing_number, :account_number, 
      :amount, :memo

    def initialize(attributes={})
      _assign_attributes(attributes)
    end

    def date
      @date||Date.today
    end

    # Returns an integer representing the number of cents of the amount
    #
    # amount = 3.23 => 23
    def cents
      ((amount.to_f - dollars) * 100).to_i
    end

    # Returns an integer representing the number of dollars of the amount
    #
    # amount = 3.23 => 3
    def dollars
      amount.to_i
    end

    def formatted_amount
      separated_dollars = dollars.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      "$#{separated_dollars}.#{cents}"
    end

    def amount_in_words
      # Wrap cents in string before calling numwords to avoid 
      # SafeBuffer cannot modify string in place error
      cents = "#{self.cents}".en.numwords

      "#{dollars.en.numwords} Dollars and #{cents} Cents".titleize
    end

    def to_pdf
      @pdf = Prawn::Document.new(:bottom_margin => 0.0)
      _generate_check_pdf
      @pdf.render
    end

    private

    def _assign_attributes(attr)
      attr.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    def _generate_check_pdf
      @pdf.move_down(between_box_height/4.0)
      #check_stub(true)
      #check_stub(false)

      @pdf.bounding_box [@pdf.bounds.left,@pdf.bounds.top - extra_top_margin_height - box_height*2 - between_box_height*2], 
        :width => @pdf.bounds.right - @pdf.bounds.left, :height => check_box_height do

        @pdf.bounding_box [@pdf.bounds.left + inches(5.5), @pdf.bounds.top - inches(0.25)], :width => inches(2) do
          check_number
        end

        bank
        payor
        #property_name
        date_and_amount_and_memo
        _payee_address
        signature
        micr
        end

      # calling stroke here seems to flush the writer. When we don't call stroke, some lines aren't output
      @pdf.stroke
    end

    def inches(inches)
      inches * 72.0
    end

    def center_of_box
      center_y = (@pdf.bounds.top - @pdf.bounds.bottom)/2.0
      return [@pdf.bounds.left, center_y + 2], [@pdf.bounds.right, center_y + 2]
    end

    def info_box(title, value, width, offset = 0)
      @pdf.bounding_box [@pdf.bounds.left + 8 + offset, @pdf.bounds.top - 2], :width => width - 8 do
        @pdf.text title, :align => :center 
        @pdf.move_down 4
        @pdf.text "#{value}"  
        @pdf.line center_of_box
      end  
    end

    def box_info_row
      info_box("Property Name", @check.property.name, inches(3.25))
      info_box("Apt #", @check.unit.unit_number, inches(0.75), inches(3.25))
      info_box("Description", "Deposit Refund", inches(1.5), inches(4.0))
      info_box("Move-Out", @check.lease.move_out_date.to_s(:mdy), inches(1), inches(5.5)) if @check.lease.move_out_date
      info_box("Amount", c(@check.amount), inches(1), inches(6.5))
    end

    def box_info_block
      @pdf.bounding_box [@pdf.bounds.left + 8, @pdf.bounds.top - inches(0.55)], :width => inches(7) do
        @pdf.text "Movein Date: #{@check.lease.move_in_date.to_time.to_s(:mdy)}" if @check.lease.move_in_date
        @pdf.text "Moveout Notice: #{@check.lease.move_out_notice_date.to_time.to_s(:mdy)}" if @check.lease.move_out_notice_date
        @pdf.text "Lease Exp. Date: #{@check.lease.expiration_date.to_time.to_s(:mdy)}" if @check.lease.expiration_date
        @pdf.text "Term: #{@check.lease.term}" 
        @pdf.text "Moveout Date: #{@check.lease.move_out_date.to_time.to_s(:mdy)}" if @check.lease.move_out_date
        @pdf.text "Moveout Reason: #{@check.lease.move_out_reason}" if @check.lease.move_out_reason
        @pdf.text "Processed By: #{@check.refund.employee}" if @check.refund.employee
        @pdf.text("STOP PAYMENT ON CHECK NO. #{@check.original_check.check_number}", :align => :center) if @check.original_check.present?
      end
    end

    def box_bottom_row
      @pdf.move_to [@pdf.bounds.left, inches(0.5)]
      @pdf.line_to [@pdf.bounds.right, inches(0.5)]
      @pdf.bounding_box [@pdf.bounds.left + 8, inches(0.5) - 6], :width => inches(6.75) do
        @pdf.text "Payor: #{@check.property}"
        @pdf.text "Payee: #{@check.lease.signers.join(", ")}"
      end
      @pdf.move_to [@pdf.bounds.right - inches(1), inches(0.5)]
      @pdf.line_to [@pdf.bounds.right - inches(1), 0]
      @pdf.bounding_box [@pdf.bounds.left + inches(6.5), inches(0.5) - 6], :width => inches(1), :height => inches(0.5) do
        @pdf.text "Date", :align => :center
        @pdf.text "#{@check.date.to_time.to_s(:mdy) if @check.date}", :align => :center
      end
    end

    def bank
      @pdf.bounding_box [@pdf.bounds.left + inches(4), @pdf.bounds.top - inches(0.25)], :width => inches(2) do
        @pdf.font_size(10) do
          @pdf.text   bank_name
          pdf_address bank_address
          @pdf.text   bank_fraction
        end
      end
    end

    def pdf_address(address)
      address.each do |line|
        @pdf.text line
      end
    end

    def payor
      @pdf.bounding_box [@pdf.bounds.left + inches(0.5), @pdf.bounds.top - inches(0.25)], :width => inches(3.5) do
        @pdf.text payor_name, :font_size => 14
        @pdf.font_size(10) do
          pdf_address(payor_address)
        end
      end
    end

    def property_name
      @pdf.bounding_box [@pdf.bounds.left + inches(0.5), @pdf.bounds.top - inches(0.85)], :width => inches(3.5) do
        @pdf.text @check.property.name, :font_size => 14
      end
    end

    def date_and_amount_and_memo
      @pdf.bounding_box [@pdf.bounds.left + inches(4.5), @pdf.bounds.top - inches(1.25)], :width => inches(1) do
        @pdf.text date.strftime('%B %e, %Y')
      end
      @pdf.bounding_box [@pdf.bounds.right - inches(1) - 4, @pdf.bounds.top - inches(1.25)], :width => inches(1) do
        @pdf.text formatted_amount, :align => :right    
      end
      @pdf.text_box "#{amount_in_words}#{" -"*72}", :at => [@pdf.bounds.left + 4, @pdf.bounds.top - inches(1.5)], :height => inches(0.2)
      @pdf.bounding_box [@pdf.bounds.right - inches(3.5), @pdf.bounds.top - inches(1.75)], :width => inches(3.5) do
        @pdf.font_size(8) do
          pdf_address([*memo])
        end
      end
    end

    def _payee_address
      @pdf.bounding_box [@pdf.bounds.left + 4, @pdf.bounds.top - inches(1.75)], :width => inches(3.5) do
        @pdf.text "TO THE ORDER OF:", :size => 8
        @pdf.bounding_box [@pdf.bounds.left + inches(0.25), @pdf.bounds.top - inches(0.3)], :width => inches(3.25) do
          @pdf.text payee_name
          pdf_address(payee_address)
        end
      end
    end

    def signature
      @pdf.bounding_box [@pdf.bounds.right - inches(2.5), @pdf.bounds.bottom + inches(0.7)], :width => inches(2.5) do
        @pdf.horizontal_rule
        @pdf.move_down 2
        # TODO: better currency formatting
        @pdf.text "NOT VALID IF OVER $#{amount}", :size => 8, :align => :center
      end
    end

    def check_number(vert_adjust=false)
      @pdf.move_down(between_box_height/2.0) if vert_adjust
      @pdf.text "Check No. #{number}", :height => 12, :align => :right
    end

    def check_stub(top_stub=true)
      check_number(!top_stub)
      top = top_stub ? @pdf.bounds.top - extra_top_margin_height : @pdf.bounds.top - extra_top_margin_height - box_height - between_box_height
      @pdf.bounding_box [@pdf.bounds.left, top], :width => @pdf.bounds.right - @pdf.bounds.left, :height => box_height do
        @pdf.stroke_bounds
        box_info_row
        box_info_block if top_stub
        box_bottom_row
      end
    end

    def micr
      @pdf.bounding_box [@pdf.bounds.left + inches(0.9), @pdf.bounds.bottom + 22], :width => inches(4.5) do
        @pdf.font MICR_FONT do
          @pdf.text "C#{number}C A#{routing_number}A #{account_number}C"
        end
      end 
    end

    def box_height
      180 # 2.5in
    end

    def between_box_height 
      54 # 3/4in
    end

    def extra_top_margin_height 
      36 # 1/2in
    end

    def check_box_height 
      252 #3.5in
    end
  end

end
