require 'test_helper'

class ApotomoTest < MiniTest::Spec
  describe "The main module ::Apotomo" do
    describe "when setting #js_framework" do
      before do
        Apotomo.js_framework = :jquery
      end

      it "respond to #js_framework" do
        assert_equal :jquery, Apotomo.js_framework
      end

      it "respond to #js_generator" do
        assert_kind_of Apotomo::JavascriptGenerator, Apotomo.js_generator
      end

      it "include correct javascript framework module" do
        assert_respond_to Apotomo.js_generator, :jquery
      end
    end

    it "respond to #setup" do
      Apotomo.setup { |config| config.js_framework = :jquery }
      assert_respond_to Apotomo.js_generator, :jquery
    end
  end
end

