require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class WidgetController < ActionController::Base
  include Apotomo::ControllerMethods
  
  def self.yui_grid(args);end
  def yui_grid(args);end
  
  # define ----------------------------------------------------
  # execute once:
  has_widgets do |root|
    #root << cell(:rendering_test, :check_state, '1')
    root << yui_grid('grid', :fill_with => :fill_grid)
    
    # we cannot define listeners here since there's no controller instance for the callback.
  end
  
  has_widgets yui_grid('grid')
  
  # listen ----------------------------------------------------
  # execute every request, since we need callbacks:  responds_to_event :click, :from => 'grid', :with => :grid_click  # controller instance method, can't render
  
  responds_to_event :click, :from => 'grid', :with => (lambda { |evt| process_click })
  
  
  def index
    # do something
    
    @v1 = render_widget('grid')
    
    # initialize ----------------------------------------------
    # render --------------------------------------------------
    @v1 = render_widget('grid') do |grid|
      grid.opts = [] if grid.new?   # initialize widget with decider?
    end
    
    # configure grid via opts={}:
    @v1 = render_widget('grid', :rows => [:col_one, :col_two])
    
    
    # render
  end
  
  def process_events
    
  end
  
  def grid_click(evt)
  
  end
  
end

class RemoveAApplicationWidgetTree < Apotomo::WidgetTree
  def draw(root)
    root << cell(:rendering_test, :widget_content, 'my_widget')
  end
  
  
end

class ControllerMethodsTest < ActionController::TestCase
  include Apotomo::UnitTestCase
  ### TODO: move to SessionTest:
  #def test_a
  #  # create an empty tree:
  #  Apotomo::WidgetTree.class_eval do
  #    def draw(root)
  #    end
  #  end
  #  t = Apotomo::WidgetTree.new.reconnect(@controller).init!
  #  t.include_application_widget_tree!
  #  r = t.root
  #  
  #  
  #  @controller.apotomo_root = r
  #  r.find_by_id('todo_section').render_content
  #  n = r.find_by_id('todo_new')
  #  r.find_by_id('todo_new').invoke_for_event(Apotomo::Event.new(:newItem, n))
  #  
  #  hibernate_tree(r)
  #  #Marshal.load(Marshal.dump(r))                                
  #end  
    
    
    
  def test_custom_apotomo_accessors
    @controller = WidgetController.new
    # default behaviour: -------------------------------------
    assert_equal Hash.new,  @controller.apotomo_default_url_options
  end
  
  def test_use_widgets
    # create an empty tree:
    Apotomo::WidgetTree.class_eval do
      def draw(root)
      end
    end
    r = Apotomo::WidgetTree.new.reconnect(@controller).init!.root
    @controller.apotomo_root = r
    
    
    assert ! r.find_by_id('my_grid')
    @controller.use_widget cell(:rendering_test, :widget_content, 'my_grid')
    @controller.use_widget cell(:rendering_test, :widget_content, 'my_grid')
    
    assert r.find_by_id('my_grid')
    # test if there really is only one child added:
    assert_equal 1, r.children.collect{ |w| w.name == 'my_grid' }.size
  end
  
  def test_apotomo_root
    # create an empty tree:
    Apotomo::WidgetTree.class_eval do
      def draw(root); end
    end
    ::ApplicationWidgetTree.class_eval do
      def draw(root)
        root << widget('apotomo/stateful_widget', :widget_content, 'widget_in_app_tree')
      end
    end
    r = @controller.apotomo_root
    
    # test if initial ApplicationWidgetTree is included: -----
    assert r.find_by_id('widget_in_app_tree')
  end
  
  def test_act_as_widget; end # is :controller/:action really current controller/action when using link_to_event? same for #render_widget :process_events => true.
  
end

### DISCUSS: explicitly copy @controller to view during #invoke, or set controller at widget instantiation time? problem: what controller to connect in controller class context (e.g. in has_widgets)?

### DISCUSS: what happens if we would store the WidgetTree in a controller meta class instance variable? would it be automatically persistent (and available in all threads? hell no- we wouldn't want that!)
###   why WidgetTree as singleton? -> access it in has_widgets, use_widget, respond_to_event controller methods.