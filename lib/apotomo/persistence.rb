module Apotomo
  # Methods needed to serialize the widget tree and back.
  module Persistence
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    # For Ruby 1.8/1.9 compatibility.
    def symbolized_instance_variables
      instance_variables.map { |ivar| ivar.to_sym }
    end
    
    def freeze_ivars_to(storage)
      frozen = {}
      (symbolized_instance_variables - unfreezable_ivars).each do |ivar|
        frozen[ivar] = instance_variable_get(ivar)
      end
      storage[path] = frozen
    end
    
    ### FIXME: rewrite so that root might be stateless as well.
    def freeze_data_to(storage)
      freeze_ivars_to(storage)# if self.kind_of?(StatefulWidget)
      children.each { |child| child.freeze_data_to(storage)  if child.kind_of?(StatefulWidget) }
    end
    
    def freeze_to(storage)
      storage[:apotomo_root]          = self          # save structure.
      storage[:apotomo_widget_ivars]  = {}
      freeze_data_to(storage[:apotomo_widget_ivars])  # save ivars.
    end
    
    def thaw_ivars_from(storage)
      storage.fetch(path, {}).each do |k, v|
        instance_variable_set(k, v)
      end
    end
    
    def thaw_data_from(storage)
      thaw_ivars_from(storage)
      children.each { |child| child.thaw_data_from(storage) }
    end
    
    
    # Serializes the widget node structure (not children, not content).
    def dump_node
      field_sep = self.class.field_sep
      "#{@name}#{field_sep}#{self.class}#{field_sep}#{root? ? @name : parent.name}"
    end
    
    # Serializes the tree structure.
    def _dump(depth)
      inject("") { |str, node| str << node.dump_node << self.class.node_sep }
    end
    
    module ClassMethods
      def field_sep;  '|';  end
      def node_sep;   "\n"; end
      
      # Creates an empty widget instance from <tt>line</tt>.
      def load_node(line)
        name, klass, parent = line.split(field_sep)
        [klass.constantize.new(name, nil), parent]
      end
      
      def _load(str)
        nodes = {}
        root  = nil
        str.split(node_sep).each do |line|
          node, parent = load_node(line)
          nodes[node.name] = node
          
          if node.name == parent # we're at the root node.
            root = node and next
          end
          
          nodes[parent].add(node)
        end
        root
      end
      
      def freeze_for(storage, root)
        storage[:apotomo_stateful_branches] = []
        storage[:apotomo_widget_ivars]      = {}
        
        stateful_branches_for(root).each do |branch|
          branch.freeze_data_to(storage[:apotomo_widget_ivars])  # save ivars.
          storage[:apotomo_stateful_branches] << [branch, branch.parent.name]
          branch.root!  # disconnect from tree.
        end
      end
      
      def thaw_for(storage, root)
        branches = storage[:apotomo_stateful_branches] || []
        branches.each do |config|
          branch = config.first
          parent = root.find_widget(config.last) or raise "Couldn't find parent `#{config.last}` for `#{branch.name}`"
          
          parent << branch
          branch.thaw_data_from(storage.fetch(:apotomo_widget_ivars, {}))
        end
        
        root
      end
  
      def thaw_from(storage)
        root = storage[:apotomo_root]
        root.thaw_data_from(storage.fetch(:apotomo_widget_ivars, {}))
        root
      end
      
      def frozen_widget_in?(storage)
        branches = storage[:apotomo_stateful_branches]
        branches.present? and branches.first.first.kind_of? Apotomo::StatefulWidget
      end
      
      def flush_storage(storage)
        storage[:apotomo_stateful_branches] = nil
        storage[:apotomo_widget_ivars]      = nil
      end
      
      # Find the first stateful widgets on each branch from +root+.
      def stateful_branches_for(root)
        to_traverse     = [root]
        stateful_roots  = []
        
        while node = to_traverse.shift
          if node.kind_of?(StatefulWidget)
            stateful_roots << node and next
          end
          to_traverse += node.children
        end
        
        stateful_roots
      end
      
    end
  end
end