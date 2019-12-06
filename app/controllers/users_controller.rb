class UsersController < ApplicationController
  layout 'mypage'

  def show
  end

  def select_registration
    render layout: 'no_menu'
  end

  def selling  ## 出品した商品（販売中）
    @items = current_user.items.selling_items
  end

  def selling_progress ## 出品した商品（取引中）
    @items = current_user.items.selling_progress_items
  end

  def sold ## 出品した商品（売却済み）
    @items = current_user.items.sold_out_items
  end

  def bought_progress ## 購入した商品（取引中）
    @items = Item.bought_progress_items(current_user.id)
  end

  def bought_past ## 購入した商品（過去の取引）
    @items = Item.bought_past_items(current_user.id)
  end

  private
  def set_side_bar
    @lists1 =
      {text: "マイページ", path: '/users/1'},
      {text: "お知らせ", path: ""},
      {text: "いいね！一覧", path: ""},
      {text: "出品する", path: new_item_path},
      {text: "出品した商品---出品中", path: ""},
      {text: "出品した商品---取引中", path: ""},
      {text: "出品した商品---売却済", path: ""},
      {text: "購入した商品---取引中", path: ""},
      {text: "購入した商品---過去の取引", path: ""},
      {text: "ニュース一覧", path: ""},
      {text: "評価一覧", path: ""},
      {text: "ガイド", path: ""},
      {text: "お問い合わせ", path: ""}
    @lists2 =
      {text: "売上・振込申請", path: ""},
      {text: "ポイント", path: ""}
    @lists3 =
    {text: "プロフィール", path: ""},
    {text: "住所変更", path: ""},
    {text: "支払い方法", path: cards_path},
    {text: "メール/パスワード", path: ""},
    {text: "本人情報", path: ""},
    {text: "電話番号の確認", path: ""},
    {text: "ログアウト", path: destroy_user_session_path, method: "delete"}
  end

end
