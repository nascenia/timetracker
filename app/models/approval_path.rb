class ApprovalPath < ActiveRecord::Base
  has_many :path_chains
  belongs_to :user
end
