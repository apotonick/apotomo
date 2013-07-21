require 'test_helper'

class ApotomoTest < MiniTest::Spec
  describe "The main module" do
    it "save the JavascriptGenerator instance when setting js_framework" do
      Apotomo.js_framework = :jquery
      assert_respond_to Apotomo.js_generator, :jquery
    end

    it "have an accessor for js_framework" do
      Apotomo.js_framework = :jquery
      assert_equal :jquery, Apotomo.js_framework
    end

    it "have a setup method" do
      Apotomo.setup { |config| config.js_framework = :prototype }
      assert_respond_to Apotomo.js_generator, :prototype
    end
  end
end
