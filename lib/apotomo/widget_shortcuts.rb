module Apotomo
  # Create widget trees using the #widget DSL.
  module WidgetShortcuts
    # Shortcut for creating an instance of <tt>class_name+"_widget"</tt> named +id+. Yields self.
    # Note that this creates a proxy object, only. The actual widget is built not until you added 
    # it, e.g. using #<<.
    #
    # Example:
    # 
    #   root << widget(:comments)
    # 
    # will create a +CommentsWidget+ with id :comments attached to +root+.
    #
    #   widget(:comments, 'post-comments', :user => current_user)
    #
    # sets id to 'posts_comments' and #options to the hash.
    #
    # You can also use namespaces.
    #
    #   widget('jquery/tabs', 'panel')
    #
    # Add a block if you need to grab the created widget right away.
    #
    #   root << widget(:comments) do |comments|
    #     comments.markdown!
    #   end
    #
    # Using #widget is just a shortcut, you can always use the constructor as well.
    #
    #   CommentsWidget.new(root, :comments) 
    def widget(*args, &block)
      FactoryProxy.new(*args, &block)
    end
    
    class FactoryProxy
      def initialize(prefix, *args, &block)
        options = args.extract_options!
        id      = args.shift || prefix
        
        @prefix, @id, @options, @block = prefix, id, options, block
      end
      
      def build(parent)
        widget = constant_for(@prefix).new(parent, @id, @options)
        @block.call(widget) if @block
        widget
      end
      
    private
      def constant_for(class_name)  # TODO: use Cell.class_from_cell_name. 
        "#{class_name}_widget".classify.constantize
      end
    end
    
    module DSL
      def <<(child)
        child.build(self)
      end
    end
  end
end
