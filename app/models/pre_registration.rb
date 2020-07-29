class PreRegistration < ActiveRecord::Base
  mount_uploader :ndaDoc, FileUploader
  belongs_to :user
  validates_uniqueness_of :companyEmail
  
  def update_from_user
    step_no = 3
    save
  end
end
