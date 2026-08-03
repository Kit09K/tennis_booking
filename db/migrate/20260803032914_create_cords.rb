class CreateCords < ActiveRecord::Migration[8.1]
  def change
    create_table :cords do |t|
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end
