require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ViewHelperTest < ActionView::TestCase  
  tests Apotomo::ViewHelper
    
  
  def test_link_tag_without_host_option
    ActionController::Base.class_eval { attr_accessor :url }
    url = {:controller => 'weblog', :action => 'show'}
    @controller = ActionController::Base.new
    @controller.request = ActionController::TestRequest.new
    @controller.url = ActionController::UrlRewriter.new(@controller.request, url)
    assert_dom_equal(%q{<a href="/weblog/show">Test Link</a>}, link_to('Test Link', url))
  end
  
  

  
  class CWidget < Apotomo::StatefulWidget
    def local_address(*args); {:c_address => :important}; end
  end
  
  
  def setup
    ### FIXME: copied from rails-2.3/actionpack/url_helper_test.rb
    ###   found no other way to test methods relying on #url_for due to rails' paucity
    ###   of an internal API, and too many dependencies on instance vars instead of arguments
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller = Class.new do
      include Apotomo::ControllerMethods
      
      def url_for(options)
        url         =  "http://www.apotomo.de/"
        action      = options[:action]      || :drink
        controller  = options[:controller]  || :beers
        
        url << "#{controller}/#{action}"
        
        return url unless options
        
        options.delete(:only_path)
        options.delete(:controller)
        options.delete(:action)        
        
        url << "?" + options.sort{|a,b| a.to_s <=> b.to_s}.collect {|e| "#{e.first}=#{e.last}"}.join("&") unless options.blank?
        url
      end
    end.new
    
    
    @a = Apotomo::StatefulWidget.new(@controller, 'a')
    @b = Apotomo::StatefulWidget.new(@controller, 'b')
    @c = CWidget.new(@controller, 'c')
    @a << @b
    @a << @c
  end
  
  def protect_against_forgery?
    false
  end
  
  # test Apotomo::ViewHelper methods --------------------------
  
  def test_current_tree
    @cell =  @a
    assert_equal @a, current_tree # --> #current_tree should return the root.
  end
  
  
  def test_target_widget_for
    @cell =  @a
    assert_equal target_widget_for(), @a
    assert_equal target_widget_for('b'), @b
  end
  
  
  def test_static_link_to_widget
    @cell =  @a
    
    # address current widget ----------------------------------
    assert_dom_equal "<a href=\"http://www.apotomo.de/beers/drink\">Static Link</a>",
      static_link_to_widget("Static Link")
    
    # explicitly define controller ----------------------------
    assert_dom_equal "<a href=\"http://www.apotomo.de/milk/drink\">Static Link</a>",
      static_link_to_widget("Static Link", false, :controller => 'milk')
  end
  
  def test_link_to_widget
    @cell =  @c
    
    assert_dom_equal "<a href=\"http://www.apotomo.de/beers/drink?c_address=important\" onclick=\"new Ajax.Request('http://www.apotomo.de/beers/drink?apotomo_action=event&amp;c_address=important&amp;source=c&amp;type=redrawApp', {asynchronous:true, evalScripts:true}); return false;\">Hybrid Link</a>",
      link_to_widget("Hybrid Link")
  end
  
  
  def test_link_to_event    
    @cell =  @c
    
    
    # test explicit source ------------------------------------
    assert_dom_equal "<a href=\"#\" onclick=\"new Ajax.Request('http://www.apotomo.de/beers/drink?apotomo_action=event&amp;source=b&amp;type=put', {asynchronous:true, evalScripts:true}); return false;\">Event Link</a>",
      link_to_event("Event Link", :source => 'b', :type => :put)
    
    
    # test default source widget ------------------------------
    assert_dom_equal "<a href=\"#\" onclick=\"new Ajax.Request('http://www.apotomo.de/beers/drink?apotomo_action=event&amp;source=c&amp;type=put', {asynchronous:true, evalScripts:true}); return false;\">Event Link</a>",
      link_to_event("Event Link", :type => :put)
  end
  
  def test_form_to_event
    @cell =  @b
    
    # test default source -------------------------------------
    l = form_to_event
    puts l
    
    assert_match /source=b/, l
    assert_match /<form/, l
    assert_no_match /<\/form>/, l
    
    return
    ### FIXME: could someone make this test work?
    # test with block -----------------------------------------
    l = form_to_event do
    end
    puts l    
    assert_match /<form/, l
    assert_match /<\/form>/, l
  end
  
  
  def test_address_to_event
    @cell =  @a
        
    addr = address_to_event()
    assert_equal addr[:source], 'a'
    
    addr = address_to_event(:source => 'b')
    assert_equal addr[:source], 'b'
    
    addr = address_to_event(:param_1 => 'one')
    assert_equal addr[:source],   'a'
    assert_equal addr[:param_1],  'one'
  end
  
  def test_address_to_event_with_default_url_options
    @cell =  @a
    
    # test implicit behaviour, with no :action set ------------
    addr = address_to_event
    assert_nil addr[:action]
    
    # set :action ---------------------------------------------
    @controller.apotomo_default_url_options = {:action => :my_process_event}
    addr = address_to_event()
    assert_equal  :my_process_event, addr[:action]
    assert_nil    addr[:controller]
    
    # set :action and :controller -----------------------------
    @controller.apotomo_default_url_options = {:action => :my_process_event, :controller => :beers}
    addr = address_to_event
    assert_equal  :my_process_event,  addr[:action]
    assert_equal  :beers,             addr[:controller]
    
    # set both but pass in :action as arg ---------------------
    @controller.apotomo_default_url_options = {:action => :my_process_event, :controller => :beers}
    addr = address_to_event(:action => :another_process_event)
    assert_equal  :another_process_event, addr[:action]
    assert_equal  :beers,                 addr[:controller]
  end
  
  
  def test_address_to_event_with_implicit_invoke_handler
    # test if handler is attached  to correct target!
  end
end
