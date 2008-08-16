### (c) 2008, Nick Sutterer <nick@tesbo.com>
module Apotomo
  # The StatefulWidget is the core component in Apotomo. Any widget is derived from 
  # this class.
  # A Widget encapsulates a part of the GUI in <em>states</em>. A state has
  # a <em>state method</em> which keeps the logic, and a corresponding view that is 
  # rendered after the logic has been executed and the children of the widget have been
  # invoked.
  
  class StatefulWidget < Cell::Base
    attr_reader :last_state
    attr_accessor :opts ### DISCUSS: don't allow this, rather introduce #visible?.

    include TreeNode
    include Apotomo::EventAware   ### TODO: set a "see also" link in the docs.
    include Apotomo::Transitions

    helper Apotomo::ViewHelper


    # Constructor which needs a unique id for the widget and one or multiple start states.
    # <tt>start_state</tt> may be a symbol or an array of symbols.
    def initialize(controller, id, start_states=:widget_content, opts={})
      super(controller, id, opts)
      @cell_name    = @name  = id
      @start_states = start_states.kind_of?(Array) ? start_states : [start_states]

      @child_params = {}  ### DISCUSS: child params are deleted once per request right now. what if we are called twice and need a clean hash? do we need that?

      init_tree_node(id)
    end


    # Default start state for any widget. Do not overwrite this, better define a new
    # state method and set it as start state when creating the instance.
    def widget_content
    end

    
    # Freezes the widget's instance variables, so it can reconstruct the state in the
    # next request.
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
    
    #--
    ### DISCUSS: this is state_data:
    #--
    def thaw_child_params ### FIXME: is this good?
      return unless widget_session
      return widget_session['@child_params']
    end

    def widget_session
      session[name.to_s]
    end

    # Returns true if the widget is currently rendering itself or its children.
    def hot?
      @content
    end

    # Explicitly defines the valid state transistions for this widget.
    #
    # Example:
    #   def transition_map
    #     { :start_state_one  => [:some_state, :looping_state],
    #       :looping_state    => [:looping_state]
    #     }
    #   end
    #
    # This would create a state machine like
    #
    #
    #                        |---> :some_state
    #   :start_state_one --->|
    #                        |---> :looping_state ---
    #                                         ^     |
    #                                         |     |
    #                                         -------
    def transition_map; {}; end
    def transitions
      transition_map
    end

    #--
    # don't thaw when
    #   - parent explicitly invokes a start state
    #   - in F5 context (*)
    #   - in init context (*)
    # the is_f5_fixme flag is needed for context propagation when children are rendered.
    # this is a part i don't like.
    #--
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
      
      invoke_state(state)
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
    
    #--
    ### DISCUSS: #rename to render_widget_for_state?
    #--
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


    # Wrap the widget's current state content into a div frame.
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


    # Force the FSM to go into <tt>state</tt>, regardless whether it's a valid 
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

      child_state_for(child.name, state) || next_state
      ### DISCUSS: this changes the "child thawing policy" from thaw-by-default to start-over.
      #child_states.fetch(state, {})[child.name]
    end

    def child_states; {}; end

    def child_state_for(child_name, state)
      child_states.fetch(state, {})[child_name] || child_states.fetch(state, {})[nil]
    end


    # is only called when the whole page is reloaded (F5).
    def render_content
      invoke("*")
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
      unless hot?
        @child_params = thaw_child_params || {}
      end

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
      way.merge!( local_address(target, way, state) )

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
    
    
    def self.current_widget
      @@current_cell
    end
  end

end
