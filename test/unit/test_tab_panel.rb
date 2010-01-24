require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class TabPanelTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_responds_to_url_change_for?
    fragment =  Apotomo::DeepLinkMethods::UrlFragment
    
    w = tab_panel('mice', :is_url_listener => true)
    w.current_child_id = 'jerry'
    
    assert ! w.responds_to_url_change_for?(fragment.new ""), "shouldn't respond to emtpy url"
    assert ! w.responds_to_url_change_for?(fragment.new "cats=tom"), "shouldn't respond to foreign url"
    assert ! w.responds_to_url_change_for?(fragment.new "mice=jerry")
    assert ! w.responds_to_url_change_for?(fragment.new "mice="), "shouldn't respond to invalid url"
    assert   w.responds_to_url_change_for?(fragment.new "mice=berry")
  end
  
  def test_local_fragment
    w = tab_panel('mice')
    w.current_child_id = 'jerry'
    
    assert_equal "mice=jerry", w.local_fragment 
  end
  
  def test_find_current_child_from_query
    w = tab_panel('mice')
      w << tab('jerry')
      w << tab('berry')
      w << tab('micky')
    
    w.controller = controller
    
    
    # default child:
    assert_equal 'jerry', w.find_current_child.name
    ### FIXME: i hate the usage of global parameters:
    controller.params = {'mice' => 'micky', :deep_link => 'mice=berry'}
    
    assert_equal 'micky', w.find_current_child.name, "didn't process the query string ?mice=micky"
  end
  
  def test_find_current_child_from_fragment
    w = tab_panel('mice', :is_url_listener => true)
      w << tab('jerry')
      w << tab('berry')
      w << tab('micky')
    
    w.controller = controller
    
    ### FIXME: i hate the usage of global parameters:
    controller.params = {'mice' => 'micky', :deep_link => 'mice=berry'}
    
    assert_equal 'berry', w.find_current_child.name, "didn't process the url fragment 'mice=berry'"
  end
  
  def test_url_fragment_for_tab
    w = tab_panel('mice', :is_url_listener => true)
      w << j= tab('jerry')
        j << c= tab_panel('jerrys_kids', :is_url_listener => true)
          c << r= tab('jerry_jr')
      w << b= tab('berry')
    
    w.current_child_id = 'jerry'
    
    assert_equal "mice=berry", w.url_fragment_for_tab(b)
    assert_equal "mice=jerry", w.url_fragment_for_tab(j)
    
    assert_equal "mice=jerry/jerrys_kids=jerry_jr", c.url_fragment_for_tab(r)
  end
end
