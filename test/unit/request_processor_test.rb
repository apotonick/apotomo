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
        assert @processor.widgets_flushed?
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
        @processor = Apotomo::RequestProcessor.new({:apotomo_root => @mum})
      end
      
      should "provide a widget family for #root" do
        assert_equal 2, @processor.root.size
        assert_equal 1, @processor.root.version
        assert_not @processor.widgets_flushed?
      end
      
      should "provide a single root for #root when :flush_tree is set" do
        @processor = Apotomo::RequestProcessor.new({:apotomo_root => @mum}, :flush_widgets => true)
        assert_equal 1, @processor.root.size
        assert @processor.widgets_flushed?
      end
      
      should "provide a single root for #root when :version differs" do
        @processor = Apotomo::RequestProcessor.new({:apotomo_root => @mum}, :version => 0)
        assert_equal 1, @processor.root.size
        assert @processor.widgets_flushed?
      end
      
      should "provide a widget family for #root when :version is correct" do
        @processor = Apotomo::RequestProcessor.new({:apotomo_root => @mum}, :version => 1)
        assert_equal 2, @processor.root.size
        assert_not @processor.widgets_flushed?
      end
    end
  end
  
  context "#process_event_request_for" do
    setup do
      ### FIXME: what about that automatic @controller everywhere?
      mum_and_kid!
      @mum.controller = nil # check if controller gets connected.
      @processor = Apotomo::RequestProcessor.new({:apotomo_root => @mum})
    end
    
    should "return 2 page_updates when @kid squeaks" do
      res = @processor.process_for({:type => :squeak, :source => 'kid'}, @controller)
      
      assert_equal 2, res.size
      assert_equal(Apotomo::Content::PageUpdate.new(:replace => 'mum', :with => 'alert!'), res[0])
      assert_equal(Apotomo::Content::PageUpdate.new(:replace => 'mum', :with => 'squeak'), res[1])
    end
  end
  
  context "#freeze!" do
    should "serialize the widget family to @session" do
      @processor = Apotomo::RequestProcessor.new({})
      @processor.root << mum_and_kid!
      assert_equal 3, @processor.root.size
      @processor.freeze!
      
      @processor = Apotomo::RequestProcessor.new(@processor.session)
      assert_equal 3, @processor.root.size
    end
  end
  
  context "#render_widget_for" do
    setup do
      @mum = mouse_mock('mum', :snuggle) do
        def snuggle; render; end
      end
      @mum.controller = nil
      
      @processor = Apotomo::RequestProcessor.new({:apotomo_root => @mum})
    end
    
    should "render the widget when passing an existing widget id" do
      assert_equal '<div id="mum"><snuggle></snuggle></div>', @processor.render_widget_for('mum', {}, @controller)
    end
    
    should "render the widget when passing an existing widget instance" do
      assert_equal '<div id="mum"><snuggle></snuggle></div>', @processor.render_widget_for(@mum, {}, @controller)
    end
    
    should "raise an exception when a non-existent widget id id passed" do
      assert_raises RuntimeError do
        @processor.render_widget_for('mummy', {}, @controller)
      end
    end
  end
end