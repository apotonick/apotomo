Ext.namespace('Ext.ux');
Ext.namespace('Ext.ux.Plugin');

Ext.ux.Plugin.LiteRemoteComponent = function (config){
	var defaultType = config.xtype || 'panel';
    var callback = function(res){ 
		this.container.add(Ext.ComponentMgr.create(Ext.decode(res.responseText), defaultType)).show();
		this.container.doLayout() ;
	};
    return{
		init : function (container){
			this.container = container;
			Ext.Ajax.request(Ext.apply(config, {success: callback, scope: this}));
    	}
	}
};

/**
 * @author Timo Michna / matikom
 * @class Ext.ux.Plugin.RemoteComponent
 * @extends Ext.util.Observable
 * @constructor
 * @param {Object} config
 * @version 0.2.1
 * Plugin for Ext.Container/Ext.Toolbar Elements to dynamically 
 * add Components from a remote source to the Element´s body.  
 * Loads configuration as JSON-String from a remote source. 
 * Creates the Components from configuration.
 * Adds the Components to the Container body.
 * Additionally to its own config options the class accepts all the 
 * configuration options required to configure its internal Ext.Ajax.request().
 */
Ext.ux.Plugin.RemoteComponent = function (config){

   /**
    * @cfg {String} breakOn set to one of the plugins events, to stop any 
    * further processing of the plugin, when the event fires.
    */
   /**
    * @cfg {String} loadOn set to one of the Containers events, to stop any 
    * further processing of the plugin, when the event fires.
    */
   /**
	* @cfg {String} xtype Default xtype for loaded toplevel component.
	* Overwritten by config.xtype or xtype declaration 
	* Defaults to 'panel'
	* in loaded toplevel component.
	*/
	var defaultType = config.xtype || 'panel';
   /**
	* @cfg {String} purgeListeners Set true to automatically purge
	* any listner for the plugin after the process chain (even when the
	* processing has been stopped by config option breakOn).
	* Defaults to true
	* Overwritten by config.xtype or xtype declaration 
	* in loaded toplevel component.
	*/
    var purgeListeners = config.purgeListeners || true;
    this.addEvents({
	    /**
	     * @event beforeload
	     * Fires before AJAX request. Return false to stop further processing.
	     * @param {Object} config
	     * @param {Ext.ux.Plugin.RemoteComponent} this
	     */
        'beforeload' : true,
	    /**
	     * @event beforecreate
	     * Fires before creation of new Components from AJAX response. 
		 * Return false to stop further processing.
	     * @param {Object} JSON-Object decoded from AJAX response
	     * @param {Ext.ux.Plugin.RemoteComponent} this
	     */
        'beforecreate' : true,
	    /**
	     * @event beforeadd
	     * Fires before adding the new Components to the Container. 
		 * Return false to stop further processing.
	     * @param {Object} new Components created from AJAX response.
	     * @param {Ext.ux.Plugin.RemoteComponent} this
	     */
        'beforeadd' : true,
	    /**
	     * @event beforecomponshow
	     * Fires before show() is called on the new Components. 
		 * Return false to stop further processing.
	     * @param {Object} new Components created from AJAX response.
	     * @param {Ext.ux.Plugin.RemoteComponent} this
	     */
        'beforecomponshow': true,
	    /**
	     * @event beforecontainshow
	     * Fires before show() is called on the Container. 
		 * Return false to stop further processing.
	     * @param {Object} new Components created from AJAX response.
	     * @param {Ext.ux.Plugin.RemoteComponent} this
	     */
        'beforecontainshow': true,
	    /**
	     * @event success
	     * Fires after full process chain. 
		 * Return false to stop further processing.
	     * @param {Object} new Components created from AJAX response.
	     * @param {Ext.ux.Plugin.RemoteComponent} this
	     */
        'success': true
    });
	// set breakpoint 
	if(config.breakOn){
	 	this.on(config.breakOn, function(){return false;});
	}
   /**
    * private
    * Callback method for successful Ajax request.
    * Creates Components from responseText and  
    * and populates Components in Container.
    * @param {Object} response object from successful AJAX request.
    */
    var callback = function(res){ 
        var JSON = Ext.decode(res.responseText);
		if(this.fireEvent('beforecreate', JSON, this)){
			var component = Ext.ComponentMgr.create(JSON, defaultType);
			if(this.fireEvent('beforeadd', component, this)){
				
        
        items = eval(res.responseText);
        for (var i=0; i<items.length; i++) {
          component = items[i];
          this.container.add(component);
				}
        if(this.fireEvent('beforecomponshow', component, this)){
					component.show();
					if(this.fireEvent('beforecontainshow', component, this)){
						this.container.doLayout();
						this.fireEvent('success', component, this);
					} 					
				} 				
			} 				
		}   
		this.purgeListeners();
		
	};
   /**
    * public
    * Processes the AJAX request.
    * Generally only called internal. Can be called external,
    * when processing has been stopped or defered by config
    * options breakOn or loadOn.
    */
	this.load = function(){
		if(this.fireEvent('beforeload', config, this)){
			Ext.Ajax.request(Ext.apply(config, {success: callback, scope: this}));				
		} 
	};
   /**
    * public
    * Initialization method called by the Container.
    */
    this.init = function (container){
		container.on('beforedestroy', function(){this.purgeListeners();}, this);
		this.container = container;
		if(config.loadOn){
		 	var defer = function (){
				this.load();
				container.un(config.loadOn, defer, this);	
			};
			container.on(config.loadOn, defer, this);
		}else{
			this.load();	
		}           
    };
};
Ext.extend(Ext.ux.Plugin.RemoteComponent, Ext.util.Observable);
