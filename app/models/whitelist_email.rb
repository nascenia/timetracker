class WhitelistEmail < ApplicationRecord
  scope :published, -> () { where(published: true) }

  validates :email, presence: true, uniqueness: true
end
