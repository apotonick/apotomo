require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class EventMethodsTest < Test::Unit::TestCase

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
        assert_equal([Apotomo::Content::PageUpdate.new(:replace => 'mum', :with => "escape")], @mum.page_updates)
      end
      
    end
    
  end 
end