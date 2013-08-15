require 'test_helper'

class ApotomoTest < MiniTest::Spec
  describe "The main module ::Apotomo" do
    describe "when setting #js_framework" do
      before do
        Apotomo.js_framework = :jquery
      end

      describe "#js_framework" do
        it "return javascript framework name" do
          assert_equal :jquery, Apotomo.js_framework
        end
      end

      describe "#js_generator" do
        it "return an JavascriptGenerator instance" do
          assert_kind_of Apotomo::JavascriptGenerator, Apotomo.js_generator
        end

        it "include correct javascript framework module" do
          assert_respond_to Apotomo.js_generator, :jquery
        end
      end
    end

    describe "#setup" do
      it "yield block on main module" do
        Apotomo.setup { |config| config.js_framework = :jquery }
        assert_respond_to Apotomo.js_generator, :jquery
      end
    end
  end
end
