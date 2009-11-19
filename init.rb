require 'from_param_acl'
ActiveRecord::Base.class_eval     { include FromParamAcl::ActiveRecord::ModelPermissions }
ActiveRecord::Base.class_eval     { include FromParamAcl::ActiveRecord::FromParam }
ActionController::Base.class_eval { include FromParamAcl::ActionController::Permissions }
ActionController::Base.class_eval { include FromParamAcl::ActionController::FinderFilters }
