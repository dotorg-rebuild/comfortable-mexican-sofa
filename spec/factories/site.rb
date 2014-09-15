FactoryGirl.define do
  factory :site, class: Comfy::Cms::Site do
    label      'dotorg'
    identifier 'dotorg'
    hostname   'localhost'
  end
end

