require 'spec_helper'

describe Comfy::Cms::Page do
  describe '.find_by_secret' do
    let(:page) { create :page }
    subject { Comfy::Cms::Page.find_by_secret(page.secret_secret) }
    before do
      expect(Comfy::Cms::Page).to receive(:find_by_sql)
    end
    it { is_expected.to eq page }
  end


  describe '#blog_categories' do
    subject { Comfy::Cms::Page }

    before do
      allow(subject).to receive(:where)
      subject.blog_categories
    end

    it { is_expected.to have_received(:where).with(is_blog: true, is_blog_post: false) }
  end

  describe '#secret_url' do
    let(:site) { build :site }
    let(:page) { build :page, site: site }
    subject { page.secret_url }
    it { is_expected.to eq '//localhost/secret/d41d8cd98f00b204e9800998ecf8427e' }
  end
end
