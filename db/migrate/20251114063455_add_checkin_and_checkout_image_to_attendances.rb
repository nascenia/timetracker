class AddCheckinAndCheckoutImageToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :checkin_image, :string
    add_column :attendances, :checkout_image, :string
  end
end
