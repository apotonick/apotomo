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

class ControllerMethodsTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_custom_apotomo_accessors
    @controller = WidgetController.new
    # default behaviour: -------------------------------------
    assert_equal Hash.new,  @controller.apotomo_default_url_options
  end
  
  def test_has_widgets
    def params; {}; end ### FIXME: refactor #widget_tree to not access param.
    assert ! widget_tree.root.find_by_id('my_grid')
    #@controller.class.has_widgets(cell(:rendering_test, :widget_content, 'my_grid'))
    @controller.use_widgets cell(:rendering_test, :widget_content, 'my_grid')
    assert widget_tree.root.find_by_id('my_grid')
  end
  
  def test_act_as_widget; end # is :controller/:action really current controller/action when using link_to_event? same for #render_widget :process_events => true.
  
end
