class ItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy, :show, :purchase_confirmation, :purchase] ## @itemを定義する
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :purchase_confirmation, :purchase] ## ログイン必須アクション
  before_action :item_selling?, only: [:edit, :update, :destroy, :purchase_confirmation, :purchase] ## 売り切れではないかチェック
  before_action :seller?, only: [:edit, :update, :destroy] ## 出品者のみ可能なアクション
  before_action :not_seller?, only: [:purchase] ## 出品者ではない人のみ可能なアクション

  def index ## トップページ
    return false if Item.count == 0 ## 商品数がゼロのときはランキングが作れないのでここで終了
    categories = Category.roots ## 親カテゴリたちを配列で取得
    items = categories.map{|root| Item.search_by_category(root.subtree_ids)} ## カテゴリごとの商品リストを取得
    @sorted_items = items.sort { |a,b| b.length <=> a.length} ## カテゴリごとの商品リストを商品数が多い順で並び替える
    @sorted_items = @sorted_items[0..3].map{|items| items.order("created_at DESC").limit(4)} ## 商品数が多いカテゴリ上位4つのみ表示したい。また、1つのカテゴリのうち新着商品は4つだけ表示する。
    @sorted_items = @sorted_items.reject(&:blank?) ## 商品数がゼロのカテゴリを削除する
    @category_ranking = @sorted_items.map{|items| items[0].category.root} ## 商品数が多いカテゴリのランキングを定義

    # @new_items_arrays = []
    # @categories = ["レディース", "メンズ", "ベビー・キッズ", "インテリア・住まい・小物"] ## 新着アイテムを表示したいカテゴリの名前たち
    # @categories = @categories.map{|category_name| Category.find_by(name: category_name)} ## カテゴリの名前たちを使ってカテゴリのインスタンスが入った配列を作成
    # @categories.each do |category|
    #   @new_items_arrays << Item.search_by_category(category.subtree_ids).order("created_at DESC").limit(4) ## カテゴリごとの新着アイテムを配列化する
    # end
  end

  def show ## 商品詳細ページ
  end

  def new ## 出品ページ
    @item = Item.new
    @item.item_images.build  ## 新規画像用
    render layout: 'no_menu', template: 'items/form'
  end

  def edit ## 商品編集ページ
    @item.item_images.build  ## 新規画像用
    render layout: 'no_menu', template: 'items/form'
  end

  def create
    redirect_to root_path, notice: "商品の出品に成功しました。" and return if params[:completed]
    @item = Item.new(item_params)
    if @item.save
     redirect_to root_path, notice: "商品の出品に成功しました。"
    else
     redirect_to new_item_path, alert: @item.errors.full_messages
    end
  end

  def update
    redirect_to root_path, notice: "商品の編集に成功しました。" and return if params[:completed]
    @item = current_user.items.find(params[:id])
    if @item.update(item_params)
     redirect_to root_path, notice: "商品の編集に成功しました。"
    else
     redirect_to edit_item_path(@item), alert: @item.errors.full_messages
    end
  end

  def destroy
    @item.destroy
    redirect_to root_path, notice: '商品を削除しました'
  end

  def purchase_confirmation ## 購入内容確認ページ
    @card = Card.get_card(current_user.card&.customer_token)
    render layout: 'no_menu'
  end

  def purchase
    ## カードを所持していないなら購入させない
    redirect_to purchase_confirmation_item_path(@item), notice: 'カード情報を登録してください。' and return unless current_user.card
    ## with_lockで同時購入などが起きることを防ぐ
    ActiveRecord::Base.transaction do
      @item.with_lock do
        ## 取引状態を更新しておく
        @item.update(deal: '売り切れ')
        Dealing.create(item_id: @item.id, buyer_id: current_user.id)

        ## 秘密鍵を渡して認証する
        Payjp.api_key = Rails.application.credentials.payjp[:secret_key]
        ## 顧客のトークンを渡して顧客情報をもらう
        customer = Card.get_customer(current_user.card.customer_token)
        ## 顧客情報を使って支払いをする
        Payjp::Charge.create(
          amount: @item.price, # 決済する値段
          customer: customer.id,
          currency: 'jpy'
        )
      end
    end
    redirect_to root_path, notice: '購入しました。'
    ## 途中でエラーが起きた場合例外処理
    rescue Payjp::CardError
      redirect_to item_path(@item), notice: '購入に失敗しました。'
  end

  def search
    if params[:q]
      ## params[:q]の中身があるときの処理
      ########商品名検索ここから########
      params[:q][:name_cont_any] = params[:name_search].squish.split(" ")  ## 入力内容を半角スペースで区切って配列を作成する
      ########商品名検索ここまで########

      ########ブランド名検索ここから########
      params[:q][:item_brand_brand_name_name_cont_any] = params[:search_brand].squish.split(" ") if params[:search_brand]  ## 入力内容を半角スペースで区切って配列を作成する
      ########ブランド名検索ここまで########

      ########サイズ検索ここから########
      if params[:size_group].present?
        @size_group_name = Size.find_by(group_name: params[:size_group])&.group_name
        @size_list = Size.where(group_name: params[:size_group])
        @size_list = @size_list.to_a.unshift(Size.new(id: -1, name: "すべて")) ## 「すべて」という選択肢を追加する
      end
      ########サイズ検索ここまで########

      ########カテゴリ関連の処理ここから########
      ## ↓ params[:q][:category_id_in]がない時は定義しておく
      params[:q][:category_id_in] = [] unless params[:q][:category_id_in]
      ## ↓ @grandchild_category_idsは孫カテゴリたちのチェック状態用
      @grandchild_category_ids = params[:q][:category_id_in]
      ## ↓親カテゴリが何かしら選択されたなら@parent_categoryを定義する
      @parent_category = Category.find(params[:q][:category_id_in][0]) if params[:q][:category_id_in][0].present?
      ## ↓子カテゴリが何かしら選択されたなら@parent_categoryを定義する
      @child_category = Category.find(params[:q][:category_id_in][1]) if params[:q][:category_id_in][1].present?
      ## ↓親カテゴリが選択されていて子カテゴリが「全て」の時、親カテゴリに属しているカテゴリ全てを検索対象とする
      ## 例えば親カテゴリが「レディース」で子カテゴリが「すべて」なら「レディース」に属しているカテゴリ全てをqに入れる
      params[:q][:category_id_in] = @parent_category.subtree_ids if params[:q][:category_id_in][1] == ""
      ## ↓子カテゴリが選択されていて孫カテゴリが選択されていない時、子カテゴリに属しているカテゴリ全てを対象とする
      if params[:q][:category_id_in][1].present? && params[:q][:category_id_in][2].blank?
        params[:q][:category_id_in] = (params[:q][:category_id_in] + @child_category.subtree_ids).uniq
      end
      ########カテゴリ関連の処理ここまで########
    else
      ## params[:q]の中身がないときの処理
      params[:q] = { sorts: 'id DESC' } ## 検索フォーム外から直接アクセスした時は新しい順にしておく
    end
    ## 共通の処理
    @q = Item.ransack(params[:q])
    @items = @q.result(distinct: true).includes(:item_images).page(params[:page]).per(6)

    @order = [["価格が安い順", "price ASC"], ["価格が高い順", "price DESC"], ["出品が新しい順", "created_at DESC"], ["出品が古い順", "created_at ASC"]]
    @price_list = [["300~1000", "300,1000"], ["1000~5000", "1000,5000"], ["5000~10000", "5000,10000"], ["10000~30000", "10000,30000"]]

  end

  private
  def item_params
    params.require(:item).permit(:name, :price, :detail, :condition, :delivery_fee_payer, :delivery_method, :delivery_agency, :delivery_days, :deal, :category_id, item_brand_attributes: [:brand_name_id], item_size_attributes: [:size], item_images_attributes: [:image, :id, :_destroy]).merge(seller_id: current_user.id)
  end

  def set_item ## @itemを定義する
    @item = Item.find(params[:id])
  end

  def item_selling? ## 売り切れだったらリダイレクトさせる
    redirect_to item_path(@item), alert: '売り切れました。' if @item.deal != "販売中"
  end

  def seller? ## 出品者ではなかったらリダイレクトさせる
    redirect_to item_path(@item), alert: "あなたは出品者ではありません。" unless @item.seller.id == current_user.id
  end

  def not_seller? ## 出品者だったらリダイレクトさせる
    redirect_to item_path(@item), alert: "あなたは出品者です。" if @item.seller.id == current_user.id
  end

end
