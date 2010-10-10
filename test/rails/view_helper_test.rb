require 'test_helper'
require 'action_view/test_case'

class ViewHelperTest < ActionView::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  tests Apotomo::Rails::ViewHelper
  
  context "A widget state view" do
    setup do
      @cell = mouse_mock('mum')
      @parent_controller = @controller
    end
    
    teardown do
      Apotomo.js_framework = :prototype
    end
    
    
    should "respond to #multipart_form_to_event" do
      assert_dom_equal "<iframe id=\"apotomo_iframe\" name=\"apotomo_iframe\" style=\"display: none;\"></iframe><form accept-charset=\"UTF-8\" action=\"/barn/render_event_response?apotomo_iframe=true&amp;source=mum&amp;type=footsteps\" enctype=\"multipart/form-data\" method=\"post\" target=\"apotomo_iframe\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div></form>",
      multipart_form_to_event(:footsteps)
    end
    
    should "render multipart form if :multipart => true" do
      assert_dom_equal "<iframe id=\"apotomo_iframe\" name=\"apotomo_iframe\" style=\"display: none;\"></iframe><form accept-charset=\"UTF-8\" action=\"/barn/render_event_response?apotomo_iframe=true&amp;source=mum&amp;type=footsteps\" enctype=\"multipart/form-data\" method=\"post\" target=\"apotomo_iframe\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div></form>",
      form_to_event(:footsteps, :multipart => true)
    end
    
    should "respond to #trigger_event" do
      assert_dom_equal "new Ajax.Request(\"/barn/render_event_response?source=mum&type=footsteps\")",
      trigger_event(:footsteps)
    end
    
    should "render RightJS if set" do
      Apotomo.js_framework = :right
      
      assert_dom_equal "new Xhr(\"/barn/render_event_response?source=mum&type=footsteps\", {evalScripts:true}).send()", trigger_event(:footsteps)
    end
    
    should "respond to #url_for_event" do
      assert_equal("/barn/render_event_response?source=mum&type=footsteps", url_for_event(:footsteps))
    end
    
    should "respond to #widget_div" do
      assert_equal '<div id="mum">squeak!</div>', widget_div { "squeak!" }
    end
    
    should "respond to #widget_div with options" do
      assert_equal '<div class="mouse" id="kid">squeak!</div>', widget_div(:id => 'kid', :class => "mouse") { "squeak!" }
    end
    
    should "respond to #widget_id" do
      assert_equal 'mum', widget_id
    end
    
    context "#widget_javascript" do
      
      should "usually render a javascript block" do
        assert_equal "<script type=\"text/javascript\">\n//<![CDATA[\nalert(\"Beer!\")\n//]]>\n</script>", widget_javascript { 'alert("Beer!")' }
      end
      
      should "be quiet if suppress_js is set" do
        @suppress_js = true ### TODO: use a local, not an instance variable.
        assert_equal nil, widget_javascript { 'alert("Beer!")' }
      end
      
      should_eventually "capture" do
      puts "capturing"
        v = ActionView::Base.new
        c = v.capture do "capture me!" end
        puts c.inspect
      end
    end
  end
  
  context "A widget including ViewHelper" do
    setup do
      barn_controller!
      @mum = mouse_mock
      @mum.parent_controller = @controller
      @mum.class_eval do
        include Apotomo::Rails::ViewHelper
      end
    end
    
    should "respond to url_for_event" do
      @mum.url_for_event(:bla)
    end
  end
end
