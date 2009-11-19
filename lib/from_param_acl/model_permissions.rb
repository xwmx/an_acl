module FromParamAcl
  module ModelPermissions
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      # Specify the instance methods used to check against each action that
      # uses an object. Each method should have one argument, the agent that
      # is requesting permission to perform the action, eg, a user object.
      def object_action_permissions(opts = {})
        HashWithIndifferentAccess.new(
          :show     => :is_readable_by?,
          :edit     => :is_updatable_by?,
          :update   => :is_updatable_by?,
          :destroy  => :is_deletable_by?,
          :default  => :is_deletable_by?
        ).merge(opts)
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
      rule = self.class.object_action_permissions[action || :default]
      if self.respond_to? rule
        self.send(rule, agent)
      else
        false
      end
    rescue TypeError
      rule.respond_to?(:call) ? rule.call : !!method_or_bool
    end
  end
end

ActiveRecord::Base.class_eval do
  include FromParamAcl::ModelPermissions
end