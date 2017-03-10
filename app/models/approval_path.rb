class ApprovalPath < ActiveRecord::Base
  has_many :path_chains
  belongs_to :user

  after_create :deactivate_previous_paths

  private

  def deactivate_previous_paths
    prev_paths = ApprovalPath.where(user: self.user).where.not(id: self)
    prev_paths.update_all(active: false)
  end
end
