require 'test_helper'

class RequestProcessorTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  def root_mum_and_kid!
    mum_and_kid!

    @root = Apotomo::Widget.new(parent_controller, 'root', :display)
    @root << @mum
  end


  describe "RequestProcessor" do
    before do
      @processor = Apotomo::RequestProcessor.new(parent_controller)
      root = @processor.root
      root << mouse_mock
    end

    it "allow external modification of the tree" do
      root = @processor.root
      assert_equal 2, @processor.root.size
    end

    it "delegate #render_widget_for to #root" do
      assert_equal 'squeak!', @processor.render_widget_for('mouse', :squeak)
    end
  end

  describe "#attach_stateless_blocks_for" do
    before do
      @processor  = Apotomo::RequestProcessor.new(parent_controller)
      @root       = @processor.root
      assert_equal @root.size, 1
    end

    it "allow has_widgets blocks with root parameter" do
      @processor.send(:attach_stateless_blocks_for, [Proc.new{ |root|
        root << widget(:mouse, 'mouse')
      }], @root, parent_controller)

      assert_equal 'mouse', @processor.root['mouse'].name
    end
  end

  describe "option processing at construction time" do
    describe "with empty options" do
      before do
        @processor = Apotomo::RequestProcessor.new(parent_controller)
      end

      it "provide a single root-node for #root" do
        assert_equal 1, @processor.root.size
      end
    end

    describe "with controller" do
      it "attach the passed parent_controller to root" do
        assert_equal parent_controller, Apotomo::RequestProcessor.new(parent_controller, {}, []).root.parent_controller
      end
    end
  end


  describe "#process_for" do
    before do
      class KidWidget < Apotomo::Widget
        responds_to_event :doorSlam, :with => :flight
        responds_to_event :doorSlam, :with => :squeak
        def flight; render :text => "away from here!"; end
        def squeak; render :text => "squeak!"; end
      end

      procs = [Proc.new{ |root|
        root << widget(:mouse, 'mum')
          KidWidget.new(root['mum'], 'kid')
      }]

      @processor = Apotomo::RequestProcessor.new(parent_controller, {:js_framework => :prototype}, procs)
    end

    it "return an empty array if nothing was triggered" do
      assert_equal [], @processor.process_for({:type => :mouseClick, :source => 'kid'})
    end

    it "return 2 page updates when @kid squeaks" do
      assert_equal ["away from here!", "squeak!"], @processor.process_for({:type => :doorSlam, :source => 'kid'})
    end

    it "append the params hash to the triggered event" do
      KidWidget.class_eval do
        def squeak(evt); render :text => evt.data.inspect; end
      end

      assert_equal ["away from here!", "{:type=>:doorSlam, :source=>\"kid\"}"], @processor.process_for({:type => :doorSlam, :source => 'kid'})
    end

    it "raise an exception when :source is unknown" do
      assert_raises Apotomo::RequestProcessor::InvalidSourceWidget do
        @processor.process_for({:type => :squeak, :source => 'tom'})
      end
    end
  end




  describe "invoking #address_for" do
    before do
      @processor = Apotomo::RequestProcessor.new(parent_controller)
    end

    it "accept an event :type" do
      assert_equal({:type => :squeak, :source => 'mum'}, @processor.address_for(:type => :squeak, :source => 'mum'))
    end

    it "accept arbitrary options" do
      assert_equal({:type => :squeak, :volume => 'loud', :source => 'mum'}, @processor.address_for(:type => :squeak, :volume => 'loud', :source => 'mum'))
    end

    it "complain if no type given" do
      assert_raises RuntimeError do
        @processor.address_for(:source => 'mum')
      end
    end

    it "complain if no source given" do
      assert_raises RuntimeError do
        @processor.address_for(:type => :footsteps)
      end
    end
  end
end

class RequestProcessorHooksTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController
  include Apotomo::TestCaseMethods

  describe "Hooks in RequestProcessor" do
    before do
      @kid = mouse_mock(:kid)
      @class = Class.new(Apotomo::RequestProcessor)
      @class.instance_eval do
        def kid=(kid); @kid=kid end
        def kid; @kid end
      end
      @class.kid = @kid
    end

    describe ":after_initialize hook" do
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
        @r.process_for(:source => "root", :type => :noop) # calls ~after_fire.

        assert @r.root[:mum][:kid]
      end
    end
  end
end
