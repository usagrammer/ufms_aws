class CreateItemBrands < ActiveRecord::Migration[5.2]
  def change
    create_table :item_brands do |t|
      t.references :item, forign_key: true, null: false
      t.references :brand_name, forign_key: true, null: false
      t.timestamps
    end
  end
end
