require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
#class RailsIntegrationTest < ActionController::IntegrationTest
class RailsIntegrationTest < ActionController::TestCase
  def simulate_request!
    @controller.instance_eval { @apotomo_request_processor = nil }
  end
  
  context "A Rails controller" do
    setup do
      @controller = ApotomoController.new
      @controller.extend Apotomo::Rails::ControllerMethods
      @controller.session = {}
      @controller.params  = {}
      
      #@mum = mouse_mock('mum', 'snuggle') { def snuggle; render; end }
      @mum = MouseCell.new('mum', :snuggle)
      @mum.instance_eval{ def snuggle; render; end }
      
      @controller.instance_variable_set(:@mum, @mum)
      @controller.instance_eval do
        def widget
          use_widgets do |root|
            root << @mum
          end
          render :text => render_widget('mum')
        end
      end
    end
    
    should "freeze the widget tree after each request" do
      assert_equal 0, @controller.session.size
      
      get 'widget'
      
      assert @controller.session[:apotomo_root]
    end
    
    should "invoke a #use_widgets block only once per session" do
      assert_equal 1, @controller.apotomo_root.size
      get 'widget'
      simulate_request!
      get 'widget'
      simulate_request!
      get 'widget'
      assert_equal 2, @controller.apotomo_root.size, "mum added multiple times"
    end
    
    should "provide the rails view helpers in state views" do
      @mum.instance_eval do
        def snuggle; render :view => :make_me_squeak; end
      end
      
      get 'widget'
      assert_select "a", "Squeak!"
    end
    
    should "contain a freshly flushed tree when ?flush_tree=1 is set" do
      get 'widget'
      assert @controller.apotomo_request_processor.widgets_flushed?
      
      simulate_request!
      get 'widget'
      assert_not @controller.apotomo_request_processor.widgets_flushed?
      
      simulate_request!
      get 'widget', :flush_widgets => 1
      assert_response :success  # will fail if no #use_widgets block invoked
      assert @controller.apotomo_request_processor.widgets_flushed?
    end
    
    should "render updates to the parent window for an iframe request" do
      get 'widget'
      assert_response :success
      @controller.apotomo_root['mum'].respond_to_event :squeak, :with => :snuggle
      
      get 'render_event_response', :source => 'mum', :type => :squeak, :apotomo_iframe => true
      
      assert_response :success
      assert_equal 'text/html', @response.content_type
      assert_equal "<html><body><script type='text/javascript' charset='utf-8'>\nvar loc = document.location;\nwith(window.parent) { setTimeout(function() { window.eval('$(\\\"mum\\\").replace(\\\"<div id=\\\\\\\"mum\\\\\\\"><snuggle><\\\\/snuggle><\\\\/div>\\\")'); window.loc && loc.replace('about:blank'); }, 1) }\n</script></body></html>", @response.body
    end
  end
end