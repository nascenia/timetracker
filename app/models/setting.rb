class Setting < ApplicationRecord
  mount_uploader :organization_logo, FileUploader
  mount_uploader :fav_icon, FileUploader

  validates :app_name, presence: true
  validates :organization_name, presence: true
  validates :organization_summary, presence: true
end
