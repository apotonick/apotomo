module Apotomo
  module ControllerHelper
    
    # Does the same as #act_as_widget, but without the controller's layout.
    def act_as_page(widget_id, model_tree_class = ::ApplicationWidgetTree)
      static = render_widget_from_model(widget_id, model_tree_class)
      render :text => static, :layout => false
    end
    
    
    # Renders the widget named <tt>widget_id</tt> from the ApplicationWidgetTree
    # into the controller action. Additionally activates event processing for this
    # widget and all its children.
    def act_as_widget(widget_id, model_tree_class = ::ApplicationWidgetTree)
      render :text => render_widget_from_model(widget_id, model_tree_class), 
        :layout => true
    end
    
    
    # Finds the widget named <tt>widget_id</tt> and renders it.
    def render_widget_from_model(widget_id, model_tree_class)
      tree = model_tree_class.new(self)
      #session['model_tree'] = Marshal.dump(model)
      #model = Marshal.load(session['model_tree'])
      
      root = tree.draw_tree
      return root.find_by_id(widget_id).render_content
    end
  end
end
