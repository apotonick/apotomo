require 'test_helper'

class RailsIntegrationTest < ActionController::TestCase
  def simulate_request!
    @controller.instance_eval { @apotomo_request_processor = nil }
    
    ### FIXME: @controller.session = Marshal.load(Marshal.dump(@controller.session))
  end
  
  include Apotomo::TestCaseMethods::TestController
  
  context "A Rails controller" do
    setup do
      @mum = MouseCell.new(parent_controller, 'mum', :snuggle)
      @mum.class.class_eval do
        responds_to_event :squeak, :with => :snuggle
        
        def snuggle; render; end
      end
      
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
    
    should "freeze the widget tree once after each request" do
      assert_equal 0, @controller.session.size
      
      get 'widget'
      assert_equal 1, @controller.session[:apotomo_stateful_branches].size
    end
    
    should "invoke a #use_widgets block only once per session" do
      #assert_equal 1, @controller.apotomo_root.size
      
      get 'widget'
      assert_response :success
      assert_equal 1, @controller.session[:apotomo_stateful_branches].size
      
      simulate_request!
      
      get 'widget'
      assert_equal 1, @controller.session[:apotomo_stateful_branches].size
      assert_response :success
      
      simulate_request!
      
      get 'widget'
      assert_response :success
      assert_equal 2, @controller.apotomo_root.size, "mum added multiple times"
    end
    
    should "provide the rails view helpers in state views" do
      @mum.instance_eval do
        def snuggle; render :view => :make_me_squeak; end
      end
      
      get 'widget'
      assert_select "a", "mum"
    end
    
    should "contain a freshly flushed tree when ?flush_widgets=1 is set" do
      get 'widget'
      assert_response :success
      assert @controller.apotomo_request_processor.widgets_flushed?
      
      simulate_request!
      
      get 'widget'
      assert_response :success
      assert_not @controller.apotomo_request_processor.widgets_flushed?
      
      simulate_request!
      
      get 'widget', :flush_widgets => 1
      assert_response :success  # will fail if no #use_widgets block invoked
      assert @controller.apotomo_request_processor.widgets_flushed?
    end
    
    should "render updates to the parent window for an iframe request" do
      get 'widget'
      assert_response :success
      
      simulate_request!
      
      get 'render_event_response', :source => 'mum', :type => :squeak, :apotomo_iframe => true
      
      assert_response :success
      assert_equal 'text/html', @response.content_type
      assert_equal "<html><body><script type='text/javascript' charset='utf-8'>\nvar loc = document.location;\nwith(window.parent) { setTimeout(function() { window.eval('<div id=\\\"mum\\\"><snuggle><\\/snuggle><\\/div>\\n'); window.loc && loc.replace('about:blank'); }, 1) }\n</script></body></html>", @response.body
    end
  end
end
