class PathChain < ActiveRecord::Base
  belongs_to :approval_path
  belongs_to :user

  def self.find_path_chain_users(path_id)
    path = ApprovalPath.find(path_id)
    path_chains = path.path_chains
    path_chain_users = Array.new
    path_chains.each do |path_chain|
      path_chain_users << User.find(path_chain.user_id)
    end
    return path_chain_users
  end

end
