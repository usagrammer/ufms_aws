class BrandName < ApplicationRecord
  has_many :brandname_brandgroups
  has_many :brand_groups, through: :brandname_brandgroups
  has_many :item_brands
end
