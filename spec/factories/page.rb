FactoryGirl.define do
  factory :page, class: Comfy::Cms::Page do
    before(:create) do |page|
      page.site = Comfy::Cms::Site.where(identifier: 'dotorg').first_or_create(
        label:      'dotorg',
        identifier: 'dotorg',
        hostname:   'localhost'
      )
      page.layout = Comfy::Cms::Layout.where(identifier: 'base').first_or_create(
        site:       page.site,
        app_layout: 'application',
        label:      'base',
        identifier: 'base',
        content:    '<header></header><div>{{ cms:page:content:string }}</div><footer></footer>'
      )
    end
    is_published true
    sequence(:label) { |x| Faker::Movie.title }
    slug { label.parameterize }
  end
end
