require 'test_helper'

class RailsIntegrationTest < ActionController::TestCase
  include Apotomo::TestCaseMethods::TestController

  tests ApotomoController

  class KidWidget < MouseWidget
    responds_to_event :squeak, :passing => :root

    def feed
      render # invokes #url_for_event.
    end

    def squeak
      render :text => "squeak!"
    end
  end

  class MumWidget < MouseWidget
    responds_to_event :squeak
    responds_to_event :sniff

    has_widgets do |me|
      me << widget("rails_integration_test/kid", :kid)
    end

    def eat
      render
    end

    def make_me_squeak
      render
    end

    def squeak(evt)
      render :text => evt.data
    end

    def sniff(evt)
      render :text => "<b>sniff sniff</b>"
    end

    def child
      render :text => render_widget(:kid, :feed)
    end
  end

  # describe "ActionController" do
    setup do
      @controller.class.has_widgets do |root|
        MumWidget.new(root, 'mum')
      end

      @controller.instance_eval do
        def mum
          render :text => render_widget('mum', params[:state])
        end
      end
    end

    ### FIXME: could somebody get skipped tests working?
    # it seems like locs *doesn't* create #mum method accessible in tests above!

    test "provide the rails view helpers in state views" do
      skip

      get 'mum', :state => :make_me_squeak

      assert_response :success
      assert_equal 'text/html', @response.content_type
      assert_select "a", "mum"
    end

    # describe "nested widgets" do
      test "render" do
        skip

        get 'mum', :state => :child

        assert_response :success
        assert_equal 'text/html', @response.content_type
        assert_equal "/barn/render_event_response?source=kid&amp;type=click\n", @response.body
      end

      test "process events" do
        skip

        get 'render_event_response', :source => 'mum', :type => :squeak

        assert_response :success
        assert_equal 'text/html', @response.content_type
        assert_equal "squeak!", @response.body
      end
    # end

    test "pass the event with all params data as state-args" do
      get 'render_event_response', :source => "mum", :type => "squeak", :pitch => "high"

      assert_response :success
      assert_equal 'text/javascript', @response.content_type
      assert_equal "{\"source\"=>\"mum\", \"type\"=>\"squeak\", \"pitch\"=>\"high\", \"controller\"=>\"barn\", \"action\"=>\"render_event_response\"}\nsqueak!", @response.body
    end

    test "render updates to the parent window for an iframe request" do
      skip

      get 'render_event_response', :source => 'mum', :type => :sniff, :apotomo_iframe => true

      assert_response :success
      assert_equal 'text/html', @response.content_type
      assert_equal "<html><body><script type='text/javascript' charset='utf-8'>\nvar loc = document.location;\nwith(window.parent) { setTimeout(function() { window.eval('<b>sniff sniff<\\/b>'); window.loc && loc.replace('about:blank'); }, 1) }\n</script></body></html>", @response.body
    # end

    # describe "ActionView" do
      before do
        @controller.instance_eval do
          def mum
            render :inline => "<%= render_widget 'mum', :eat %>"
          end
        end
      end

      test "respond to #render_widget" do
        get :mum

        assert_response :success
        assert_equal 'text/html', @response.content_type
        assert_select "#mum", "burp!"
      end

      test "respond to #url_for_event" do
        @controller.instance_eval do
          def mum
            render :inline => "<%= url_for_event :footsteps, :source => 'mum' %>"
          end
        end

        get :mum

        assert_response :success
        assert_equal 'text/html', @response.content_type
        assert_equal "/barn/render_event_response?source=mum&amp;type=footsteps", @response.body
      end
    end
  # end
end

class IncludingApotomoSupportTest < ActiveSupport::TestCase
  # describe "A controller not including ControllerMethods explicitely" do
    setup do
      @class      = Class.new(ActionController::Base)
      @controller = @class.new
      @controller.request = ActionController::TestRequest.new
    end

    test "respond to .has_widgets only" do
      assert_respond_to @class, :has_widgets
      assert_not_respond_to @class, :apotomo_request_processor
    end

    test "mixin all methods after first use of .has_widgets" do
      @class.has_widgets do |root|
      end

      assert_respond_to @class, :has_widgets
      assert_respond_to @controller, :apotomo_request_processor
    end
  # end
end

class RoutingTest < ActionController::TestCase
  include Apotomo::TestCaseMethods::TestController

  tests ApotomoController

  # describe "Routing" do
    ### FIXME: could somebody get that working?
    test "generate routes to the render_event_response action" do
      skip

      assert_generates "/barn/render_event_response?type=squeak", { :controller => "barn", :action => "render_event_response", :type => "squeak" }
    end

    ### FIXME: could somebody get that working?
    test "recognize routes to the render_event_response action" do
      skip

      assert_recognizes({ :controller => "apotomo", :action => "render_event_response", :type => "squeak" }, "/apotomo/render_event_response?type=squeak")
    end
  # end
end
