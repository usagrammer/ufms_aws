class CreateCommentItems < ActiveRecord::Migration[5.2]
  def change
    create_table :comment_items do |t|
      t.text :comment, null: false
      t.references :item, forign_key: true
      t.references :user, forign_key: true
      t.timestamps
    end
  end
end
