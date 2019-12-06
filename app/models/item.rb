class Item < ApplicationRecord
  enum condition:{"新品、未使用": 0, "未使用に近い": 1, "目立った傷や汚れなし": 2, "やや傷や汚れあり": 3, "傷や汚れあり": 4, "全体的に状態が悪い": 5}
  enum delivery_fee_payer:{"送料込み（出品者負担）": 0, "着払い（購入者負担）": 1}
  enum delivery_method:{"未定": 0, "らくらくメルカリ便": 1, "ゆうメール": 2, "レターパック": 3, "普通郵便（定形、定形外）": 4, "クロネコヤマト": 5, "ゆうパック": 6, "クリックポスト": 7, "ゆうパケット": 8}
  enum delivery_days:{"1〜2日で発送": 0, "2〜3日で発送": 1, "4〜7日で発送": 2}
  enum deal:{"販売中": 0, "売り切れ": 1}

  validates :name, :price, :detail, :condition, :delivery_fee_payer, :delivery_method, :delivery_agency, :delivery_days, :deal, presence: true
  validates :price, numericality:{greater_than_or_equal_to: 300,less_than_or_equal_to: 9999999}
  validates :item_images, length: { minimum: 1, message: "がありません。"}

  ## カテゴリーでitemを検索
  ## 条件に配列を渡すと、配列の中身全てをチェックしてくれる
  scope :search_category, -> (category_id) {includes(:item_images).where(category_id: category_id)}
  ## 販売中の商品
  scope :selling_items, -> {includes(:item_images).where(deal: "販売中")}
  ## 出品した商品（取引中)
  scope :selling_progress_items, -> {includes(:item_images).joins(:dealing).where(deal: "売り切れ").where('dealings.phase != ?', 10)}
  ## 出品した商品（売却済み）
  scope :sold_out_items, -> {includes(:item_images).joins(:dealing).where(deal: "売り切れ").where('dealings.phase = ?', 10)}
  ## 購入した商品（取引中）
  scope :bought_progress_items, -> (user_id) {includes(:item_images).joins(:dealing).where(deal: "売り切れ").where('dealings.phase != ? and dealings.buyer_id = ?', 10, user_id)}
  ## 購入した商品（過去の取引）
  scope :bought_past_items, -> (user_id) {includes(:item_images).joins(:dealing).where(deal: "売り切れ").where('dealings.phase = ? and dealings.buyer_id = ?', 10, user_id)}

  has_many :item_images, dependent: :destroy
  belongs_to :category
  belongs_to :seller, class_name: "User", foreign_key: 'seller_id'
  accepts_nested_attributes_for :item_images, allow_destroy: true
  has_one :item_brand, dependent: :destroy
  accepts_nested_attributes_for :item_brand, allow_destroy: true
  has_one :item_size, dependent: :destroy
  accepts_nested_attributes_for :item_size, allow_destroy: true
  has_one :dealing

  extend ActiveHash::Associations::ActiveRecordExtensions
  belongs_to_active_hash :prefecture

  def self.search_by_category(category)
    return Item.where(category_id: category).includes(:item_images, :category)
  end

  def get_brand
    return nil unless self.item_brand
    return self.item_brand.brand_name.name
  end

end
