class Card < ApplicationRecord
  belongs_to :user, optional: true

  validates :customer_token, presence: true

  private
  def self.regist_customer(card_token, email)  ## カードのトークンを渡して顧客のトークンをもらいDBに登録する。
    Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
    return nil unless card_token  ## カードのトークンが無い場合、nilを返してリダイレクトさせる。
    customer = Payjp::Customer.create(  ## 顧客の作成
    email: email,
    card: card_token
    )
    return customer
  end

  def self.get_card(customer_token)  ## カード情報を取得する。支払い方法ページで使用する。
    return nil unless customer_token
    Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
    customer = Payjp::Customer.retrieve(customer_token)
    card = {}
    card_data = customer.cards.retrieve(customer.default_card)
    card[:last4] = "************" + card_data.last4
    card[:exp_month]= card_data.exp_month
    card[:exp_year] = card_data.exp_year - 2000
    card[:brand] = card_data.brand
    return card
  end

  def self.get_customer(customer_token)  ## 顧客情報を取得する。これを使って支払いをする。
    return nil unless customer_token
    customer = Payjp::Customer.retrieve(customer_token)
  end

end
