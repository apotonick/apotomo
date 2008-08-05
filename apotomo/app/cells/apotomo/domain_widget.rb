class Apotomo::DomainWidget < Apotomo::StatefulWidget
  
  def initialize(*args)
    super(*args)
    
    @user_param_handler     = {}
    @default_param_handler  = {}
    
    init_domain_params(domain_params)
  end
  
  
  ### FIXME: i don't like this part:
  def domain_params
    @opts
  end
  
  
  def init_domain_params(params_with_defaults)
    @domain_params = HashWithIndifferentAccess.new.merge!(params_with_defaults)
  end
  
  def add_domain_param(param, default=true)
    @domain_params[param] = default
  end
  
  
  #def prepare_render
  #  self.state_data= current_domain_values
  #end
  
  
  #def address_to(way, state)
  #  self.state_data= current_domain_values  ### FIXME: not nice here!
  #  super(way, state)
  #end
  
  
  def current_domain_values
    domain_values = {}
    @domain_params.each_key do |param_name|
      domain_values[param_name] = current_domain_value_for_param(param_name)
    end
    
    domain_values
  end
   
  
  ### DISCUSS: we should use param(param_name).
  ### DISCUSS: is it wise to access the request param value here? it's a
  ### security hole.
  ### DISCUSS: should the call to param(s) be first choice 
  ### (request -> user_val -> default)?
  def current_domain_value_for_param(param_name)
    
    res = user_value_for_param(param_name) || params[param_name] || default_value_for_param(param_name)
    
    return res
  end
  
  
  ### TODO: refactorate the following two in one method:
  def user_value_for_param(param_name)
    method = "user_value_for_#{param_name}"
    
    return method(method.to_sym).call if methods.include?(method)
    
    if block = @user_param_handler[param_name]
      return block.call(param_name)
    end
    
    return params[param_name.to_s]
  end
  
  
  def default_value_for_param(param_name)
    method = "default_value_for_#{param_name}"
    
    return method(method.to_sym).call if methods.include?(method)
    
    if block = @default_param_handler[param_name]
      return block.call(param_name)
    end
    
    puts "returning default for #{param_name}"
    
    return @domain_params[param_name]
  end
  
  
  def param_for(name, cell)
    return unless is_my_domain?(name)
    
    return current_domain_value_for_param(name)
  end
  
  
  def is_my_domain?(name)
    @domain_params.has_key?(name)
  end
  
end
