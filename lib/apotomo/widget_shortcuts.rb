module Apotomo
  # Shortcut methods for creating widget trees.
  module WidgetShortcuts
    # Creates an instance of <tt>class_name</tt> with the id <tt>id</tt> and start state <tt>state</tt>.
    # Default start state is <tt>:display</tt>.
    # Yields self if a block is passed.
    # Example:
    #   widget(:form, 'uploads', :build_form) do |form|
    #     form << widget(:upload_field)
    def widget(class_name, id, state=:display, *args)
      object = class_name.to_s.classify.constantize.new(id, state, *args)
      yield object if block_given?
      object
    end
    
    def container(id, *args, &block)
      widget('apotomo/container_widget', id, *args, &block)
    end
    
    def section(*args)
      container(*args)
    end
    
    def cell(base_name, states, id, *args)
      widget(base_name.to_s + '_cell', states, id, *args)
    end
    
    def tab_panel(id, *args)
      widget('apotomo/tab_panel_widget', :display, id, *args)
    end
    
    def tab(id, *args)
      widget('apotomo/tab_widget', :display, id, *args)
    end
  end
end
