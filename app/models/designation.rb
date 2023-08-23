class Designation < ApplicationRecord
  scope :published,    -> { where(published: true) }
  scope :unpublished,  -> { where(published: false) }

  validates :team, presence: true
  validates :title, presence: true
  validates :description, presence: true
end
