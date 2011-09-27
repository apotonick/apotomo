require 'test_helper'

class <%= class_name %>WidgetTest < Apotomo::TestCase
  has_widgets do |root|
    root << widget(:<%= file_name %>)
  end
  
  test "display" do
    render_widget :<%= file_name %>
    assert_select "h1"
  end
end
