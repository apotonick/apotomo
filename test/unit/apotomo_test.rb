require File.dirname(__FILE__) + '/../test_helper'

class ApotomoTest < Test::Unit::TestCase
  context "The main module" do
    teardown do
      Apotomo.js_framework = nil
    end
    
    should "not have a default js_framework" do
      assert_nil Apotomo.js_framework
    end
    
    should "have accessors for js_framework" do
      Apotomo.js_framework = :right
      assert_equal :right, Apotomo.js_framework
    end
    
    should "have a setup method" do
      Apotomo.setup { |config| config.js_framework = :prototype }
      assert_equal :prototype, Apotomo.js_framework
    end
  end
end