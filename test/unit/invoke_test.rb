require 'test_helper'

class InvokeTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  class LocalMouse < MouseCell
    def snuggle; render; end
    def educate; render :view => :snuggle; end
  end
  
  context "Invoking a single widget" do
    setup do
      @mum = LocalMouse.new(parent_controller, 'mum', :snuggle)
    end
    
    context "implicitely" do
      should "always enter the given state" do
        @mum.invoke :snuggle
        assert_equal 'snuggle', @mum.last_state
        
        @mum.invoke :educate
        assert_equal 'educate', @mum.last_state
      end
    end
    
    context "explicitely" do
      should "per default enter the start state" do
        @mum.invoke
        assert_equal 'snuggle', @mum.last_state
        
        @mum.invoke
        assert_equal 'snuggle', @mum.last_state
      end
      
      context "with defined transitions" do
        setup do
          @mum.instance_eval do
            self.class.transition :from => :snuggle, :to => :educate
          end
          
          @mum.invoke
          assert_equal 'snuggle', @mum.last_state
        end
        
        should "automatically follow the transitions if defined" do
          assert_equal 'snuggle', @mum.last_state
          puts "invoooooooooooooogue"
          puts @mum.last_state.inspect
          @mum.invoke
          assert_equal 'educate', @mum.last_state
        end
        
        should "nevertheless allow undefined implicit invokes" do
          @mum.invoke :snuggle
          assert_equal 'snuggle', @mum.last_state
        end
      end
    end
  end
  
  context "Invoking a widget family" do
    setup do
      @mum = LocalMouse.new(parent_controller, 'mum', :snuggle)
      
      # create an anonym class for @kid so we don't pollute with #transition's.
      @mum << @kid = mouse_class_mock.new(parent_controller, 'kid', :snooze)
      @kid.instance_eval do
        def snooze; render :nothing => true; end
        def listen; render :nothing => true; end
      end
    end
    
    context "implicitely" do
      should "per default send kid to its start state" do
        @mum.invoke :snuggle
        assert_equal 'snuggle',  @mum.last_state
        assert_equal 'snooze',   @kid.last_state
        
        @mum.invoke :educate
        assert_equal 'educate',  @mum.last_state
        assert_equal 'snooze',   @kid.last_state
      end
      
      should "follow the kid's transition if defined" do
        @kid.instance_eval do
          self.class.transition :from => :snooze, :to => :listen
        end
        
        @mum.invoke :snuggle
        @mum.invoke :educate
        assert_equal 'educate',  @mum.last_state
        assert_equal 'listen',   @kid.last_state
      end
      
      should "send kid to the given state passed to #render" do
        @mum.instance_eval do
          def snuggle
            render :invoke => {'kid' => :listen}
          end
        end
        
        @mum.invoke :snuggle
        assert_equal 'snuggle',  @mum.last_state
        assert_equal 'listen',   @kid.last_state
      end
      
      should "send kid to the :invoke state as it overrides #transition" do
        @kid.instance_eval do
          self.class.transition :from => :snooze, :to => :listen
        end
        
        @mum.instance_eval do
          def educate
            render :nothing => true, :invoke => {'kid' => :snooze}
          end
        end
        
        @mum.invoke :snuggle
        assert_equal 'snuggle',  @mum.last_state
        assert_equal 'snooze',   @kid.last_state
        
        @mum.invoke :educate
        assert_equal 'educate',  @mum.last_state
        assert_equal 'snooze',   @kid.last_state
      end
    end
  end
end
