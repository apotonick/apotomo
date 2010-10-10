require 'test_helper'

class <%= class_name %>Test < Apotomo::TestCase
<% for state in @states -%>
  test "<%= state %>" do
    invoke :<%= state %>
    assert_select "p"
  end
  
<% end %>
end
