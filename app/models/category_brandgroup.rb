class CategoryBrandgroup < ApplicationRecord
  belongs_to :category
  belongs_to :brand_group
end
