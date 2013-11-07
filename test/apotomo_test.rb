require 'test_helper'

class ApotomoTest < MiniTest::Spec
  describe "The main module ::Apotomo" do
    describe "when setting #js_framework" do
      before do
        Apotomo.js_framework = :jquery
      end

      it "respond to #js_framework and return javascript framework's name" do
        assert_equal :jquery, Apotomo.js_framework
      end

      it "respond to #js_generator and return an correct instance" do
        assert_kind_of Apotomo::JavascriptGenerator, Apotomo.js_generator
        assert_kind_of Apotomo::JavascriptGenerator::Jquery, Apotomo.js_generator
      end
    end

    it "respond to #setup" do
      Apotomo.setup { |config| config.js_framework = :jquery }
      # TODO: Apotomo expect #js_framework
      assert_respond_to Apotomo.js_generator, :jquery
    end
  end
end
