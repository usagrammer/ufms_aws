class Api::BrandNamesController < ApplicationController

  def index
    if params[:category_id]
      category = Category.find(params[:category_id])
      brand_groups = category.get_brand_groups
      return @brand_names = category.get_brand_names(brand_groups)
    end
    @brand_names = BrandName.all.pluck(:name)
  end

end
