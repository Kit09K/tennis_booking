class RemoveAccountFieldsFromBookings < ActiveRecord::Migration[8.1]
  def change
    remove_column :bookings, :name_account, :string
    remove_column :bookings, :account_number, :string
  end
end
