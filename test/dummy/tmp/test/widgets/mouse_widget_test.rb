require 'test_helper'

class MouseWidgetTest < Apotomo::TestCase
  has_widgets do |root|
    root << widget(:mouse_widget, 'me')
  end
  
  test "display" do
    render_widget 'me'
    assert_select "h1"
  end
end
