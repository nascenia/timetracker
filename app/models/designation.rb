class Designation < ActiveRecord::Base
  scope :published,    -> { where(published: true) }
  scope :unpublished,  -> { where(published: true) }
end
