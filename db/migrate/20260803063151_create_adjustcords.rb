class CreateAdjustcords < ActiveRecord::Migration[8.1]
  def change
    create_table :adjustcords do |t|
      t.references :cord, null: false, foreign_key: true
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
