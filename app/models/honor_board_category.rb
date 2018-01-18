class HonorBoardCategory < ActiveRecord::Base
  has_many :honor_board_contents
end
