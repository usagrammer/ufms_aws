class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook google]

  has_one :address, dependent: :destroy
  has_one :sns_credential, dependent: :destroy
  has_one :card, dependent: :destroy

  has_many :items, foreign_key: "seller_id"
  has_many :dealings, foreign_key: "buyer_id"

  validates :nickname, :birthday, :earnings, :points, presence: true
  validates :first_name_reading, presence: true, format: { with: /\A[\p{katakana}\p{blank}ー－]+\z/, message: 'はカタカナで入力して下さい。'}
  validates :last_name_reading, presence: true, format: { with: /\A[\p{katakana}\p{blank}ー－]+\z/, message: 'はカタカナで入力して下さい。'}

  private

  def self.find_oauth(auth)
    ## ↓既にsns_credentialのレコードがあるかを検索する。
    ## first_or_initialize→既にDBに存在するならDBから読み込む。無いなら新しく作る（newする）
    sns_credential = SnsCredential.where(uid: auth.uid, provider: auth.provider).first_or_initialize
    ## ↓①既にsns_credentialが登録済みのパターン
    ## ↓がomniauthコントローラのsession["devise.sns_auth"]に入る
    return {user: sns_credential.user, sns: sns_credential} if sns_credential.persisted?
    ## ↓まだsns_credentialが未登録の場合。
    ## 既にuserがemailで登録されているか調べる（例：googleでログインしようとしたが既にメールアドレスで新規登録済み）
    user = User.where(email: auth.info.email).first_or_initialize
    if user.persisted? ## ②sns_credentialは無いがuserは登録済みのパターン
      ## sns_credentialとuserを紐付ける。
      sns_credential.user_id = user.id
      sns_credential.save
    else ## ③sns_credentialとuserの両方が未登録のパターン
      user.nickname = auth.info.name
    end
    ## ↓がomniauthコントローラのsession["devise.sns_auth"]に入る
    return {user: user, sns: sns_credential}
  end

end
