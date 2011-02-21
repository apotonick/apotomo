require 'test_helper'

# TODO: assert that same-named cells and widgets don't overwrite their caches.

class CachingTest < ActiveSupport::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  class CheeseWidget < Apotomo::Widget
    cache :holes
    
    def holes(count)
      render :text => count
    end 
  end
  
  context "A caching widget" do
    setup do
      ActionController::Base.perform_caching = true
      @cheese = CheeseWidget.new(parent_controller, 'cheese', :holes)
    end
    
    teardown do
      ActionController::Base.perform_caching = false
    end
    
    should "invoke the cached state only once" do
      assert_equal "1", @cheese.invoke(:holes, 1)
      assert_equal "1", @cheese.invoke(:holes, 2)
    end
  end
end
