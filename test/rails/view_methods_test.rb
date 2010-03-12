require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ViewMethodsTest < ActionController::TestCase
  context "A Rails controller view invoking #render_widget" do
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
          render :inline => "<%= render_widget 'mum' %>"
        end
      end
    end
    
    should "render the passed widget" do
      get :widget
      assert_select "#mum>snuggle"
    end
  end
end