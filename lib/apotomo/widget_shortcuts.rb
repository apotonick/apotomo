module Apotomo
  # Shortcut methods for creating widget trees.
  module WidgetShortcuts
    # Shortcut for creating an instance of <tt>class_name+"_widget"</tt> named +id+. Yields self.
    #
    # Example:
    # 
    #   widget(:comments)
    # 
    # will create a +CommentsWidget+ with id :comments.
    #
    #   widget(:comments, 'post-comments', :user => current_user)
    #
    # sets id to 'posts_comments' and #options to the hash.
    #
    # You can also use namespaces.
    #
    #   widget('jquery/tabs', 'panel')
    def widget(prefix, *args)
      options = args.extract_options!
      id      = args.shift || prefix
      
      constant_for(prefix).new(parent_controller, id, options).tap do |object|
        yield object if block_given?  
      end
    end
    
    private
      def constant_for(class_name)  # TODO: use Cell.class_from_cell_name. 
        "#{class_name}_widget".classify.constantize
      end
  end
end
