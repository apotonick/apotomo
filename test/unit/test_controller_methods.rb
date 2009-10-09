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
  
  def teardown
    WidgetController.instance_eval do @has_widgets_blocks = [] end
  end
  
  # Creates the test root widget and sets it in @controller.apotomo_root for you.
  ### DISCUSS: move to test_helper?
  def init_apotomo_root_mock!
    r = apotomo_root_mock
    r.root.controller = @controller
    @controller.instance_eval do
      @apotomo_root = r
    end
  end
  
  def test_custom_apotomo_accessors
    @controller = WidgetController.new
    # default behaviour: -------------------------------------
    assert_equal Hash.new,  @controller.apotomo_default_url_options
  end
  
  
  
  # test has_widgets -----------------------------------------------------------
  
  def test_has_widgets_blocks_accessors
    controller = Class.new(ActionController::Base)
    controller.instance_eval{ include Apotomo::ControllerMethods }
    
    # as none of the controllers calls #has_widgets we have a virgin blocks array:
    assert_equal Array.new, controller.has_widgets_blocks
    
    
    controller  = Class.new(ActionController::Base)
    controller.instance_eval{ include Apotomo::ControllerMethods; has_widgets; }
    
    child       = Class.new(controller)
    child.instance_eval{ include Apotomo::ControllerMethods
      has_widgets; 
      has_widgets;}
    
    assert_equal 3, child.has_widgets_blocks.size
  end
  
  def test_has_widgets
    controller_class = Class.new(ActionController::Base)
    
    # first call to #has_widgets:
    controller_class.instance_eval{
      include Apotomo::ControllerMethods
      has_widgets do |root|
        root << cell(:rendering_test, :widget_content, 'my_grid')
      end
    }
    assert_equal 1, controller_class.has_widgets_blocks.size
    assert_kind_of Proc, controller_class.has_widgets_blocks.first
    
    # and the second call in the same class:
    controller_class.instance_eval{
      has_widgets do |root|
        root << cell(:rendering_test, :widget_content, 'my_grid')
      end
    }
    
    assert_equal 2, controller_class.has_widgets_blocks.size
  end
  
  
  def test_collect_unbound_has_widgets_blocks
    controller = Class.new(ActionController::Base)
    controller.instance_eval{ include Apotomo::ControllerMethods }
    
    assert_equal [], controller.new.collect_unbound_has_widgets_blocks
    
    
    # one block:
    controller = Class.new(ActionController::Base)
    controller.instance_eval{ include Apotomo::ControllerMethods
      has_widgets{} }
    
    controller = controller.new
    controller.session = {}
    
    procs = controller.collect_unbound_has_widgets_blocks
    assert_equal 1, procs.size
    assert_kind_of Proc, procs.first
    
    
    # all blocks already bound:
    p = Apotomo::ControllerMethods::ProcHash.new
    p << procs.first
    controller.session = {:apotomo_bound_procs => p}
    assert_equal [], controller.collect_unbound_has_widgets_blocks
  end
  
  
  def test_add_unbound_procs_to
    # no block:
    controller_class = Class.new(ActionController::Base)
    controller_class.instance_eval{ include Apotomo::ControllerMethods }
    controller  = controller_class.new
    root        = widget('apotomo/stateful_widget', :widget_content, '__root__')
    
    controller.session = {}
    controller.add_unbound_procs_to(root)
    
    assert_equal [],  controller.bound_procs
    assert_equal 0,   root.children.size
    
    # one block:
    controller_class = Class.new(ActionController::Base)
    controller_class.instance_eval{ 
      include Apotomo::ControllerMethods
      
      has_widgets do |root|
        root << widget('apotomo/stateful_widget', :widget_content, '__child__')
      end
    }
    controller = controller_class.new
    
    controller.session = {}
    controller.add_unbound_procs_to(root)
    
    assert_equal 1,   controller.bound_procs.size
    assert_equal 1,   root.children.size
    
    # try it again, nothing should happen anymore:
    controller.add_unbound_procs_to(root)
    
    assert_equal 1,   controller.bound_procs.size
    assert_equal 1,   root.children.size
  end
  
  def test_proc_hash
    p = Apotomo::ControllerMethods::ProcHash.new
    assert_equal 0, p.size
    
    b = Proc.new{}; d = Proc.new{}
    c = Proc.new{}
    
    p << b
    assert p.include?(b)
    assert p.include?(d)  ### DISCUSS: line no is id, or YOU got a better idea?!
    assert ! p.include?(c)
  end
  
  
  def test_has_widgets_inheritance_on_first_level
    # application controller defines:
    a_class = Class.new(ActionController::Base)
    a_class.instance_eval { 
      include Apotomo::ControllerMethods
      
      has_widgets do |root|
        root << widget('apotomo/stateful_widget', :widget_content, 'a')
      end
    }
    
    # derived controller doesn't define:
    b = Class.new(a_class).new
    
    b.session = {}
    b.params  = {}
    root      = b.apotomo_root
    puts root.printTree
    assert_equal 1,   root.children.size
    assert_equal "a", root.children.first.name
  end
  
  
  def test_has_widgets_inheritance_on_both_levels
    # application controller defines:
    a_class = Class.new(ActionController::Base)
    a_class.instance_eval { 
      include Apotomo::ControllerMethods
      
      has_widgets do |root|
        root << widget('apotomo/stateful_widget', :widget_content, 'a')
      end
    }
    
    # derived controller defines as well:
    b_class = Class.new(a_class)
    b_class.instance_eval {
      has_widgets do |root|
        root.find_by_id('a') << widget('apotomo/stateful_widget', :widget_content, 'b')
      end
    }
    b = b_class.new
    
    b.session = {}
    b.params  = {}
    root      = b.apotomo_root
    
    assert_equal 1,   root.children.size
    a = root.children.first
    assert_equal "a", a.name
    assert_equal 1,   a.children.size
    assert_equal "b", a.children.first.name
  end
  
  
  def test_use_widget
    r = init_apotomo_root_mock!
    
    assert ! r.find_by_id('my_grid')
    @controller.use_widget cell(:rendering_test, :widget_content, 'my_grid')
    @controller.use_widget cell(:rendering_test, :widget_content, 'my_grid')
    
    assert r.find_by_id('my_grid')
    # test if there really is only one child added:
    assert_equal 1, r.children.collect{ |w| w.name == 'my_grid' }.size
  end
  
  
  def test_use_widgets
    a_class = Class.new(ActionController::Base)
    a_class.instance_eval { 
      include Apotomo::ControllerMethods
    }
    a = a_class.new
    a.session = {}
    a.params  = {}
    
    # call to #use_widgets:
    a.instance_eval {
      use_widgets do |root|
        root << cell(:rendering_test, :widget_content, 'a')
      end
    }
    
    root = a.apotomo_root
    
    assert_equal 1,   root.children.size
    assert_equal "a", root.children.first.name
  end
  
  def test_use_widgets_with_subsequent_calls
    a_class = Class.new(ActionController::Base)
    a_class.instance_eval { 
      include Apotomo::ControllerMethods
    }
    a = a_class.new
    a.session = {}
    a.params  = {}
    
    (1..2).each do
      a.instance_eval {
        use_widgets do |root|
          root << cell(:rendering_test, :widget_content, 'a')
        end
      }
    end
    
    root = a.apotomo_root
    # assure 'a' got added only once:
    assert_equal 1,   root.children.size
    assert_equal "a", root.children.first.name
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
  
  
  def test_apotomo_root_with_root_only
    r = @controller.apotomo_root  # empty tree.
    puts r.printTree
    assert_equal 0, r.children.size
  end
  
  
  def test_apotomo_root_with_children
    @controller.instance_eval {
      use_widgets do |root|
        root << widget('apotomo/stateful_widget', :widget_content, 'widget_in_app_tree')
      end
    }
    r = @controller.apotomo_root  # starts the tree creation.
    
    assert_equal 1, r.children.size
    assert r.find_by_id('widget_in_app_tree')
  end
  
  def test_act_as_widget; end # is :controller/:action really current controller/action when using link_to_event? same for #render_widget :process_events => true.
  
  
  # render_widget --------------------------------------------------------------
  def test_render_widget_with_id
    r = init_apotomo_root_mock!
    r << cell(:rendering_test, :widget_content, 'wigald')
    c = @controller.render_widget('wigald')
    
    assert_selekt c, "#wigald"
  end
  
  def test_render_widget_with_object
    r = init_apotomo_root_mock!
    w = cell(:rendering_test, :widget_content, 'wigald')
    w.controller = @controller
    c = @controller.render_widget(w)
    
    assert ! r.find_by_id(w.name)
    assert_selekt c, "#wigald"
  end
  
  
  def test_executable_javascript?
    assert !  @controller.executable_javascript?("output from widget")
    assert    @controller.executable_javascript?(Apotomo::JavascriptSource.new)
  end
  
end

# render_widget w, :user => user do..end
# is passed to w (only!)

### DISCUSS: explicitly copy @controller to view during #invoke, or set controller at widget instantiation time? problem: what controller to connect in controller class context (e.g. in has_widgets)?