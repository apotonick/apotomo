require 'test_helper'
require 'action_view/test_case'

class ViewHelperTest < Apotomo::TestCase
  include Apotomo::TestCaseMethods::TestController
  include ActionDispatch::Assertions::DomAssertions

  # TODO: use Cell::TestCase#in_view here.
  def in_view(subject, &block)
    subject = subject.new(@controller, :mum) unless subject.kind_of?(Apotomo::Widget)
    setup_test_states_in(subject)
    subject.invoke(:in_view, block)
  end

  # describe "Rails::ViewHelper" do
    ### DISCUSS: needed?
    ### FIXME: could somebody get that working?
    test "respond to #multipart_form_to_event" do
      skip

      assert_dom_equal( "<iframe id=\"apotomo_iframe\" name=\"apotomo_iframe\" style=\"display: none;\"></iframe><form accept-charset=\"UTF-8\" action=\"/barn/render_event_response?apotomo_iframe=true&amp;source=mum&amp;type=footsteps\" enctype=\"multipart/form-data\" method=\"post\" target=\"apotomo_iframe\"><div style=\"margin:0;padding:0;display:inline\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div></form>",
      in_view(MouseWidget) do
        multipart_form_to_event(:footsteps)
      end)
    end

    test "respond to #url_for_event" do
      assert_equal "/barn/render_event_response?source=mum&amp;type=footsteps", in_view(MouseWidget) { url_for_event(:footsteps) }
    end

    test "respond to #url_for_event with a namespaced controller" do
      @controller = namespaced_controller
      assert_equal "/farm/barn/render_event_response?source=mum&amp;type=footsteps", in_view(MouseWidget) { url_for_event(:footsteps) }
    end

    test "respond to #widget_tag" do
      assert_equal('<span id="mum">squeak!</span>', in_view(MouseWidget) do
        widget_tag(:span) do
          "squeak!"
        end
      end)
    end

    test "respond to #widget_tag with options" do
      assert_equal('<span class="mouse" id="kid">squeak!</span>', in_view(MouseWidget) do
        widget_tag(:span, :id => 'kid', :class => "mouse") do
          "squeak!"
        end
      end)
    end

    test "respond to #widget_div" do
      assert_equal('<div id="mum">squeak!</div>', in_view(MouseWidget) do widget_div { "squeak!" } end)
    end

    test "respond to #widget_id" do
      assert_equal 'mum', in_view(MouseWidget) { widget_id }
    end

    test "respond to #render_widget" do
      mum = mouse
      MouseWidget.new(mum, :kid)

      assert_equal("<div id=\"kid\">burp!</div>\n", in_view(mum) do
        render_widget('kid', :eat)
      end)
    end

    test "respond to #children" do
      mum = mouse
      MouseWidget.new(mum, :kid)

      assert_equal("<div id=\"kid\">burp!</div>\n", in_view(mum) do
        children.collect do |child|
          render_widget(child, :eat)
        end.join.html_safe
      end)
    end

    # TODO: test #js_generator

    # TODO: test instance variables access

  # end
end
