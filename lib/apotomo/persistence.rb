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
    
    
    def dump_tree
      collect  { |n|  [n.class, n.name, n.root? ? nil : n.parent.name] }
    end
    
    
    module ClassMethods
      # Dump the shit to storage.
      def freeze_for(storage, root)
        storage[:apotomo_stateful_branches] = []
        storage[:apotomo_widget_ivars]      = {}
        
        stateful_branches_for(root).each do |branch|
          branch.freeze_data_to(storage[:apotomo_widget_ivars])  # save ivars.
          storage[:apotomo_stateful_branches] << branch.dump_tree
        end
      end
      
      # Create tree from storage and add branches to root/stateless parents.
      def thaw_for(controller, storage, root)
        branches = storage.delete(:apotomo_stateful_branches) || []
        branches.each do |data|
          branch = load_tree(controller, data)
          parent = root.find_widget(data.first.last) or raise "Couldn't find parent `#{data.first.last}` for `#{branch.name}`"
          
          parent << branch
          branch.thaw_data_from(storage.delete(:apotomo_widget_ivars) || {})
        end
        
        root
      end
      
      def frozen_widget_in?(storage)
        storage[:apotomo_stateful_branches].kind_of? Array
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
      
    private
      def load_tree(parent_controller, cold_widgets)
        root = nil
        cold_widgets.each do |data|
          node = data[0].new(parent_controller, data[1], "")
          root = node and next unless root
          root.find_widget(data[2]) << node
        end
        root
      end
    end
  end
end
