require 'test_helper'

class RequestProcessorTest < ActiveSupport::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  def root_mum_and_kid!
    
        mum_and_kid!
        
        @root = Apotomo::Widget.new(parent_controller, 'root', :display)
        @root << @mum
        
        
        @session = {}
        #freeze!
  end
  
  # Call SW.freeze_for on @session, "freezing" stateful widgets below @root there.
  def freeze!
    Apotomo::StatefulWidget.freeze_for(@session, @root)
  end
  
  
  context "#root" do
    should "allow external modification of the tree" do
      @processor = Apotomo::RequestProcessor.new(parent_controller, {})
      root = @processor.root
      root << mouse_mock
      assert_equal 2, @processor.root.size
    end
  end
  
  context "#attach_stateless_blocks_for" do
    setup do
      @processor  = Apotomo::RequestProcessor.new(parent_controller, {})
      @root       = @processor.root
      assert_equal @root.size, 1
    end
    
    should "allow has_widgets blocks with root parameter, only" do
      @processor.send(:attach_stateless_blocks_for, [Proc.new{ |root|
        root.add widget('mouse_cell', 'mouse') 
      }], @root, parent_controller)
      
      assert_equal 'mouse', @processor.root['mouse'].name
    end
    
    should "allow has_widgets blocks with both root and controller parameter" do
      @processor.send(:attach_stateless_blocks_for, [Proc.new{ |root,controller| 
        root.add widget('mouse_cell', 'mouse') 
      }], @root, parent_controller)
      assert_equal 'mouse', @processor.root['mouse'].name
    end
  end
    
  context "option processing at construction time" do
    context "with empty session and options" do
      setup do
        @processor = Apotomo::RequestProcessor.new(parent_controller, {})
      end
      
      should "mark the tree as flushed" do
        assert @processor.widgets_flushed?
      end
      
      should "provide a single root-node for #root" do
        assert_equal 1, @processor.root.size
      end
      
      should "initialize version to 0" do
        assert_equal 0, @processor.root.version
      end
    end
    
    context "with controller" do
      should "attach the passed parent_controller to root" do
        assert_equal parent_controller, Apotomo::RequestProcessor.new(parent_controller, {}, {}, []).root.parent_controller
      end
    end
    
    context "with session" do
      setup do
        root_mum_and_kid!
        @mum.version = 1
        freeze!
        
        @processor = Apotomo::RequestProcessor.new(parent_controller, @session)
      end
      
      should "provide a widget family for #root" do
        assert_equal 3, @processor.root.size
        assert_equal 1, @processor.root['mum'].version
        assert_not @processor.widgets_flushed?
      end
      
      context "having a flush flag set" do
        setup do
          @processor = Apotomo::RequestProcessor.new(parent_controller, @session, :flush_widgets => true)
        end
        
        should "provide a single root for #root when :flush_widgets is set" do
          assert_equal 1, @processor.root.size
          assert @processor.widgets_flushed?
        end
        
        should "wipe-out our session variables" do
          assert_nil @session[:apotomo_stateful_branches]
          assert_nil @session[:apotomo_widget_ivars]
        end
        
      end
      
      context "and with stateless widgets" do
        setup do
          root_mum_and_kid!
          freeze!
          @processor = Apotomo::RequestProcessor.new(parent_controller, @session, {}, [Proc.new { |root| root << Apotomo::Widget.new(parent_controller, 'grandma', :eating) }])
        end
        
        should "first attach passed stateless, then stateful widgets to root" do
          assert_equal 4, @processor.root.size
        end
      end
    end
    
  end
  
  context "#process_for" do
    setup do
      class KidCell < Apotomo::Widget
        responds_to_event :doorSlam, :with => :flight
        responds_to_event :doorSlam, :with => :squeak
        def flight; render :text => "away from here!"; end
        def squeak; render :text => "squeak!"; end
      end
  
      procs = [Proc.new{ |root,controller| 
        root << mum = MouseCell.new(parent_controller, 'mum', :squeak) << KidCell.new(parent_controller, 'kid', :squeak)
      }]
    
      @processor = Apotomo::RequestProcessor.new(parent_controller, {}, {:js_framework => :prototype}, procs)
    end
    
    should "return an empty array if nothing was triggered" do
      assert_equal [], @processor.process_for({:type => :mouseClick, :source => 'kid'})
    end
    
    should "return 2 page updates when @kid squeaks" do
      assert_equal ["away from here!", "squeak!"], @processor.process_for({:type => :doorSlam, :source => 'kid'})
    end
    
    should "raise an exception when :source is unknown" do
      assert_raises RuntimeError do
        @processor.process_for({:type => :squeak, :source => 'tom'})
      end
    end
  end
  
  
  
  context "#freeze!" do
    should "serialize stateful branches to @session" do
      @processor = Apotomo::RequestProcessor.new(parent_controller, {})
      @processor.root << mum_and_kid!
      assert_equal 3, @processor.root.size
      @processor.freeze!
      
      @processor = Apotomo::RequestProcessor.new(parent_controller, @processor.session)
      assert_equal 3, @processor.root.size
    end
  end
  
  context "#render_widget_for" do
    setup do
      class MouseCell < Apotomo::Widget
        def squeak; render :text => "squeak!"; end
      end
      
      @processor = Apotomo::RequestProcessor.new(parent_controller, {}, {}, 
        [Proc.new { |root| root << MouseCell.new(parent_controller, 'mum', :squeak) }])
    end
    
    should "render the widget when passing an existing widget id" do
      assert_equal 'squeak!', @processor.render_widget_for('mum', {})
    end
    
    should "render the widget when passing an existing widget instance" do
      assert_equal 'squeak!', @processor.render_widget_for(@processor.root['mum'], {})
    end
    
    should "raise an exception when a non-existent widget id id passed" do
      assert_raises RuntimeError do
        @processor.render_widget_for('mummy', {})
      end
    end
  end
  
  context "invoking #address_for" do
    setup do
      @processor = Apotomo::RequestProcessor.new(parent_controller, {})
    end
    
    should "accept an event :type" do
      assert_equal({:type => :squeak, :source => 'mum'}, @processor.address_for(:type => :squeak, :source => 'mum'))
    end
    
    should "accept arbitrary options" do
      assert_equal({:type => :squeak, :volume => 'loud', :source => 'mum'}, @processor.address_for(:type => :squeak, :volume => 'loud', :source => 'mum'))
    end
    
    should "complain if no type given" do
      assert_raises RuntimeError do
        @processor.address_for(:source => 'mum')
      end
    end
    
    should "complain if no source given" do
      assert_raises RuntimeError do
        @processor.address_for(:type => :footsteps)
      end
    end
  end
end
