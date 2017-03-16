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

  def self.remove_not_passed_chain_users(path, approval_chain)
    removed_users = path.path_chains.where.not( :id => approval_chain )
    removed_users.each do |user|
      user.destroy
    end
  end

  def self.add_newly_passed_chain_users(path, approval_chain)
    approval_chain.each do |id|
      unless path.path_chains.find_by(:user_id => id).present?
        path_chain = path.path_chains.build(user_id: id, priority: 0)
        path_chain.save
      end
    end
  end

  def self.update_priority_and_name(path, approval_chain, name)
    path.update_attribute(:name, name)
    max_priority = approval_chain.size
    approval_chain.each do |user_id|
      chain = path.path_chains.find_by(:user_id => user_id)
      chain.update_attribute(:priority, max_priority)
      max_priority = max_priority - 1
    end
  end

  def self.update(path, approval_chain, name)
    remove_not_passed_chain_users(path, approval_chain)
    add_newly_passed_chain_users(path, approval_chain)
    update_priority_and_name(path, approval_chain, name)
  end
end
