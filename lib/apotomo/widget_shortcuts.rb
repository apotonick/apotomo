module Apotomo
  # Shortcut methods for creating widget trees.
  module WidgetShortcuts
    # Shortcut for creating an instance of <tt>class_name+"_widget"</tt> named +id+.
    # If +start_state+ is omited, :display is default. Yields self.
    #
    # Example:
    # 
    #   widget(:comments, 'post-comments')
    #   widget(:comments, 'post-comments', :user => @current_user)
    #
    # Start state is <tt>:display</tt>, whereas the latter also populates #options.
    #
    #   widget(:comments, 'post-comments', :reload)
    #   widget(:comments, 'post-comments', :reload, :user => @current_user)
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
      widget('apotomo/container', id, *args, &block)
    end
    
    private
      def constant_for(class_name)  # TODO: use Cell.class_from_cell_name. 
        "#{class_name}_widget".classify.constantize
      end
  end
end
