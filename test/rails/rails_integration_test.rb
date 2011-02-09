require 'test_helper'

class RailsIntegrationTest < ActionController::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  def simulate_request!
    @controller.instance_eval { @apotomo_request_processor = nil }
  end
  
  context "A Rails controller" do
    setup do
      @mum = mum = MouseWidget.new(parent_controller, 'mum', :snuggle)
      
      @mum.respond_to_event :squeak, :with => :snuggle
      @mum.instance_eval do
        def snuggle; render; end
      end
      
      @controller.class.has_widgets do |root|
        root << mum
      end
      
      @controller.instance_eval do
        def widget
          render :text => render_widget('mum')
        end
      end
    end
    
    should "provide the rails view helpers in state views" do
      @mum.instance_eval do
        def snuggle; render :view => :make_me_squeak; end
      end
      
      get 'widget'
      assert_select "a", "mum"
    end
    
    should "pass the event with all params data as state-args" do
      @mum.instance_eval do
        def snuggle(evt); render :text => evt.data; end
      end
      
      get 'render_event_response', :source => 'mum', :type => :squeak, :pitch => :high
      assert_equal "{\"source\"=>\"mum\", \"type\"=>:squeak, \"pitch\"=>:high, \"controller\"=>\"barn\", \"action\"=>\"render_event_response\"}", @response.body
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
