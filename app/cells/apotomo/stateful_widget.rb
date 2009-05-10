### (c) 2008-2009, Nick Sutterer <nick@tesbo.com>
module Apotomo
  # The StatefulWidget is the core component in Apotomo. Any widget is derived from 
  # this class.
  #
  # === Widgets are mini-controllers
  # Widgets are derived cells[http://cells.rubyforge.org/rdoc], meaning they basically
  # look and behave like super-fast mini-controllers known from Rails. State actions in 
  # a widget are like controller actions - they implement the business logic in a method
  # and can render a corresponding view.
  # Instance variables from the widget are passed to the state view, which is
  # automatically found by convention: view filename and state method usually have the
  # same name. If you need another view, instruct the widget by calling #state_view.
  # 
  # You can plug multiple of these "mini-controllers" into a page, and you can even make
  # one widget contain others. The modeling currently happens in the WidgetTree.
  #
  # === Widgets are state machines
  # States can be connected to model a workflow. For example, a form widget could have
  # one state for diplaying an empty form, one state showing the filled-out form 
  # with messages at invalid fields, and one state showing a success message after the
  # form had valid input.
  # 
  # To send a widget - from outside - into a certain state, you usually #invoke a
  # state. Initial start states are defined in #new. Valid transitions are defined in
  # #transition_map and you can jump to an arbitrary state by calling #jump_to_state
  # inside a state method.
  #
  # When a widget changes its state, it automatically updates the respective part in the
  # page.
  # 
  # === Widgets are stateful
  # After a state transition a widget restores the last environment it was in. So you
  # have all the instance variables back that have been there when the state method
  # finished. You no longer are aware of requests, rather think in a persistent
  # environment.
  # 
  # === Widgets are event-driven
  # Unlike in traditional rails, widgets are not updated by requests 
  # directly, but by events. Events usually get triggered by form submits using 
  # ViewHelper#form_to_event, by clicking links or by real GUI events (as a 
  # <tt>onChange</tt> event in Javascript which you map to an Apotomo event with 
  # ViewHelper#address_to_event).
  # 
  # Widgets can also fire events internally using EventAware#trigger.
  # Listeners that handle an event are attached with EventAware#watch.
  
  # The brain
  # collects ivars set during state execution(s), even in successive state jumps.
  # brain content is exposed to view and unset when hitting a start state.
  # If you want to set an everlasting ivar which survives a start state, set it before
  # #render_content_for_state, best place is the constructor.
  
  class StatefulWidget < Cell::Base
    attr_accessor :opts ### DISCUSS: don't allow this, rather introduce #visible?.
    
    attr_reader :last_state
    
    include TreeNode
    include EventAware   ### TODO: set a "see also" link in the docs.
    include Transitions
    include Caching
    
    
    helper Apotomo::ViewHelper
    
attr_writer :controller
    # Constructor which needs a unique id for the widget and one or multiple start states.
    # <tt>start_state</tt> may be a symbol or an array of symbols.
    attr_reader :last_brain
    def initialize(controller, id, start_states=:widget_content, opts={})
      super(controller, opts)
      @name         = id
      @start_states = start_states.kind_of?(Array) ? start_states : [start_states]

      @child_params = {}
      @visible      = true
      @version      = 0
      @last_state   = nil
      @ivars_before = nil
      @invoke_block = nil
            
      reset_rendering_ivars!    ### DISCUSS: called twice, see #render_content_for_state.
      
      @brain        = []        # ivars set during state execution(s).
      
      init_tree_node(id)
    end


    # Default start state for any widget. Do not overwrite this, better define a new
    # state method and set it as start state when creating the instance.
    def widget_content
    end


    # Defines the instance vars that should <em>not</em> survive between requests, 
    # which means they're not frozen in Apotomo::StatefulWidget#freeze.
    def ivars_to_forget
      unfreezeable_ivars
    end
    
    def unfreezeable_ivars
      ['@childrenHash', '@children', '@parent', '@controller', '@cell', '@invoke_block', '@ivars_before', '@rendered_children']
    end

    # Defines the instance vars which should <em>not</em> be copied to the view.
    # Called in Cell::Base.
    def ivars_to_ignore
      (instance_variables - ivars_to_expose)
    end
    
    # Defines the ivars which should be copied to and accessable in the view.
    def ivars_to_expose
      @brain + ['@rendered_children']
    end

    
    ### DISCUSS: @state_view and @ivars_before are both flags i'd like to get rid of.
    def reset_rendering_ivars!
      @state_view         = nil
      ### TODO: implementation decision, move outside!
      @rendered_children  = ActiveSupport::OrderedHash.new
    end

    #--
    # don't thaw when
    #   - parent explicitly invokes a start state
    #   - in F5 context (*)
    #   - in init context (*)
    # the is_f5_fixme flag is needed for context propagation when children are rendered.
    # this is a part i don't like.
    #--
    # Central entry point for starting the FSM and recursively executing the respective
    # state method and rendering its view. The invoke'd widget will call #invoke
    # for each visible child, per default.
    # See #invoke_state.
    
    ### DISCUSS: state is input in FSM speech, or event.
    def invoke(input=nil, &block)
      @invoke_block = block ### DISCUSS: store block so we don't have to pass it 10 times?
      puts "\ninvoke on #{name} with #{input.inspect}"

      if input.to_s == "*"
        @is_f5_fixme = true
        input= start_state_for_state(last_state)
        puts "F5, going back to #{input}"
      end
      
      process_input(input)
    end

    # Initiates the rendering cycle of the widget:
    # - if <tt>state</tt> isn't a start state, the environment of the widget is restored
    #   using #thaw.
    # - find the next valid state (usually this should be the passed <tt>state</tt>).
    # - executes the respective state method for <tt>state</tt> 
    #   (per default also named <tt>state</tt>)
    # - invoke the children
    # - render the view for the state (per default named after the state method)
    def process_input(input)
      state = input
      unless start_state?(input)
        state = find_next_state_for(last_state, input)
      end 
      
      
      
      invoke_state(state)
    end
    
    # Returns the rendered content for the widget by running the state method for <tt>state</tt>.
    # This might lead us to some other state since the state method could call #jump_to_state.
    def invoke_state(state)
      puts "#{name}: transition: #{last_state} to #{state}"
      puts "                                    ...#{state}"
      
      ### DISCUSS: at this point, we finally know the concrete next state.
      ### this is the next state we go to, all prior references to state where input.
      ### #render_state really means what it does: we processed the input symbol, checked the condition and now go to the new state (which produces output).
      
      flush_brain if start_state?(state)
      @ivars_before = instance_variables
      
      run(state)
    end
    
    # This freaky method is dedicated to Lance Ivy.
    def run(state)
      while true
        state = catch(:state_jump) do
          content = render_state(state)  # calls Cell::render_state, which is caching-aware.
          
          @last_state = state
          return content
        end
      end
    end
    
    # either jump out due to a state_jump, or return the complete widget content,
    # including rendered children.
    # called in Cell::Base#render_state
    def dispatch_state(state)
      reset_rendering_ivars!
      content = send(state, &@invoke_block)  # maybe there's a state jump in here and we're out.
      
      
      puts @brain.inspect
      puts "state ivars:"  
      @brain |= (instance_variables - @ivars_before)
      puts @brain.inspect
      
      
      
      # instantly return content, without further view rendering or framing:
      return content if content.kind_of? String
      
      
      render_children_for_state(state)
      
      
      state = @state_view if @state_view 
      ### FIXME: we need to expose @controller here for several helper method. that sucks!
      @controller =root.controller
      
      
      content = render_view_for_state(state)  # defined in Cell::Base.
      
      frame_content(content)
    end
    

    # Wrap the widget's current state content into a div frame.
    def frame_content(content)
      '<div id="' + name.to_s + '">'+content+"</div>"
    end
    

    # Force the FSM to go into <tt>state</tt>, regardless whether it's a valid 
    # transition or not.
    def jump_to_state(state)
      puts "STATE JUMP! to #{state}"

      throw :state_jump, state
    end
    
    
    def children_to_render
      children.find_all do |w|
        w.visible?
      end
    end

    def render_children_for_state(state)
      children_to_render.each do |cell|
        child_state = decide_child_state_for(cell, state.to_sym)

        puts "    #{cell.name} -> #{child_state}"
        render_child(cell, child_state)
      end
    end

    def render_child(cell, state)
      view = cell.invoke(state)
      @rendered_children[cell.name] = view
    end

    def decide_child_state_for(child, state)
      next_state = "_"
      next_state = "*" if @is_f5_fixme

      child_state_for(child.name, state) || next_state
      ### DISCUSS: this changes the "child thawing policy" from thaw-by-default to start-over.
      #child_states.fetch(state, {})[child.name]
    end

    def child_states; {}; end

    def child_state_for(child_name, state)
      child_states.fetch(state, {})[child_name] || child_states.fetch(state, {})[nil]
    end


    # is only called when the whole page is reloaded (F5).
    def render_content &block
      invoke("*", &block)
    end


    
    
    def state_view(view_name)
      ### TODO: deprecate
      state_view!(view_name)
    end
    def state_view!(view_name)
      puts "setting state_view to #{view_name}"
      @state_view = view_name
      nil
    end
    
    #--
    ### parameter accessing -------------------------------------------------------
    
    
    ### DISCUSS: do we really need specific params for specific childs? isn't one
    ### local param enough?
    #--
    def set_child_param(child_name, param, value)
      @child_params[child_name] ||= {}
      @child_params[child_name][param] = value  ### needed for #param.
    end

    # sets a persisting param value for _any_ child widget.
    def set_local_param(param, value)
      set_child_param(nil, param, value)
    end

    # Retrieve the param value for child. This parameter has to be explicitly set 
    # with #set_child_param prior to this call.
    def child_param(child_name, param)
      @child_params[child_name][param] if @child_params.has_key?(child_name)
    end

    def local_param(param)
      child_param(nil, param)
    end

    ### NOTE: @opts aren't frozen, so this really ensures we get explicitly*
    ### set options from the parent widget.
    ### * explicitly means here: set only for the next invocation.
    def param(name, cell=self)
      # if called outside #invoke, get child params from last invocation:
      
      ###@ unless hot?
      ###@   @child_params = thaw_child_params || {}
      ###@ end

      ### opts -> param_for (in both frozen/thawed) -> child_params -> parent?
      return @opts[name] || param_for(name, cell) || child_param(cell.name, name) || local_param(name) || find_param(name, cell)
    end

    def find_param(name, cell=self)
      if isRoot?
        return params[name]
      end

      parent.param(name, cell)
    end


    # Override this to provide your own parameter value.
    # If you want to be sure the param-retrieving stops here, always return something 
    # that does NOT evaluate to false, otherwise the pvf will travel further up.
    # You have to find out yourself if you want to return a remembered value or look it up
    # in the request.
    def param_for(name, cell)
    end

    #--
    ### addressing/utilities ------------------------------------------------------
    #--
    
    # This is called when a bookmarkable link is calculated. Every widget on the path
    # from the targeted to root can insert state recovery information in the address
    # by overriding #local_address.
    def address(way={}, target=self, state=nil)
    #def address(way=HashWithIndifferentAccess.new, target=self, state=nil)
      way.merge!( local_address(target, way, state) )
      
      #puts "address: #{name}"
      #puts way.inspect

      return way if isRoot?

      return parent.address(way, target)
    end

      
    # Override this if the widget needs to set state recovery information for a 
    # bookmarkable link.
    # Must return a Hash with the local state recovery information.
    def local_address(target, way, state)
      {}
    end

    def find_by_id(widget_id)
      return find {|node| node.name.to_s == widget_id.to_s}
    end
    
    
    
    
    
    def controller
      @controller || root.controller
    end
    
    # Sets the widget to invisible, which will usually suppress executing the 
    # state method and rendering. Apparently the same applies to all children 
    # of this widget.
    def invisible!; @visible = false; end
    # Sets the widget to visible (default).
    def visible!;   @visible = true; end
    # Returns if visible.
    def visible?;   @visible; end
    
    
    def createDumpRep
      strRep = String.new
      strRep << @name.to_s << @@fieldSep << self.class.to_s << @@fieldSep << (isRoot? ? @name.to_s : @parent.name.to_s)
      
      ###@ strRep << @@fieldSep << dump_instance_variables << @@recordSep
      strRep << @@recordSep
    end
  
  #--
  ### DISCUSS: taking the path as key slightly blows up the session.
  #--
  def freeze_instance_vars_to_storage(storage)
    #puts "freezing in #{path}"
    storage[path] = {}  ### DISCUSS: check if we overwrite stuff?
    (self.instance_variables - ivars_to_forget).each do |var|
      storage[path][var] = instance_variable_get(var)
      #puts "  #{var}: #{storage[path][var]}"
    end
    
    children.each { |ch| ch.freeze_instance_vars_to_storage(storage) }
  end
  def thaw_instance_vars_from_storage(storage)
    #puts "thawing in #{path}"
    storage[path].each do |k, v|
      instance_variable_set(k, v)
      #puts "  set #{k}: #{v}"
    end
    
    children.each { |ch| ch.thaw_instance_vars_from_storage(storage) }
  end
  
  
  def flush_brain
    @brain.each do |var|
      remove_instance_variable(var)
    end
    @brain.clear
  end

  def _dump(depth)
      strRep = String.new
      each {|node| strRep << node.createDumpRep}
      strRep
  end
  
    def self._load(str)
      ### TODO: fix multiple loading issue.
      #@@load_count ||= 0
      #@@load_count+=1
      #raise "too much loading" if @@load_count > 1
      
      loadDumpRep(str)
    end
    def self.loadDumpRep(str)
      nodeHash = Hash.new
      rootNode = nil
      str.split(@@recordSep).each do |line|
        
          ###@ name, klass, parent, content_str = line.split(@@fieldSep)
          name, klass, parent = line.split(@@fieldSep)
          #puts "thawing #{name}->#{parent}"
          currentNode = klass.constantize.new(nil, name)
          
          ###@ Marshal.load(content_str).each do |k,v|
          ###@   ###@ puts "setting "+k.inspect
          ###@   currentNode.instance_variable_set(k, v)
          ###@ end
          
          nodeHash[name] = currentNode
          if name != parent  # Do for a child node
              nodeHash[parent].add(currentNode)
          else
              rootNode = currentNode
          end
      end
      rootNode
  end
  end

end
