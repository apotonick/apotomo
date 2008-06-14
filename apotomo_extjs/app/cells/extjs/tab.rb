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
    end
    
    
    def render_constructor
      "#{config_js};"
    end
    
    
    def _load
      render_children
      puts "items:"
      #puts @cell_views.inspect
      
      content = []
      @cell_views.each do |cell_name, c|
        if c.kind_of? JavaScriptSource  ### FIXME: JavaScriptSource should be derived from the ActiveSupport::JSON thing.
          content << str2js(c)
        end
      end
            
      return render :json => content
      
      config_js ### FIXME: we don't need all of that method.
      puts @config[:items].inspect
      
      render :js => @config[:items]
      ### TODO: what about non-extjs :html content?
    end
  end
end
