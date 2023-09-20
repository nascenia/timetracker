class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  CONFIG = Rails.application.config.x.app
end
