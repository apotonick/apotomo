require 'test_helper'
require 'generators/apotomo/widget_generator'

class WidgetGeneratorTest < Rails::Generators::TestCase
  destination File.join(Rails.root, "tmp")
  setup :prepare_destination
  tests ::Apotomo::Generators::WidgetGenerator

  context "Running rails g apotomo::widget" do
    context "Gerbil squeak snuggle" do
      should "create the standard assets" do

        run_generator %w(Gerbil squeak snuggle -t test_unit)

        assert_file "app/widgets/gerbil/gerbil_widget.rb", /class GerbilWidget < Apotomo::Widget/
        assert_file "app/widgets/gerbil/gerbil_widget.rb", /def snuggle/
        assert_file "app/widgets/gerbil/gerbil_widget.rb", /def squeak/
        
        assert_file "app/widgets/gerbil/views/snuggle.html.erb", %r(app/widgets/gerbil/views/snuggle\.html\.erb)
        assert_file "app/widgets/gerbil/views/snuggle.html.erb", %r(<p>)
        assert_file "app/widgets/gerbil/views/squeak.html.erb", %r(app/widgets/gerbil/views/squeak\.html\.erb)

        assert_file "test/widgets/gerbil/gerbil_widget_test.rb", %r(class GerbilWidgetTest < Apotomo::TestCase)
        assert_file "test/widgets/gerbil/gerbil_widget_test.rb", %r(widget\(:gerbil\))
      end

      should "create javascript and css assets" do
        run_generator %w(Gerbil squeak snuggle -t test_unit)

        assert_file "app/assets/javascripts/widgets/gerbil_widget.coffee", /Define your coffeescript code for the Gerbil widget*/
        assert_file "app/assets/stylesheets/widgets/gerbil_widget.css", /Define your css code for the Gerbil widget*/
      end

      should "create haml assets with -e haml" do
        run_generator %w(Gerbil squeak snuggle -e haml -t test_unit)

        assert_file "app/widgets/gerbil/gerbil_widget.rb", /class GerbilWidget < Apotomo::Widget/
        assert_file "app/widgets/gerbil/gerbil_widget.rb", /def snuggle/
        assert_file "app/widgets/gerbil/gerbil_widget.rb", /def squeak/
        
        assert_file "app/widgets/gerbil/views/snuggle.html.haml", %r(app/widgets/gerbil/views/snuggle\.html\.haml)
        assert_file "app/widgets/gerbil/views/snuggle.html.haml", %r(%p)
        assert_file "app/widgets/gerbil/views/squeak.html.haml", %r(app/widgets/gerbil/views/squeak\.html\.haml)
        
        assert_file "test/widgets/gerbil/gerbil_widget_test.rb"
      end

      should "create slim assets with -e slim" do
        run_generator %w(Gerbil squeak snuggle -e slim -t test_unit)

        assert_file "app/widgets/gerbil/gerbil_widget.rb", /class GerbilWidget < Apotomo::Widget/
        assert_file "app/widgets/gerbil/gerbil_widget.rb", /def snuggle/
        assert_file "app/widgets/gerbil/gerbil_widget.rb", /def squeak/
        
        assert_file "app/widgets/gerbil/views/snuggle.html.slim", %r(app/widgets/gerbil/views/snuggle\.html\.slim)
        assert_file "app/widgets/gerbil/views/snuggle.html.slim", %r(p)
        assert_file "app/widgets/gerbil/views/squeak.html.slim", %r(app/widgets/gerbil/views/squeak\.html\.slim)
        
        assert_file "test/widgets/gerbil/gerbil_widget_test.rb"
      end

      should "work with namespaces" do
        run_generator %w(Gerbil::Mouse squeak -t test_unit)

        assert_file "app/widgets/gerbil/mouse/mouse_widget.rb", /class Gerbil::MouseWidget < Apotomo::Widget/
        assert_file "app/widgets/gerbil/mouse/mouse_widget.rb", /def squeak/
        
        assert_file "app/widgets/gerbil/mouse/views/squeak.html.erb", %r(app/widgets/gerbil/mouse/views/squeak\.html\.erb)
        
        assert_file "test/widgets/gerbil/mouse/mouse_widget_test.rb"
      end

    end
  end
end