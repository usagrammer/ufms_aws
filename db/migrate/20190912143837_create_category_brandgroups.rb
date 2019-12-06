class CreateCategoryBrandgroups < ActiveRecord::Migration[5.2]
  def change
    create_table :category_brandgroups do |t|
      t.references :category, forign_key: true, null: false
      t.references :brand_group, forign_key: true, null: false
      t.timestamps
    end
  end
end
