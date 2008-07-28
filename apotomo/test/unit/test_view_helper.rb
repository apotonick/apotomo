### TODO: implement!
require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ApotomoViewHelperTestCell < Apotomo::Widget
  helper Apotomo::ViewHelper
  
  def self.view_for_state(action_view, state)
    File.expand_path(File.dirname(__FILE__)) + "/../views/#{state}.haml"
  end
  
  
  def state_with_address_to_remote_widget
  end
end

class ViewHelperModelTree < Apotomo::WidgetTree
  def draw_model_tree(root)
    domain('param_domain', 'booze_id' => 1) << root
      #root << cell(:booze, :info, 'booze_info')
      #root << cell(:booze, :edit, 'booze_edit', :states => [:update])
      root << widget_factory.widget("apotomo_view_helper_test_cell", 'test_cell', :state_with_address_to_remote_widget)
  end
end

class ApplicationModelTree < ViewHelperModelTree; end;



class ViewHelperTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  include Apotomo::ViewHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  
  
  # extend StatefulWidget for testing purposes.
  Apotomo::StatefulWidget.class_eval do
    cattr_accessor :current_widget
  end
  
  
  def setup
    super
    
    @a = Apotomo::StatefulWidget.new(@controller, 'a')
    @b = Apotomo::StatefulWidget.new(@controller, 'b')
    @a << @b
  end
  
  # test Apotomo::ViewHelper methods --------------------------
  
  def test_current_tree
    Apotomo::StatefulWidget.current_widget = @a
    assert_equal current_tree, @a # --> #current_tree should return the root.
  end
  
  
  def test_target_widget_for
    Apotomo::StatefulWidget.current_widget = @a
    assert_equal target_widget_for(), @a
    assert_equal target_widget_for('b'), @b
  end
  
  
  def test_static_link_to_widget
    get :index
    Apotomo::StatefulWidget.current_widget = @a
    l = static_link_to_widget("Static Link", false, :static => true)
    puts l
    assert_no_match /static=/, l
  end
  
  def test_link_to_widget
    get :index
    Apotomo::StatefulWidget.current_widget = @b
    l = link_to_widget("Static Link")
    puts l
    assert_no_match /static=/, l
    assert_match /source=b/, l
  end
  
  def test_link_to_event
    get :index
    Apotomo::StatefulWidget.current_widget = @a
    
    # test explicit source ------------------------------------
    l = link_to_event("Event Link", :source => 'b')
    assert_match /source=b/, l
    assert_no_match /source=a/, l
    
    # test default source widget ------------------------------
    l = link_to_event("Event Link")
    assert_match /source=a/, l
    assert_no_match /source=b/, l
    # test implicit type --------------------------------------
    assert_no_match /type=/, l
    
    # test explicit type --------------------------------------
    l = link_to_event("Event Link", :type => :click)
    assert_match /type=click/, l
  end
  
  def dont_test_form_to_event
    get :index
    Apotomo::StatefulWidget.current_widget = @b
    
    # test default source -------------------------------------
    l = form_to_widget
    assert_match /source=b/, l
  end


  def test_address_to_event_for_widget
    Apotomo::StatefulWidget.current_widget = @a
    
    assert_equal Apotomo::StatefulWidget.current_widget, @a
    
    addr = address_to_event_for_widget()
    #puts addr.inspect
    assert addr[:source], 'a'
    
    addr = address_to_event_for_widget('b')
    assert addr[:source], 'b'
    
    addr = address_to_event_for_widget(false, :param_1 => 'one')
    assert addr[:source],  'a'
    assert addr[:param_1],    'one'
  end
  
  
  def test_address_to_event
    Apotomo::StatefulWidget.current_widget = @a
        
    addr = address_to_event()
    assert addr[:source], 'a'
    
    addr = address_to_event(:source => 'b')
    assert addr[:source], 'b'
    
    addr = address_to_event(:param_1 => 'one')
    assert addr[:source],  'a'
    assert addr[:param_1],    'one'
  end
  
end
