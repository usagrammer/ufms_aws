class ItemBrand < ApplicationRecord
  belongs_to :item
  belongs_to :brand_name
end
