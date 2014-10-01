FactoryGirl.define do
  factory :page, class: Comfy::Cms::Page do
    site
    layout
    is_published true
    sequence(:label) { |x| Faker::Movie.title }
    slug { label.parameterize }
  end
end
