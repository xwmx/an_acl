module FromParamAcl
  module Ext
    module FinderFilters
      # Use as a before filter to get object for the resource if current_user
      # has the necessary permissions.
      def get_from_param_for
        instance_variable_set("@#{self.controller_name.singularize}", self.controller_name.classify.constantize.from_param_for(current_user, action_name, params[:id]))
      end

      # Use as a before filter to get object for the resource without checking
      # permissions.
      def get_from_param
        instance_variable_set("@#{self.controller_name.singularize}", self.controller_name.classify.constantize.from_param(params[:id]))
      end
    end
  end
end