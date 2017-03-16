class ApprovalPath < ActiveRecord::Base
  has_many :leaves
  has_many :path_chains
  has_many :users

  validates_presence_of :name, message: 'Path name must be provided.'
end
