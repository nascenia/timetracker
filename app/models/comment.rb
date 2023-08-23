class Comment < ApplicationRecord
  belongs_to :leave
  belongs_to :user

  validates :body, presence: true
end
