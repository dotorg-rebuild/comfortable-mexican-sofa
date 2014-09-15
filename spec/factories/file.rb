FactoryGirl.define do
  factory :image_file, class: Comfy::Cms::File do
    before(:create) do |image_file|
      image_file.site = Comfy::Cms::Site.where(identifier: 'dotorg').first_or_create(
        label:      'dotorg',
        identifier: 'dotorg',
        hostname:   'localhost'
      )
    end
    sequence(:label) { |n| "image_#{n}" }
    file_file_name { "#{label}.jpg" }
    file_content_type 'image/jpeg'
    file_file_size 1024
  end
end
