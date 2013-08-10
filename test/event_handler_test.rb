require 'test_helper'

class EventHandlerTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "EventHandler" do
    before do
      @mum = mouse
        @mum << mouse_mock(:kid)
    end

    describe "#call" do
      it "push nil to root's page_updates" do
        [@mum, @mum[:kid], @mum].each do |source|
          Apotomo::EventHandler.new.call(Apotomo::Event.new(:squeak, source))
        end

        assert_equal 3, @mum.page_updates.size
        assert_equal nil, @mum.page_updates[0]
        assert_equal nil, @mum.page_updates[1]
        assert_equal nil, @mum.page_updates[2]
        assert_equal 0, @mum[:kid].page_updates.size
      end
    end
  end

  ### TODO: test #call

end
