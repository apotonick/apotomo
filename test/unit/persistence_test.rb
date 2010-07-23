require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class PersistenceTest < Test::Unit::TestCase
  
  class PersistentMouse < Apotomo::StatefulWidget # we need a named class for marshalling.
    attr_reader :who, :what
      
    def educate
      @who  = "the cat"
      @what = "run away"
      render :nothing => true
    end
      
    def recap;  render :nothing => true; end
  end
  
  context "After #hibernate_widget (request) the widget" do
    should "still have the same ivars" do
      @mum = PersistentMouse.new('mum', :educate)
      @mum.controller = @controller ### FIXME: remove that dependency
      
      @mum.invoke(:educate)
      
      assert_equal @mum.last_state, :educate
      assert_equal @mum.who,  "the cat"
      assert_equal @mum.what, "run away"
      
      @mum = hibernate_widget(@mum)
      @mum.controller = @controller ### FIXME: remove that dependency
      
      @mum.invoke(:recap)
      
      assert_equal @mum.last_state, :recap
      assert_equal @mum.who,  "the cat"
      assert_equal @mum.what, "run away"
    end
    
    should "still have its event_table" do
      @mum    = PersistentMouse.new('mum', :educate)
      @event  = Apotomo::Event.new(:squeak, @mum)
      @mum.respond_to_event :squeak, :with => :educate
      
      assert_equal 1, @mum.send(:local_event_handlers, @event).size
      @mum = hibernate_widget(@mum)
      assert_equal 1, @mum.send(:local_event_handlers, @event).size
    end
  end
  
  context "freezing and thawing a widget family" do
    setup do
      mum_and_kid!
      @storage = {}
    end
    
    should "push @mum's freezable ivars to the storage when calling #freeze_ivars_to" do
      @mum.freeze_ivars_to(@storage)
      
      assert_equal 1, @storage.size
      assert_equal 5, @storage['mum'].size
    end
    
    should "push family's freezable ivars to the storage when calling #freeze_data_to" do
      @kid << mouse_mock('pet')
      @mum.freeze_data_to(@storage)
      
      assert_equal 3, @storage.size
      assert_equal 5, @storage['mum'].size
      assert_equal 5, @storage['mum/kid'].size
      assert_equal 4, @storage['mum/kid/pet'].size
    end
    
    should "push ivars and structure to the storage when calling #freeze_to" do
      @mum.freeze_to(@storage)
      assert_equal 2, @storage[:apotomo_widget_ivars].size
      assert_kind_of Apotomo::StatefulWidget, @storage[:apotomo_root]
    end
    
    should "ignore stateless widgets when calling #freeze_to" do
      @mum << Apotomo::Widget.new('berry', :eating)
      @mum.freeze_to(@storage)
      
      assert_equal ['mum', 'mum/kid'], @storage[:apotomo_widget_ivars].keys
    end
    
    should "update @mum's ivars when calling #thaw_ivars_from" do
      @mum.instance_variable_set(:@name, "zombie mum")
      assert_equal 'zombie mum', @mum.name
      
      @mum.thaw_ivars_from({'zombie mum' => {'@name' => 'mum'}})
      assert_equal 'mum', @mum.name
    end
    
    should "update family's ivars when calling #thaw_data_from" do
      @kid << @pet = mouse_mock('pet')
      @kid.instance_variable_set(:@name, "paranoid kid")
      @pet.instance_variable_set(:@name, "mad dog")
      assert_equal "paranoid kid", @kid.name
      
      @mum.thaw_data_from({ "mum/paranoid kid"  => {'@name' => 'kid'},
                            "mum/kid/mad dog"   => {'@name' => 'pet'}})
      assert_equal 'kid', @kid.name
      assert_equal 'pet', @pet.name
    end
    
    should "recreate it when calling #thaw_from" do
      @kid << @pet = mouse_mock('pet', :bark)
      @mum.freeze_to(@storage)
      
      mum = Apotomo::StatefulWidget.thaw_from(@storage)
      assert_equal 3, mum.size
      assert_equal :answer_squeak,  mum.instance_variable_get(:@start_state)
      assert_equal :peek,           mum.children.first.instance_variable_get(:@start_state)
      assert_equal :bark,           mum.children.first.children.first.instance_variable_get(:@start_state)
    end
  end
  
  context "dumping and loading" do
    setup do
      @mum = PersistentMouse.new('mum', :eating)
      @mum << @kid = PersistentMouse.new('kid', :eating)
    end
    
    context "a single widget" do
      should "provide a serialized widget on #node_dump" do
        assert_equal "mum|PersistenceTest::PersistentMouse|mum", @mum.dump_node
        assert_equal "kid|PersistenceTest::PersistentMouse|mum", @kid.dump_node
      end
      
      should "recover the widget skeleton when invoking self.node_load" do
        @mum, parent = ::Apotomo::StatefulWidget.load_node(@mum.dump_node)
        assert_kind_of PersistentMouse, @mum
        assert_equal 'mum', @mum.name
        assert_equal 1,     @mum.size
        assert_equal 'mum', parent
      end
    end
    
    context "a widget family" do
      should "provide the serialized tree on _dump" do
        assert_equal "mum|PersistenceTest::PersistentMouse|mum\nkid|PersistenceTest::PersistentMouse|mum\n", @mum._dump(10)
      end
      
      should "recover the widget tree on _load" do
        @mum = ::Apotomo::StatefulWidget._load(@mum._dump(10))
        assert_equal 2, @mum.size
        assert_equal @mum, @mum['kid'].parent
      end
    end
  end
  
  context "#frozen_widget_in?" do
    should "return true if a valid widget is passed" do
      assert_not Apotomo::StatefulWidget.frozen_widget_in?({})
      assert Apotomo::StatefulWidget.frozen_widget_in?({:apotomo_root => mouse_mock})
    end
  end
  
  context "#symbolized_instance_variables?" do
    should "return instance_variables as symbols" do
      @mum = mouse_mock
      assert_equal @mum.instance_variables.size, @mum.symbolized_instance_variables.size
      assert_not @mum.symbolized_instance_variables.find { |ivar| ivar.kind_of? String }
    end
  end
end