require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ControllerMethodsTest < Test::Unit::TestCase
  context "A Rails controller" do
    setup do
      @controller = Class.new(ActionController::Base).new
      @controller.extend Apotomo::ControllerMethods
      @controller.session = {}
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
  
  context "responding to an event request and" do
    setup do
      @controller.instance_variable_set :@page, mock()
      @controller.instance_eval do
        def render(*args)
          @page.expects(:replace).with('mum', '<div id="mum">burp!</div>')
          @page.expects(:replace_html).with('kid', 'squeak!')
          @page.expects(:<<).with('squeak();')
          
          yield @page
        end
      end
    end
    
    context "invoking #render_page_updates" do
      should "render one replace, one replace_html and one JS injection" do
        @controller.send :render_page_updates, [
          Apotomo::PageUpdate.new(:replace => 'mum', :with => '<div id="mum">burp!</div>'),
          Apotomo::PageUpdate.new(:replace_html => 'kid', :with => 'squeak!'),
          ActiveSupport::JSON::Variable.new('squeak();')
        ]
      end
    end
    
    context "processing the request in #render_event_response" do
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
          def squeak; render :text => 'squeak!', :replace_html => :true; end
        end
      end
      
      should "render one replace, one replace_html and one JS injection" do
        @controller.params = {:source => :kid, :type => :doorSlam}
        @controller.apotomo_root << @mum
        @controller.render_event_response
      end
    end
    
    context "responding to #apotomo_address_for" do
      setup do
        @mum = mouse_mock
      end
      
      should "per default add the :render_event_response action to the url" do
        assert_equal({:action => :render_event_response, :type => :squeak, :source => 'mouse'}, @controller.apotomo_address_for(@mum, :type => :squeak))
      end
    end
  end
  
  context "The ProcHash" do
    setup do
      @procs = Apotomo::ControllerMethods::ProcHash.new
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