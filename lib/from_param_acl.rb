# FromParamAcl
module FromParamAcl
  
  module ActiveRecordExtensions
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      # Passes to find_by_id by default, but will search using a permalink_field if specified in the model.
      def from_param(*options)
        if respond_to?(:permalink_field) && !permalink_field.nil?
          send(:"find_by_#{permalink_field}", *options)
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
  
  module FinderFilters
    # Use as a before filter to get object for the resource if current_user
    # has the necessary permissions.
    def get_from_param_for
      instance_variable_set("@#{self.controller_name.singularize}", self.controller_name.classify.constantize.from_param_for(current_user, params[:action], params[:id]))
    end
    
    # Use as a before filter to get object for the resource without checking
    # permissions.
    def get_from_param
      instance_variable_set("@#{self.controller_name.singularize}", self.controller_name.classify.constantize.from_param(params[:id]))
    end
  end
  
  
  module Permissions
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
      
        case params[:action]
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