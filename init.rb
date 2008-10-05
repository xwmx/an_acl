require 'from_param_acl'
ActiveRecord::Base.class_eval { include FromParamAcl::ActiveRecordExtensions }
ActionController::Base.class_eval { include FromParamAcl::Permissions }
ActionController::Base.class_eval { include FromParamAcl::FinderFilters }