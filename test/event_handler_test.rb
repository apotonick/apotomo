require 'test_helper'
require 'apotomo/proc_event_handler'

class EventHandlerTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "an abstract EventHandler" do
    it "push nil to root's ordered page_updates when #call'ed" do
      @mum = mouse
        @mum << mouse_mock(:kid)

      assert_equal 0, @mum.page_updates.size

      [@mum, @mum[:kid], @mum].each do |source|
        Apotomo::EventHandler.new.call(Apotomo::Event.new(:squeak, source))
      end

      # order matters:
      assert_equal 3, @mum.page_updates.size
      assert_equal 0, @mum[:kid].page_updates.size
      assert_equal(nil, @mum.page_updates[0])
      assert_equal(nil, @mum.page_updates[1])
      assert_equal(nil, @mum.page_updates[2])
    end
  end



  def test_invoke_to_s
    h = Apotomo::InvokeEventHandler.new
    h.widget_id = :widget_id
    h.state     = :my_state
    assert_equal "InvokeEventHandler:widget_id#my_state", h.to_s
  end

  def test_proc_to_s
    h = Apotomo::ProcEventHandler.new
    h.proc = :my_method
    assert_equal "ProcEventHandler:my_method", h.to_s
  end

  def test_constructor_for_proc
    h = Apotomo::ProcEventHandler.new
    assert_nil h.proc
    h = Apotomo::ProcEventHandler.new(:proc => :method)
    assert_equal :method, h.proc
  end

  def test_constructor_for_invoke
    h = Apotomo::InvokeEventHandler.new
    assert_nil h.widget_id
    assert_nil h.state
    h = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)
    assert_equal :widget, h.widget_id
    assert_equal :state,  h.state
  end

  def test_equal
    h1 = Apotomo::ProcEventHandler.new(:proc => :run)
    h2 = Apotomo::ProcEventHandler.new(:proc => :run)
    h3 = Apotomo::ProcEventHandler.new(:proc => :walk)

    assert h1 == h2
    assert h1 != h3
  end

  ### TODO: test #call

end
