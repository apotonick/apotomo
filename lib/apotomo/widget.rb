require 'cells'
require 'onfire'
require 'hooks'

require 'apotomo/tree_node'
require 'apotomo/event'
require 'apotomo/event_methods'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/view_helper'
require 'apotomo/rails/controller_methods'  # FIXME.

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
  class Widget < Cell::Base
    
    DEFAULT_VIEW_PATHS = [
      File.join('app', 'widgets'),
      File.join('app', 'widgets', 'layouts')
    ]
    
    include Hooks
    
    # Use this for setup code you're calling in every state. Almost like a +before_filter+ except that it's
    # invoked after the initialization in #has_widgets.
    #
    # Example:
    #
    #   class MouseWidget < Apotomo::Widget
    #     after_initialize :setup_cheese
    #     
    #     # we need @cheese in every state:
    #     def setup_cheese(*)
    #       @cheese = Cheese.find options[:cheese_id]
    define_hook :after_initialize
    define_hook :has_widgets
    define_hook :after_add
    
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
    
    
    # Runs callbacks for +name+ hook in instance context.  
    def run_widget_hook(name, *args)
      self.class.callbacks_for_hook(name).each { |blk| instance_exec(*args, &blk) }
    end
    
    def add_has_widgets_blocks(*)
      run_widget_hook(:has_widgets, self)
    end
    after_initialize :add_has_widgets_blocks
    
    
    def initialize(parent_controller, id, options={})
      super(parent_controller, options)  # do that as long as cells do need a parent_controller.
      
      @name         = id
      @visible      = true
      
      run_hook :after_initialize, self
    end
    
    def visible?
      @visible
    end
    
    # Invokes +state+ and hopefully returns the rendered content.
    def invoke(state, *args)
      return render_state(state, *args) if state_accepts_args?(state)
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
    #  render :js => "alert('SQUEAK!');"
    #
    # issues a squeaking alert dialog on the page.
    def render(*args, &block)
      super
    end
    
    alias_method :emit, :render
    
    def param(name)
      msg = "Deprecated. Use #options for widget constructor options or #params for request data."
      ActiveSupport::Deprecation.warn(msg)
      raise msg
    end
    
    
    # Returns the widget named <tt>widget_id</tt> as long as it is below self or self itself.
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
    end
  end
end
 
