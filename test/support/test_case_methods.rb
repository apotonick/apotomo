module Apotomo
  module TestCaseMethods
    # Provides a ready-to-use mouse widget instance.
    def mouse_mock(id='mouse', start_state=:display, opts={}, &block)
      mouse = MouseWidget.new(parent_controller, id, start_state, opts)
      mouse.instance_eval &block if block_given?
      mouse
    end
    
    def mouse_class_mock(&block)
      klass = Class.new(MouseWidget)
      klass.instance_eval &block if block_given?
      klass
    end
    
    def mum_and_kid!
      @mum = mouse_mock('mum', :answer_squeak)
        @mum << @kid = mouse_mock('kid', :peek)
      
      @mum.respond_to_event :squeak, :with => :answer_squeak
      @mum.respond_to_event :squeak, :from => 'kid', :with => :alert
      @mum.respond_to_event :footsteps, :with => :escape
      
      @kid.respond_to_event :footsteps, :with => :peek
      
      
      @mum.instance_eval do
        def list; @list ||= []; end
        
        def answer_squeak;  self.list << 'answer squeak'; render :text => "squeak", :render_children => false; end
        def alert;          self.list << 'be alerted';    render :text => "alert!", :render_children => false; end
        def escape;         self.list << 'escape';        render :text => "escape", :render_children => false; end
      end
      
      @kid.instance_eval do
        def peek;           root.list << 'peek'; render :text => "" end
      end
      
      @mum
    end
    
    def barn_controller!
      @controller = Class.new(ActionController::Base) do
        def self.default_url_options; {:controller => :barn}; end
      end.new
      @controller.class.instance_eval { include Apotomo::Rails::ControllerMethods }
      @controller.extend ActionController::UrlWriter
      @controller.params  = {}
      ### FIXME: @controller.session = {}
    end
    

    
    module TestController
      def setup
        barn_controller!
      end
      
      # Creates a mock controller instance. Currently, each widget needs a parent controller instance due to some
      # sucky dependency in cells.
      def barn_controller!
        @controller = Class.new(ApotomoController) do
          def initialize(*)
            super
            self.request = ActionController::TestRequest.new
          end
          
          def self.name; "BarnController"; end
          
          def self.default_url_options; {:controller => :barn}; end
        end.new
      end
      
      def parent_controller
        @controller
      end
      
      def namespaced_controller
        controller = Farm::BarnController.new
        controller.request = ActionController::TestRequest.new
        controller
      end
      
    end
  end
end
