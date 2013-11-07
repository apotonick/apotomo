require 'test_helper'

class EventTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "Event" do
    it "is a kind of Onfire::Event" do
      @event = Apotomo::Event.new(:footsteps, 'mum')

      assert_kind_of Onfire::Event, @event
    end

    it "respond to #type and #source" do
      @event = Apotomo::Event.new(:footsteps, 'mum')

      assert_equal :footsteps, @event.type
      assert_equal 'mum', @event.source
    end

    it "accept an additional data object and respond to #data" do
      @event = Apotomo::Event.new(:footsteps, 'mum', {:volume => :loud})

      assert_equal({:volume => :loud}, @event.data)
    end

    it "delegate #[] to data" do
      @event = Apotomo::Event.new(:footsteps, 'mum', {:volume => :loud})

      assert_equal :loud, @event[:volume]
    end

    it "respond to #to_s" do
      @event = Apotomo::Event.new(:footsteps, mouse('mum'))

      assert_equal "<Event :footsteps source=mum>", @event.to_s
    end
  end
end
