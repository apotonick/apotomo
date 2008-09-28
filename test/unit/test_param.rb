require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ParamTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
  end
  
  def test_child_param_accessors
    w = cell(:param, :state, 'a')
    w.set_child_param('child_1', :prm, "wow")
    assert_equal w.child_param('child_2', :prm), nil
    assert_equal w.child_param('child_1', :prm), "wow"
    assert_equal w.local_param(:prm), nil
    assert_equal w.local_param(:unknown), nil
  end
  
  def test_local_param_accessors
    w = cell(:param, :state, 'a')
    w.set_local_param(:prm, "wow")
    assert_equal w.child_param('child_2', :prm), nil
    assert_equal w.child_param('child_1', :prm), nil
    assert_equal w.local_param(:prm), "wow"
    assert_equal w.local_param(:unknown), nil
  end
  
  def test_param_from_global_params
    w = cell(:param, :state, 'a')
    
    assert_equal w.param(:my_param), nil
    assert_equal w.param('my_param'), nil
    
    controller.params = {:my_param => 1}
    assert_equal w.param(:my_param), 1
    #assert_equal w.param('my_param'), 1
    
    controller.params = {'my_param' => 1}
    #assert_equal w.param(:my_param), 1
    assert_equal w.param('my_param'), 1
  end
  
  # as soon as a widget sets a child_param, it is authorative, even in later requests.
  def test_param_from_child_params_standard
    controller.params = {:my_param => 1}
    
    w = cell(:param, :set_my_param, 'a')    
    assert_equal w.param(:my_param), 1
    w.invoke
    assert_equal w.param(:my_param), "set_in_set_local_param"
    
    # simulate request ----------------------------------------
    controller.params = {}
    
    assert_equal w.param(:my_param), "set_in_set_local_param"
    w.invoke
    assert_equal w.param(:my_param), "set_in_set_local_param"
  end
  
  def test_param_from_static_domain
    controller.params = {:my_param => 1}
    
    dmn = cell(:static_domain, :no_state, 'b')
     dmn << w = cell(:param, :set_my_param, 'a')    
    
    assert_equal w.param(:my_param), "static"
    
    # simulate request ----------------------------------------
    controller.params = {}
    dmn = cell(:static_domain, :no_state, 'b')
     dmn << w = cell(:param, :set_my_param, 'a')
     
    assert_equal w.param(:my_param), "static"
  end
  
  def test_param_from_remembering_domain
    controller.params = {:my_param => 1}
    
    dmn = cell(:dynamic_domain, :no_state, 'b')
     dmn << w = cell(:param, :set_my_param, 'a')    
    
    assert_equal w.param(:my_param), "1-dynamic"
    
    # simulate request ----------------------------------------
    controller.params = {}
    
    assert_equal w.param(:my_param), "1-dynamic"
  end
  
  def test_param_finding_order
    controller.params = {:my_param => "set_globally_in_params"}
    
    dmn = cell(:static_domain, :no_state, 'b')
     dmn << w = cell(:param, :set_my_param, 'a', :my_param => "set_in_opts")
    
    # test @opts ----------------------------------------------
    assert_equal w.param(:my_param), "set_in_opts"
    # test if @opts still is authorative
    w.invoke
    assert_equal w.param(:my_param), "set_in_opts"
    
    
    w = cell(:param, :set_my_param, 'a2')
    
    # test stepwise -------------------------------------------
    assert_equal w.param(:my_param), "set_globally_in_params"
    w.invoke  # now :my_param is set via set_local_param
    assert_equal w.param(:my_param), "set_in_set_local_param"
    
  end
end 


class ParamCell < Apotomo::StatefulWidget
  def set_my_param
    set_local_param(:my_param, "set_in_set_local_param")
  end
end


class StaticDomainCell < Apotomo::StatefulWidget
  def param_for(p, cell)
    "static"
  end
end

class DynamicDomainCell < Apotomo::StatefulWidget
  def param_for(p, cell)
    #if value = parent.param(:my_param)
    if value = params[:my_param]
      value = "#{value}-dynamic"
      set_local_param(:my_param, value)
      #freeze
    else
      value = local_param(:my_param)
    end
    
    return value
  end
end
