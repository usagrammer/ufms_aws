class CreateBrandNames < ActiveRecord::Migration[5.2]
  def change
    create_table :brand_names do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :brand_names, :name
  end
end
