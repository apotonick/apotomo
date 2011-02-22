require 'test_helper'
require 'action_view/test_case'

class ViewHelperTest < Apotomo::TestCase
  include ActionDispatch::Assertions::DomAssertions
  include Apotomo::TestCase::TestController
  
  # TODO: use Cell::TestCase#in_view here.
  def in_view(subject, &block)
    if subject.kind_of?(Apotomo::Widget)
      subject.options[:block] = block
    else
      subject = subject.new(@controller, 'mum', :display, :block => block)
    end
     
    setup_test_states_in(subject) unless subject.respond_to?(:in_view)# add #in_view state to subject cell.
    
    subject.class.action_methods << "in_view"
    
    subject.invoke(:in_view)
  end
  def mouse_mock(id='mum', start_state=:eat, opts={}, &block)
    mouse = MouseWidget.new(parent_controller, id, start_state, opts)
    mouse.instance_eval &block if block_given?
    mouse
  end
  
  
  context "A widget state view" do
    teardown do
      Apotomo.js_framework = :prototype
    end
    
    should_eventually "respond to #multipart_form_to_event" do
      assert_dom_equal( "<iframe id=\"apotomo_iframe\" name=\"apotomo_iframe\" style=\"display: none;\"></iframe><form accept-charset=\"UTF-8\" action=\"/barn/render_event_response?apotomo_iframe=true&amp;source=mum&amp;type=footsteps\" enctype=\"multipart/form-data\" method=\"post\" target=\"apotomo_iframe\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div></form>",
      in_view(MouseWidget) do
        multipart_form_to_event(:footsteps)
      end)
    end
    
    should "respond to #url_for_event" do
      assert_equal("/barn/render_event_response?source=mum&amp;type=footsteps", in_view(MouseWidget) do 
        url_for_event(:footsteps)
      end)
    end
    
    should "respond to #url_for_event with a namespaced controller" do
      @controller = namespaced_controller
      assert_equal("/farm/barn/render_event_response?source=mum&amp;type=footsteps", in_view(MouseWidget) do 
        url_for_event(:footsteps)
      end)
    end
    
    should "respond to #widget_div" do
      assert_equal('<div id="mum">squeak!</div>', in_view(MouseWidget) do widget_div { "squeak!" } end)
    end
    
    should "respond to #widget_div with options" do
      assert_equal('<div class="mouse" id="kid">squeak!</div>', in_view(MouseWidget) do
        widget_div(:id => 'kid', :class => "mouse") { "squeak!" }
      end)
    end
    
    should "respond to #widget_id" do
      assert_equal('mum', in_view(MouseWidget){ widget_id })
    end
    
    should "respond to #render_widget" do
      mum = mouse_mock << mouse_mock('kid')
      assert_equal("<div id=\"kid\">burp!</div>\n", in_view(mum){ render_widget 'kid', :eat })
    end
    
    context "#widget_javascript" do
      
      should "usually render a javascript block" do
        assert_equal("<script type=\"text/javascript\">\n//<![CDATA[\nalert(&quot;Beer!&quot;)\n//]]>\n</script>", in_view(MouseWidget) do
          widget_javascript { 'alert("Beer!")' }
        end)
      end
      
      # FIXME: get the test running?
      should_eventually "be quiet if suppress_js is set" do
        @suppress_js = true ### TODO: use a local, not an instance variable.
        mum = mouse_mock do
          def in_view
            render :suppress_js => true
          end
        end

        assert_equal(nil, in_view(mum) do
          widget_javascript { 'alert("Beer!")' }
        end)
      end
    end
  end
end
