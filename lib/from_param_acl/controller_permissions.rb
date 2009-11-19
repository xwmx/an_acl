module FromParamAcl
  module ActionController
    module Permissions
        # Use as a before filter in controllers. Uses default permitted?
        # or the version of permitted? defined locally within a controller.
        # Requires that the controller implements two methods:
        #  * logged_in? returns true or false
        #  * login_required => behavior for when logged_in? returns false
        # If permitted? false, 403 header is sent and 'Not Permitted'
        # text is rendered.
        def permission_required
          unless permitted?
            unless logged_in?
              login_required
            else
              respond_to do |format|
                format.html {
                  render :text => 'Not Permitted',
                  :status => :forbidden
                }
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
          case action_name
          when "index"
            current_model.is_readable_by?(current_user, current_context)
          when "show"
            current_object && current_object.is_readable_by?(current_user)
          when "new", "create"
            current_model.is_creatable_by?(current_user, current_context)
          when "edit", "update"
            current_object && current_object.is_updatable_by?(current_user)
          when "destroy"
            current_object && current_object.is_deletable_by?(current_user)
          end
        end
      
        # Override in controller or assign an object to an @context variable 
        # to provide a context for class-level permissions.
        def current_context
          @context
        end
        
        def current_model
          self.controller_name.classify.constantize
        end
        
        def current_object
          instance_variable_get("@#{self.controller_name.singularize}")
        end
    end
  end
end

ActionController::Base.class_eval do
  include FromParamAcl::ActionController::Permissions
end
