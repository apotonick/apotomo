require 'cell/test_case'

module Apotomo
  # Testing is fun. Test your widgets!
  #
  # This class helps you testing widgets where it can. It is similar as in a controller.
  # A declarative test would look like
  #
  #   class BlogWidgetTest < Apotomo::TestCase
  #     has_widgets do |root|
  #       root << widget(:comments_widget, 'post-comments')
  #     end
  #     
  #     it "should be rendered nicely" do
  #       render_widget 'post-comments'
  #       
  #       assert_select "div#post-comments", "Comments for this post"
  #     end
  #
  #     it "should redraw on :update" do
  #       trigger :update
  #       assert_response "$(\"post-comments\").update ..."
  #     end
  #
  # For unit testing, you can grab an instance of your tested widget.
  #
  #     it "should be visible" do
  #       assert root['post-comments'].visible?
  #     end
  #
  # See also in Cell::TestCase.
  class TestCase < Cell::TestCase
    class << self
      def has_widgets_blocks; @has_widgets; end
      
      # Setup a widget tree as you're used to it from your controller. Executed in test context.
      def has_widgets(&block)
        @has_widgets = block  # DISCUSS: use ControllerMethods?
      end
    end
    
    def setup
      super
      @controller.instance_eval do 
        def controller_path
         'barn'
        end
      end
      @controller.extend Apotomo::Rails::ControllerMethods
    end
    
    
    # Returns the widget tree from TestCase.has_widgets.
    def root
      blk = self.class.has_widgets_blocks or raise "Please setup a widget tree using TestCase.has_widgets"
      @root ||= Apotomo::Widget.new(parent_controller, "root", :display).tap do |root|
         self.instance_exec(root, &blk)
      end
    end
    
    def parent_controller
      @controller
    end
    
    # Renders the widget +name+.
    def render_widget(*args)
      @last_invoke = root.render_widget(*args)
    end
    
    # Triggers an event of +type+. You have to pass <tt>:source</tt> as options.
    #
    # Example:
    #
    #   trigger :submit, :source => "post-comments"
    def trigger(type, options)
      source = root.find_widget(options.delete(:source))
      source.options.merge!(options)  # TODO: this is just a try-out (what about children?). 
      source.fire(type)
      root.page_updates # DISCUSS: use ControllerMethods?
    end
    
    # After a #trigger this assertion compares the actually triggered page updates with the passed. 
    #
    # Example:
    #
    #   trigger :submit, :source => "post-comments"
    #   assert_response "alert(\":submit clicked!\")", /\$\("post-comments"\).update/
    def assert_response(*content)
      updates = root.page_updates
      
      i = 0
      content.each do |assertion|
        if assertion.kind_of? Regexp
          assert_match assertion, updates[i] 
        else
          assert_equal assertion, updates[i]
        end
        
        i+=1
      end
    end
    
    include Apotomo::WidgetShortcuts
  end
end
