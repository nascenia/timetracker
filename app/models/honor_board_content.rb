class HonorBoardContent < ActiveRecord::Base
  belongs_to :honor_board_category, :foreign_key => :category_id
  has_attached_file :thumbnail, styles: { large: "1000x1000#", medium: "250x250#", thumb: "100x100#" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :thumbnail, content_type: /\Aimage\/.*\z/
  accepts_nested_attributes_for :honor_board_category

end
