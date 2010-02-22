module Apotomo
  module TestCaseMethods
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
    

  end
end