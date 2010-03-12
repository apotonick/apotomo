module Apotomo::Transition
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    # Defines a transition for an implicit invoke.
    #
    # Usually when a container widget renders its kids there is no <tt>state</tt> passed to the
    # kid's #invoke ("implicit invoke") and thus the kid will enter its start state again.
    # You can customize that behaviour by setting a transition to let the widget jump to the 
    # defined <tt>:to</tt> state in place of the start state.
    #
    # Example:
    #   class Kid < MouseWidget
    #     transition :from => :sleep, :to => :snore
    #
    # Next time when mum renders and kid is in <tt>:sleep</tt> state kid will not return to its 
    # start state but invoke <tt>:snore</tt>.
    #
    #   class Kid < MouseWidget
    #     transition :in => :snore
    #
    # In subsequent render cycles from mum kid will keep snoring whereas other kids would go back
    # to the start state.
    def transition(options)
      if from = options[:from]
        class_transitions[from] = options[:to]
      elsif loop = options[:in]
        transition :from => loop, :to => loop
      end
    end
    
    def class_transitions
      @class_transitions ||= {}
    end
  end
  
  protected
    # Returns the next state for <tt>state</tt> or nil. A next state must have been defined 
    # with #transition.
    def next_state_for(state)
      self.class.class_transitions[state]
    end
end
