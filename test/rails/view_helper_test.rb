require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class ViewHelperTest < ActionView::TestCase
  tests Apotomo::Rails::ViewHelper
  
  context "A widget state view" do
    setup do
      @controller = Class.new(ActionController::Base) do
        def self.default_url_options; {:controller => :barn}; end
      end.new
      @controller.extend Apotomo::Rails::ControllerMethods
      @controller.extend ActionController::UrlWriter
      @controller.params  = {}
      @controller.session = {}
      
      @cell = mouse_mock('mum')
    end
    
    teardown do
      Apotomo.js_framework = nil
    end
    
    should "respond to #link_to_event" do
      assert_dom_equal "<a href=\"#\" onclick=\"new Ajax.Request('/barn/render_event_response?source=mum&amp;type=footsteps', {asynchronous:true, evalScripts:true}); return false;\">Walk!</a>",
      link_to_event("Walk!", :footsteps)
    end
    
    should "respond to #form_to_event" do
      assert_dom_equal "<form onsubmit=\"new Ajax.Request('/barn/render_event_response?source=mum&amp;type=footsteps', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;\" method=\"post\" action=\"/barn/render_event_response?source=mum&amp;type=footsteps\">",
      form_to_event(:footsteps)
    end
    
    should "respond to #multipart_form_to_event" do
      assert_dom_equal "<iframe name=\"apotomo_iframe\" id=\"apotomo_iframe\" style=\"display: none;\"></iframe><form enctype=\"multipart/form-data\" method=\"post\" action=\"/barn/render_event_response?apotomo_iframe=true&amp;source=mum&amp;type=footsteps\" target=\"apotomo_iframe\">",
      multipart_form_to_event(:footsteps)
    end
    
    should "render multipart form if :multipart => true" do
      assert_dom_equal "<iframe name=\"apotomo_iframe\" id=\"apotomo_iframe\" style=\"display: none;\"></iframe><form enctype=\"multipart/form-data\" method=\"post\" action=\"/barn/render_event_response?apotomo_iframe=true&amp;source=mum&amp;type=footsteps\" target=\"apotomo_iframe\">",
      form_to_event(:footsteps, :multipart => true)
    end
    
    should "respond to #trigger_event" do
      assert_dom_equal "new Ajax.Request(\"/barn/render_event_response?source=mum&amp;type=footsteps\")",
      trigger_event(:footsteps)
    end
    
    should "render RightJS if set" do
      Apotomo.js_framework = :right
      
      assert_dom_equal "new Xhr(\"/barn/render_event_response?source=mum&amp;type=footsteps\", {evalScripts:true}).send()", trigger_event(:footsteps)
    end
    
    should "respond to #url_for_event" do
      assert_equal("/barn/render_event_response?source=mum&amp;type=footsteps", url_for_event(:footsteps))
    end
  end
end