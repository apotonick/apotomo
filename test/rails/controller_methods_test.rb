require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ControllerMethodsTest < ActionController::TestCase
  context "A Rails controller" do
    setup do
      barn_controller!
    end
    
    context "responding to #apotomo_root" do
      should "initially return a root widget" do
        assert_equal 1, @controller.apotomo_root.size
      end
      
      should "allow tree modifications" do
        @controller.apotomo_root << mouse_mock
        assert_equal 2, @controller.apotomo_root.size
      end
    end
    
    context "responding to #apotomo_request_processor" do
      should "initially return the processor which has a flushed root" do
        assert_kind_of Apotomo::RequestProcessor, @controller.apotomo_request_processor
        assert_equal 1, @controller.apotomo_request_processor.root.size
      end
    end
    
    context "invoking #uses_widgets" do
      setup do
        @controller.class.uses_widgets do |root|
          root << mouse_mock('mum')
        end
      end
      
      should "add the widgets to apotomo_root" do
        assert_equal 'mum', @controller.apotomo_root['mum'].name
      end
      
      should "add the widgets only once in apotomo_root" do
        @controller.apotomo_root
        assert @controller.apotomo_root['mum']
      end
      
      should "allow multiple calls to uses_widgets" do
        @controller.class.uses_widgets do |root|
          root << mouse_mock('kid')
        end
        
        assert @controller.apotomo_root['mum']
        assert @controller.apotomo_root['kid']
      end
      
      should "inherit uses_widgets blocks to sub-controllers" do
        berry = mouse_mock('berry')
        @sub_controller = Class.new(@controller.class) do
          uses_widgets { |root| root << berry }
        end.new
        @sub_controller.params  = {}
        @sub_controller.session = {}
        
        assert @sub_controller.apotomo_root['mum']
        assert @sub_controller.apotomo_root['berry']
      end
      
      should "be aliased to has_widgets" do
        @controller.class.has_widgets do |root|
          root << mouse_mock('kid')
        end
        
        assert @controller.apotomo_root['mum']
        assert @controller.apotomo_root['kid']
      end
    end
    
    context "invoking #use_widgets" do
      should "have an empty apotomo_root if no call happened, yet" do
        assert_equal [],  @controller.bound_use_widgets_blocks
        assert_equal 1,   @controller.apotomo_root.size
      end
      
      should "extend the widget family and remember the block with one #use_widgets call" do
        @controller.use_widgets do |root|
          root << mouse_mock
        end
        
        assert_equal 1, @controller.bound_use_widgets_blocks.size
        assert_equal 2, @controller.apotomo_root.size
      end
      
      should "add blocks only once" do
        block = Proc.new {|root| root << mouse_mock}
        
        @controller.use_widgets &block
        @controller.use_widgets &block
        
        assert_equal 1, @controller.bound_use_widgets_blocks.size
        assert_equal 2, @controller.apotomo_root.size
      end
      
      should "allow multiple calls with different blocks" do
        mum_and_kid!
        @controller.use_widgets do |root|
          root << @mum
        end
        @controller.use_widgets do |root|
          root << mouse_mock('pet')
        end
        
        assert_equal 2, @controller.bound_use_widgets_blocks.size
        assert_equal 4, @controller.apotomo_root.size
      end
    end
    
    context "invoking #url_for_event" do
      should "compute an url for any widget" do
        assert_equal "/barn/render_event_response?source=mouse&type=footsteps&volume=9", @controller.url_for_event(:footsteps, :source => :mouse, :volume => 9)
      end
    end
    
    should "flush its bound_use_widgets_blocks with, guess, #flush_bound_use_widgets_blocks" do
      @controller.bound_use_widgets_blocks << Proc.new {}
      assert_equal 1, @controller.bound_use_widgets_blocks.size
      @controller.flush_bound_use_widgets_blocks
      assert_equal 0, @controller.bound_use_widgets_blocks.size
    end 
  end
  
  context "invoking #render_widget" do
    setup do
      @mum = mouse_mock('mum', 'snuggle') {def snuggle; render; end}
    end
    
    should "render the widget" do
      @controller.apotomo_root << @mum
      assert_equal '<div id="mum"><snuggle></snuggle></div>', @controller.render_widget('mum')
    end
  end
  
  
  
  context "invoking #apotomo_freeze" do
    should "freeze the widget tree to session" do
      assert_equal 0, @controller.session.size
      @controller.send :apotomo_freeze
      assert @controller.session[:apotomo_widget_ivars]
      assert @controller.session[:apotomo_stateful_branches]
    end
  end
    
  context "processing an event request" do
    setup do
      @mum = mouse_mock('mum', :eating)
      @mum << @kid = mouse_mock('kid', :squeak)
      
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
    
    ### DISCUSS: needed?
    context "in event mode" do
      should_eventually "set the MIME type to text/javascript" do
        @controller.apotomo_root << @mum
        
        get :render_event_response, :source => :kid, :type => :doorSlam
        
        assert_equal Mime::JS, @response.content_type
        assert_equal "$(\"mum\").replace(\"<div id=\\\"mum\\\">burp!<\\/div>\")\n$(\"kid\").update(\"squeak!\")\nsqueak();", @response.body
      end
    end
  end
  
  context "The ProcHash" do
    setup do
      @procs = Apotomo::Rails::ControllerMethods::ProcHash.new
      @b = Proc.new{}; @d = Proc.new{}
      @c = Proc.new{}
      @procs << @b
    end
    
    should "return true for procs it includes" do
      assert @procs.include?(@b)
      assert @procs.include?(@d)  ### DISCUSS: line nr is id, or do YOU got a better idea?!
    end
    
    should "reject unknown procs" do
      assert ! @procs.include?(@c)
    end
  end
  
  ### FIXME: could somebody get that working?
  context "Routing" do
    should_eventually "generate routes to the render_event_response action" do
      assert_generates "/barn/render_event_response?type=squeak", { :controller => "barn", :action => "render_event_response", :type => "squeak" }
      
      assert_recognizes({ :controller => "apotomo", :action => "render_event_response", :type => "squeak" }, "/apotomo/render_event_response?type=squeak")
    end
  end
  
end