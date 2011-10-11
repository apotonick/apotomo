require 'test_helper'
 
class ControllerMethodsTest < ActionController::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "A Rails controller" do
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
      should "initially return the processor which has an empty root" do
        assert_kind_of Apotomo::RequestProcessor, @controller.apotomo_request_processor
        assert_equal 1, @controller.apotomo_request_processor.root.size
      end
    end
    
    context "invoking #has_widgets" do
      setup do
        @controller.class.has_widgets do |root|
          root << widget(:mouse, 'mum')
        end
      end
      
      should "add the widgets to apotomo_root" do
        assert_equal 'mum', @controller.apotomo_root['mum'].name
      end
      
      should "add the widgets only once in apotomo_root" do
        @controller.apotomo_root
        assert @controller.apotomo_root['mum']
      end
      
      should "allow multiple calls to has_widgets" do
        @controller.class.has_widgets do |root|
          root << widget(:mouse, 'kid')
        end
        
        assert @controller.apotomo_root['mum']
        assert @controller.apotomo_root['kid']
      end
      
      should "inherit has_widgets blocks to sub-controllers" do
        berry = widget(:mouse, 'berry')
        @sub_controller = Class.new(@controller.class) do
          has_widgets { |root| root << berry }
        end.new
        @sub_controller.params  = {}
        
        assert @sub_controller.apotomo_root['mum']
        assert @sub_controller.apotomo_root['berry']
      end
      
      should "be executed in controller context" do
        @controller.instance_eval do
          def roomies; ['mice', 'cows']; end
        end
        
        @controller.class.has_widgets do |root|
          root << widget(:mouse, 'kid', :display, :roomies => roomies)
        end
        
        assert_equal ['mice', 'cows'], @controller.apotomo_root['kid'].options[:roomies]
      end
    end
    
    
    
    context "invoking #url_for_event" do
      should "compute an url for any widget" do
        assert_equal "/barn/render_event_response?source=mouse&type=footsteps&volume=9", @controller.url_for_event(:footsteps, :source => :mouse, :volume => 9)
      end
    end
  end
  
  context "invoking #render_widget" do
    setup do
      @mum = mouse_mock('mum', 'eating')
    end
    
    should "render the widget" do
      @controller.apotomo_root << @mum
      assert_equal "<div id=\"mum\">burp!</div>\n", @controller.render_widget('mum', :eat)
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
  
  ### FIXME: could somebody get that working?
  context "Routing" do
    should_eventually "generate routes to the render_event_response action" do
      assert_generates "/barn/render_event_response?type=squeak", { :controller => "barn", :action => "render_event_response", :type => "squeak" }
      
      assert_recognizes({ :controller => "apotomo", :action => "render_event_response", :type => "squeak" }, "/apotomo/render_event_response?type=squeak")
    end
  end
  
end
