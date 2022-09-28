class PreRegistration < ActiveRecord::Base
  mount_uploader :ndaDoc, FileUploader
  belongs_to :user

  attr_accessor :zoho_email_account

  validates_uniqueness_of :companyEmail, allow_blank: true, allow_nil: true
  
  validates :employee_id, presence: true, uniqueness: true, length: { is: 5 }
  #validates :employee_id, format: { with: /[^a-zA-Z0-9]/, message: 'Only letter and number are allowed', multiline: true }

  def update_from_user
    step_no = 3
    save
  end
end
