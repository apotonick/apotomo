require 'rubygems'
require 'shoulda'

require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

Cell::Base.view_paths.unshift File.expand_path(File.dirname(__FILE__) + "/fixtures")

# Load test support files.
Dir[File.join(File.dirname(__FILE__), *%w[support ** *.rb]).to_s].each { |f| require f }


Test::Unit::TestCase.class_eval do
  include Apotomo::WidgetShortcuts
  include Apotomo::TestCaseMethods
  include Apotomo::AssertionsHelper
  
  def setup
    @controller = UrlMockController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.request   = @request
    @controller.response  = @response
    @controller.params    = {}
    @controller.session   = @session = {}
  end
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


class UrlMockController < ActionController::Base
  include Apotomo::ControllerMethods
  
  def controller;self;end
  
  def rescue_action(e) raise e end
  
  def index; render :text => ""; end
  
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
end