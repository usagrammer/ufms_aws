crumb :root do
  link "メルカリ", root_path
end

crumb :category_index do
  link "カテゴリー一覧", categories_path
end

crumb :category_show do |category|
  link "#{category.name}", category_path(category)
  parent :category_index
end

crumb :item_show do |item|
  link "#{item.name}", item_path(item)
  parent :category_show, item.category
end

crumb :item_search do |keyword|
  link "#{keyword}", root_path
end

crumb :user_show do |user|
  link "#{user.nickname}さんのマイページ", user_path(user)
end

crumb :card_show do |user|
  link "#{user.nickname}さんのカード一覧", cards_path
  parent :user_show, user
end

crumb :card_new do |user|
  link "#{user.nickname}さんのカード登録", new_cards_path
  parent :card_show, user
end

crumb :selling do |user|
  link "#{user.nickname}さんの出品した商品（販売中）", selling_users_path
  parent :user_show, user
end

crumb :selling_progress do |user|
  link "#{user.nickname}さんの出品した商品（取引中）", selling_progress_users_path
  parent :user_show, user
end

crumb :sold do |user|
  link "#{user.nickname}さんの出品した商品（売却済み）", sold_users_path
  parent :user_show, user
end

crumb :bought_progress do |user|
  link "#{user.nickname}さんの購入した商品（取引中）", bought_progress_users_path
  parent :user_show, user
end

crumb :bought_past do |user|
  link "#{user.nickname}さんの購入した商品（過去の取引）", bought_past_users_path
  parent :user_show, user
end
