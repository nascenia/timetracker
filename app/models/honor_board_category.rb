class HonorBoardCategory < ActiveRecord::Base
  has_many :honor_board_contents , dependent: :destroy
  validates :category, presence: true, uniqueness: {case_sensitive: false}, length: {minimum: 3, maximum: 15}
end
