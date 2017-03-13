class PathChain < ActiveRecord::Base
  belongs_to :approval_path
  belongs_to :user
end
