# wycats says...
require 'bundler'
Bundler.setup

#require 'rubygems'
require 'shoulda'
require 'mocha'
require 'mocha/integration'


require 'cells'
Cell::Base.add_view_path File.expand_path(File.dirname(__FILE__) + "/fixtures")

puts Cell::Base.view_paths

require 'apotomo'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/controller_methods'
require 'apotomo/rails/view_methods'
#require 'apotomo/assertions_helper'

#require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')



# Load test support files.
Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }


Test::Unit::TestCase.class_eval do
  include Apotomo::WidgetShortcuts
  include Apotomo::TestCaseMethods
  include Apotomo::AssertionsHelper
  
  def setup
    @controller = ApotomoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.request   = @request
    @controller.response  = @response
    @controller.params    = {}
    @controller.session   = @session = {}
  end
end

class ApotomoController < ActionController::Base
  include Apotomo::Rails::ControllerMethods
end

class MouseCell < Apotomo::StatefulWidget
  def eating; render; end
end

class RenderingTestCell < Apotomo::StatefulWidget
  attr_reader :brain
  attr_reader :rendered_children
  
  
  
  def jump
    jump_to_state :check_state
  end
end



# We need to setup a fake route for the controller tests.
ActionController::Routing::Routes.draw do |map|
  map.connect 'apotomo/:action', :controller => 'apotomo'
  map.connect 'barn/:action', :controller => 'barn'
end

module ::Rails
  def logger(*args); end
end

require 'app/cells/apotomo/container_widget' ### FIXME: change to lib...