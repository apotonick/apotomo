require 'test_helper'

class AddressingTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_url_fragment
    frag = Apotomo::DeepLinkMethods::UrlFragment.new("tabs=first/mouse=eating")
    
    assert_equal "tabs=first/mouse=eating", frag.to_s
    assert_equal "first",   frag[:tabs]
    assert_equal "first",   frag['tabs']
    assert_equal "eating",  frag[:mouse]
    assert_equal "eating",  frag['mouse']
    assert_equal nil,       frag[:non_existent]
    
    frag = Apotomo::DeepLinkMethods::UrlFragment.new(nil)
    assert_equal nil,       frag[:non_existent]
  end
  
  def test_url_fragment_accessor
    assert_kind_of Apotomo::DeepLinkMethods::UrlFragment, mouse_mock.url_fragment
  end
  
  def test_url_fragment_blank?
    assert Apotomo::DeepLinkMethods::UrlFragment.new("").blank?
  end
  
  
  def test_responds_to_url_change?
    m = mouse_mock
    assert ! m.responds_to_url_change?
    
    m.respond_to_event :urlChange, :with => :eating
    assert m.responds_to_url_change?, "should be true as an :urlChanged listener is attached."
    
    # test with explicit source:
    m = mouse_mock
    m.respond_to_event :urlChange, :with => :eating, :from => 'mouse'
    assert m.responds_to_url_change?, "should be true as an :urlChanged listener is attached."
  end
  
  def test_deep_link_addressing
    t = mouse_mock('top', :upside) do
      def local_fragment; "top=upside"; end
    end
    b = mouse_mock('bottom', :downside) do
      def local_fragment; "bottom=downside"; end
    end
    
    t.respond_to_event :urlChange, :with => :eating
    b.respond_to_event :urlChange, :with => :eating
    
    t << b
      b << j = cell(:mouse, :eating, 'jerry')
    
    
    assert_equal "top=upside",  t.local_fragment
    assert_equal "v",           t.url_fragment_for("v")
    
    assert_equal "bottom=downside",             b.local_fragment
    assert_equal "top=upside/bottom=downside",  b.url_fragment_for
    assert_equal "top=upside/v",                b.url_fragment_for('v')
    
    assert_equal nil, j.local_fragment
    assert_equal "top=upside/bottom=downside",        j.url_fragment_for
    assert_equal "top=upside/bottom=downside/jerry",  j.url_fragment_for('jerry')
  end
  
  
  def test_default_local_fragment
    assert_equal nil, mouse_mock.local_fragment
  end
  
  
  def test_responds_to_url_change_for
    m = mouse_mock do
      def eating; render :nothing => :true; end
    end
    
    assert ! m.responds_to_url_change_for?(""), "should return false by default"
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
