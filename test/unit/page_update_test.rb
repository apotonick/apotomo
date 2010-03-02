require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class PageUpdateTest < Test::Unit::TestCase
  
  context "when creating you" do
    should "raise an exception if you forget the target" do
      assert_raises ArgumentError do
        Apotomo::PageUpdate.new
      end
      
      assert_raises RuntimeError do
        Apotomo::PageUpdate.new :with => "squeak!"
      end
    end
    
    should "be allowed to omit the :with" do
      mum = Apotomo::PageUpdate.new :replace => "mum"
      assert_equal "", mum.to_s
    end
    
  end
  
  context "a PageUpdate instance" do
    setup do
      @outer  = Apotomo::PageUpdate.new :replace      => 'mum', :with =>"squeak!"
      @inner  = Apotomo::PageUpdate.new :replace_html => 'kid', :with =>"squeak!"
    end
    
    context "in string context" do
      should "simply expose its content" do
        assert_equal "squeak!", @outer.to_s
        assert_equal "squeak!", @inner.to_s  
      end
      
      should "respond stringy to #kind_of?" do
        assert_kind_of String, @outer
      end
      
    end
    
    context "in comparison with another instance" do
      should "return true only if all options are equal" do
        assert @outer == Apotomo::PageUpdate.new(:replace => 'mum', :with =>"squeak!")
        assert @outer != Apotomo::PageUpdate.new(:replace => 'mum', :with =>"miau!")
        assert @outer != Apotomo::PageUpdate.new(:replace_html => 'mum', :with =>"squeak!")
      end
    end
    
    should "respond to #replace?" do
      assert @outer.replace?
      assert ! @inner.replace?
    end
    
    should "respond to #replace_html?" do
      assert ! @outer.replace_html?
      assert @inner.replace_html?
    end
    
    should "respond to #target" do
      assert_equal "mum", @outer.target
      assert_equal "kid", @inner.target
    end
    
  end
end