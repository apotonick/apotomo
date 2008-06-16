require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper') # the default rails helper


# set up the fixtures location
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__)  + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)



class ApotomoUnitTestController < ApplicationController
  def rescue_action(e) raise e end
  
  def index; render :text => ""; end
end

module Apotomo::EmptyModule
  def setup
    super
    @controller = ApotomoUnitTestController.new
    @controller.params  = {}
    
    
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
end

module Apotomo::UnitTestCase
  
  def setup
    super ### FIXME: if omitted, the fixtures don't get inserted.
    @controller = ApotomoUnitTestController.new
    @controller.params  = {}
    @controller.session = {}
    
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  
  def with_loading(*from)
 	  old_mechanism, Dependencies.mechanism = Dependencies.mechanism, :load
 	  dir = File.dirname(__FILE__)
 	  prior_autoload_paths = Dependencies.load_paths
 	  Dependencies.load_paths = from.collect { |f| "#{dir}/unit/#{f}" }
 	  yield
  ensure
 	  Dependencies.load_paths = prior_autoload_paths
 	  Dependencies.mechanism = old_mechanism
  end
  
  
  def assert_selekt(content, *args)
    assert_select(HTML::Document.new(content).root, *args)
  end
  
  def re(str)
    Regexp.new(Regexp.escape(str))
  end
  
end
