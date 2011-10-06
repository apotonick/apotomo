require 'test_helper'
 
class EventTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "An Event" do
    should "respond to #type and #source" do
      @event = Apotomo::Event.new(:footsteps, 'mum')
      assert_equal :footsteps,  @event.type
      assert_equal 'mum',       @event.source
    end
    
    should "accept an additional data object and respond to #data" do
      @event = Apotomo::Event.new(:footsteps, 'mum', {:volume => :loud})
      assert_equal({:volume => :loud}, @event.data)
    end
    
    should "delegate #[] to data" do
      @event = Apotomo::Event.new(:footsteps, 'mum', {:volume => :loud})
      assert_equal :loud, @event[:volume]
    end
    
    should "respond to #to_s" do
      @event = Apotomo::Event.new(:footsteps, mouse_mock('mum'))
      assert_equal "<Event :footsteps source=mum>", @event.to_s
    end
  end
end
