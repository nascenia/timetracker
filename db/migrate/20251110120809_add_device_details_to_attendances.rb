class AddDeviceDetailsToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :checkin_device, :string
    add_column :attendances, :checkout_device, :string
  end
end
