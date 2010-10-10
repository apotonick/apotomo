require "test_helper"

class <%= class_name %>Test < Test::Unit::TestCase
  test "a first test" do
    html = widget(:<%= file_name %>, :<%= states.first %>, 'my_<%= file_name %>').invoke
    assert_selekt html, "p"
  end
end
