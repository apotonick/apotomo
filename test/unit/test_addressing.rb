require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class AddressingTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_path
    w= cell(:my_test, :some, 'root')
    assert_equal w.path, 'root'
    
    w << a= cell(:my_test, :some, 'a')
    
    assert_equal a.path, 'root.a'
  end
  
end

class MyTestCell < Apotomo::StatefulWidget
  

end
