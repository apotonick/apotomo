require 'cells'
require 'onfire'
require 'hooks'


require 'apotomo/event'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/view_helper'
require 'apotomo/rails/controller_methods'  # FIXME.

require 'apotomo/widget/tree_node'
require 'apotomo/widget/event_methods'
require 'apotomo/widget/javascript_methods'


module Apotomo
  # == Accessing Parameters
  #
  # Apotomo tries to prevent you from having to access the global #params hash. We have the following
  # concepts to retrieve input data.
  #
  # 1. Configuration values are available both in render and triggered states. Pass those in #widget
  # when creating the widget tree. Use #options for reading.
  #
  #   has_widgets do |root|
  #     root << widget(:mouse_widget, 'mum', :favorites => ["Gouda", "Chedar"])
  #
  # and read in your widget state
  #
  #   def display
  #     @cheese = options[:favorites].first
  #
  # 2. Request data from forms etc. is available through <tt>event.data</tt> in the triggered states. 
  # Use the <tt>#[]</tt> shortcut to access values directly.
  #
  #   def update(evt)
  #     @cheese = Cheese.find evt[:cheese_id]
  class Widget < Cell::Rails    
    DEFAULT_VIEW_PATHS = [File.join('app', 'widgets')]
    
    include Hooks
    
    # Use this for setup code you're calling in every state. Almost like a +before_filter+ except that it's
    # invoked after the initialization in #has_widgets.
    #
    # Example:
    #
    #   class MouseWidget < Apotomo::Widget
    #     after_initialize do
    #       @cheese = Cheese.find options[:cheese_id]
    #     end
    define_hook :after_initialize
    define_hook :has_widgets
    
    attr_writer :visible
    
    include TreeNode
    
    include Onfire
    
    include EventMethods
    include WidgetShortcuts
    include JavascriptMethods
    
    helper Apotomo::Rails::ViewHelper
    helper Apotomo::Rails::ActionViewMethods
    
    abstract!
    undef :display  # We don't want #display to be listed in #internal_methods.
    
    alias_method :widget_id, :name
    attr_reader :options
    
    after_initialize do
      run_hook :has_widgets, self
    end
    
    
    def initialize(parent, id, options={})
      super(parent)  # TODO: do that as long as cells do need a parent_controller.
      @options      = options
      @name         = id
      @visible      = true
      
      setup_tree_node(parent)      

      run_hook :after_initialize, self
    end
    
    def parent_controller
      # i hope we'll get rid of any parent_controller dependency, soon.
      root? ? @parent_controller : root.parent_controller
    end
    
    def visible?
      @visible
    end
    
    # Invokes +state+ and hopefully returns the rendered content.
    def invoke(state, *args)
      return render_state(state, *args) if method(state).arity != 0 # TODO: remove check and make trigger states receive the evt default. 
      render_state(state)
    end
    
    # Renders and returns a view for the current state. That's why it is usually called at the end of 
    # a state method.
    #
    # ==== Options
    # * <tt>:view</tt> - Renders +view+. Defaults to the current state name.
    # * <tt>:state</tt> - Invokes the +state+ method and returns whatever the state returns.
    # * See http://rdoc.info/gems/cells/3.5.4/Cell/Rails#render-instance_method
    #
    # Example:
    #  class MouseWidget < Apotomo::Widget
    #    def eat
    #      render 
    #    end
    #
    # render the view <tt>eat.haml</tt>.
    #
    #  render :text => "alert('SQUEAK!');"
    #
    # issues a squeaking alert dialog on the page.
    def render(*args, &block)
      puts "apotomo render: #{args}"
      super
    end
    
    # Returns the widget named +widget_id+ if it's a descendent or self.
    def find_widget(widget_id)
      find {|node| node.name.to_s == widget_id.to_s}
    end
    
    def address_for_event(type, options={})
      options.reverse_merge!  :source     => name,
                              :type       => type,
                              :controller => parent_controller.controller_path  # DISCUSS: dependency to parent_controller.  
    end
    
    def url_for_event(type, options={})
      apotomo_event_path address_for_event(type, options) 
    end
    
    
    def self.controller_path
      @controller_path ||= name.sub(/Widget$/, '').underscore unless anonymous?
    end
    
    # Renders the +widget+ (instance or id).
    def render_widget(widget_id, state=:display, *args)
      if widget_id.kind_of?(Widget)
        widget = widget_id
      else
        widget = find_widget(widget_id) or raise "Couldn't render non-existent widget `#{widget_id}`"
      end      

      widget.invoke(state, *args)
    rescue NameError => e
      return widget.invoke(:show, *args)  if state == :display
      raise e
    end
  end
end
 
