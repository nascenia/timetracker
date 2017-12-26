class Comment < ActiveRecord::Base
  belongs_to :leave
  belongs_to :user

  validates :body, presence: true
  validates :leave, presence: true
  validates :user, presence: true
end
