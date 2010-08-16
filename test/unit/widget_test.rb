require File.join(File.dirname(__FILE__), '..', 'test_helper')

class WidgetTest < ActiveSupport::TestCase
  context "#has_widgets in class context" do
    setup do
      @mum = Class.new(MouseCell) do
        has_widgets do |me|
          me << widget('mouse_cell', 'baby', :squeak)
        end
      end.new('mum', :squeak)
      
      @kid = Class.new(@mum.class).new('mum', :squeak)
    end
    
    should "setup the widget family at creation time" do
      assert_equal 1, @mum.children.size
      assert_kind_of Apotomo::StatefulWidget, @mum['baby']
    end
    
    should "not inherit trees for now" do
      assert_equal [], @kid.children
    end
  end
end