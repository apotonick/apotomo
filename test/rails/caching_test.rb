require 'test_helper'



class CachingTest < ActiveSupport::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  class CheeseWidget < Apotomo::Widget
    cache :holes
    
    @@holes = 0
    cattr_accessor :holes
    
    
    #def self.reset!
    #  @@counter = 0
    #end
    
    def increment!
      self.class.holes += 1
    end
    
    def holes
      render :text => increment!
    end 
  end
  
  context "A caching widget" do
    setup do
      @cheese = CheeseWidget.new(parent_controller, 'cheese', :holes)
    end
    
    should "invoke the cached state only once" do
      assert_equal "1", @cheese.invoke
      assert_equal "1", @cheese.invoke
    end
  end
end
