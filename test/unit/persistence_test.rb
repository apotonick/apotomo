require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class PersistenceTest < Test::Unit::TestCase
  
  context "After some requests the widget" do
    should "still have the same ivars" do
      class PersistentMouse < Apotomo::StatefulWidget # we need a named class for marshalling.
            transition :from => :educate, :to => :recap
            attr_reader :who, :what
          
          def educate
            @who  = "the cat"
            @what = "run away"
            render :nothing => true
          end
          
          def recap;  render :nothing => true; end
      end
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
  end
end