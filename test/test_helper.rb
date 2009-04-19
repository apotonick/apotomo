require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

Cell::Base.view_paths << File.expand_path(File.dirname(__FILE__) + "/fixtures")

class RenderingTestCell < Apotomo::StatefulWidget
  attr_reader :brain
  attr_reader :rendered_children, :state_view
  
  def check_state   # view resides in fixtures/apotomo/stateful_widget/
    @ivar = "#{@name} is cool."
    nil
  end
  
  def set_state_view_and_jump
    state_view! :widget_content
    jump_to_state :check_state
  end
end













class ApotomoUnitTestController < ApplicationController
  def rescue_action(e) raise e end
  
  def index; render :text => ""; end
end

module Apotomo::UnitTestCase
  
  attr_accessor :controller, :session
  
  # allow people to set up trees within test methods, with shortcuts.
  include Apotomo::WidgetShortcuts
  
  
  def setup
    @controller = ApotomoUnitTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.request   = @request
    @controller.response  = @response
    @controller.params    = {}
    @controller.session   = @session = {}
  end
  
  
  # session/request simulation --------------------------------------------------
  include Apotomo::ControllerMethods ### TODO: move neccessary methods to Persistance module.
  
  # Simulate a request-cycle end and the start of a new request. The tree is returned  
  # exactly as if there had been a new request and Rails handled the session thawing.
  def hibernate_tree(tree)
    freeze_tree_for(tree, session)
    
    # simulate CGI::Session's marshaling:
    dumped_tree = Marshal.dump(session['apotomo_widget_tree'])
    session['apotomo_widget_tree'] = Marshal.load(dumped_tree)
    
    return thaw_tree_for(session, controller)
  end
  
  
  
  
  # assertions ------------------------------------------------------------------
  
  def assert_selekt(content, *args, &block)
    assert_select(HTML::Document.new(content).root, *args, &block)
  end
  
  # Assert the <tt>widget</tt> is in <tt>state</tt>.
  def assert_state(widget, state)
    assert_equal state, widget.last_state
  end
  
  # Assert that an event of <tt>type</tt> and with <tt>source_id</tt> was triggered
  # and catched by at least one EventHandler.
  def assert_event(type, source_id)
    handlers = Apotomo::EventProcessor.instance.processed_handlers
    assert handlers.find{|h| h.event.type == type and h.event.source_id == source_id}
  end
  
  # test utils ------------------------------------------------------------------
  
  def re(str)
    Regexp.new(Regexp.escape(str))
  end
  
end
