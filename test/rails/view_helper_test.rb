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
      
      @cell = mouse_mock('mum')
    end
    
    should "respond to #link_to_event" do
      assert_dom_equal "<a href=\"#\" onclick=\"new Ajax.Request('/barn/render_event_response?source=mum&amp;type=footsteps', {asynchronous:true, evalScripts:true}); return false;\">Walk!</a>",
      link_to_event("Walk!", :footsteps)
    end
    
    should "respond to #form_to_event" do
      assert_dom_equal "<form onsubmit=\"new Ajax.Request('/barn/render_event_response?source=mum&amp;type=footsteps', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this)}); return false;\" method=\"post\" action=\"/barn/render_event_response?source=mum&amp;type=footsteps\">",
      form_to_event(:footsteps)
    end
    
    should "respond to #trigger_event" do
      assert_dom_equal "new Ajax.Request('/barn/render_event_response?source=mum&type=footsteps', {asynchronous:true, evalScripts:true})",
      trigger_event(:footsteps)
    end
    
    should "respond to #url_for_event" do
      assert_equal({:type=>:footsteps, :source=>"mum", :action=>:render_event_response}, url_for_event(:footsteps))
    end
  end
end