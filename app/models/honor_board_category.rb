class HonorBoardCategory < ActiveRecord::Base
  has_many :honor_board_contents , dependent: :destroy
end
