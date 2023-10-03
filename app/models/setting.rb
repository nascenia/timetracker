class Setting < ApplicationRecord
  mount_uploader :organization_logo, AvatarUploader
  mount_uploader :fav_icon, AvatarUploader

  validates :app_name, presence: true
  validates :organization_name, presence: true
  validates :organization_summary, presence: true
end
