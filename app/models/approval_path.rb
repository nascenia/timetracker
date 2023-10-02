class ApprovalPath < ApplicationRecord
  has_many :leaves
  has_many :path_chains
  has_many :users

  validates :name, presence: true
end
