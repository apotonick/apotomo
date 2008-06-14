require File.expand_path(File.dirname(__FILE__) + "/../../apotomo/test/test_helper")


class TabPanelTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
  end
  
  
  def test_js_rendering
      w = Extjs::TabPanel.new(@controller, 'my_tab_panel', :render_as_function)
    
    puts c = w.invoke
    
    c = c.to_s
    
    assert_match /\(function\(\)\{ el = new Ext\.TabPanel/, c
  end
  
  
  def test_tab_rendering
    w = Extjs::Tab.new(@controller, 'my_tab_1', :render_as_function, {}, :title=>"Tab 1")
      w << Extjs::Widget.new(@controller, 'child_1', :render_as_function)
    
    c = w.invoke
    c = c.to_s
    puts c
    
    # assure the constructor is just a js hash:
    assert_match /\(function\(\)\{ el = \{\w+: /, c
    assert_match re('id: "my_tab_1"'), c
    assert_match re('title: "Tab 1"'), c
    assert_match /\};\s+return/, c
    assert_no_match re("items: []"), c
    #assert_no_match re("items: {}"), c
    assert_match re("plugins: [new Ext.ux.Plugin.RemoteComponent"), c
    
    
    c = w.invoke(:_load)
    c = c.to_s
    
    puts "_load:"
    puts c
    
    assert_match re("[(function"), c
  end
  
  def test_tab_tabs_rendering
    w = Extjs::TabPanel.new(@controller, 'my_tab_panel', :render_as_function)
      w << t1 = Extjs::Tab.new(@controller, 'my_tab_1', :render_as_function, {}, :title=>"Tab 1")
      t1 << Extjs::Widget.new(@controller, 'child_1', :render_as_function)
      w << t2 = Extjs::Tab.new(@controller, 'my_tab_2', :render_as_function, {}, :title=>"Tab 2")
    
    
    puts c = w.invoke
    c = c.to_s
    
    assert_match /\(function\(\)\{ el = new Ext\.TabPanel/, c
  end
end

