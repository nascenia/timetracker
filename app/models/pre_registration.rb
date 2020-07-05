class PreRegistration < ActiveRecord::Base
    belongs_to :user
    mount_uploader :ndaDoc, FileUploader

    def update_from_user
        step_no = 3
        save
    end
end
