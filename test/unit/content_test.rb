require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ContentTest < Test::Unit::TestCase
  
  context "PageUpdate" do
    context "when creating you" do
      should "raise an exception if you forget the target" do
        assert_raises ArgumentError do
          Apotomo::Content::PageUpdate.new
        end
        
        assert_raises RuntimeError do
          Apotomo::Content::PageUpdate.new :with => "squeak!"
        end
      end
      
      should "be allowed to omit the :with" do
        mum = Apotomo::Content::PageUpdate.new :replace => "mum"
        assert_equal "", mum
      end
      
    end
    
    context "a PageUpdate instance" do
      setup do
        @outer  = Apotomo::Content::PageUpdate.new :replace => 'mum', :with =>"squeak!"
        @inner  = Apotomo::Content::PageUpdate.new :update  => 'kid', :with =>"squeak!"
      end
      
      context "in string context" do
        should "simply expose its content" do
          assert_equal "squeak!", "#{@outer}"
          assert_equal "squeak!", "#{@inner}"
        end
        
        should "respond stringy to #to_s" do
          assert_equal "squeak!", @outer.to_s
          assert_equal "squeak!", @inner.to_s
        end
        
        should "respond stringy to #kind_of?" do
          assert_kind_of String, @outer
        end
        
        should "respond stringy to #blank?" do
          assert Apotomo::Content::PageUpdate.new(:replace => 'mum').blank?
          assert ! Apotomo::Content::PageUpdate.new(:replace => 'mum', :with => "squeak!").blank?
        end
        
      end
      
      context "in comparison with another instance" do
        should "return true only if all options are equal" do
          assert @outer == Apotomo::Content::PageUpdate.new(:replace  => 'mum', :with =>"squeak!")
          assert @outer != Apotomo::Content::PageUpdate.new(:replace  => 'mum', :with =>"miau!")
          assert @outer != Apotomo::Content::PageUpdate.new(:update   => 'mum', :with =>"squeak!")
        end
      end
      
      should "respond to #replace?" do
        assert @outer.replace?
        assert ! @inner.replace?
      end
      
      should "respond to #update?" do
        assert ! @outer.update?
        assert @inner.update?
      end
      
      should "respond to #target" do
        assert_equal "mum", @outer.target
        assert_equal "kid", @inner.target
      end
    end
    
    context "Javascript" do
      should "act stringy in string context" do
        assert_equal "squeak();", "#{Apotomo::Content::Javascript.new('squeak();')}"
      end
    end
    
    context "Raw" do
      should "act stringy in string context" do
        assert_equal "squeak", "#{Apotomo::Content::Raw.new('squeak')}"
      end
    end
  end
end