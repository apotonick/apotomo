require "onfire/debugging"

Apotomo::Event.class_eval do
  include Onfire::Event::Debugging
  
  debug do |widget, event|
    puts "#{widget.name}: #{event}"
  end
end
