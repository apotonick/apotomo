#(function(){ el = {title: 'First Tab!', html: 'static content', id: 'static_tab', items:
# {}, }; return el; })(),
 
 # plugins: [new Ext.ux.Plugin.RemoteComponent({url: '/gui_dev.php/widget/remoteLoader/_component/sample/_action/tabPanel/wid/panel', loadOn: 'show'}), ],
 
 module Extjs
  class Tab < Widget
    
    #def extjs_class; "Ext.TabPanel"; end
    def transition_map
      { :render_as_function => [:_load],
        :_load => [:_load]
      }
    end
    
    
    def init_config
      @config = {
        :id         => name,  ### TODO: generate auto-id.
        #:items => [],
        :plugins => [loader_js]
      }
    end
    
    
    def loader_js
      str2js("new Ext.ux.Plugin.RemoteComponent({
  url: '/apotomo/data?widget_id=#{name}&state=_load',
  loadOn: 'show'})")
    end
    
    
    
    
    # the Tab  widget never renders its children directly, they're retrieved 
    # on-demand via RemoteComponent currently.
    def render_children_content
      @last_invocation_state = "*" if @is_f5_fixme  ### FIXME! pass "*" as arg!!!
    end
    
    
    def render_constructor
      "#{config_js};"
    end
    
    
    def _load
      @is_f5_fixme = true if @last_invocation_state == "*"
      render_children
      @last_invocation_state = nil
      
      #puts "items:"
      #puts @cell_views.inspect
      
      content = []
      @cell_views.each do |cell_name, c|
        if c.kind_of? JavaScriptSource
          content << c
        end
        ### TODO: what about non-extjs :html content?
      end
            
      render :json => content
    end
  end
end
