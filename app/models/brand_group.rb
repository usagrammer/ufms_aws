class BrandGroup < ApplicationRecord
  has_many :brandname_brandgroups
  has_many :brand_names, through: :brandname_brandgroups
  has_many :category_brandgroups
  has_many :categories, through: :category_brandgroups
end
