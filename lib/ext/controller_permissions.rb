module FromParamAcl
  module Ext
    module ControllerPermissions
        # Use as a before filter in controllers. Uses default permitted?
        # or the version of permitted? defined locally within a controller.
        def permission_required
          unless permitted?
            unless logged_in?
              login_required
            else
              respond_to do |format|
                format.html { redirect_to(PERMISSION_DENIED_REDIRECTION) }
                format.xml  { render :nothing => true, :status => 401 }
              end
            end
          end
        end
      
      protected
      
        # Override in controller to have custom permissions for the resource.
        # If permissions are dependent on context, override the current_context
        # method or assign a value to an @context variable. On object actions, 
        # expects the existence of instance variable using the singular name of 
        # the current resource.
        def permitted?
          klass = self.controller_name.classify.constantize
          object = instance_variable_get("@#{self.controller_name.singularize}")
      
          case action_name
          when "index"
            klass.is_readable_by?(current_user, current_context)
          when "show"
            object && object.is_readable_by?(current_user)
          when "new", "create"
            klass.is_creatable_by?(current_user, current_context)
          when "edit", "update"
            object && object.is_updatable_by?(current_user)
          when "destroy"
            object && object.is_deletable_by?(current_user)
          end
        end
      
        # Override in controller or assign an object to an @context variable 
        # to provide a context for class-level permissions.
        def current_context
          @context
        end
    end
  end
end