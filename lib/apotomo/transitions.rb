module Apotomo::Transitions
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    ### TODO: document me, as soon as DSL is considered stable.
    def transition(options)
      if from = options[:from]
        class_transitions[from] ||= []
        class_transitions[from] << options[:to]
        return
      end
      
      if loop = options[:in]
        transition :from => loop, :to => loop
      end
    end
    
    def class_transitions; @class_transitions ||= {}; end
  end
  
  # Returns list of allowed transitions, which can be set in #transition_map and
  # with successive calls to #transition in the widget class.
  # Note that #transition_map will take precedence.
  def transitions; 
    self.class.class_transitions.merge(transition_map)
  end
  
  # Explicitly defines the valid state transistions for this widget instance.
  #
  # Example:
  #   def transition_map
  #     { :start_state_one  => [:some_state, :looping_state],
  #       :looping_state    => [:looping_state]
  #     }
  #   end
  #
  # This would create a state machine like
  #
  #
  #                        |---> :some_state
  #   :start_state_one --->|
  #                        |---> :looping_state ---
  #                                         ^     |
  #                                         |     |
  #                                         -------
  # Should be overridden by widgets, if they need to define a transition map per object.
  # Successive calls to #transition in the widget class should be sufficient for most needs.
  def transition_map; {};             end
  
  # Returns list of initial states which are set in widget constructor.
  def start_states; @start_states;    end
  
  
  def start_state?(state)
    start_states.include?(state)
  end
  
  def valid_next_state?(last_state, state)
    transitions.fetch(last_state, []).include?(state)
  end
  
  
  def find_next_state_for(last_state, input)
    input = input.to_sym if input
    
    # handle start states: ------------------------------------
    if not last_state
      return input if start_state?(input)
      return default_start_state
    end
    
    # handle thaw states --------------------------------------
    return input if valid_next_state?(last_state, input)
    return default_next_state_for(last_state) if transitions[last_state]
    return default_start_state
  end
  
  
  def default_start_state
    start_states.first
  end
  
  def default_next_state_for(last_state)
    transitions.fetch(last_state, []).first
  end
  
  
  # When the app is reloaded ("F5") by the user, every widget needs to go back to
  # a start state. This methods finds out this start state depending on the current
  # state of the widget.
  # Default is the first elem in start_states.
  # If you need to explicitly define a start state, put it into the transition_map.
  #
  # Example:
  # 
  # def transition_map
  #   { :current_state => [:_some_other_state, :_another_state, :amazing_start_state]
  #   }
  # end
  #
  # start_state_for_state(:current_state)
  #   => :amazing_start_state
  def start_state_for_state(state)
    s= (@start_states & transitions.fetch(state, [])).first || default_start_state
    puts "start_state: #{s}"
    return s
  end
  
end
