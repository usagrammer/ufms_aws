class CreateDealingChatMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :dealing_chat_messages do |t|
      t.text :message, null: false
      t.references :dealing, forign_key: true
      t.references :user, forign_key: true
      t.timestamps
    end
  end
end
