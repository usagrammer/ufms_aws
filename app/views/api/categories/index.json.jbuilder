json.choices do
  json.array! @categories, :id, :name
end
json.size_lists @size_lists
json.brand_names @brand_names
json.brand_groups @brand_groups&.pluck(:name)
