require 'from_param_acl'
ActiveRecord::Base.class_eval     { include FromParamAcl::Ext::ModelPermissions }
ActiveRecord::Base.class_eval     { include FromParamAcl::Ext::FromParam }
ActionController::Base.class_eval { include FromParamAcl::Ext::ControllerPermissions }
ActionController::Base.class_eval { include FromParamAcl::Ext::FinderFilters }
