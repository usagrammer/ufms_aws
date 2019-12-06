class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string     :name, null: false, index:true  ## 商品名
      t.integer    :price, null:false              ## 価格
      t.text       :detail, null:false             ## 紹介文
      t.integer    :condition, null:false          ## 状態（中古、新品など）
      t.integer    :delivery_fee_payer, null:false ## 送料負担者
      t.integer    :delivery_method, null:false    ## 配送方法
      t.integer    :delivery_agency, null:false    ## 配送元地域
      t.integer    :delivery_days, null:false      ## 配送にかかる日数
      t.integer    :deal, default: 0                           ## 販売状況
      t.references :category, null:false, forign_key: true
      t.references :seller, null:false, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
