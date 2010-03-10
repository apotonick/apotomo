module Apotomo
  module TestCaseMethods
    PageUpdate= Apotomo::PageUpdate
    
    # Provides a ready-to-use mouse widget instance.
    def mouse_mock(id='mouse', start_state=:eating, opts={}, &block)
      mouse = mouse_class_mock.new(id, start_state, opts)
      mouse.instance_eval &block if block_given?
      mouse.controller = @controller
      mouse
    end
    
    def mouse_class_mock(&block)
      klass = Class.new(MouseCell)
      klass.instance_eval &block if block_given?
      klass
    end
    
    def mum_and_kid!
      @mum = mouse_mock('mum', :answer_squeak)
        @mum << @kid = mouse_mock('kid', :peek)
      
      @mum.respond_to_event :squeak, :with => :answer_squeak
      @mum.respond_to_event :squeak, :from => 'kid', :with => :alert
      @mum.respond_to_event :footsteps, :with => :escape
      
      @kid.respond_to_event :footsteps, :with => :peek
      
      
      @mum.instance_eval do
        def list; @list ||= []; end
        
        def answer_squeak;  self.list << 'answer squeak'; render :text => "squeak" end
        def alert;          self.list << 'be alerted';    render :text => "alert!" end
        def escape;         self.list << 'escape';        render :text => "escape" end
      end
      
      @kid.instance_eval do
        def peek;           root.list << 'peek'; render :text => "" end
      end
      
      @mum
    end
    
    
    def hibernate_widget(widget)
      session = {}
      widget.freeze_to(session)
      
      session = Marshal.load(Marshal.dump(session))
      
      Apotomo::StatefulWidget.thaw_from(session)
    end
  
  end
end