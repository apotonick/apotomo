module Apotomo
  module TreeNode
    include Enumerable
    include Apotomo::WidgetShortcuts::DSL

    # DISCUSS: do we need it? we have []!
    # DISCUSS: #children receives a block, but #childrenHash doesn't
    attr_reader :childrenHash
    attr_accessor :parent
  
    def setup_tree_node(parent) # DISCUSS: make private?
      @parent       = nil
      @childrenHash = {}
      @children     = []
      
      # DISCUSS: and what if not a Widget?
      parent.add_widget(self) if parent.kind_of? Widget # TODO: as long as cells needs parent_controller.
    end

    # Print the string representation of this node.
    def to_s
      # DISCUSS: why self.widget_id but parent.name ?
      "Node ID: #{widget_id} Parent: " + (root?  ? "ROOT" : "#{parent.name}") +
        " Children: #{children.length}" + " Total Nodes: #{size}"
    end

    def add_widget(child)  # TODO: rename #add, make private
      raise "Child already added" if @childrenHash.has_key?(child.name)
      
      @childrenHash[child.widget_id] = child
      @children << child
      child.parent = self
    
      child
    end

    # Removes the specified child node from the receiver node.
    # The removed children nodes are orphaned but available
    # if an alternate reference exists.
    # Returns the child node.
    def remove!(child)
      @childrenHash.delete(child.name)
      @children.delete(child)
      # DISCUSS: why `unless child == nil`? if child is nil, an exception has been raised two locs above!
      child.root! unless child == nil
      child
    end

    # Private method which sets this node as a root node.
    def root!
      @parent = nil
    end
  
    # Indicates whether this node is a root node. Note that
    # orphaned children will also be reported as root nodes.
    def root?
      @parent == nil
    end
  
    # Returns an array of all the immediate children.
    # If a block is given, yields each child node to the block.
    def children
      if block_given?
        @children.each { |child| yield child }
      else
        @children
      end
    end

    # Returns every node (including the receiver node) from the
    # tree to the specified block.
    def each(&block)
      yield self
      children { |child| child.each(&block) }
    end

    # Returns the requested node from the set of immediate
    # children.
    #
    # If the key is _numeric_, then the in-sequence array of
    # children is accessed (see Tree#children).
    # If the key is not _numeric_, then it is assumed to be
    # the *name* of the child node to be returned.
    def [](name)
      if name.kind_of?(Integer)
        children[name]
      else
        childrenHash[name]
      end
    end

    # Returns the total number of nodes in this tree, rooted
    # at the receiver node.
    def size
      children.inject(1) {|sum, node| sum + node.size}
    end

    # Pretty prints the tree starting with the receiver node.
    def printTree(tab = 0)
      children {|child| child.printTree(tab + 4)}
    end

    # Returns the root for this node.
    def root
      root = self
      root = root.parent while !root.root?
      root
    end

    # Provides a comparision operation for the nodes. Comparision
    # is based on the natural character-set ordering for the
    # node names.
    # DUISCUSS: useful?
    # DUISCUSS: <, >, etc., operators doesn't work because of Comparable isn't included
    def <=>(other)
      return +1 if other == nil
      self.name <=> other.name
    end
  
    protected :parent=, :root!
  
    def find_by_path(selector)
      next_node = self
      last      = nil # prevents self-finding loop.
      selector.to_s.split(/ /).each do |node_id|
        last = next_node = next_node.find {|n|
          n.name.to_s == node_id.to_s and not n==last
        }
      end
    
      next_node
    end
  
  
    # Returns the path from the widget to root, encoded as
    # a string of slash-seperated names.
    def path
      path      = [name]
      ancestor  = parent
      while ancestor
        path << ancestor.name
        ancestor = ancestor.parent
      end
    
      path.reverse.join("/")
    end
  end
end
