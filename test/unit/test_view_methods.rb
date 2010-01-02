class ViewMethodsTest < ActionController::TestCase
  include Apotomo::UnitTestCase
  
  def test_render_widget_in_view
    
    #ActionView::Base.extend Apotomo::ViewMethods
    v = ActionView::Base.new([], {}, @controller)
    v.extend Apotomo::ViewMethods # about the same as a helper.
    
    init_apotomo_root_mock!
    @controller.apotomo_root << mouse_mock
    
    assert_selekt v.render(:inline => "<%= render_widget 'mouse' %>"), "div","burp!"
  end
end