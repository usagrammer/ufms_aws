# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  before_action :signed_up?
  layout 'no_menu'

  def select  ##登録方法の選択ページ
    @auth_text = "で登録する"
    session.delete(:"devise.sns_auth") if session["devise.sns_auth"]
  end

  # GET /resource/sign_up
  def new
    @progress = 1
    ## ↓sessionにsns認証のデータがある場合
    @user = User.new(session["devise.sns_auth"]["user"]) if session["devise.sns_auth"]
    ## ↓sessionにsns認証のデータがない場合
    super if !session["devise.sns_auth"]
  end

  # POST /resource
  def create
    redirect_to new_user_registration_path, alert: "reCAPTCHAを承認してください" and return unless verify_recaptcha
    if session["devise.sns_auth"] ## sessionがあるとき＝sns認証でここまできたとき
      ## パスワードが未入力なのでランダムで生成する
      pass = Devise.friendly_token[8,12]
      ## 生成したパスワードをparamsに入れる
      params[:user][:password] = pass
      params[:user][:password_confirmation] = pass
      sns = SnsCredential.new(session["devise.sns_auth"]["sns"])
    end
    ## ↓は@user = User.new(sign_up_params)と同じ
    build_resource(sign_up_params)
    ## save出来るか予めチェック
    unless resource.valid? ## 登録に失敗したとき
      ## 進捗バー用の@progressとflashメッセージをセットして戻る
      @progress = 1
      flash.now[:alert] = resource.errors.full_messages
      render :new and return
    end
    ## sessionに後々saveするuserを入れておく
    session["devise.regist_data"] = {user: @user.attributes}
    ## ↑だけだと後々passwordが空になってしまうので↓を入れておく
    session["devise.regist_data"][:encrypted_password] = nil
    session["devise.regist_data"][:user][:password] = params[:user][:password]
    redirect_to confirm_phone_path
  end

  def confirm_phone ## userのcreateに成功したらここに来る
    @progress = 2
  end

  def new_address ## 電話番号認証ページのボタンを押したらここに来る
    ## address登録済の時はリダイレクト
    redirect_to new_regist_payment_path if session["devise.regist_data"][:address] || current_user&.address
    @progress = 3
    @address = Address.new
  end

  def create_address
    @address = Address.new(address_params)
    if @address.valid? ## バリデーションに引っかからない（save可能な）時
      session["devise.regist_data"][:address] = @address
      redirect_to new_regist_payment_path
    else  ## バリデーションに引っかかる（save不可な）時
      redirect_to new_regist_address_path, alert: @address.errors.full_messages
    end
  end

  def new_payment
    ## card登録済の時はリダイレクト
    redirect_to regist_completed_path and return if session["devise.regist_data"][:card] || current_user&.card
    @progress = 4
    @card = Card.new
    render template: "cards/new"
  end

  def completed
    redirect_to root_path, alert: "エラーが発生しました" unless session["devise.regist_data"]
    @progress = 5
    @user = build_resource(session["devise.regist_data"]["user"])
    @user.build_sns_credential(session["devise.sns_auth"]["sns"]) if session["devise.sns_auth"] ## sessionがあるとき＝sns認証でここまできたとき
    @user.build_address(session["devise.regist_data"]["address"])
    @user.build_card(session["devise.regist_data"]["card"])
    if @user.save
      sign_up(resource_name, resource)  ## ログインさせる
    else
      redirect_to root_path, alert: @user.errors.full_messages
    end
  end

  private

  def address_params
    params.require(:address).permit(:postal_code, :prefecture, :city, :house_number, :building_name, :phone_number)
  end

  def signed_up?
    redirect_to root_path, alert: "ログインしています。" if user_signed_in?
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  ## 新規登録成功後のページ
  def after_sign_up_path_for(resource)
    ## 電話番号認証ページのパスを指定
    confirm_phone_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
