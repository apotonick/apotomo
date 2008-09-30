require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


### FIXME: how can we set @@current_cell from outside without destroying the world?
#Apotomo::StatefulWidget.class_eval do
#    def self.set_current_widget=(widget)
#      @@current_cell = widget
#    end
#  end
  
class ViewHelperTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  include Apotomo::ViewHelper
  #include ActionView::Helpers::PrototypeHelper
  #include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::TextHelper
  include ApplicationHelper
    
  
  def is_haml?; false; end  ### FIXME: this seems to be a problem with rails/haml.
  #def _erbout();end
  def protect_against_forgery?; false; end  ### needed in rails 2.1.
  
  # extend StatefulWidget for testing purposes.
  

  
  class CWidget < Apotomo::StatefulWidget
    def local_address(*args); {:c_address => :important}; end
  end
  
  
  def setup
    super
    
    @a = Apotomo::StatefulWidget.new(@controller, 'a')
    @b = Apotomo::StatefulWidget.new(@controller, 'b')
    @c = CWidget.new(@controller, 'c')
    @a << @b
    @a << @c
  end
  
  # test Apotomo::ViewHelper methods --------------------------
  
  def test_current_tree
    @a.invoke
    #Apotomo::StatefulWidget.set_current_widget=(@a)
    assert_equal @a, current_tree # --> #current_tree should return the root.
  end
  
  
  def test_target_widget_for
    @a.invoke
    #Apotomo::StatefulWidget.set_current_widget = @a
    assert_equal target_widget_for(), @a
    assert_equal target_widget_for('b'), @b
  end
  
  
  def test_static_link_to_widget
    get :index
    @a.invoke
    #Apotomo::StatefulWidget.set_current_widget = @a
    l = static_link_to_widget("Static Link", false, :static => true)
    puts l
    assert_no_match /static=/, l
  end
  
  def test_static_link_to_widget_with_controller
    get :index
    @a.invoke
    #Apotomo::StatefulWidget.set_current_widget = @a
    l = static_link_to_widget("Static Link", false, :controller => 'user')
    assert_match /\/user/, l
  end
  
  def test_link_to_widget
    get :index
    @c.invoke
    #Apotomo::StatefulWidget.set_current_widget = @c
    l = link_to_widget("Static Link")
    assert_no_match /static=/, l
    assert_match /c_address=important/, l
  end
  
  def test_link_to_event
    get :index
    @a.invoke
    #Apotomo::StatefulWidget.set_current_widget = @a
    
    # test explicit source ------------------------------------
    l = link_to_event("Event Link", :source => 'b')
    assert_match /source=b/, l
    assert_no_match /source=a/, l
    
    # test default source widget ------------------------------
    l = link_to_event("Event Link")
    assert_match /source=a/, l
    assert_no_match /source=b/, l
    # test implicit type --------------------------------------
    assert_match /type=a_/, l
    
    # test explicit type --------------------------------------
    l = link_to_event("Event Link", :type => :click)
    assert_match /type=click/, l
  end
  
  def test_form_to_event
    get :index
    @b.invoke
    #Apotomo::StatefulWidget.set_current_widget = @b
    
    # test default source -------------------------------------
    l = form_to_event
    puts l
    
    assert_match /source=b/, l
    assert_match /<form/, l
    assert_no_match /<\/form>/, l
    
    return
    ### FIXME: could someone make this test work?
    # test with block -----------------------------------------
    l = form_to_event do
    end
    puts l    
    assert_match /<form/, l
    assert_match /<\/form>/, l
  end


  def test_address_to_event_for_widget
    #Apotomo::StatefulWidget.set_current_widget = @a
    @a.invoke
    
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
    @a.invoke
    #Apotomo::StatefulWidget.set_current_widget = @a
        
    addr = address_to_event()
    assert addr[:source], 'a'
    
    addr = address_to_event(:source => 'b')
    assert addr[:source], 'b'
    
    addr = address_to_event(:param_1 => 'one')
    assert addr[:source],  'a'
    assert addr[:param_1],    'one'
  end
  
  
  def test_address_to_event_with_implicit_invoke_handler
  
  end
end
