module FromParamAcl
  module Extensions
    module ModelExtensions
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        
        # Passes to find_by_id by default, but will search using a permalink_field if specified in the model.
        def from_param(*options)
          if respond_to?(:from_param_field) && !from_param_field.nil?
            send(:"find_by_#{from_param_field}", *options)
          else
            find(*options)
          end
        end
        
        # Returns an object using ActiveRecord::Base#from_param if agent meets requirements for the 
        # specified action as defined by the model.
        def from_param_for(agent, action = nil, *options)
          object = self.from_param(*options) or raise ActiveRecord::RecordNotFound
          if object.permits_for?(agent, action)
            object
          else
            nil
          end
        end
        
        # Override in model to define permissions for model reads.
        # Defaults to true, providing access to any user.
        def is_readable_by?(agent = nil, current_context = nil)
          true
        end
        
        # Override in model to define permissions for new object creation.
        # Defaults to true, providing access to any user.
        def is_creatable_by?(agent = nil, current_context = nil)
          true
        end
      
      end
      
      # Override in model to define permissions for reading instances.
      # Defaults to true, providing access to any user.
      def is_readable_by?(agent = nil)
        true
      end
      
      # Override in model to define permissions for updating instances.
      # Defaults to true, providing access to any user.
      def is_updatable_by?(agent = nil)
        true
      end
      
      # Override in model to define permissions for deleting instances.
      # Defaults to ActiveRecords::Base#is_updatable_by?(agent)
      def is_deletable_by?(agent = nil)
        is_updatable_by?(agent)
      end
      
      # Check object permissions by action.
      def permits_for?(agent, action = nil)
        case action
        when "show"
          is_readable_by?(agent)
        when "edit", "update"
          is_updatable_by?(agent)
        when "destroy", nil
          is_deletable_by?(agent)
        end
      end
      
    end
  end
end