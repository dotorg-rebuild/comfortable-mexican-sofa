FactoryGirl.define do
  factory :layout, class: Comfy::Cms::Layout do
    before(:create) do |layout|
      layout.site = Comfy::Cms::Site.where(identifier: 'dotorg').first_or_create(
        label:      'dotorg',
        identifier: 'dotorg',
        hostname:   'localhost'
      )
    end
    app_layout 'application'
    label      'base'
    identifier 'base'
    content    '<header></header><div>{{ cms:page:content:string }}</div><footer></footer>'
  end
end
