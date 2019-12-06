class Api::CardsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update]  ## ログイン必須のアクション

  def create #payjpにカード情報を登録
    Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      customer = Payjp::Customer.create(
      email: current_user.email, #なくてもOK
      card: params['payjp-token'],
      metadata: {user_id: current_user.id} #なくてもOK
      )
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        redirect_to action: "show"
      else
        redirect_to action: "pay"
      end
    end
  end

  def update  ## カードの更新
    customer = Payjp::Customer.create(
        email: current_user.email,
        card: params[:token],
        metadata: {user_id: current_user.id}
    )
    @card_data = current_user.card.update(card_token:customer.id)
  end

end
