class AddPhoneToBookings < ActiveRecord::Migration[8.1]
  def change
    add_column :bookings, :phone, :string
  end
end
