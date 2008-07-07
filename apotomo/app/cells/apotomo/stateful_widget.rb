### (c) 2008, Nick Sutterer <nick@tesbo.com>

### TODO: clean up the state data before invoking a start state more than once
### in one request.


class Apotomo::StatefulWidget < Cell::Base
  attr_reader :last_state
  attr_accessor :opts ### DISCUSS: don't allow this, rather introduce #visible?.
  
  include TreeNode
  include Apotomo::EventAware   ### TODO: set a "see also" link in the docs.
  include Apotomo::Transitions
  
  helper Apotomo::ViewHelper
  
  
  # Constructor which needs a unique id for the widget and one or multiple start states.
  # start_state may be a symbol or an array of symbols.
  def initialize(controller, id, start_states=:widget_content, opts={})
    #@controller   = controller
    super(controller, id, opts)
    @cell_name    = @name  = id
    #@opts         = opts
    @start_states = start_states.kind_of?(Array) ? start_states : [start_states]

    @child_params = {}  ### DISCUSS: child params are deleted once per request right now. what if we are called twice and need a clean hash? do we need that?
    
    init_tree_node(id)
  end
  
  
  # Default start state for any widget. Do not overwrite this, better define a new
  # state method and set it as start state when creating the instance.
  def widget_content
  end
  
  
  def freeze
    session[name.to_s] = freezer = {}
    
    (self.instance_variables - ivars_to_forget).each do |var|
      freezer[var.to_s] =  instance_variable_get(var)
    end
    
  end
  
  
  def thaw
    return unless widget_session
    
    widget_session.each do |var, val|
      ### DISCUSS: what about some "generic" special treatment?
      if val.kind_of?(ActiveRecord::Base) and not val.new_record?
        val.reload
      end
      self.instance_variable_set(var, val)
    end
  end
  
  
  # Defines the instance vars that should <em>not</em> survive between requests, 
  # which means they're not frozen in Apotomo::StatefulWidget#freeze.
  def ivars_to_forget
    ivars_to_ignore + ['@content', '@cell_views']
  end
  
  # Defines the instance vars which should <em>not</em> be copied to the view.
  def ivars_to_ignore
    super + ['@children', '@parent', '@childrenHash', '@cell', '@opts', '@state_view',
    '@is_f5_fixme'
    ]
  end
  
  def thaw_last_state
    return unless widget_session
    #puts "session is here: #{session[name.to_s].inspect}"
    return widget_session['@last_state']
  end
  
  ### DISCUSS: this is state_data:
  def thaw_child_params ### FIXME: is this good?
    return unless widget_session
    return widget_session['@child_params']
  end
  
  def widget_session
    session[name.to_s]
  end
  
  
  # Explicitly defines the valid state transistions.
  #
  # Example:
  # { :start_state_one  => [:some_state, :looping_state],
  #   :looping_state    => [:looping_state]
  # }
  def transition_map; {}; end
  def transitions
    transition_map
  end
  
  
  # don't thaw when
  #   - parent explicitly invokes a start state
  #   - in F5 context (*)
  #   - in init context (*)
  # the is_f5_fixme flag is needed for context propagation when children are rendered.
  # this is a part i don't like.
  
  # Central entry point for starting the FSM, executing state methods and rendering 
  # state views.
  def invoke(state="_")
    puts "\ninvoke on #{name}"
    
    last_state = thaw_last_state
    #puts last_state
    if state.to_s == "*"
      @is_f5_fixme = true
      state= start_state_for_state(last_state)
      puts "F5, going back to #{state}"
    end    
        
    
    c= invoke_state(state)
    
    ### DISCUSS: here we should push the content into the page.
    #puts c
    
    c
  end
  
  
  def invoke_state(state=nil)
    last_state = thaw_last_state  ### DISCUSS: remove @last_state from to-thaw list?
    
    thaw if state.to_s =~ /^_/  ### DISCUSS: is this... good?

    unless start_state?(state)
      state = find_next_state_for(last_state, state) 
    end
    
    puts "#{name}: transition: #{last_state} to #{state}"
    puts "                                    ...#{state}"    
    
    
    ###@ self.last_state=(state)
    
    render_content_for_state(state)    
  end
  
  ### DISCUSS: #rename to render_widget_for_state?
    def render_content_for_state(state)
      @content        = []
      @cell_views     = {}
      @@current_cell  = self
      
      #content = render_state(state) # dispatch to the actual method, render view.
      content = ""
      
      while (state != content)
        state = catch(:state_jump) do
          content = render_state(state)
        end
      end
      
      frame_content(content)
    end
  
  
  # wrap the widget's current state content into a frame.
  def frame_content(content)
    '<div id="' + name.to_s + '">'+content+"</div>"
  end
    
    
  
  def last_state=(state)
    puts "last_state => #{state}"
    @last_state = state.to_sym
  end 
  
  
  def render_state(state)
      @cell = self
      state = state.to_s
      self.state_name = state
      self.last_state = state
      
      content = dispatch_state(state)

      #if content.class == String
      return content if content

      return render_view_for_state(state)
    end
  
  
  # Force the FSM to go into state "state", regardless whether it's a valid 
  # transition or not.
  def jump_to_state(state)
    puts "STATE JUMP! to #{state}"
    
    throw :state_jump, state
  end
  
  
  def dispatch_state(state)    
    #@last_state = state.to_sym
    
    
    content = execute_state(state)  # call the state.
    ### DISCUSS: maybe there's a state jump here.
    

    render_children
    
    freeze

    ###@ @@current_cell = self
    content
  end
  
  def execute_state(state)
    send(state)
  end
  
  def children_to_render
      children
    end
    
  def render_children
    children_to_render.each do |cell|
      #puts cell
      ### FIXME: call to state_name here SUCKS:
      child_state = decide_child_state_for(cell, state_name.to_sym)
      
      puts "    #{cell.name} -> #{child_state}"
      render_child(cell, child_state)
    end
  end
  
  def render_child(cell, state)
    view = cell.invoke(state)
    @content << view
    @cell_views[cell.name] = view
  end
  
  def decide_child_state_for(child, state)
    next_state = "_"
    next_state = "*" if @is_f5_fixme
    child_states.fetch(state, {})[child.name] || next_state
    ### DISCUSS: this changes the "child thawing policy" from thaw-by-default to start-over.
    #child_states.fetch(state, {})[child.name]
  end
  
  def child_states; {}; end
  
  def child_state_for(state, child_name)
  end
  
  
  # is only called when the whole page is reloaded (F5).
  def render_content
    #begin 
    invoke("*")
    #rescue
    #  p $!.message
    #  exit 
    #end
  end
  
  
  def render_view_for_state(state)
    state = @state_view if @state_view
    super(state)
  end
  
  def state_view(view_name)
    puts "setting state_view to #{view_name}"
    @state_view = view_name
    nil
  end
  
  
  
  ### addressing ----------------------------------------------------------------
  
  def address(way={}, target=self, state=nil)
    way.merge!( local_address(target, way, state) )
    
    return way if isRoot?
    
    return parent.address(way, target)
  end
  
  
  # Is called when this widget lies on the way to the target.
  # May be overridden, if this widget needs to set way information.
  # Must return a Hash.
  def local_address(target, way, state)
    {}
  end
  
  
  ### parameter accessing -------------------------------------------------------
  
  def set_child_param(child_name, param, value)
    @child_params[child_name] ||= {}
    @child_params[child_name][param] = value  ### needed for #param.
    
    return
    
    child = find_by_id(child_name)
    return unless child

    child.opts[param] = value
  end
  
  ### DISCUSS: move to Apotomo::Widget ?
  ### NOTE: @opts aren't frozen, so this really ensures we get explicitly*
  ### set options from the parent widget.
  ### * explicitly means here: set only for the next invocation.
  #attr_accessor :opts
  def param(name, cell=self)
    #puts "param? #{name}"
    #puts cell.name
    #puts @child_params
    #puts
    
    ###@ @child_params ||= {}  ### FIXME: move to constructor?
    #if @opts[name]
    #  puts "  ... is in @opts"
    #  return @opts[name]
    #elsif @child_params.fetch(cell.name){{}}[name]
    #  puts "  ... is in @child_params"
    #  return @child_params.fetch(cell.name){{}}[name]
    #else
    #  puts "  ... passing request to parent"
    #  return super(name, cell)
    #end
      
      # if widget is still frozen, get child params from last invocation:
    unless @last_state
      ### FIXME: this is called in root every time!
      #puts "frozen widget: #{name}"
      #puts self.name
    @child_params = thaw_child_params || {}
    end
    
    
    return @opts[name] || @child_params.fetch(cell.name){{}}[name] || @child_params.fetch(nil){{}}[name] || find_param(name, cell)
  end
  def find_param(name, cell=self)
      
      # local lookup, for currently traversed widget
      value = param_for(name, cell)
      return value if value
      ### FIXME: look in state_data of the currently traversed cell?
      
      
      if isRoot?
        return params[name]
      end
      
      return parent.param(name, cell)
    end
  
  
  # may be overridden.
  def param_for(name, cell)
  end
    
  
  
    def find_by_id(widget_id)
      return find {|node| node.name.to_s == widget_id.to_s}
    end
    
    def address_for_id(widget_id)
      widget = find_by_id(widget_id) or return nil
      widget.address
    end



    def self.current_widget
      @@current_cell
    end
end
