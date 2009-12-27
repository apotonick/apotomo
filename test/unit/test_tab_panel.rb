require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class TabPanelTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_recognizes_path?
    w = tab_panel('mice')
    w.current_child_id = 'jerry'
    
    assert ! w.recognizes_path?("")
    assert ! w.recognizes_path?("mice=jerry")
    assert w.recognizes_path?("mice=")
    assert w.recognizes_path?("mice=berry")
  end
  
  def test_local_fragment
    w = tab_panel('mice')
    w.current_child_id = 'jerry'
    
    assert_equal "mice=jerry", w.local_fragment 
  end
  
  def test_find_current_child
    w = tab_panel('mice')
      w << tab('jerry')
      w << tab('berry')
      w << tab('micky')
    
    w.controller = controller
    
    
    # default child:
    assert_equal 'jerry', w.find_current_child.name
    ### FIXME: i hate the usage of global parameters:
    
    # find child from query:
    controller.params = {'mice' => 'micky', :deep_link => 'mice=berry'}
    assert_equal 'micky', w.find_current_child.name
    
    # find child from fragment:
    w.add_deep_link
    assert_equal 'berry', w.find_current_child.name
  end
  
  def test_url_fragment_for_tab
    w = tab_panel('mice')
      w << j= tab('jerry')
        j << c= tab_panel('jerrys_kids')
          c << r= tab('jerry_jr')
      w << b= tab('berry')
    
    w.add_deep_link
    w.current_child_id = 'jerry'
    c.add_deep_link
    
    assert_equal "mice=berry", w.url_fragment_for_tab(b)
    assert_equal "mice=jerry", w.url_fragment_for_tab(j)
    
    assert_equal "mice=jerry/jerrys_kids=jerry_jr", c.url_fragment_for_tab(r)
  end
end
