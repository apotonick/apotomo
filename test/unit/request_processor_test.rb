require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RequestProcessorTest < Test::Unit::TestCase
  context "#root" do
    should "allow external modification of the tree" do
      @processor = Apotomo::RequestProcessor.new({})
      root = @processor.root
      root << mouse_mock
      assert_equal 2, @processor.root.size
    end
  end
    
  context "option processing at construction time" do
    context "with empty session and options" do
      setup do
        @processor = Apotomo::RequestProcessor.new({})
      end
      
      should "mark the tree as flushed" do
        assert @processor.tree_flushed?
      end
      
      should "provide a single root-node for #root" do
        assert_equal 1, @processor.root.size
      end
      
      should "initialize version to 0" do
        assert_equal 0, @processor.root.version
      end
    end
    
    context "with session" do
      setup do
        mum_and_kid!
        @mum.version = 1
        @processor = Apotomo::RequestProcessor.new({'apotomo_root' => @mum})
      end
      
      should "provide a widget family for #root" do
        assert_equal 2, @processor.root.size
        assert_equal 1, @processor.root.version
        assert_not @processor.tree_flushed?
      end
      
      should "provide a single root for #root when :flush_tree is set" do
        @processor = Apotomo::RequestProcessor.new({'apotomo_root' => @mum}, :flush_tree => true)
        assert_equal 1, @processor.root.size
        assert @processor.tree_flushed?
      end
      
      should "provide a single root for #root when :version differs" do
        @processor = Apotomo::RequestProcessor.new({'apotomo_root' => @mum}, :version => 0)
        assert_equal 1, @processor.root.size
        assert @processor.tree_flushed?
      end
      
      should "provide a widget family for #root when :version is correct" do
        @processor = Apotomo::RequestProcessor.new({'apotomo_root' => @mum}, :version => 1)
        assert_equal 2, @processor.root.size
        assert_not @processor.tree_flushed?
      end
    end
  end
end