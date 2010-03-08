require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class StatefulWidgetTest < Test::Unit::TestCase
  context "The StatefulWidget" do
    setup do
      @mum = Apotomo::StatefulWidget.new('mum', :squeak)
    end
    
    should "accept an id as first option" do
      assert_equal 'mum', @mum.name
    end
    
    should "accept a start state as second option" do
      assert_equal :squeak, @mum.instance_variable_get('@start_state')
    end
  end
end