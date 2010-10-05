require 'test_helper'

class ApotomoTest < Test::Unit::TestCase
  context "The main module" do    
    should "save the JavascriptGenerator instance when setting js_framework" do
      Apotomo.js_framework = :jquery
      assert_respond_to Apotomo.js_generator, :jquery
    end
    
    should "have an accessor for js_framework" do
      Apotomo.js_framework = :jquery
      assert_equal :jquery, Apotomo.js_framework
    end
    
    should "have a setup method" do
      Apotomo.setup { |config| config.js_framework = :prototype }
      assert_respond_to Apotomo.js_generator, :prototype
    end
  end
end
