require 'test_helper'

class ViewMethodsTest < ActionController::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "A Rails controller view" do
    setup do
      @mum = mum = mouse_mock('mum', 'snuggle') {def snuggle; render; end}
      @controller.class.has_widgets do |root|
        root << mum
      end
      
      @controller.class_eval do
        def widget
          render :inline => "<%= render_widget 'mum' %>"
        end
      end
    end
    
    should "respond to render_widget" do
      get :widget
      assert_select "#mum>snuggle"
    end
    
    should "respond to url_for_event" do
      @controller.class_eval do
        def widget
          render :inline => "<%= url_for_event :footsteps, :source => 'mum' %>"
        end
      end
      
      get :widget
      assert_equal "/barn/render_event_response?source=mum&amp;type=footsteps", @response.body
    end
  end
end
