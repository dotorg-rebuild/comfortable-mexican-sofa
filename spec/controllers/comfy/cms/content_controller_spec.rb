require 'spec_helper'

describe Comfy::Cms::ContentController, type: :controller do
  describe '#secret' do
    let(:model_class) { class_double('Comfy::Cms::Page', {
      find_by_secret: page
    }) }

    let(:layout) { object_double(Comfy::Cms::Layout.new, {
      app_layout: 'application'
    })}

    let(:site) { object_double(Comfy::Cms::Site.new, {
      id: 1,
      path: 'path'
    })}

    let(:page) { instance_double('Comfy::Cms::Page', {
      secret_secret: 'secret',
      layout: layout,
      content_cache: 'content_cache',
      target_page: nil
    })}

    subject { response }

    before do
      model_class.as_stubbed_const

      allow(controller).to receive(:load_cms_site)
      controller.instance_variable_set '@cms_site', site

      allow(site).to receive_message_chain(:pages, :find_by_full_path!).and_return(page)

      get :secret, secret: page.secret_secret, site_id: site.id
    end

    it { is_expected.to be_success }
  end
end
