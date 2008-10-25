require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class AddressingTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
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
