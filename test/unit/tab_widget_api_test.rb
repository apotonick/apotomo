require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class TabWidgetApiTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_object_creation
    tab = Apotomo::TabWidget.new(@controller, 'id')
    assert_kind_of Apotomo::TabWidget, tab
  end
  
  #def test_default_page_view
  #  page = Apotomo::PageWidget.new(@controller, 'pageId', :page_content)
  #  self.buffer = page.content
  #  assert_select buffer, "div.ApotomoPage>h3"
  #end
  
end
