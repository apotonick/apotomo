require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RequestProcessorTest < Test::Unit::TestCase
  context "#root" do
    should "allow external modification of the tree" do
      @processor = Apotomo::RequestProcessor.new({})
      root = @processor.root
      root << mouse_mock
      assert_equal 2, @processor.root.size
    end
  end
    
  context "option processing at construction time" do
    context "with empty session and options" do
      setup do
        @processor = Apotomo::RequestProcessor.new({})
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
    
    context "with session" do
      setup do
        mum_and_kid!
        @mum.version = 1
        @session = {:apotomo_stateful_branches => [[@mum, 'root']]}
        @processor = Apotomo::RequestProcessor.new(@session)
      end
      
      should "provide a widget family for #root" do
        assert_equal 3, @processor.root.size
        assert_equal 1, @processor.root['mum'].version
        assert_not @processor.widgets_flushed?
      end
      
      context "having a flush flag set" do
        setup do
          @processor = Apotomo::RequestProcessor.new(@session, :flush_widgets => true)
        end
        
        should "provide a single root for #root when :flush_widgets is set" do
          assert_equal 1, @processor.root.size
          assert @processor.widgets_flushed?
        end
        
        should "wipe-out our session variables" do
          assert_nil @session[:apotomo_stateful_branches]
          assert_nil @session[:apotomo_widget_ivars]
        end
        
        should ""
      end
      
      context "and with stateless widgets" do
        setup do
          @session = {:apotomo_stateful_branches => [[@mum, 'grandma']]}
          @processor = Apotomo::RequestProcessor.new(@session, {}, [Proc.new { |root| root << Apotomo::Widget.new('grandma', :eating) }])
        end
        
        should "first attach passed stateless, then stateful widgets to root" do
          assert_equal 4, @processor.root.size
        end
      end
    end
    
    context "js_generator" do
      #should "set a default javascript framework" do
      #  @processor = Apotomo::RequestProcessor.new({})
      #  assert_respond_to @processor.javascript_generator, :prototype
      #end
      
      should "return the passed framework" do
        @processor = Apotomo::RequestProcessor.new({}, :js_framework => :right)
        assert_respond_to @processor.js_generator, :right
      end
    end
  end
  
  context "#process_for" do
    setup do
      ### FIXME: what about that automatic @controller everywhere?
      mum_and_kid!
      @mum.controller = nil # check if controller gets connected.
      @processor = Apotomo::RequestProcessor.new({:apotomo_stateful_branches => [[@mum, 'root']]}, :js_framework => :prototype)
      
      
      
      
      
      @kid.respond_to_event :doorSlam, :with => :eating, :on => 'mum'
          @kid.respond_to_event :doorSlam, :with => :squeak
          @mum.respond_to_event :doorSlam, :with => :squeak
          
          @mum.instance_eval do
            def squeak; render :js => 'squeak();'; end
          end
          @kid.instance_eval do
            def squeak; render :text => 'squeak!', :update => :true; end
          end
    end
      
    should "return 2 page_updates when @kid squeaks" do
      res = @processor.process_for({:type => :squeak, :source => 'kid'}, @controller)
      
      assert_equal ["alert!", "squeak"], res
    end
    
    should "raise an exception when :source is unknown" do
      assert_raises RuntimeError do
        @processor.process_for({:type => :squeak, :source => 'tom'}, @controller)
      end
    end
  end
  
  
  
  context "#freeze!" do
    should "serialize stateful branches to @session" do
      @processor = Apotomo::RequestProcessor.new({})
      @processor.root << mum_and_kid!
      assert_equal 3, @processor.root.size
      @processor.freeze!
      
      @processor = Apotomo::RequestProcessor.new(@processor.session)
      assert_equal 3, @processor.root.size
    end
  end
  
  context "#render_widget_for" do
    setup do
      @mum = mouse_mock('mum', :snuggle) do
        def snuggle; render; end
      end
      @mum.controller = nil
      
      @processor = Apotomo::RequestProcessor.new({:apotomo_stateful_branches => [[@mum, 'root']]})
    end
    
    should "render the widget when passing an existing widget id" do
      assert_equal '<div id="mum"><snuggle></snuggle></div>', @processor.render_widget_for('mum', {}, @controller)
    end
    
    should "render the widget when passing an existing widget instance" do
      assert_equal '<div id="mum"><snuggle></snuggle></div>', @processor.render_widget_for(@mum, {}, @controller)
    end
    
    should "raise an exception when a non-existent widget id id passed" do
      assert_raises RuntimeError do
        @processor.render_widget_for('mummy', {}, @controller)
      end
    end
  end
  
  context "invoking #address_for" do
    setup do
      @processor = Apotomo::RequestProcessor.new({})
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