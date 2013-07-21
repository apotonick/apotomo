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

  describe "A caching widget" do
    before do
      ActionController::Base.perform_caching = true
      @cheese = CheeseWidget.new(parent_controller, 'cheese', :holes)
    end

    after do
      ActionController::Base.perform_caching = false
    end

    it "invoke the cached state only once" do
      assert_equal "1", @cheese.invoke(:holes, 1)
      assert_equal "1", @cheese.invoke(:holes, 2)
    end
  end
end
