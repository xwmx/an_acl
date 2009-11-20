class ActionController::Base
  # Use as a before filter in controllers. Uses default permitted?
  # or the version of permitted? defined locally within a controller.
  # If permitted? false, 403 header is sent and 'Not Permitted'
  # text is rendered.
  def permission_required
    unless permitted?
      respond_to do |format|
        format.html {
          render :text => 'Not Permitted',
          :status => :forbidden
        }
      end
    end
  end

protected
  
  # Returns a boolean. Can override to completely ignore per-action tests.
  def permitted?
    !!test_permissions(action_tests)
  end
  
  # Override in controller to have custom permissions for the resource.
  # The method should return a hash of with action names for keys pointing 
  # to boolean-returning procs or booleans. To preserve default tests simply
  # merge the new hash with `default_action_tests` when overriding the
  # method.
  def action_tests
    default_action_tests
  end
  
  def default_action_tests
    HashWithIndifferentAccess.new(
      :index    => lambda do
        current_model.is_readable_by?(current_user, current_context)
      end,
      :show     => lambda do
        current_object.is_readable_by?(current_user)
      end,
      :new      => lambda do
        current_model.is_creatable_by?(current_user, current_context)
      end,
      :create   => lambda do
        current_model.is_creatable_by?(current_user, current_context)
      end,
      :edit     => lambda do
        current_object.is_updatable_by?(current_user)
      end,
      :update   => lambda do
        current_object.is_updatable_by?(current_user)
      end,
      :destroy  => lambda do
        current_object.is_deletable_by?(current_user)
      end
    )
  end
  
  def test_permissions(tests)
    test = tests[action_name]
    if test.respond_to?(:call)
      test.call
    else
      test
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
