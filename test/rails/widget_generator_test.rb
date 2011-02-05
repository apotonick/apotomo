require 'test_helper'
require 'generators/apotomo/widget_generator'

class WidgetGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests ::Apotomo::Generators::WidgetGenerator
   
  context "Running rails g apotomo::widget" do
    context "Mouse squeak snuggle" do
      should "create the standard assets" do
        
        run_generator %w(MouseWidget squeak snuggle -t test_unit)
        
        assert_file "app/cells/mouse_widget.rb", /class MouseWidget < Apotomo::Widget/
        assert_file "app/cells/mouse_widget.rb", /def snuggle/
        assert_file "app/cells/mouse_widget.rb", /def squeak/
        assert_file "app/cells/mouse_widget/snuggle.html.erb", %r(app/cells/mouse_widget/snuggle\.html\.erb)
        assert_file "app/cells/mouse_widget/snuggle.html.erb", %r(<p>)
        assert_file "app/cells/mouse_widget/squeak.html.erb", %r(app/cells/mouse_widget/squeak\.html\.erb)

        assert_file "test/widgets/mouse_widget_test.rb", %r(class MouseWidgetTest < Apotomo::TestCase)
        assert_file "test/widgets/mouse_widget_test.rb", %r(widget\(:mouse_widget, 'me'\))
      end
      
      should "create haml assets with -e haml" do
        run_generator %w(MouseWidget squeak snuggle -e haml -t test_unit)
        
        assert_file "app/cells/mouse_widget.rb", /class MouseWidget < Apotomo::Widget/
        assert_file "app/cells/mouse_widget.rb", /def snuggle/
        assert_file "app/cells/mouse_widget.rb", /def squeak/
        assert_file "app/cells/mouse_widget/snuggle.html.haml", %r(app/cells/mouse_widget/snuggle\.html\.haml)
        assert_file "app/cells/mouse_widget/snuggle.html.haml", %r(%p)
        assert_file "app/cells/mouse_widget/squeak.html.haml", %r(app/cells/mouse_widget/squeak\.html\.haml)
        assert_file "test/widgets/mouse_widget_test.rb"
      end
    end
  end
end
