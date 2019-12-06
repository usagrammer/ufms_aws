class CardsController < ApplicationController
  layout 'mypage'
  before_action :authenticate_user!, except: [:create]

  def show
    @card = Card.get_card(current_user.card&.customer_token)
    render layout: 'mypage'
  end

  def new
    redirect_back(fallback_location: regist_completed_path) if current_user.card ## 既にカードを登録しているならリダイレクト
    @progress = 4
    @card = Card.new
  end

  def create #データベースにカードのcustomerのtokenを保存する。
    email = current_user.email if user_signed_in?  ## マイページのカード登録画面から遷移してきた場合
    email = session["devise.regist_data"]["user"]["email"] if session["devise.regist_data"] ## 新規ユーザー登録画面から遷移してきた場合
    # params[:card_token]に「tok_hogehoge」という形でカードのトークンが送られてきている
    # ↑このトークンはjsの方でappendしたhidden_fieldに埋め込まれていたもの
    customer = Card.regist_customer(params[:card_token], email) ## customerを作成
    @card = Card.new(customer_token: customer&.id)
    redirect_to action: "new", alert: "カードの登録に失敗しました。" and return if @card.invalid? ## カードの保存に失敗した場合
    ## 保存に成功した場合
    before_controller = Rails.application.routes.recognize_path(request.referer)[:controller]
    ## ページの遷移元に応じてリダイレクト先を変更する。
    if before_controller == "users/registrations"
      ## 新規ユーザー登録画面から遷移してきた場合、登録完了画面へ遷移
      session["devise.regist_data"][:card] = @card
      redirect_to regist_completed_path and return
    end
    ## マイページの支払い方法ページから遷移してきた場合、支払い方法ページへ遷移
    @card.user_id = current_user.id
    @card.save
    redirect_to cards_path and return
  end

  def destroy
    @card = current_user.card
    @card.destroy
    redirect_to cards_path
  end

end
