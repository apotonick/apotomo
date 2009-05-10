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
  
  # Creates the test root widget and sets it in @controller.apotomo_root for you, ensuring
  # a blank ApplicationWidgetTree is mixed into your test tree.
  ### DISCUSS: move to test_helper?
  def init_apotomo_root_mock!
    # create a blank tree:
    ApplicationWidgetTree.class_eval do
      def draw(root)
      end
    end
    r = apotomo_root_mock
    @controller.instance_eval do
      @apotomo_root = r
    end
  end
  
  def test_custom_apotomo_accessors
    @controller = WidgetController.new
    # default behaviour: -------------------------------------
    assert_equal Hash.new,  @controller.apotomo_default_url_options
  end
  
  def test_use_widgets
    r = init_apotomo_root_mock!
    
    assert ! r.find_by_id('my_grid')
    @controller.use_widget cell(:rendering_test, :widget_content, 'my_grid')
    @controller.use_widget cell(:rendering_test, :widget_content, 'my_grid')
    
    assert r.find_by_id('my_grid')
    # test if there really is only one child added:
    assert_equal 1, r.children.collect{ |w| w.name == 'my_grid' }.size
  end
  
  def test_respond_to_event
    r = init_apotomo_root_mock!
    
    assert_equal 0, r.evt_table.size
    
    @controller.respond_to_event :click, :with => :method
    assert_equal 1, r.evt_table.size
    
    # assert that a subsequent call to #respond_to_event does not attach a second handler.
    # since the same #respond_to_event is called multiple times in different requests, this
    # prevents copying the handler over and over.
    @controller.respond_to_event :click, :with => :method
    assert_equal 1, r.evt_table.size
  end

  def test_apotomo_root
    ApplicationWidgetTree.class_eval do
      include Apotomo::WidgetShortcuts
      def draw(root)
        root << widget('apotomo/stateful_widget', :widget_content, 'widget_in_app_tree')
      end
    end
    r = @controller.apotomo_root  # starts the tree creation.
    
    # test if initial ApplicationWidgetTree is included: -----
    assert r.find_by_id('widget_in_app_tree')
  end
  
  def test_act_as_widget; end # is :controller/:action really current controller/action when using link_to_event? same for #render_widget :process_events => true.
  
end

### DISCUSS: explicitly copy @controller to view during #invoke, or set controller at widget instantiation time? problem: what controller to connect in controller class context (e.g. in has_widgets)?

### DISCUSS: what happens if we would store the WidgetTree in a controller meta class instance variable? would it be automatically persistent (and available in all threads? hell no- we wouldn't want that!)
###   why WidgetTree as singleton? -> access it in has_widgets, use_widget, respond_to_event controller methods.