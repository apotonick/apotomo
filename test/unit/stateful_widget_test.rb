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
    
    should "respond to #version" do
      assert_equal 0, mouse_mock.version
    end
    
    should "have a version setter" do
      @mum = mouse_mock
      @mum.version = 1
      assert_equal 1, @mum.version
    end
    
    context "responding to #address_for_event" do
      should "accept an event :type" do
        assert_equal({:type => :squeak, :source => 'mum'}, @mum.address_for_event(:type => :squeak))
      end
      
      should "accept a :source" do
        assert_equal({:type => :squeak, :source => 'kid'}, @mum.address_for_event(:type => :squeak, :source => 'kid'))
      end
      
      should "accept arbitrary options" do
        assert_equal({:type => :squeak, :volume => 'loud', :source => 'mum'}, @mum.address_for_event(:type => :squeak, :volume => 'loud'))
      end
      
      should "complain if no type given" do
        assert_raises RuntimeError do
          @mum.address_for_event(:source => 'mum')
        end
      end
    end
    
    context "implementing visibility" do
      should "per default respond to #visible?" do
        assert @mum.visible?
      end
      
      should "expose a setter therefore" do
        @mum.visible = false
        assert_not @mum.visible?
      end
      
      context "in a widget family" do
        setup do
          @mum << @jerry = mouse_mock('jerry')
          @mum << @berry = mouse_mock('berry')
        end
        
        should "per default return all #visible_children" do
          assert_equal [@jerry, @berry], @mum.visible_children
          assert_equal [], @jerry.visible_children
        end
        
        should "hide berry in #visible_children if he's invisible" do
          @berry.visible = false
          assert_equal [@jerry], @mum.visible_children
        end
      end
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