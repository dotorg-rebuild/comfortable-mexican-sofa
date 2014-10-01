FactoryGirl.define do
  factory :image_file, class: Comfy::Cms::File do
    site
    sequence(:label) { |n| "image_#{n}" }
    file_file_name { "#{label}.jpg" }
    file_content_type 'image/jpeg'
    file_file_size 1024
  end
end
