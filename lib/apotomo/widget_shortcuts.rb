module Apotomo
  # Shortcut methods for creating widget trees.
  module WidgetShortcuts
    # Shortcut for creating an instance of <tt>class_name+"_widget"</tt> named +id+.
    # If +start_state+ is omited, :display is default. Yields self.
    #
    # Example:
    # 
    #   widget(:comments)
    # 
    # will create a +CommentsWidget+ with id :comments.
    #
    #   widget(:comments, 'post-comments', :user => current_user)
    #
    # sets the start state to <tt>:display</tt>, id to 'posts_comments' and #options to the hash.
    #
    #   widget(:comments, 'post-comments', :reload)
    #
    # start state will be <tt>:reload</tt>.
    #
    #   widget(:comments, 'post-comments', :reload, :user => @current_user)
    #
    # The verbose way.
    #
    # You can also use namespaces.
    #
    #   widget('jquery/tabs', 'panel')
    def widget(prefix, *args)
      options = args.extract_options!
      id      = args.shift || prefix
      state   = args.shift || :display
      
      constant_for(prefix).new(parent_controller, id, state, options).tap do |object|
        yield object if block_given?  
      end
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
