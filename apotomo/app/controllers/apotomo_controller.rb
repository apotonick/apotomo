class ApotomoController < ApplicationController
  
  # The central action for events within the Apotomo environment.
  # Any event is sent to this action. It just triggers the event,
  # the processing happens through the widget tree. 
  def event
    tree      = ApplicationWidgetTree.new(self).draw_tree.root
    processor = Apotomo::EventProcessor.instance
    processor.init
    
    type = params[:type] || :invoke
    
    
    tree.find_by_id(params[:source]).trigger(type.to_sym)
    
    processed_handlers = processor.process_queue_for(tree, nil)


    render :update do |page|
      processed_handlers.each do |handler|
        ### DISCUSS: i don't like that switch, but moving this behaviour into the
        ###   actual handler is too complicated, as we just need replace and exec.
        if handler.content.class == String
          page.replace handler.widget_id, handler.content
        else
          page << handler.content
        end
      end

    end
  end
  
  
  ### FIXME: duplicate code sucks!
  
  def data
    tree = ApplicationWidgetTree.new(self).draw_tree.root
    
    # simulate initial event:
    #handler= Apotomo::AjaxEventHandler.new
    handler= Apotomo::EventHandler.new
    handler.widget_id = params[:widget_id]
    handler.state     = params[:state].to_sym if params[:state]
    
    
    processor = Apotomo::EventProcessor.instance
    processor.init
    processor.queue_handler(handler)
    #@processed_handlers = processor.process_queue_for_tree(tree)
    
    puts "# handlers processed:"
    #puts @processed_handlers.size
    
    #@processed_handlers.each do |h|
    #  puts "#{h.widget_id} -> #{h.state}"
    #end
    @processed_handlers = processor.process_queue_for(tree, nil)
    render :text => @processed_handlers.first.content
  end
  
end
