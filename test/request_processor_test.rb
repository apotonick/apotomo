require 'test_helper'

class RequestProcessorTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "RequestProcessor" do
    before do
      @processor = Apotomo::RequestProcessor.new(parent_controller)
      @processor.root << mouse_mock
    end

    describe "constructor, #parent_controller, #root" do
      it "provide #parent_controller and a single root-node for #root" do
        assert_kind_of Apotomo::Widget, @processor.root
        assert_equal 2, @processor.root.size # because we added a child
        assert_equal :root, @processor.root.name

        assert_equal parent_controller, @processor.root.parent_controller
      end

      # TODO: test options argument

      # TODO: test has_widgets_blocks argument

      # TODO: test if after_initialize hook has been run
    end

    it "allow external modification of the tree" do # DISCUSS: needed?
      assert_equal 2, @processor.root.size
    end

    it "delegate #render_widget_for to #root" do
      # TODO: @processor.root should expect #render_widget_for
      assert_equal 'squeak!', @processor.render_widget_for('mouse', :squeak)
    end

    describe "#attach_stateless_blocks_for" do
      it "allow has_widgets blocks with root parameter" do
        @processor.send(:attach_stateless_blocks_for, [
          Proc.new{ |root|
            root << widget(:mouse, 'mouse_sister')
          },
          Proc.new{ |root|
            root << widget(:mouse, 'mouse_brother')
          }], @processor.root, parent_controller)

        # TODO: test if blocks are yielded
        # TODO: test what blocks gets

        assert_kind_of MouseWidget, @processor.root['mouse_sister']
        assert_equal 'mouse_sister', @processor.root['mouse_sister'].name
        assert_kind_of MouseWidget, @processor.root['mouse_brother']
        assert_equal 'mouse_brother', @processor.root['mouse_brother'].name
      end
    end

    describe "#process_for" do
      before do
        class KidWidget < Apotomo::Widget
          responds_to_event :doorSlam, :with => :flight
          responds_to_event :doorSlam, :with => :squeak

          def flight
            render :text => "away from here!"
          end

          def squeak
            render :text => "squeak!"
          end
        end
  
        procs = [Proc.new{ |root|
          root << widget(:mouse, 'mum')
            KidWidget.new(root['mum'], 'kid')
        }]
  
        @processor = Apotomo::RequestProcessor.new(parent_controller, {:js_framework => :prototype}, procs)
      end
  
      it "return an empty array if nothing was triggered" do
        assert_equal [], @processor.process_for(:type => :mouseClick, :source => 'kid')
      end
  
      it "return ordered results if something was triggered" do
        assert_equal ["away from here!", "squeak!"], @processor.process_for(:type => :doorSlam, :source => 'kid')
      end
  
      # TODO: test a situation: root.page_updates is not empty before #process_for call

      # TODO: widget instance should expect #fire

      # TODO: make this test without #inspect
      # TODO: widget instance should expect responder method (replace this test with)
      it "append the params hash to the triggered event" do
        KidWidget.class_eval do
          def squeak(evt)
            render :text => evt.data.inspect
          end
        end
  
        assert_equal ["away from here!", %Q({:type=>:doorSlam, :param=>:value, :source=>"kid"})], @processor.process_for(:type => :doorSlam, :param => :value, :source => 'kid')
      end
  
      # TODO: test if after_fire hook has been run

      it "raise an exception when :source is unknown" do
        e = assert_raises Apotomo::RequestProcessor::InvalidSourceWidget do
          @processor.process_for(:type => :squeak, :source => 'tom')
        end
        assert_match "Source \"tom\" non-existent", e.message
      end
    end
  
    describe "#address_for" do
      before do
        @processor = Apotomo::RequestProcessor.new(parent_controller)
      end
  
      it "accept an event :type and :source" do
        assert_equal({:type => :squeak, :source => 'mum'}, @processor.address_for(:type => :squeak, :source => 'mum'))
      end
  
      it "accept arbitrary options" do
        assert_equal({:type => :squeak, :volume => 'loud', :source => 'mum'}, @processor.address_for(:type => :squeak, :volume => 'loud', :source => 'mum'))
      end
  
      it "complain if no :type given" do
        e = assert_raises RuntimeError do
          @processor.address_for(:source => 'mum')
        end
        assert_equal "You forgot to provide :source or :type", e.message
      end
  
      it "complain if no :source given" do
        e = assert_raises RuntimeError do
          @processor.address_for(:type => :footsteps)
        end
        assert_equal "You forgot to provide :source or :type", e.message
      end
    end
  end
end

class RequestProcessorHooksTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController
  include Apotomo::TestCaseMethods

  describe "RequestProcessor' hooks" do
    before do
      @kid = mouse_mock(:kid)
      @class = Class.new(Apotomo::RequestProcessor)
      @class.instance_eval do
        def kid=(kid); @kid = kid; end
        def kid; @kid; end
      end
      @class.kid = @kid
    end

    describe ":after_initialize hook" do
      # TODO: test when hooks are called
      # TODO: test if block is yielded
      # TODO: test what blocks gets

      it "be called after the has_widgets blocks invokation" do
        @class.after_initialize do |r|
          r.root[:mum] << self.class.kid # requires that :mum is there, yet.
        end

        @r = @class.new(parent_controller, {},
          [Proc.new { |root| root << widget(:mouse, :mum) }])

        assert @r.root[:mum][:kid]
      end
    end

    describe ":after_fire hook" do
      it "be called in #process_for after fire" do
        @class.after_fire do |r|
          r.root[:mum] << self.class.kid
        end

        # DISCUSS: maybe add a trigger test here?
        @r = @class.new(parent_controller, {},
          [Proc.new { |root| root << widget(:mouse, :mum) }])
        @r.process_for(:source => "root", :type => :noop) # calls after_fire hook

        assert @r.root[:mum][:kid]
      end
    end
  end
end
