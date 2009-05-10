module Apotomo
  class ProcEventHandler < EventHandler
    attr_accessor :proc
    
    def initialize(opts={})
      @proc = opts.delete(:proc)
    end
    
    def process_event(event)
      puts "ProcEventHandler: calling #{@proc}"
      #@proc.call(event)
      event.source.controller.send(@proc, event)
      nil ### DISCUSS: needed so that controller doesn't evaluate the "content".
    end
    
    def to_s; "ProcEventHandler:#{proc}"; end
  end
end