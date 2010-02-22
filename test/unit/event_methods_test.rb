require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class EventMethodsTest < Test::Unit::TestCase

  context "#respond_to_event and #trigger" do
    setup do
      @mum = mouse_mock('mum', [:answer_squeak, :escape, :alert])
      @mum << @kid = mouse_mock('kid', :peek)
      
      @mum.respond_to_event :squeak, :with => :answer_squeak
      @mum.respond_to_event :squeak, :from => 'kid', :with => :alert
      @mum.respond_to_event :footsteps, :with => :escape
      
      @kid.respond_to_event :footsteps, :with => :peek
      
      @mum.instance_eval do
        class << self;      attr_writer :list; end
        def list;           @list ||= []; end
        
        def answer_squeak;  self.list << 'answer squeak'; "" end
        def alert;          self.list << 'be alerted'; "" end
        def escape;         self.list << 'escape'; "" end
      end
      @kid.instance_eval do
        def peek;           root.list << 'peek'; "" end
      end
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
    
  end 
end