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
  class Widget < Cell::Base
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
    #       @cheese = Cheese.find @opts[:cheese_id]
    define_hook :after_initialize
    define_hook :has_widgets
    define_hook :after_add
    
    attr_accessor :opts
    attr_writer   :visible
    
    attr_writer   :controller
    attr_accessor :version
    
    include TreeNode
    
    include Onfire
    include EventMethods
    
    include Transition
    include WidgetShortcuts
    
    helper Apotomo::Rails::ViewHelper
    
    
    # Runs callbacks for +name+ hook in instance context.  
    def run_widget_hook(name, *args)
      self.class.callbacks_for_hook(name).each { |blk| instance_exec(*args, &blk) }
    end
    
    def add_has_widgets_blocks(*)
      run_widget_hook(:has_widgets, self)
    end
    after_initialize :add_has_widgets_blocks
    
    
    # Constructor which needs a unique id for the widget and one or multiple start states.  
    def initialize(parent_controller, id, start_state, opts={})
      super(parent_controller, opts)  # do that as long as cells do need a parent_controller.
      
      @name         = id
      @start_state  = start_state

      @visible      = true
      @version      = 0 ### DISCUSS: neeed in stateLESS?
      
      @cell         = self  ### DISCUSS: needed?
      
      @params       = parent_controller.params.dup.merge(opts)
      
      run_hook :after_initialize, self
    end
    
    def last_state
      action_name
    end
    
    def visible?
      @visible
    end
    
    # Returns the rendered content for the widget by running the state method for <tt>state</tt>.
    # This might lead us to some other state since the state method could call #jump_to_state.
    def invoke(state=nil, &block)
      @invoke_block = block ### DISCUSS: store block so we don't have to pass it 10 times?
      logger.debug "\ninvoke on #{name} with #{state.inspect}"
      
      if state.blank?
        state = next_state_for(last_state) || @start_state
      end
      
      logger.debug "#{name}: transition: #{last_state} to #{state}"
      logger.debug "                                    ...#{state}"
      
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
      
      
      render_view_for(options, action_name) # defined in Cell::Base.
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

    # Force the FSM to go into <tt>state</tt>, regardless whether it's a valid 
    # transition or not.
    ### TODO: document the need for return.
    def jump_to_state(state)
      logger.debug "STATE JUMP! to #{state}"
      
      render_state(state)
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
    
    
    ### DISCUSS: use #param only for accessing request data.
    def param(name)
      @params[name]
    end
    
    
    # Returns the widget named <tt>widget_id</tt> as long as it is below self or self itself.
    def find_widget(widget_id)
      find {|node| node.name.to_s == widget_id.to_s}
    end
    
    def address_for_event(type, options={})
      options.reverse_merge!  :source     => name,
                              :type       => type,
                              :controller => parent_controller.controller_name  # DISCUSS: dependency to parent_controller.  
    end
    
    def url_for_event(type, options={})
      apotomo_event_path address_for_event(type, options) 
    end
    
    alias_method :widget_id, :name
  end
end
