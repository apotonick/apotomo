module Apotomo
  module TestCaseMethods
    def root_mock
      MouseWidget.new(parent_controller, :root)
    end
    
    def mouse(id=nil, &block)
      MouseWidget.new(parent_controller, id || :mouse).tap do |widget|
        widget.instance_eval &block if block_given?
      end
    end
    
    def mouse_mock(id='mouse', opts={}, &block)
      widget(:mouse, id, opts)
    end
    
    def mouse_class_mock(&block)
      klass = Class.new(MouseWidget)
      klass.instance_eval &block if block_given?
      klass
    end
    
    def mum_and_kid!
      @mum = mouse('mum')
        @kid = MouseWidget.new(@mum, 'kid')
      
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
    
    def root_mum_and_kid!
      mum_and_kid!

      @root = Apotomo::Widget.new(parent_controller, 'root', :display)
      @root << @mum
    end

    def barn_controller!
      @controller = Class.new(ActionController::Base) do
        def self.default_url_options
          { :controller => :barn }
        end
      end.new
      @controller.extend(ActionController::UrlWriter)
      @controller.params = {}
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
          
          def self.name
            "BarnController"
          end
          
          def self.default_url_options
            { :controller => :barn }
          end
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
