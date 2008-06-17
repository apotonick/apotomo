require File.expand_path(File.dirname(__FILE__) + "/../../apotomo/test/test_helper")


class TreePanelTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
  end
  
  
  def test_js_rendering
      w = Extjs::TreePanel.new(@controller, 'my_tree_panel', :render_as_function)
    
    puts c = w.invoke
    
    c = c.to_s
    
    assert_match /\(function\(\)\{ var el = new Ext\.tree\.TreePanel/, c
    assert_match /listeners: \{click:/, c
    assert_match /loader: new /, c
    assert_match /id: "my_tree_panel"/, c
    assert_no_match /var root = new/, c # no store set!
  end
  
  
  ### TODO: test this with TabPanel instead of Panel.
  def test_correct_states_selection
    ts = TestTreeStore.new
    ts[:root] = {:two=>{:two_one=>{}}, :three=>{}}
    
    root = Extjs::Panel.new(@controller, 'root', :render_as_function_to)
    root << w = Extjs::TreePanel.new(@controller, 'my_tree_panel', :render_as_function)
    w.set_store(ts)
    
    # render initial TreePanel:
    c = w.invoke(:render_as_function)
    assert_equal w.last_state, :render_as_function
    
    # simulate the initial load for e.g. the root node:
    @controller.params[:node] = :three
    c = w.invoke(:load)
    assert_equal w.last_state, :load
    
    # simulate a F5:
    c = root.invoke("*")
    assert_equal w.last_state, :render_as_function
  end
  
  
  def test_add_store
    ts = TestTreeStore.new
    ts[:root] = {:two=>{:two_one=>{}}, :three=>{}}

    w = Extjs::TreePanel.new(@controller, 'my_tree_panel', :render_as_function)
    w.set_store(ts)
      
    puts c = w.invoke
    
    assert_match /text: "root"/, c.to_s
    #w.opts={:node_id}
    #data = w.load
  end
  
  
  def test_data_tree
    ts = TestTreeStore.new
    ts[:root] = {:two=>{:two_one=>{}}, :three=>{}}
    
    puts ts.root_item
    puts ts.items_for_node_id(:root).inspect
    ### FIXME:
    
    # return an empty list if node NOT FOUND:
    #assert_equal ts.items_for_node_id(nil), []
  end
end

class TestTreeStore < Hash
  def root_item    
    {:text => :root, :leaf => false}
  end
  def items_for_node_id(node_id)  
    return root_item if node_id == :root  
    
    fetch(:root)[node_id].collect do |k,v|
      {:text => k, :leaf => v.size > 0 ? true : false}
    end
  end
end
