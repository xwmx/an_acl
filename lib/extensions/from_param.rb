module FromParamAcl
  module Extensions
    module FromParam
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        
        # Passes to find_by_id by default, but will search using a from_param_field if specified in the model.
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
      end
    end
  end
end