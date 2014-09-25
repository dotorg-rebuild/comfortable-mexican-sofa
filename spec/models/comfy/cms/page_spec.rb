require 'spec_helper'

describe Comfy::Cms::Page do
  describe '.find_by_secret' do
    let(:page) { create :page }
    subject { Comfy::Cms::Page.find_by_secret(page.secret_secret) }
    before do
      expect(Comfy::Cms::Page).
        to receive(:find_by_sql).
        with("SELECT *\n        FROM comfy_cms_pages\n       WHERE MD5(comfy_cms_pages.full_path) = '#{page.secret_secret}'").
        and_return([page])
    end

    after do
      page.destroy
    end

    it { is_expected.to eq page }
  end

  describe '.published' do
    let!(:page) { create :page, publish_at: publish_at }
    let(:publish_at) { nil }

    subject { Comfy::Cms::Page.published.find_by(id: page) }

    context 'no publish_at' do
      it { is_expected.to be_falsey }
    end

    context 'past publish_at' do
      let(:publish_at) { 1.day.ago }
      it { is_expected.to be_truthy }
    end

    context 'future publish_at' do
      let(:publish_at) { 1.day.from_now }
      it { is_expected.to be_falsey }
    end
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


  describe '#is_published?' do
    let(:datetime) { nil }
    let(:page) { build :page, publish_at: datetime }
    subject { page.is_published? }

    context 'it should behave like it`s the AR method still' do
      subject { page.is_published }
      it { is_expected.to be_falsey }
    end

    context 'no publish date' do
      let(:datetime) { nil }
      it { is_expected.to be_falsey }
    end

    context 'publish date is in the past' do
      let(:datetime) { 1.day.ago }
      it { is_expected.to be_truthy }
    end

    context 'publish date is in the future' do
      let(:datetime) { 1.day.from_now }
      it { is_expected.to be_falsey }
    end
  end

  describe 'page tag references' do
    let(:site) { build :site }
    let(:page) { build :page, site: site }
    let(:artist1) { build :artist, first_name: 'Tom', last_name: 'Hanks' }
    let(:artist2) { build :artist, first_name: 'Tom', last_name: 'Selek' }
    let(:program) { build :program, name: 'Directors Cuts' }

    describe '#refers_to' do
      let(:list_arg1) { [ 'Tom Hanks', 'Tom Selek' ] }
      let(:list_arg2) { [ 'Directors Cuts', 'Tom Selek' ] }

      context 'the first time a page is given tags' do
        before { page.page_referables = [] }
        it 'populates page_referables table/assignes them to correct page' do
          expect(page.page_referables.length).to eq 0
          expect{ page.refers_to = list_arg1 }.to change{Comfy::Cms::PageReferable.count}.by(2)
          expect(page.page_referables.length).to eq 2
        end
      end

      it 'returns a list comma-separated list of names' do
        page.refers_to = list_arg1
        expect(page.refers_to).to eq 'Tom Hanks, Tom Selek'
      end

      it 'overwrites previous page_referables' do
          page.refers_to = list_arg1
          expect(page.page_referables.map(&:referable_reference_name)).to include('Tom Hanks')
          page.refers_to = list_arg2
          expect(page.page_referables.map(&:referable_reference_name)).to_not include('Tom Hanks')
          expect(page.page_referables.map(&:referable_reference_name)).to include('Directors Cuts')
      end
    end
  end
end
