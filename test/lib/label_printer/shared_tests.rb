module LabelPrinterTests
  module SharedTubeTests
    def self.included(base)
      base.class_eval do
        test 'should return the correct values' do
          assert_equal (barcode1).to_s, tube_label.middle_line(tube1)
          assert_equal prefix, tube_label.round_label_top_line(tube1)
          assert_equal barcode1, tube_label.round_label_bottom_line(tube1)
          assert_match barcode1, tube_label.barcode(tube1)
        end

        test 'should return the correct label' do
          assert_equal label, tube_label.create_label(tube1)
          assert_equal ({ main_label: label }), tube_label.label(tube1)
        end
      end
    end
  end

  module SharedPlateTests
    def self.included(base)
      base.class_eval do
        test 'should return correct common values' do
          assert_match barcode1, plate_label.bottom_left(plate1)
          assert_match barcode1, plate_label.barcode(plate1)
        end

        test 'should return the correct label' do
          assert_equal label, plate_label.create_label(plate1)
          assert_equal ({ main_label: label }), plate_label.label(plate1)
        end
      end
    end
  end
end
