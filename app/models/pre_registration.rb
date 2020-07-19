class PreRegistration < ActiveRecord::Base
  mount_uploader :ndaDoc, FileUploader
  belongs_to :user

  def update_from_user
    step_no = 3
    save
  end
end
