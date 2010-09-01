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
  
  context "A stateless widget" do
    setup do
      @mum = Apotomo::Widget.new('mum', :squeak)
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
      
      should "respond to #find_widget" do
        mum_and_kid!
        assert_not @mum.find_widget('pet')
        assert @kid, @mum.find_widget('kid')
      end
      
      should "respond to the WidgetShortcuts methods, like #widget" do
        assert_respond_to @mum, :widget
      end
      
      context "with initialize_hooks" do
        should "expose its class_inheritable_array with #initialize_hooks" do
          @mum = mouse_class_mock.new('mum', :eating)
          @mum.class.instance_eval { self.initialize_hooks << :initialize_mouse }
          assert ::Apotomo::StatefulWidget.initialize_hooks.size + 1 == @mum.class.initialize_hooks.size
        end
        
        should "execute the initialize_hooks in the correct order in #process_initialize_hooks" do
          @mum = mouse_class_mock.new('mum', :eating)
          @mum.class.instance_eval do
            define_method(:executed) { |*args| @executed ||= [] }
            define_method(:setup) { |*args| executed << :setup }
            define_method(:configure) { |*args| executed << :configure }
            initialize_hooks << :setup
            initialize_hooks << :configure
          end
          
          assert_equal [:setup, :configure], @mum.class.new('zombie', nil).executed
        end
        
        should "provide after_initialize" do
          @mum = mouse_class_mock.new('mum', :eat)
          @mum.class.instance_eval do
            after_initialize :first
            after_initialize :second
          end
          
          assert_equal @mum.class.initialize_hooks[-1], :second
          assert_equal @mum.class.initialize_hooks[-2], :first
        end
      end
    end
end