def seed_db
  site = Comfy::Cms::Site.create!(label: 'dotorg', identifier: 'dotorg', hostname: 'localhost')
  layout = Comfy::Cms::Layout.create!(site_id: site.id,
                             app_layout: 'application',
                             label: 'base',
                             identifier: 'base',
                             content: '<header></header><div>{{ cms:page:content:string }}</div><footer></footer>')

  layout = Comfy::Cms::Layout.create!(site_id: site.id,
                             app_layout: 'application',
                             label: 'program-base',
                             identifier: 'program-base',
                             content: '')

  root_menu_item = MenuItem.create!(label: 'root', parent: nil)
end

def login_and_create_home_page
  login_as_editor
  visit new_comfy_admin_cms_site_page_path(site_id: site.id)
  fill_in 'Label', with: 'index'
  select layout.identifier, from: 'Layout'

  find('#new_page').click_button('Create Page')
end
