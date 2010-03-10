module Apotomo
  module Persistence
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def freeze_ivars_to(storage)
      frozen = {}
      (self.instance_variables - unfreezable_ivars).each do |ivar|
        frozen[ivar] = instance_variable_get(ivar)
      end
      storage[path] = frozen
    end
    
    def freeze_data_to(storage)
      freeze_ivars_to(storage)
      children.each { |child| child.freeze_data_to(storage) }
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
    
    module ClassMethods
      def thaw_from(storage)
        root = storage[:apotomo_root]
        root.thaw_data_from(storage.fetch(:apotomo_widget_ivars, {}))
        root
      end
      
      def frozen_widget_in?(storage)
        storage[:apotomo_root].kind_of? Apotomo::StatefulWidget
      end
    end
  end
end