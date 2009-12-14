require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ChildStatesTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_invoke_in_render_opts
    @w  = MouseCell.new('mommy')
    @c  = MouseCell.new('bubi')
    
    assert_equal :eat,  @w.decide_child_state_for(@c, {'bubi'  => :eat})
    assert_equal :eat,  @w.decide_child_state_for(@c, {:bubi   => :eat})
    
    assert_equal nil,   @w.decide_child_state_for(@c, {})
    assert_equal nil,   @w.decide_child_state_for(@c, nil)
  end
  
  
  def test_render_children_for_with_options
    local_class = Class.new(MouseCell) 
    m  = local_class.new('mommy', :feed)
    m.instance_eval do
      self.class.transition :from => :feed, :to => :sleep
      
      #def feed;   render :invoke => {'bubi' => :sleep};    end
      def feed;   render;                       end
    end
    
    b  = local_class.new('bubi', [:eat, :sleep])
    b.instance_eval do
      self.class.transition :from => :eat, :to => :sleep
      
      def eat;    render :text => "eating";     end
      def sleep;  render :text => "sleeping";   end
    end
    
    m << b
    
    # both widgets will go to their (first) start state:
    m.invoke
    assert_state m, :feed
    assert_state b, :eat
    
    
    m.instance_eval do
      def feed;   render :invoke => {'bubi' => :sleep};    end
    end
    # now bubi will be sent to :sleep instead of :feed:
    m.invoke :feed
    assert_state m, :feed
    assert_state b, :sleep
  end
end