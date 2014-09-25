class Comfy::Cms::PageReferable < ActiveRecord::Base
  belongs_to :page, class_name: 'Comfy::Cms::Page'
  belongs_to :referable, polymorphic: true
end
