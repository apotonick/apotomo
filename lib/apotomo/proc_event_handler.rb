module Apotomo
  class ProcEventHandler < EventHandler
    attr_accessor :proc
    
    def process_event(event)
      puts "ProcEventHandler: calling #{@proc}"
      #@proc.call(event)
      event.source.controller.send(@proc, event)
      self
    end
    
    def to_s; "ProcEventHandler:#{proc}"; end
  end
end