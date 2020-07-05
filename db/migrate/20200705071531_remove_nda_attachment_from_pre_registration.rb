class RemoveNdaAttachmentFromPreRegistration < ActiveRecord::Migration
  def change
    remove_column :pre_registrations, :ndaAttachment, :string
  end
end
