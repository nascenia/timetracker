class Network < ApplicationRecord
  enum status: { 
    draft: 'draft', 
    activated: 'activated', 
    archived: 'archived' 
  }

  validates :name, presence: true
  validates :ip_address, presence: true
end
