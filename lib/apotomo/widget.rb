require 'cells'
require 'onfire'
require 'hooks'

require 'apotomo/tree_node'
require 'apotomo/event'
require 'apotomo/event_methods'
require 'apotomo/transition'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/view_helper'

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
    attr_reader :start_state

    include TreeNode
    
    include Onfire
    include EventMethods
    
    include Transition
    include WidgetShortcuts
    
    helper Apotomo::Rails::ViewHelper
    
    abstract!
    
    undef :display  # We don't want #display to be listed in #internal_methods.
    
    alias_method :last_state, :action_name
    alias_method :widget_id,  :name
    
    
    # Runs callbacks for +name+ hook in instance context.  
    def run_widget_hook(name, *args)
      self.class.callbacks_for_hook(name).each { |blk| instance_exec(*args, &blk) }
    end
    
    def add_has_widgets_blocks(*)
      run_widget_hook(:has_widgets, self)
    end
    after_initialize :add_has_widgets_blocks
    
    
    # Constructor which needs a unique id for the widget and one or multiple start states.  
    def initialize(parent_controller, id, start_state, options={})
      super(parent_controller, options)  # do that as long as cells do need a parent_controller.
      
      @name         = id
      @start_state  = start_state
      @visible      = true
      
      run_hook :after_initialize, self
    end
    
    def visible?
      @visible
    end
    
    # Returns the rendered content for the widget by running the method for +state+.
    def invoke(state=nil, *args)
      logger.debug "#{name}.invoke(#{state.inspect})"
      
      state ||= (next_state_for(last_state) || start_state) # TODO: move to separate method.
      
      logger.debug "#{name}: transition: #{last_state} to #{state}"
      
      invoke_state(state, *args)
    end
    
    def invoke_state(state, *args)
      return render_state(state, *args) if state_accepts_args?(state)
      render_state(state)
    end
    
    
    
    # Render the view for the current state. Usually called at the end of a state method.
    #
    # ==== Options
    # * <tt>:view</tt> - Specifies the name of the view file to render. Defaults to the current state name.
    # * <tt>:template_format</tt> - Allows using a format different to <tt>:html</tt>.
    # * <tt>:layout</tt> - If set to a valid filename inside your cell's view_paths, the current state view will be rendered inside the layout (as known from controller actions). Layouts should reside in <tt>app/cells/layouts</tt>.
    # * <tt>:render_children</tt> - If false, automatic rendering of child widgets is turned off. Defaults to true.
    # * <tt>:invoke</tt> - Explicitly define the state to be invoked on a child when rendering.
    # * see Cell::Base#render for additional options
    #
    # Note that <tt>:text => ...</tt> and <tt>:update => true</tt> will turn off <tt>:frame</tt>.
    #
    # Example:
    #  class MouseCell < Apotomo::StatefulWidget
    #    def eating
    #      # ... do something
    #      render 
    #    end
    #
    # will just render the view <tt>eating.html</tt>.
    # 
    #    def eating
    #      # ... do something
    #      render :view => :bored, :layout => "metal"
    #    end
    #
    # will use the view <tt>bored.html</tt> as template and even put it in the layout
    # <tt>metal</tt> that's located at <tt>$RAILS_ROOT/app/cells/layouts/metal.html.erb</tt>.
    #
    #  render :js => "alert('SQUEAK!');"
    #
    # issues a squeaking alert dialog on the page.
    def render(options={}, &block)
      if options[:nothing]
        return "" 
      end
      
      if options[:text]
        options.reverse_merge!(:render_children => false)
      end
      
      options.reverse_merge!  :render_children  => true,
                              :locals           => {},
                              :invoke           => {},
                              :suppress_js      => false
                              
      
      rendered_children = render_children_for(options)
      
      options[:locals].reverse_merge!(:rendered_children => rendered_children)
      
      @suppress_js = options[:suppress_js]    ### FIXME: implement with ActiveHelper and :locals.
      
      
      render_view_for(action_name, options) # defined in Cell::Base.
    end
    
    alias_method :emit, :render
    
    # Wraps the rendered content in a replace statement targeted at your +Apotomo.js_framework+ setting.
    # Use +:selector+ to change the selector.
    #
    # Example:
    #
    # Assuming you set 
    #   Apotomo.js_framework = :jquery
    #
    # and call replace in a state
    #
    #   replace :view => :squeak, :selector => "div#mouse"
    #   #=> "$(\"div#mouse\").replaceWith(\"<div id=\\\"mum\\\">squeak!<\\/div>\")"
    def replace(options={})
      content = render(options)
      Apotomo.js_generator.replace(options[:selector] || self.name, content)
    end
    
    # Same as replace except that the content is wrapped in an update statement.
    #
    # Example for +:jquery+:
    #
    #   update :view => :squeak
    #   #=> "$(\"mum\").html(\"<div id=\\\"mum\\\">squeak!<\\/div>\")"
    def update(options={})
      content = render(options)
      Apotomo.js_generator.update(options[:selector] || self.name, content)
    end
    
    def visible_children
      children.find_all { |kid| kid.visible? }
    end

    def render_children_for(options)
      return {} unless options[:render_children]
      
      render_children(options[:invoke])
    end
    
    def render_children(invoke_options={})
      ActiveSupport::OrderedHash.new.tap do |rendered_children|
        visible_children.each do |kid|
          child_state = decide_state_for(kid, invoke_options)
          logger.debug "    #{kid.name} -> #{child_state}"
          
          rendered_children[kid.name] = render_child(kid, child_state)
        end
      end
    end   

    def render_child(cell, state)
     cell.invoke(state)
    end

    def decide_state_for(child, invoke_options)
      invoke_options.stringify_keys[child.name.to_s]
    end
    
    
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
  
  
    module Helper
      # Renders the +widget+ (instance or id).
      def render_widget(widget_id, *args)
        if widget_id.kind_of?(Widget)
          widget = widget_id
        else
          widget = controller[widget_id] or raise "Couldn't render non-existent widget `#{widget_id}`"
        end
        
        widget.invoke(*args)
      end
    end
    helper Helper
    
  end
end
