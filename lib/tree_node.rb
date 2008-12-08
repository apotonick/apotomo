# stolen from ... ? couldn't find the original lib on the net.
### TODO: insert copyright notice!

module TreeNode
  include Enumerable

  attr_reader :content, :name, :parent
  attr_writer :content

  @@fieldSep = '|'
  @@recordSep = "\n.\n"

  # Constructor which expects the name of the node
  #
  # name of the node is expected to be unique across the
  # tree.
  def init_tree_node(name)
    @name = name
    self.setAsRoot!

    @childrenHash = Hash.new
    @children = []
  end

  # Print the string representation of this node.
  def to_s
          s = size()
          "Node ID: #{@name} Content: #{@content} Parent: " +
                  (isRoot?()  ? "ROOT" : "#{@parent.name}") +
                  " Children: #{@children.length}" +
                  " Total Nodes: #{s}"
  end

  # Protected method to set the parent node.
  # This method should NOT be invoked by client code.
  def parent=(parent)
      @parent = parent
  end

  # Convenience synonym for Tree#add method. 
  # This method allows a convenient method to add
  # children hierarchies in the tree.
  # E.g. root << child << grand_child
  def <<(child)
      add(child)
  end

  # Adds the specified child node to the receiver node.
  # The child node's parent is set to be the receiver.
  # The child is added as the last child in the current
  # list of children for the receiver node.
  def add(child)
      raise "Child already added" if @childrenHash.has_key?(child.name)

      @childrenHash[child.name]  = child
      @children << child
      child.parent = self
      return child

  end

  # Removes the specified child node from the receiver node.
  # The removed children nodes are orphaned but available
  # if an alternate reference exists.
  # Returns the child node.
  def remove!(child)
      @childrenHash.delete(child.name)
      @children.delete(child)
      child.setAsRoot! unless child == nil
      return child
  end

  # Removes this node from its parent. If this is the root node,
  # then does nothing.
  def removeFromParent!
      @parent.remove!(self) unless isRoot?
  end

  # Removes all children from the receiver node.
  def removeAll!
      for child in @children
          child.setAsRoot!
      end
      @childrenHash.clear
      @children.clear
      self
  end
  
  def move_children_to(target)
    children.clone.each {|c|# puts "adding child #{c}";  
      @childrenHash.delete(c.name)
      @children.delete(c)
      target << c
    }
  end
  
  
  # Private method which sets this node as a root node.
  def setAsRoot!
      @parent = nil
  end

  # Indicates whether this node is a root node. Note that
  # orphaned children will also be reported as root nodes.
  def isRoot?
      @parent == nil
  end

  # Indicates whether this node has any immediate child nodes.
  def hasChildren?
      @children.length != 0
  end

  # Returns an array of all the immediate children.
  # If a block is given, yields each child node to the block.
  def children
      if block_given?
          @children.each {|child| yield child}
      else
          @children
      end
  end

  # Returns every node (including the receiver node) from the
  # tree to the specified block.
  def each &block
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
  def [](key)
      raise "Key needs to be provided" if key == nil

      if key.kind_of?(Integer)
          @children[key]
      else
          @childrenHash[key]
      end
  end

  # Returns the total number of nodes in this tree, rooted
  # at the receiver node.
  def size
      @children.inject(1) {|sum, node| sum + node.size}
  end

  # Convenience synonym for Tree#size
  def length
      size()
  end

  # Pretty prints the tree starting with the receiver node.
  def printTree(tab = 0)
      puts((' ' * tab) + self.to_s)
      children {|child| child.printTree(tab + 4)}
  end

  # Returns the root for this node.
  def root
      root = self
      root = root.parent while !root.isRoot?
      root
  end

  # Returns an array of siblings for this node.
  # If a block is provided, yeilds each of the sibling
  # nodes to the block.
  def siblings
      if block_given?
          return nil if isRoot?
          for sibling in parent.children
  yield sibling if sibling != self
          end
      else
        return [self] if isRoot?
          siblings = []
          parent.children {|sibling| siblings << sibling if sibling != self}
          siblings
      end
  end

  # Provides a comparision operation for the nodes. Comparision
  # is based on the natural character-set ordering for the
  # node names.
  def <=>(other)
      return +1 if other == nil
      self.name <=> other.name
  end

  # Freezes all nodes in the tree
  def freezeTree!
      each {|node| node.freeze}
  end

  # Creates a dump representation
  def createDumpRep
      strRep = String.new
      #strRep << @name << @@fieldSep << (isRoot? ? @name : @parent.name)
      strRep << @name.to_s << @@fieldSep << (isRoot? ? @name.to_s : @parent.name.to_s)
      #strRep << @@fieldSep << Marshal.dump(@content) << @@recordSep
      
      instance_content = String.new
      
      (self.instance_variables - ivars_to_forget).each do |var|
        #puts var
        #puts instance_variable_get(var).inspect
        instance_content << var << ":" << Marshal.dump(instance_variable_get(var)) << "^"
      end
      #strRep << @@fieldSep << Marshal.dump(@content) << @@recordSep
      
      strRep << @@fieldSep << instance_content << @@recordSep
  end

  def _dump(depth)
      strRep = String.new
      each {|node| strRep << node.createDumpRep}
      strRep
  end
  
  
  def self.loadDumpRep(str)
      nodeHash = Hash.new
      rootNode = nil
      str.split(@@recordSep).each do |line|
          name, parent, contentStr = line.split(@@fieldSep)
          content = Marshal.load(contentStr)
          currentNode = Tree::TreeNode.new(name, content)
          nodeHash[name] = currentNode
          if name != parent  # Do for a child node
              nodeHash[parent].add(currentNode)
          else
              rootNode = currentNode
          end
      end
      rootNode
  end

  #def TreeNode._load(str)
  def self._load(str)
      loadDumpRep(str)
  end
  
  protected :parent=, :setAsRoot!
  private_class_method :loadDumpRep
  
  
  def find_by_path(selector)
    next_node = self
    last      = nil # prevents self-finding loop.
    selector.to_s.split(/ /).each do |node_id| 
      last = next_node = next_node.find {|n|
        n.name.to_s == node_id.to_s and not n==last
      }
    end
    
    return next_node
  end
  
  
  def find  ### DISCUSS: do we need that? isn't this implemented in Enumerable?
    self.each do |node|
      return node if yield node
    end
    
    return nil  ### DISCUSS: what about some exception if we can't find the node?
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
