ログイン情報

・郵便番号
・都道府県
・市区町村
・番地
・建物名
・電話番号

・メールアドレス
・パスワード
・ニックネーム
・introduction
・名字
・名字　読み
・名前
・名前　読み
・生年月日

## ◆user モデル

**● ユーザーテーブル**
ログインに必要な情報などアカウントの情報を入れておく。
クレカのトークンにはカード自体のトークンとカードに結びついている顧客のトークンがある。
どちらでも購入はできるがカード自体のトークンは 1 回しか使えないので顧客の方を使う。

・メルカリの新規登録画面：https://div.docbase.io/posts/622079

| Column     | Type   | Options                  |
| :--------- | :----- | :----------------------- |
| nickname   | string | null: false              |
| email      | string | null: false,unique: true |
| password   | string | null: false              |
| card_token | string |                          | [](クレカの"顧客の"トークンが入る) |

### Association

- has_many :items
- has_many :dealings
- has_one :sns_credential
- has_one :profile

## ◆profile モデル

**● 主にユーザーの個人情報を入れておくテーブル。**

| Column             | Type       | Options                        |
| :----------------- | :--------- | :----------------------------- |
| first_name         | string     | null: false                    |
| first_name_reading | string     | null: false                    |
| last_name          | string     | null: false                    |
| last_name_reading  | string     | null: false                    |
| phone_number       | integer    |                                |
| post_number        | integer    | null: false                    |
| prefecture         | integer    | null: false                    |
| city               | string     | null: false                    |
| house_number       | string     | null: false                    |
| building_name      | string     |                                |
| introduction       | text       |                                | [](自己紹介文) |
| avatar             | string     |                                | [](アイコン) |
| user               | references | null: false, foreign_key: true |

### Association

- belongs_to :user

## ◆sns_credential モデル

**●SNS による認証情報を入れておくテーブル。**
SNS 認証でユーザー登録すると生成される。

| Column   | Type       | Options                        |
| :------- | :--------- | :----------------------------- |
| provider | string     | null: false                    | [](googleなのかfacebookなのかが入る) |
| uid      | string     | null: false                    | [](細かい情報その1) |
| token    | string     | null: false                    | [](細かい情報その2) |
| user     | references | null: false, foreign_key: true |

### Association

- belongs_to :user

## ◆item(product) モデル

**● 商品テーブル**

| Column             | Type       | Options                        |
| :----------------- | :--------- | :----------------------------- |
| name               | string     | null: false, index: true       |
| price              | integer    | null: false                    |
| detail             | text       | null: false                    | [](説明文) |
| condition          | integer    | null: false                    | [](状態) |
| shipping_tax_payer | integer    | null: false                    | [](送料負担者) |
| shipping_agency    | integer    | null: false                    | [](発送元地域) |
| shipping_days      | integer    | null: false                    | [](発送までの日数) |
| deal               | integer    | default: 0                     | [](販売状態（0:出品中、1:取引中、2:売り切れなど）) |
| category           | references | null: false, foreign_key: true |
| user               | references | null: false, foreign_key: true | [](出品者のid) |

### Associations

- has_many :item_images
- has_one :item_option_size
- has_one :item_option_brand
- has_one :dealing
- belongs_to :user
- belongs_to :category

## ◆item_image モデル

**● 商品画像テーブル**
item_id は出品ボタンを押してから登録するので null:true

| Column | Type       | Options           |
| :----- | :--------- | :---------------- |
| image  | string     | null: false       |
| item   | references | foreign_key: true |

### Association

- belongs_to :item

## ◆category モデル

**● カテゴリーテーブル**
ancestry という gem を使う前提
・ancestry の github:https://github.com/stefankroes/ancestry

| Column   | Type   | Options                  |
| :------- | :----- | :----------------------- |
| name     | string | null: false, index: true |
| ancestry | string |                          | [](親子関係) |

### Association

- has_many :items
- has_one :category_option

## ◆category_option モデル

**● ブランドやサイズを選択できるかといったカテゴリーに対するオプションを設定するためのテーブル。**
このモデルのレコードを 1 つも持っていないカテゴリの商品はブランド、サイズを選択できないようにする。
size カラムの値に応じてサイズの選択肢を変化させる。

| Column   | Type       | Options                        |
| :------- | :--------- | :----------------------------- |
| brand    | integer    | default:0                      | [](1なら選択可能にする。) |
| size     | integer    | default:0                      | [](0以外なら選択可能かつカテゴリによって選択肢を変える。) |
| category | references | null: false, foreign_key: true |

### Association

- belongs_to :category

## ◆brand_list モデル

**● ブランドの一覧を入れておくテーブル**
※item は item_option_brand モデルを通してブランドを取得する。（商品によってはブランドを選択させないため）
インクリメンタルサーチがあるため index: true をかけておく。

| Column | Type   | Options                 |
| :----- | :----- | :---------------------- |
| name   | string | null: false,index: true |

### Association

- has_many :item_option_brands

## ◆item_option_brand モデル

**● 各商品がどのブランドに属しているかを示すテーブル**

| Column     | Type       | Options                        |
| :--------- | :--------- | :----------------------------- |
| brand_list | references | null: false, foreign_key: true |
| item       | references | null: false, foreign_key: true |

### Association

- belongs_to :item
- belongs_to :brand_list

## ◆item_option_size モデル

**● 各商品のサイズについてのテーブル**
例えば服の L サイズなら 10001、靴の 26.0 なら 11002 というふうに登録しておく。
一律で 1〜10 などの範囲にしておくと詳細検索のときに困るため（靴のサイズで検索したら服もヒットしたといった現象が起こる）。

| Column | Type       | Options                        |
| :----- | :--------- | :----------------------------- |
| size   | integer    | null: false                    |
| item   | references | null: false, foreign_key: true |

### Association

- belongs_to :item

## ◆dealing モデル

**● 取引テーブル**
商品が購入されるとこれのレコードが生成される。
誰が商品を購入したかは item モデル ではなくこれの user_id カラムで管理する。
item モデルに seller_id、buyer_id を入れて出品者、購入者を管理している人が多い？

> `@dealing.item.user`
> → 出品者のユーザー

> `@dealing.user`
> → 購入者のユーザー

> `Item.where('user_id = ?, deal = ?', current_user.id, 1)`
> → 取引中の出品した商品一覧

> `current_user.dealings`と each メソッド
> → 取引中の購入した商品一覧

が取得できるはず。

・buyer_id,seller_id についての参考記事（よく聞かれる）:
https://qiita.com/takeoverjp/items/bb56d6a8eae191cd3732

| Column | Type       | Options                        |
| :----- | :--------- | :----------------------------- |
| phase  | integer    | default:0                      | [](取引の進捗) |
| item   | references | null: false, foreign_key: true | [](購入された商品のid) |
| user   | references | null: false, foreign_key: true | [](購入者のid) |

### Association

- belongs_to :item
- belongs_to :user
