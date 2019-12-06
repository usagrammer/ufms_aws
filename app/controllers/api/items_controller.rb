class Api::ItemsController < ApplicationController

  def create
    @item = Item.new(item_params)
    ## ブランド検索フォームの入力結果からブランド名を検索する
    set_brand_id
    @item.save
    @error_messages = @item.get_error_messages
    @error_messages = @error_messages.merge(@brand_error_message) if @brand_error_message
  end

  def update
    @item = current_user.items.find(params[:id])
    ## ブランド検索フォームの入力結果からブランド名を検索する
    set_brand_id
    @item.update(item_params)
    @error_messages = @item.get_error_messages
    @error_messages = @error_messages.merge(@brand_error_message) if @brand_error_message
  end

  private
  def item_params
    params.require(:item).permit(:name, :price, :detail, :condition, :delivery_fee_payer, :delivery_method, :delivery_agency, :delivery_days, :deal, :category_id, item_brand_attributes: [:brand_name_id], item_size_attributes: [:size_id], item_images_attributes: [:image, :id, :_destroy]).merge(seller_id: current_user.id)
  end

  def set_brand_id
    brand_id = BrandName.find_by(name: params[:brand_name])&.id
    if brand_id  ## ブランドがヒットした場合
      ## ヒットしたブランドのidをparamsに入れる
      params[:item][:item_brand_attributes] = {brand_name_id: brand_id}
    elsif params[:brand_name].present?  ## 検索フォームの入力があった場合且つブランドがヒットしなかった場合、エラーを表示して終了
      @brand_error_message = {brand: ["無効なブランドです。"]}
    end
  end

end
