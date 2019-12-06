class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :phone_number
      t.string :postal_code, default: ""
      t.integer :prefecture, default: 0
      t.string :city, default: ""
      t.string :house_number, default: ""
      t.string :building_name, default: ""
      t.references :user, forign_key: true
      t.timestamps
    end
  end
end
