# wycats says...
require 'rubygems'
require 'bundler'
Bundler.setup

require 'shoulda'
require 'cells'
require 'apotomo'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # sets up ActionController::TestCase's @routes


Cell::Base.append_view_path File.expand_path(File.dirname(__FILE__) + "/fixtures")

# Load test support files.
require File.join(File.dirname(__FILE__), "support/test_case_methods")


Test::Unit::TestCase.class_eval do
  include Apotomo::WidgetShortcuts
  include Apotomo::TestCaseMethods
  
  def assert_not(assertion)
    assert !assertion
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


# Enable dynamic states so we can do Cell.class_eval { def ... } at runtime.
class Apotomo::Widget
  def action_method?(*); true; end
end
