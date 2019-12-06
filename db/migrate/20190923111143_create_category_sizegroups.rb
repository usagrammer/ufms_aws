class CreateCategorySizegroups < ActiveRecord::Migration[5.2]
  def change
    create_table :category_sizegroups do |t|
      t.references :category, forign_key: true, null: false
      t.references :size_group, forign_key: true, null: false
      t.timestamps
    end
  end
end
