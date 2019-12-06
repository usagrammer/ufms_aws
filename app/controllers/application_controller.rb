class ApplicationController < ActionController::Base
  before_action :configure_permitted_paramaters, if: :devise_controller?
  before_action :basic_auth, if: :production?
  before_action :clean_items

  private

  def clean_items ## 商品の定期消去
    if Time.now.wday == 6 && Time.now.hour == 18
      delete_items = Item.where("created_at <= ?", 7.day.ago)
      return false if delete_items.length == 0
      delete_items.each do |item|
        item.destroy
      end
    end
  end

  def configure_permitted_paramaters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :avatar, :introduction, :first_name, :first_name_reading, :last_name, :last_name_reading, :birthday, :earnings, :points])
  end

  def production?
    Rails.env.production?
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.basic[:auth_user] && password == Rails.application.credentials.basic[:auth_password]
    end
  end

end
