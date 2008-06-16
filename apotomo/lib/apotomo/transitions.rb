### DISCUSS: it's a module so we can better test it. is this good?
module Apotomo::Transitions
  
  def transitions; {}; end
  
  
  def start_state?(state)
    @start_states.include?(state)
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
    @start_states.first
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
