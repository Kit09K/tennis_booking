class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cord, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :account_number
      t.string :name_account

      t.timestamps
    end
  end
end
