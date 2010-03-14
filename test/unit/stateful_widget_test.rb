require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class StatefulWidgetTest < Test::Unit::TestCase
  context "The StatefulWidget" do
    setup do
      @mum = Apotomo::StatefulWidget.new('mum', :squeak)
    end
    
    should "accept an id as first option" do
      assert_equal 'mum', @mum.name
    end
    
    should "accept a start state as second option" do
      assert_equal :squeak, @mum.instance_variable_get('@start_state')
    end
    
    should "respond to #version" do
      assert_equal 0, mouse_mock.version
    end
    
    should "have a version setter" do
      @mum = mouse_mock
      @mum.version = 1
      assert_equal 1, @mum.version
    end
    
    context "responding to #address_for_event" do
      should "accept an event :type" do
        assert_equal({:type => :squeak, :source => 'mum'}, @mum.address_for_event(:type => :squeak))
      end
      
      should "accept a :source" do
        assert_equal({:type => :squeak, :source => 'kid'}, @mum.address_for_event(:type => :squeak, :source => 'kid'))
      end
      
      should "accept arbitrary options" do
        assert_equal({:type => :squeak, :volume => 'loud', :source => 'mum'}, @mum.address_for_event(:type => :squeak, :volume => 'loud'))
      end
      
      should "complain if no type given" do
        assert_raises RuntimeError do
          @mum.address_for_event(:source => 'mum')
        end
      end
    end
  end
end