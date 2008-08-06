class Extjs::FormPanel < Extjs::Panel
  
  def extjs_class
    "Ext.FormPanel"
  end
  
  def transition_map
    { :render_as_function => [:_load],
      :_load => [:_load, :_save],           # allow multiple loading.
      :_save => [:_save],                   # allow multiple saving.
    }
  end
  
  
  # loading ---------------------------------------------------
  # public. called either internal via #jump_to_state or via a /data request.
  ### DISCUSS: will this work?
  def _load
    data = load_data
    render :json => {:success => true, :data => data}
  end
  
  
  # may be overridden.
  def load_data
    {}
  end
  
  
  # saving ----------------------------------------------------
  
  def _save
    res = validate
    render :json => res
  end
  
  
  def validate
    res = process_data(get_input)
    
    ### DISCUSS: build Extjs result hash here?
  end
  
  
  # Implement your form workflow in this method (check -> confirm -> save -> whatever).
  # This method <em>must</em> return a ... ### TODO: what object should be returned?
  # may be overridden.
  def process_data(data)
    {:success => false, :errors => {}}
  end
  
  def get_input
    params  ### FIXME: only provide form input data!!!
    
    ### DISCUSS: would it be helpful to get input from the childs here?
    ###   in most cases, this might be to fine-grained.
  end
  
  
  # Return this in #process_data to report valid input to the user and
  # to let him know his data was saved. 
  def valid_answer(data={}) ### TODO: pass data to the form, like :flash.
    {:success => true}
  end
  
  
  # Return this in #process_data to report invalid input to the user.
  # Add error messages to errors to inform him about his false input.
  def invalid_answer(errors={})
    {:success => false, :errors => errors}
  end
  
  
  # javascript generation -------------------------------------
  
  ### TODO: move this into the JS config hash, and let ExtJS do the JS generation.
  def append_to_constructor
    ### DISCUSS: right now, clicking "Load" (re-)loads form data for testing purposes.
    "
#{loader_js}

el.addButton('Save', function(){
  el.getForm().submit({
      url: '#{save_url}', 
      waitMsg: 'Saving...', waitTitle: 'Please have patience'});
  });  
  
    
"
  end
  
  def loader_js
    "
var loader = (function(fp) {
    fp.getForm().load(
    {
      url: '#{load_url}',
      method: 'GET',
      waitMsg: 'Loading...',
      waitTitle: 'Please have patience',
    });
    /*fp.removeListener('show', fp.loader);*/
});
el.addListener('show', loader);
el.addButton('Load', function(){
    loader(el);
  });
"
  end
  
  
  def load_url
    "/apotomo/data?widget_id=#{name}&state=_load"
  end
  
  def save_url
    "/apotomo/data?widget_id=#{name}&state=_save"
  end
end
