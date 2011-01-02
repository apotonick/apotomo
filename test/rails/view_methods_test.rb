require 'test_helper'
Debugger.start

class ViewMethodsTest < ActionController::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "A Rails controller view" do
    setup do
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
      assert_equal "/barn/render_event_response?source=mum&amp;type=footsteps", @response.body
    end
    
    context "with a namespaced controller" do
      setup do
        @controller.class.class_eval do
          def self.name; "Admin::BarnController"; end
          # def self.default_url_options; {:controller => "/admin/barn"}; end
        end
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
        assert_equal "/admin/barn/render_event_response?source=mum&amp;type=footsteps", @response.body
      end
    end
    
  end
end
