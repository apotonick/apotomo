class Extjs::TextField < Extjs::Widget
  
  def extjs_class
    "Ext.form.TextField"
  end
  
  #def transition_map
  #  { :render_as_function => [:_load],
  #  }
  #end
  
  def init_config
      @config = {:id => name, :name => name}
    end
  
  # public. called either internal via #jump_to_state or via a /data request.
  ### DISCUSS: will this work?
  def _load
    data = load_data
    render :json => {:success => true, :data => data}
  end
  
  
  # may be overridden.
  def load_data
    value = param(:obj)
    @obj = {:text_field => value}
    return @obj
  end
  
  
  def load_url
    "/apotomo/data?widget_id=#{name}&state=_load"
  end
  
  def append_to_constructor_ignore
    ### DISCUSS: do we need .loadData ? is it an API property?
    "
el.loadData = function(fp)
  {
    fp.getForm().load(
    {
      url: '#{load_url}',
      method: 'GET',
      waitMsg: 'Lade Formulardaten..',
      waitTitle: 'Bitte warten',
    });
    fp.removeListener('show', fp.loadData);
  }
el.addListener('show', el.loadData);
el.addButton('Speichern', function(){
  el.getForm().submit(
    {
      url: 'blabla', 
      waitMsg: 'Speichere Daten', waitTitle: 'Bitte warten'});
  });         
  el.addButton('Abbrechen', function(){
    el.loadData(el);
  });
"
  end
  
end
