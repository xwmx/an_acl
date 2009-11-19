module FromParamAcl
  module ActionController
    module FinderFilters
      # Use as a before filter to get object for the resource if current_user
      # has the necessary permissions.
      def get_from_param_for
        instance_variable_set("@#{obj_name}", current_model.from_param_for(current_user, action_name, params[:id]))
      end

      # Use as a before filter to get object for the resource without checking
      # permissions.
      def get_from_param
        instance_variable_set("@#{obj_name}", current_model.from_param(params[:id]))
      end
    
    protected
      
      def obj_name
        self.controller_name.singularize
      end
      
      def current_model
        self.controller_name.classify.constantize
      end
    end
  end
end

ActionController::Base.class_eval do
  include FromParamAcl::ActionController::FinderFilters
end
