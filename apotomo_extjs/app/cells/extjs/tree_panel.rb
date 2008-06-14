module Extjs
  class TreePanel < Panel
    
    def extjs_class; "Ext.tree.TreePanel"; end
    
    def init_config
      @config = {
        :loader     => loader_js,
        :listeners  => listener_js,
        :id         => name,
      }
    end
    
    
    def transition_map
      { :render_as_function => [:load],
        :load => [:load]
      }
    end
    
    
    ### TODO: replace hardcoded controller/action urls.
    ### FIXME: these javascript generators are NOT ugly! ;-)
    def listener_js
      str2js("{click: function(node, e) {Ext.Ajax.request({
 url: '/apotomo/event?source=#{name}&type=click',
 params: {node_id: node.id},
 method: 'POST',
 success: function ( result, request ) {eval(result.responseText); },
} ) }}")
    end
    
    def loader_js
    str2js("new Ext.tree.TreeLoader({dataUrl: '/apotomo/data?widget_id=#{name}&state=load'})")
    end
    
    def append_to_constructor
      return unless store
      str2js("var root = new Ext.tree.AsyncTreeNode(#{store.root_item.to_json});
el.setRootNode(root);
root.expand();")
    end
    
  
    # state method called whenever the TreePanel needs to load data.
    # returns a JSON-encoded item list for the requested node.
    def load
      node_id = param(:node)
      render :json => store.items_for_node_id(node_id)
    end

    def set_store(store)
      @store = store
    end

    # called by #load to retrieve the internal data structure for the tree.
    def store
      @store || param(:store)
    end
  
  end
end
