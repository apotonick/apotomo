require 'test_helper'
require 'apotomo/test_case'

class TestCaseTest < Test::Unit::TestCase
  
  class CommentsWidgetTest < Apotomo::TestCase
  end
  
  class CommentsWidget < Apotomo::Widget
  end
  
  context "TestCase" do
    
    context "responding to #root" do
      class MouseWidgetTest < Apotomo::TestCase
      end
  
      setup do
        @klass = MouseWidgetTest
        @test = @klass.new(:widget).tap{ |t| t.setup }
        @klass.has_widgets { |r| r << widget(:mouse, 'mum', :eating) }
      end
      
      should "respond to #root" do  
        assert_equal ['root', 'mum'], @test.root.collect { |w| w.name }
      end
      
      should "raise an error if no has_widgets block given" do
        exc = assert_raises RuntimeError do
          @test = Class.new(Apotomo::TestCase).new(:widget).tap{ |t| t.setup }
          @test.root
        end
        
        assert_equal "Please setup a widget tree using has_widgets()", exc.message
      end
      
      should "memorize root" do
        @test.root.visible=false
        assert_equal false, @test.root.visible?
      end
      
      should "respond to #render_widget" do
        assert_equal "<div id=\"mum\">burp!</div>\n", @test.render_widget('mum', :eat)
        assert_equal "<div id=\"mum\">burp!</div>\n", @test.last_invoke
      end
      
      should "respond to #assert_select" do
        @test.render_widget('mum', :eat)
        
        assert_nothing_raised { @test.assert_select("div#mum", "burp!") } 
        
        exc = assert_raises( MiniTest::Assertion){  @test.assert_select("div#mummy", "burp!"); }
        assert_equal 'Expected at least 1 element matching "div#mummy", found 0.', exc.message 
      end
      
      context "using events" do
        setup do
          @mum = @test.root['mum']
          @mum.respond_to_event :footsteps, :with => :squeak
          @mum.instance_eval do
            def squeak(evt)
              render :text => evt.data  # this usually leads to "{}".
            end
          end
        end
        
        should "respond to #trigger" do
          assert_equal ["{}"], @test.trigger(:footsteps, 'mum')
        end
        
        should "pass options from #trigger to the evt" do
          assert_equal(["{:direction=>:kitchen}"] , @test.trigger(:footsteps, 'mum', :direction => :kitchen))
        end
        
        should "respond to #assert_response" do
          @test.trigger(:footsteps, 'mum')
          assert @test.assert_response("{}")
        end
      end
      
      context "#view_assigns" do
        should "be emtpy when nothing was set" do
          @test.render_widget('mum')
          assert_equal({}, @test.view_assigns)
        end
        
        should "return the instance variables from the last #render_widget" do
          @mum = @test.root['mum']
          @mum.instance_eval do
            def sleep
              @duration = "8h"
            end
          end
          @test.render_widget('mum', :sleep)
          assert_equal({:duration => "8h"}, @test.view_assigns)
        end
      end
    end
    
    context "responding to parent_controller" do
      setup do
        @test = Apotomo::TestCase.new(:widget).tap{ |t| t.setup }
      end
      
      should "provide a test controller" do
        assert_kind_of ActionController::Base, @test.parent_controller
      end
      
      should "respond to #controller_path" do
        assert_equal "barn", @test.parent_controller.controller_path
      end
    end
  end
end
