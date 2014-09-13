FactoryGirl.define do
  factory :menu_item do
    before(:create) do |menu_item|
      menu_item.parent = MenuItem.where(label: 'root').first_or_create(
        label:     'root',
        url:       'root',
        parent_id: nil
      )
    end
    label { Faker::Lorem.word }
    url   { |item| item.label }
  end
end
