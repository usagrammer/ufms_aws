class CreateValues < ActiveRecord::Migration[5.2]
  def change
    create_table :values do |t|
      t.references :dealing, forign_key: true
      t.references :user, forign_key: true
      t.timestamps
    end
  end
end
