require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


# fixture:
class MyTestCell < Apotomo::StatefulWidget
  def a_state
    "a_state"
  end
end

class TestWidgetTree < Apotomo::WidgetTree  
  def draw(root)
    root << tab_panel = Apotomo::TabPanelWidget.new(@controller, 'my_tab_panel', :switch)
      tab_panel << Apotomo::TabWidget.new(@controller, 'tab_one', :widget_content, 
        :title => "Tab One")
  end
end


class SwitchTestWidgetTree < Apotomo::WidgetTree  
  def draw(root)
    root << first = Apotomo::ChildSwitchWidget.new(@controller, 'first_switch', :switch)
      first << second = Apotomo::ChildSwitchWidget.new(@controller, 'second_switch', :switch)
       second << cell(:my_test, :a_state, 'first_child')
       second << cell(:my_test, :a_state, 'second_child')
  end
end



class TabPanelTest < ActionController::TestCase
  include Apotomo::UnitTestCase
  
  def test_tab_panel
    p = tab_panel('my_tab_panel')
      p << tab("First")
      p << tab("Second")
      p << tab("Third")
    
    
    c = p.invoke
    assert_selekt c, ".TabPanel>ul>li", "First" # test tab.
    assert_selekt c, "div#my_tab_panel #First"  # test tab content.
    
    p = hibernate_widget(p)
    
    c = p.invoke
    assert_selekt c, ".TabPanel>ul>li", "First" # test tab.
    assert_selekt c, "div#my_tab_panel #First"  # test tab content.
  end
  
  
  def test_panel_event_cycle_for_f5_request
    p = tab_panel('my_tab_panel')
      p << tab("First")
      p << tab("Second")
      p << tab("Third")
    
    c = p.invoke
    assert_state p, :switch
    
    p = hibernate_widget(p)
    controller.params = {}
    
    c = p.invoke
    assert_state p, :_switch
    assert_equal p.current_child_id, "First"
  end
  
  
  def test_panel_event_cycle_for_ajax_request
    p = tab_panel('my_tab_panel')
      p << tab("First")
      p << tab("Second")
      p << tab("Third")
    
    c = p.invoke
    assert_state p, :switch
    
    # next request ------------------------------------------
    p = hibernate_widget(p)    
    controller.params = {'my_tab_panel_child' => "Third"}
    
    
    evt = Apotomo::Event.new(:switchChild, p, {'my_tab_panel_child' => "Third"})
    c = p.invoke_for_event(evt)
    
    assert_state p, :_switch
    assert_equal p.current_child_id, "Third"
  end
  
  
  
  def test_tab_widget_api
    t = Apotomo::TabWidget.new(@controller, 'tab_id', :widget_content, :title => "The Tab")
    
    assert_equal t.title, "The Tab"
    
    t = tab('my_id', :title => "A Title")
    assert_equal t.title, "A Title"
  end
  
  
  def test_tab_widget_title
    t = tab('my_id', :title => "A Title")
    assert_equal t.title, "A Title"
    
    t = hibernate_widget(t)
    assert_equal t.title, "A Title"
  end
  
  
  def test_switch_addressing
    @controller.session = {}
    r = apotomo_root_mock
    tree = SwitchTestWidgetTree.new.draw(r)
    
    child1  = r.find_by_id('first_child')
    child2  = r.find_by_id('second_child')
    
    assert_equal child1.address['first_switch_child'], 'second_switch'
    assert_equal child1.address['second_switch_child'], 'first_child'
    assert_equal child2.address['first_switch_child'], 'second_switch'
    assert_equal child2.address['second_switch_child'], 'second_child'
  end
    
end
