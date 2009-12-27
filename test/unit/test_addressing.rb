require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class AddressingTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_deep_link_addressing
    t = mouse_mock('top', :upside) do
      def upside; render :nothing => :true; end
    end
    b = mouse_mock('bottom', :downside) do
      def downside; render :nothing => :true; end
    end
    
    t.class.adds_deep_link
    b.class.adds_deep_link
    
    t << b
      b << j = cell(:mouse, :eating, 'jerry')
    
    t.invoke
    b.invoke
    
    assert_equal "top=upside", t.local_fragment
    assert_equal "top=upside", t.url_fragment
    
    assert_equal "bottom=downside", b.local_fragment
    assert_equal "top=upside/bottom=downside",  b.url_fragment
    assert_equal "top=upside/v",                b.url_fragment_with('v')
    
    assert_equal "jerry=", j.local_fragment
    assert_equal "top=upside/bottom=downside",        j.url_fragment
    assert_equal "top=upside/bottom=downside/jerry",  j.url_fragment_with('jerry')
  end
  
  def test_adds_deep_link_with_class
    m = mouse_mock
    
    assert ! m.adds_deep_link?
    
    m.class.instance_eval do
      adds_deep_link
    end
    
    assert m.adds_deep_link?
  end
  
  def test_adds_deep_link_with_instance
    m = mouse_mock
    
    assert ! m.adds_deep_link?
    
    m.add_deep_link
    
    assert m.adds_deep_link?
  end
  
  def test_default_local_fragment
    m = mouse_mock do
      def eating; render :nothing => :true; end
    end
    
    assert_equal "mouse=", m.local_fragment
    m.invoke
    assert_equal "mouse=eating", m.local_fragment
  end
  
  
  
  
  def test_path
    w= cell(:my_test, :some, 'root')
    assert_equal w.path, 'root'
    
    w << a= cell(:my_test, :some, 'a')
    
    assert_equal a.path, 'root/a'
  end
  
  
  def test_find
    root = widget("apotomo/stateful_widget", :widget_content, 'root')
      root << a = widget("apotomo/stateful_widget", :widget_content, 'a')
        a << aa = widget("apotomo/stateful_widget", :widget_content, 'a')
    
    assert_equal a, root.find_by_id("a")
    assert_equal a, root.find_by_path("a")
    assert_equal a, root.find_by_path(:a)
    assert_equal aa, root.find_by_path("a a")
  end
  
end

class MyTestCell < Apotomo::StatefulWidget
  

end
