class Designation < ActiveRecord::Base
  scope :published,    -> { where(published: true) }
  scope :unpublished,  -> { where(published: true) }

  validates :team, presence: true
  validates :title, presence: true
  validates :description, presence: true
end
