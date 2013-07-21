require 'test_helper'

class EventMethodsTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  def handler(id, state)
    Apotomo::InvokeEventHandler.new(:widget_id => id, :state => state)
  end


  describe "#respond_to_event and #fire" do
    before do
      mum_and_kid!
    end

    it "alert @mum first, then make her squeak when @kid squeaks" do
      @kid.fire :squeak
      assert_equal ['be alerted', 'answer squeak'], @mum.list
    end

    it "make @mum just squeak back when jerry squeaks" do
      @mum << mouse_mock(:jerry)
      @mum[:jerry].fire :squeak
      assert_equal ['answer squeak'], @mum.list
    end


    it "make @mum run away while @kid keeps watching" do
      @kid.fire :footsteps
      assert_equal ['peek', 'escape'], @mum.list
    end

    it "by default add a handler only once" do
      @mum.respond_to_event :peep, :with => :answer_squeak
      @mum.respond_to_event :peep, :with => :answer_squeak
      @mum.fire :peep
      assert_equal ['answer squeak'], @mum.list
    end

    it "squeak back twice when using the :once => false option" do
      @mum.respond_to_event :peep, :with => :answer_squeak
      @mum.respond_to_event :peep, :with => :answer_squeak, :once => false
      @mum.fire :peep
      assert_equal ['answer squeak', 'answer squeak'], @mum.list
    end

    it "also accept an event argument only" do
      @mum.respond_to_event :answer_squeak
      @mum.fire :answer_squeak
      assert_equal ['answer squeak'], @mum.list
    end

    it "make pass the event into the triggered state" do
      @mum.instance_eval do
        respond_to_event :footsteps

        def footsteps(evt)
          list << evt
        end
      end

      @mum.trigger :footsteps, "near"
      assert_kind_of Apotomo::Event, @mum.list.last
    end

    it "accept payload data for the event" do
      @mum.respond_to_event :answer_squeak
      @mum.instance_eval do
        def answer_squeak(evt)
          list << evt.data
        end
      end

      @mum.fire :answer_squeak, :volume => 9
      assert_equal [{:volume => 9}], @mum.list
    end


    describe "#responds_to_event with :passing" do
      before do
        class AdolescentMouse < MouseWidget
          responds_to_event :squeak, :passing => :root
        end

        @root = mouse(:root)
      end

      it "add handlers to root when called with :passing" do
        AdolescentMouse.new(@root, 'jerry')

        assert_equal [handler('jerry', :squeak)], @root.event_table.all_handlers_for(:squeak, 'jerry')
      end

      it "inherit :passing handlers" do
        Class.new(AdolescentMouse).new(@root, 'jerry')

        assert_equal [handler('jerry', :squeak)], @root.event_table.all_handlers_for(:squeak, 'jerry')
      end

    end

    describe "#responds_to_event in class context" do
      class AdultMouse < Apotomo::Widget
        responds_to_event :peep, :with => :answer_squeak
      end
      class BabyMouse < AdultMouse
        responds_to_event :peep
        responds_to_event :footsteps, :with => :squeak
      end

      before do
        @mum = AdultMouse.new(parent_controller, 'mum')
      end

      it "add the handlers at creation time" do
        assert_equal [handler('mum', :answer_squeak)], @mum.event_table.all_handlers_for(:peep, 'mum')
      end

      it "inherit handlers" do
        assert_equal [[:peep, {:with=>:answer_squeak}]], AdultMouse.responds_to_event_options
        assert_equal [[:peep, {:with=>:answer_squeak}], [:peep], [:footsteps, {:with=>:squeak}]], BabyMouse.responds_to_event_options
      end

      it "not share responds_to_event options between different instances" do
        assert_equal [handler('mum', :answer_squeak)], @mum.event_table.all_handlers_for(:peep, 'mum')

        assert_equal [handler('dad', :answer_squeak)], AdultMouse.new(parent_controller, 'dad', :show).event_table.all_handlers_for(:peep, 'dad')
      end
    end

    describe "#trigger" do
      it "be an alias for #fire" do
        @kid.trigger :footsteps
        assert_equal ['peek', 'escape'], @mum.list
      end
    end


    describe "page_updates" do
      it "expose a simple Array for now" do
        assert_kind_of Array, @mum.page_updates
        assert_equal 0, @mum.page_updates.size
      end

      it "be queued in root#page_updates after #fire" do
        @mum.fire :footsteps
        assert_equal ["escape"], @mum.page_updates
      end
    end

  end
end
