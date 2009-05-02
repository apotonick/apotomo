require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ApotomoCachingTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session= {}
    @cc = CachingCell.new(@controller, 'caching_cell', :start)
  end
  
  
  def test_caching_with_instance_version_proc
    unless ActionController::Base.cache_configured?
      throw Exception.new "cache_configured? returned false. You may enable caching in your config/environments/test.rb to make this test pass."
      return
    end
    c1 = @cc.invoke
    c2 = @cc.invoke
    assert_equal c1, c2
    
    @cc.dirty!
    
    c3 = @cc.invoke
    assert c2 != c3
  end
  
end


class CachingCell < Apotomo::StatefulWidget
  
  cache :cached_state
  
  transition :in => :cached_state
  
  
  def start
    jump_to_state :cached_state
  end
  
  def cached_state
    @counter ||= 0
    @counter += 1
    "#{@counter}"
    
  end
  
  def not_cached_state
    "i'm really static"
  end
end
