module Extjs
  class Widget < Apotomo::JavaScriptWidget
    
    def extjs_class; "Ext.Window"; end


    def initialize(controller, id, start_states=:widget_content, opts={}, ext_opts={})
      super(controller, id, start_states, opts)

      init_config
      @config.merge!(ext_opts)
    end

    def init_config
      @config = {:title => "Apotomo rocks!"}
    end

    def render_as_function

      render_children_content
      
      #puts "childs:"
      #puts @cell_views.inspect

      render :js => "(function(){ el = #{render_constructor} #{append_to_constructor} return el; })()"
    end
    
    
    def render_children_content
      render_children
    end
    
    ### FIXME: do NOT overwrite this!
    def dispatch_state(state)    
      content = execute_state(state)  # call the state.
      ### DISCUSS: maybe there's a state jump here.
      
      #render_children
      
      freeze

      #@@current_cell = self
      content
    end
    
    def render_constructor
      "new #{extjs_class}(#{config_js});"
    end
    
    def append_to_constructor
    end
    
    def render_as_function_to
      ### FIXME: make it clean.
      render :js => render_as_function.to_s+'.render("desktop");'
    end

    def config_js
      @cell_views.each do |cell_name, c|
        if c.kind_of? JavaScriptSource
          @config[:items] ||= []
          @config[:items] << c
        else
          @config[:html] ||= ""
          @config[:html] += c
        end

      end


      @config.to_json
    end

    def config=(config)
      @config = config
    end
    
    def str2js(str)
      JavaScriptSource.new(str.to_s)
      #ActiveSupport::JSON::Variable.new(str.to_s)
    end

    # this method is never called in an Ext widget, since all output is generated before.
    ### DISCUSS: what do to with it?
    def render_view_for_state(state)
      constructor = super(state)
    end


    ### FIXME: move to StatefulWidget.
    def render(what, &block)
      if (what.keys.first == :json)  ### FIXME: what a mess!
        return what[:json].to_json


      elsif (what.keys.first == :js)  ### FIXME: what a mess!
        return JavaScriptSource.new(what[:js])
      end
    end
  end
end

