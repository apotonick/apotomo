require 'rubygems'
require 'shoulda'
require 'mocha'

require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

Cell::Base.view_paths.unshift File.expand_path(File.dirname(__FILE__) + "/fixtures")

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
  include Apotomo::ControllerMethods
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


