require 'test_helper'
 
class EventMethodsTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "#respond_to_event and #fire" do
    setup do
      mum_and_kid!
    end
    
    should "alert @mum first, then make her squeak when @kid squeaks" do
      @kid.fire :squeak
      assert_equal ['be alerted', 'answer squeak'], @mum.list
    end
    
    should "make @mum just squeak back when @jerry squeaks" do
      @mum << @jerry = mouse_mock('jerry')
      @jerry.fire :squeak
      assert_equal ['answer squeak'], @mum.list
    end
    
    
    should "make @mum run away while @kid keeps watching" do
      @kid.fire :footsteps
      assert_equal ['peek', 'escape'], @mum.list
    end
    
    should "by default add a handler only once" do
      @mum.respond_to_event :peep, :with => :answer_squeak
      @mum.respond_to_event :peep, :with => :answer_squeak
      @mum.fire :peep
      assert_equal ['answer squeak'], @mum.list
    end
    
    should "squeak back twice when using the :once => false option" do
      @mum.respond_to_event :peep, :with => :answer_squeak
      @mum.respond_to_event :peep, :with => :answer_squeak, :once => false
      @mum.fire :peep
      assert_equal ['answer squeak', 'answer squeak'], @mum.list
    end
    
    should "also accept an event argument only" do
      @mum.respond_to_event :answer_squeak
      @mum.fire :answer_squeak
      assert_equal ['answer squeak'], @mum.list
    end
    
    should "accept payload data for the event" do
      @mum.respond_to_event :answer_squeak
      @mum.instance_eval do
        def answer_squeak
          evt = @opts[:event]
          list << evt.data
        end
      end
      
      @mum.fire :answer_squeak, :volume => 9
      assert_equal [{:volume => 9}], @mum.list
    end
    
    context "#responds_to_event in class context" do
      setup do
        class AdultMouseCell < MouseCell
          responds_to_event :peep, :with => :answer_squeak
        end
        class BabyMouseCell < AdultMouseCell
          responds_to_event :footsteps, :with => :squeak
        end
      end
      
      should "add the handlers at creation time" do
        assert_equal [Apotomo::InvokeEventHandler.new(:widget_id => 'mum', :state => :answer_squeak)], AdultMouseCell.new(parent_controller, 'mum', :show).event_table.all_handlers_for(:peep, 'mum')
      end
      
      should "not inherit handlers for now" do
        assert_equal [], BabyMouseCell.new(parent_controller, 'kid', :show).event_table.all_handlers_for(:peep, 'kid')
      end
    end
    
    context "#trigger" do
      should "be an alias for #fire" do
        @kid.trigger :footsteps
        assert_equal ['peek', 'escape'], @mum.list
      end
    end
    
    
    context "page_updates" do
      should "expose a simple Array for now" do
        assert_kind_of Array, @mum.page_updates
        assert_equal 0, @mum.page_updates.size
      end
      
      should "be queued in root#page_updates after #fire" do
        @mum.fire :footsteps
        assert_equal ["escape"], @mum.page_updates
      end
    end
    
  end 
end
