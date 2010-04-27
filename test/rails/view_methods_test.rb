require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ViewMethodsTest < ActionController::TestCase
  context "A Rails controller view" do
    setup do
      @controller = ApotomoController.new
      @controller.extend Apotomo::ControllerMethods
      @controller.session = {}
      
      @controller.instance_variable_set(:@mum, mouse_mock('mum', 'snuggle') {def snuggle; render; end})
      @controller.instance_eval do
        def widget
          use_widgets do |root|
            root << @mum
          end
          render :inline => "<%= render_widget 'mum' %>"
        end
      end
    end
    
    should "respond to render_widget" do
      get :widget
      assert_select "#mum>snuggle"
    end
    
    should "respond to url_for_event" do
      @controller.instance_eval do
        def widget
          use_widgets do |root|
            root << @mum
          end
          render :inline => "<%= url_for_event :footsteps, :source => 'mum' %>"
        end
      end
      
      get :widget
      assert_equal "/apotomo/render_event_response?source=mum&type=footsteps", @response.body
    end
  end
end