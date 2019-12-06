class Category < ApplicationRecord
  has_many :items
  has_ancestry
  has_many :category_brandgroups
  has_many :brand_groups, through: :category_brandgroups
  has_one :category_sizegroup
  has_one :size_group, through: :category_sizegroup

  def get_children  ## ヘッダーのカテゴリリスト用にキャッシュを作る
    Rails.cache.fetch("#{self.id}_children") do
      self.children.to_a
    end
  end

  def get_brand_groups
    brand_groups = []
    category = self ## self＝このメソッドを呼び出したカテゴリ
    loop do  ## 親子孫カテゴリそれぞれが選択できるbrand_nameを取得する。
     category.brand_groups&.each do |brand_group|  ## brand_groupsを持っていたらそれに含まれるブランド名たちを配列に入れていく。
       brand_groups << brand_group
     end
     category = category.parent  ## 親子カテゴリも確認する。
     return brand_groups unless category  ## これ以上親がいないなら終了。
   end
  end

  def get_brand_names(brand_groups)  ## 選択できるブランド名のリストを取得する。
    brand_names = []
    brand_groups&.each do |brand_group|  ## brand_groupsを持っていたらそれに含まれるブランド名たちを配列に入れていく。
      brand_names = (brand_names+brand_group.brand_names.pluck(:name)).uniq  ## pluckメソッド→引数で指定したカラムの配列を作る。name以外いらないので。
    end
    return brand_names
  end

  def get_size_list  ## size_groupモデルからサイズの選択肢を取得する。
    size_lists = ""
    category = self
    size_type = ""
    loop do  ## 親子孫カテゴリのうちどれかがsize_groupを持っているかチェックし、nameを取得する。
      size_type = category.size_group&.name
      if size_type  ## size_typeがある＝サイズが選択できるカテゴリなので選択肢を取得して抜ける。
        size_lists = Size.where(group_name: size_type)  ## active_hashのせいかattributesメソッドをしないとハッシュ構造が変になる。
        puts size_type
        puts size_lists
      end
      category = category.parent  ## 親子カテゴリも確認する。
      break unless category  ## これ以上親がいないなら終了。
    end
    return size_lists
  end

end
