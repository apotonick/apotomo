require File.join(File.dirname(__FILE__), *%w[.. test_helper])
 
class ControllerMethodsTest < Test::Unit::TestCase
  context "#process_event_request" do
    setup do
      mum_and_kid!
      
      PageUpdate = Apotomo::PageUpdate
    end
    
    should "encounter 2 page-updates when @kid squeaks" do
      @controller = Class.new do
        def self.before_filter(*args);end
        def freeze_apotomo_root!;end        ### FIXME: remove #freeze_apotomo_root! dependency from #process_event_request. what does it do there?
        include Apotomo::ControllerMethods  ### FIXME: remove before_filter dependency.
        
        def render_page_update_for(page_updates)
          page_updates
        end
      end.new
      
      mum = @mum
      @controller.instance_eval do  ### FIXME: how do we connect RequestProcessor and the widget tree from the session?
        @apotomo_root = mum
      end
      
      
      res = @controller.process_event_request({:type => :squeak, :source => 'kid', :action => :event})  ### FIXME: remove :action, find out differently.
      
      assert_equal 2, res.size
      assert_equal(PageUpdate.new(:replace => 'mum'), res.first)
      assert_equal(PageUpdate.new(:replace => 'mum'), res.last)
    end
    
  end
end