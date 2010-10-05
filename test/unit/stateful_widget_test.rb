require 'test_helper'

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
    
    should "respond to #version" do
      assert_equal 0, mouse_mock.version
    end
    
    should "have a version setter" do
      @mum = mouse_mock
      @mum.version = 1
      assert_equal 1, @mum.version
    end
  end
  
  context "mum having a family" do
    setup do
      mum_and_kid!
      @mum << @berry = mouse_mock('berry')
        @berry << @pet = mouse_mock('pet')
    end
    
    context "responding to #render_children" do
      should "return an OrderedHash for the rendered kids" do
        kids = @mum.render_children
        assert_kind_of ::ActiveSupport::OrderedHash, kids
        assert_equal 2, kids.size
      end
      
      should "return an OrderedHash even if there are no kids" do
        kids = @kid.render_children
        assert_kind_of ::ActiveSupport::OrderedHash, kids
        assert_equal 0, kids.size
      end
      
      should "return an empty OrderedHash when all kids are invisible" do
        @pet.visible = false
        kids = @berry.render_children
        assert_kind_of ::ActiveSupport::OrderedHash, kids
        assert_equal 0, kids.size
      end
    end
  end
end
