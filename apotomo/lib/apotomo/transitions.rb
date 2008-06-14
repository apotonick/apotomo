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
  
  def start_state_for_state(state)
    #s= (@start_states & transitions.fetch(state, [])).first
    s= (@start_states & transitions.fetch(state, [])).first || default_start_state
    puts "start_state: #{s}"
    return s
  end
  
end
