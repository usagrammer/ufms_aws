class Api::CategoriesController < ApplicationController

  def index
    category = Category.find(params[:category_id])
    @categories = category.children
    @brand_names = nil
    @size_lists = nil
    if category.children.length == 0
      ## category.childrenが空の時、最下層のカテゴリを選んだということなので
      ## ブランドやサイズのフォームを表示したい
      @size_lists = category.get_size_list
      @brand_groups = category.get_brand_groups
      if @brand_groups.pluck(:name) == params[:brand_groups] ## ブランドのグループに変化があった時だけbrand_namesを更新する
        ## ブランドのグループに変化がない
        @brand_names = "no_changed"
      else
        ## ブランドのグループに変化があった
        @brand_names = category.get_brand_names(@brand_groups)
      end
    end
  end

  def get_options
    category = Category.find(params[:category_id])
    @size_lists = category.get_size_list
    @brand_groups = category.get_brand_groups
    if @brand_groups.pluck(:name) == params[:brand_groups]
      @brand_names = "no_changed" ## ブランドのグループに変化がない
    else
      @brand_names = category.get_brand_names(@brand_groups)
    end
  end

end
