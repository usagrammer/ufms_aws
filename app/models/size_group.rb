class SizeGroup < ApplicationRecord
  has_many :category_sizegroups
  has_many :categories, through: :category_sizegroups
end
