require 'from_param_acl'
ActiveRecord::Base.class_eval     { include FromParamAcl::Extensions::ModelExtensions }
ActionController::Base.class_eval { include FromParamAcl::Extensions::ControllerPermissions }
ActionController::Base.class_eval { include FromParamAcl::Extensions::FinderFilters }