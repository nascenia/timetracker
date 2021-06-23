class PreRegistration < ActiveRecord::Base
  mount_uploader :ndaDoc, FileUploader
  belongs_to :user
  validates_uniqueness_of :companyEmail, allow_blank: true, allow_nil: true
  
  validates :employee_id, presence: true, uniqueness: true, length: { is: 5 }
  validates :employee_id, format: { with: /^A[A-Za-z0-9]+\z/, message: 'Only letter and number are allowed', multiline: true }

  def update_from_user
    step_no = 3
    save
  end
end
