FactoryGirl.define do
  factory :site, class: Comfy::Cms::Site do
    label      'dotorg'
    identifier 'dotorg'
    hostname   'localhost'

    initialize_with { Comfy::Cms::Site.where(identifier: 'dotorg').first_or_create(
        label:      'dotorg',
        identifier: 'dotorg',
        hostname:   'localhost'
      ) }
  end
end

