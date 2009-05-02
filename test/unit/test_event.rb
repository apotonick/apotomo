require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class EventTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_explicit_construction_with_accessors
    evt = Apotomo::Event.new
    evt.type      = :click
    evt.source    = 'some_widget'
    evt.data      = {:key => 'value'}
    
    assert_equal :click, evt.type
    assert_equal 'some_widget', evt.source
    assert_equal({:key => 'value'}, evt.data)
  end
  
  def test_explicit_construction_with_args
    evt = Apotomo::Event.new(:click, 'some_widget', {:key => 'value'})
    
    assert_equal :click, evt.type
    assert_equal 'some_widget', evt.source
    assert_equal({:key => 'value'}, evt.data)
  end
  
  def test_implicit_construction_with_args
    evt = Apotomo::Event.new(nil, 'some_widget')
    
    assert_equal :invoke, evt.type
    assert_equal 'some_widget', evt.source
    assert_equal({}, evt.data)
  end
  
end
