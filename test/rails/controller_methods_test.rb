require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ControllerMethodsTest < ActionController::TestCase
  context "A Rails controller" do
    setup do
      @controller = Class.new(ActionController::Base) do
        def self.default_url_options; {:controller => :barn}; end
      end.new
      @controller.extend ActionController::UrlWriter
      @controller.extend Apotomo::Rails::ControllerMethods
      @controller.session = {}
      @controller.params  = {}
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
      assert @controller.session[:apotomo_root]
      assert @controller.session[:apotomo_widget_ivars]
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
    
    context "in event mode" do
      should "set the MIME type to text/javascript" do
        @controller.apotomo_root << @mum
        
        get :render_event_response, :source => :kid, :type => :doorSlam
        
        assert_equal Mime::JS, @response.content_type
        assert_equal "$(\"mum\").replace(\"<div id=\\\"mum\\\">burp!<\\/div>\")\n$(\"kid\").update(\"squeak!\")\nsqueak();", @response.body
      end
    end
    
    
    context "for a data push event and" do
      setup do
        @controller.instance_eval do
          def render(options); options; end
        end
      end
      
      context "invoking render_raw" do
        should "pass-through the content to render :text" do
          assert_equal({:text => "squeak\n"}, @controller.send(:render_raw, [Apotomo::Content::Raw.new("squeak\n")]))
        end
      end
      
      context "processing it in #render_event_response" do
        setup do
          @mum = mouse_mock('mum') do
            def squeak; render :raw => "squeak\n"; end
          end
          
          @mum.respond_to_event :dataLoad, :with => :squeak
        end
        
        should "render :text" do
          @controller.params = {:source => :mum, :type => :dataLoad}
          @controller.apotomo_root << @mum
          assert_equal({:text => "squeak\n"}, @controller.render_event_response)
        end
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
end