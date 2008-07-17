module Apotomo
  module ControllerHelper
    
    ### DISCUSS: where does this model-tree classname come from?
    def act_as_page(name, model_tree_class = ::ApplicationWidgetTree)
      static = render_widget_from_model(name, model_tree_class)
      render :text => static, :layout => false
    end
    
    
    ### NOTE: "act_as" because we do not only render but also provide 
    ### defined behaviour.
    def act_as_widget(name, model_tree_class = ::ApplicationWidgetTree)
      render :text => render_widget_from_model(name, model_tree_class), :layout => true
    end
    
    # not public:
    
    def render_widget_from_model(widget_id, model_tree_class)
      tree = model_tree_class.new(self)
      #session['model_tree'] = Marshal.dump(model)
      #model = Marshal.load(session['model_tree'])
      
      root = tree.draw_tree
      #return root.find_by_name(widget_id).content
      return root.find_by_id(widget_id).render_content
    end
  end
end
