require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ParamTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
    
    @w = cell(:param, :state, 'a')
    @w.controller = @controller
  end
  
  def test_local_param_accessors
    w = @w
    w.set_local_param(:prm, "wow")
    assert_equal w.local_param(:prm), "wow"
    assert_equal w.local_param(:unknown), nil
  end
  
  
end 


class ParamCell < Apotomo::StatefulWidget
  def set_my_param
    set_local_param(:my_param, "set_in_set_local_param")
  end
end