require 'test_helper'

class MouseWidgetTest < Apotomo::TestCase
  test "squeak" do
    invoke :squeak
    assert_select "p"
  end
  
  test "snuggle" do
    invoke :snuggle
    assert_select "p"
  end
  

end
