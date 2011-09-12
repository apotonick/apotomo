# wycats says...
require 'rubygems'
require 'bundler'
Bundler.setup

require 'shoulda'

ENV['RAILS_ENV'] = 'test'
require "dummy/config/environment"
require "rails/test_help" # sets up ActionController::TestCase's @routes

require 'cells'
require 'apotomo'

Apotomo::Widget.append_view_path(File.expand_path(File.dirname(__FILE__) + "/widgets"))

# Load test support files.
require "test_case_methods"


Test::Unit::TestCase.class_eval do
  include Apotomo::WidgetShortcuts
  include Apotomo::TestCaseMethods
  
  def assert_not(assertion)
    assert !assertion
  end
end

class ApotomoController < ActionController::Base
  include Apotomo::Rails::ControllerMethods
  include Rails.application.routes.url_helpers
  
  def mum
  end
end

module Farm
  class BarnController < ApotomoController
  end
end

class MouseWidget < Apotomo::Widget
end


class MouseWidget < Apotomo::Widget
  def squeak
    render :text => "squeak!"
  end
  def eating
    render
  end
  def eat
    render
  end
  
end

# Enable dynamic states so we can do Cell.class_eval { def ... } at runtime.
Apotomo::Widget.class_eval do
  def action_method?(*); true; end
end
