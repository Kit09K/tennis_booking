class CreateTopups < ActiveRecord::Migration[8.1]
  def change
    create_table :topups do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount
      t.string :status

      t.timestamps
    end
  end
end
