require File.expand_path(File.dirname(__FILE__) + "/../../apotomo/test/test_helper")

### DISCUSS: how could we test the generated JavaScript? currently, i
###   use quite weak regular expressions. any ideas?


class ExtJSWidgetTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
  end
  
  
  def test_constructor_with_single_widget
    w = Extjs::Widget.new(@controller, 'single', :render_as_function_to, {}, :title => "A Title")
    
    puts c = w.invoke
    
    c = c.to_s
    
    assert_match /title: "A Title"/, c
  end
  
  
  def test_js_rendering
    w = Extjs::Widget.new(@controller, 'first_extjs', :render_as_function)
      w << Extjs::Panel.new(@controller, 'second_extjs', :render_as_function)
      w << TestCell.new(@controller, 'html_widget', :some_html)
    
    puts c = w.invoke(:render_as_function)
    
    c = c.to_s
    
    assert_match /html: "<div/, c
    assert_match /items: \[\(function\(\)\{ var el = new Ext\.Panel/, c
    assert_no_match /\.render\(/, c
  end
end



### fixtures ------------------------------------------------
class TestCell < Apotomo::StatefulWidget
  def some_html
    "yo!"
  end
end
