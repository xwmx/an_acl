module FromParamAcl
  module ActiveRecord
    module FromParam    
      # Passes to find_by_id by default, but will search using a from_param_field if specified in the model.
      def from_param(*options)
        if respond_to?(:from_param_field) && !from_param_field.nil?
          send(:"find_by_#{from_param_field}", *options)
        else
          find(*options)
        end
      end
    end
  end
end

ActiveRecord::Base.extend FromParamAcl::ActiveRecord::FromParam
