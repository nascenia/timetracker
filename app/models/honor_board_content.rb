class HonorBoardContent < ActiveRecord::Base

  belongs_to :honor_board_category , :foreign_key => :honor_board_category_id
  mount_uploader :photo, AvatarUploader

  accepts_nested_attributes_for :honor_board_category
  VALID_NAME_REGEX = /[A-Z].+/
  validates :name, presence: true, length: {minimum: 3, maximum: 30}, format: {with: VALID_NAME_REGEX}
  validates :honor_board_category_id, presence: true
  validates :reason, presence: true, length: {minimum: 10, maximum: 300}
  validates :photo, presence: true




end
