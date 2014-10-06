FactoryGirl.define do
  factory :page, class: Comfy::Cms::Page do
    site
    layout
    is_published true
    sequence(:label) { "#{Faker::Movie.title}-#{rand(10000)}" }
    slug { label.parameterize }
  end
end
