require 'test_helper'

class ApotomoTest < MiniTest::Spec
  describe "::Apotomo" do
    describe "when setting #js_framework" do
      before do
        Apotomo.js_framework = :jquery
      end

      describe "#js_framework" do
        it "return value has been set" do
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
      it "yield block on ::Apotomo module" do
        Apotomo.setup do |config|
          config.js_framework = :jquery
        end
        #TODO: replace with ::Apotomo.expect :js_generator, :jquery, [:jquery]
        assert_respond_to Apotomo.js_generator, :jquery
      end
    end
  end
end
