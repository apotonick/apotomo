module Apotomo
  # Shortcut methods for creating widget trees.
  module WidgetShortcuts
    # Shortcut for creating an instance of +class_name+ named +id+.
    # If +start_state+ is omited, :display is default. Yields self.
    #
    # Example:
    # 
    #   widget(:comments_widget, 'post-comments')
    #   widget(:comments_widget, 'post-comments', :user => @current_user)
    #
    # Start state is <tt>:display</tt>, whereas the latter also populates @opts.
    #
    #   widget(:comments_widget, 'post-comments', :reload)
    #   widget(:comments_widget, 'post-comments', :reload, :user => @current_user)
    #
    # Explicitely sets the start state.
    #
    # You can also use namespaces.
    #
    #   widget('jquery/tabs', 'panel')
    def widget(class_name, id, state=:display, *args)
      if state.kind_of?(Hash)
        args << state
        state = :display
      end
      
      object = constant_for(class_name).new(parent_controller, id, state, *args)
      yield object if block_given?
      object
    end
    
    def container(id, *args, &block)
      widget('apotomo/container_widget', id, *args, &block)
    end
    
    def section(*args)
      container(*args)
    end
    
    # TODO: deprecate.
    def cell(base_name, states, id, *args)
      widget(base_name.to_s + '_cell', states, id, *args)
    end
    
    def tab_panel(id, *args)
      widget('apotomo/tab_panel_widget', :display, id, *args)
    end
    
    def tab(id, *args)
      widget('apotomo/tab_widget', :display, id, *args)
    end
    
    private
      def constant_for(class_name)
        class_name.to_s.camelize.constantize
      end
  end
end
