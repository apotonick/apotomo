require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
#class RailsIntegrationTest < ActionController::IntegrationTest
class RailsIntegrationTest < ActionController::TestCase
  context "A Rails controller" do
    setup do
      @controller = UrlMockController.new
      @controller.extend Apotomo::ControllerMethods
      @controller.session = {}
      
      @controller.instance_variable_set(:@mum, mouse_mock('mum', 'snuggle') {def snuggle; render; end})
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
      get 'widget'
      get 'widget'
      assert_equal 2, @controller.apotomo_root.size, "mum added multiple times"
    end
  end
end