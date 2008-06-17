require File.expand_path(File.dirname(__FILE__) + "/../../apotomo/test/test_helper")



class FormPanelTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
  end
  
  
  def test_js_rendering
    f = Extjs::FormPanel.new(@controller, 'my_form_panel', :render_as_function)
    
    c = f.invoke
    c = c.to_s
    puts c
    
    assert_match re("(function(){ var el = new Ext.FormPanel"), c
    # test load url:
    assert_match re("url: '/apotomo/data?widget_id=my_form_panel&state=_load'"), c
  end
  
  
  def test_loading_in_concrete_form
    f = ConcreteForm.new(@controller, 'concrete_form', :render_as_function, :obj => "object")
    f << Extjs::TextField.new(@controller, 'my_text', :render_as_function, {}, :fieldLabel => "My Text")
    
    c = f.invoke
    c = c.to_s
    puts c
    
    assert_match re("(function(){ var el = new Ext.FormPanel"), c
    
    c = f.invoke  # :_load
    assert_equal f.last_state, :_load
    # JSON form data should be embraced:
    assert_match /^\{.+\}$/, c
    assert_match re("success: true"), c
    assert_match re("text_field: \"object\""), c
    
    
    # test saving:
    c = f.invoke(:_save)
    assert_equal f.last_state, :_save 
    assert_match /^\{.+\}$/, c
    assert_match re("success: false"), c
  end
  
  
  def test_vtype_config
    f = VtypeForm.new(@controller, 'my_form_panel', :render_as_function)
    
    c = f.invoke
    c = c.to_s
    puts c
    
    assert_match /items: \[\{.+"pass"/, c
  end
end


class ConcreteForm < Extjs::FormPanel
  def load_data
    {:text_field => "object"}
  end
end


class VtypeForm < Extjs::FormPanel
  def init_config
    config = super.merge!( {
      :items => [
        { :fieldLabel => 'Password',
          :name       => 'pass',
          :xtype      => 'textfield'}
      ]
    })
  end
end
