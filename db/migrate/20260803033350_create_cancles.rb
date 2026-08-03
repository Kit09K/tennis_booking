class CreateCancles < ActiveRecord::Migration[8.1]
  def change
    create_table :cancles do |t|
      t.references :booking, null: false, foreign_key: true

      t.timestamps
    end
  end
end
