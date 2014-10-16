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

  describe '#read_page_file' do
    let(:page) { create :page }
    let(:comfy_file) { create :image_file }

    before do
      page.blocks.create! identifier: 'manamana', files: [comfy_file]
    end
    subject { page.read_page_file('manamana').url }
    it { is_expected.to eq comfy_file.file.url }
  end

  describe '#append_page_file!' do
    let(:page) { create :page }
    let(:file) { File.new(Rails.root.join('app/assets/images/comfortable_mexican_sofa/checkerboard.gif')) }

    before do
      page.append_page_file!('manamana', file)
    end

    subject { page.read_page_file('manamana').url }

    it { is_expected.to match 'checkerboard' }
  end

  describe '#write_page_attribute' do
    let(:page) { create :page }
    let(:string) { rand(1000).to_s(36) }
    before do
      page.write_page_attribute 'manamana', string
    end
    subject { page.read_page_attribute('manamana') }
    it { is_expected.to eq string }

    context 'overwriting an existing attribute' do
      before do
        page.write_page_attribute 'manamana', 'bazqux'
        page.write_page_attribute 'manamana', 'foobar'
      end
      it { is_expected.to eq 'foobar' }
    end
  end

  describe '#read_page_attribute,#write_page_attribute' do
    let(:page) { create :page }
    let(:string) { rand(1000).to_s(36) }
    before do
      page.write_page_attribute 'manamana', string
    end

    subject { page.read_page_attribute('manamana') }
    it { is_expected.to eq string }

    context 'when the identifier does NOT exist' do
      subject { page.read_page_attribute('bananana') }
      it { is_expected.to eq nil }
    end
  end

  describe 'page tag references' do
    let(:page) { build :page }
    let(:list_arg1) { [ 'Tom Hanks', 'Tom Selek' ] }

    describe '#refers_to=' do
      let(:referable) { double :referable, :save => true, :referable= => true, :referable_reference_name= => true }
      let(:page_referables) { double :page_referables, build: referable }
      let(:tom_hanks) { double :tom_hanks, reference_name: 'Tom Hanks' }

      subject { page.page_referables }

      before do
        allow(page).to receive(:page_referables).and_return(page_referables)
        allow(page.class).to receive(:find_referable_from_referable_classes).and_yield(tom_hanks)
        page.refers_to = list_arg1
      end

      context 'with a different list' do
        before do
          allow(page).to receive(:page_referables=)
          page.refers_to = list_arg1
        end

        specify 'overwrites previous page_referables' do
          expect(page).to have_received(:page_referables=).with([])
        end
      end

      it { is_expected.to have_received(:build).with(referable_reference_name: 'Tom Hanks') }
    end

    describe '#refers_to' do
      let(:page_referables) { double :page_referables, pluck: ['Tom Hanks', 'Tom Selek'] }

      before do
        allow(page).to receive(:page_referables).and_return(page_referables)
      end

      it 'returns a list comma-separated list of names' do
        expect(page.refers_to).to eq 'Tom Hanks, Tom Selek'
      end
    end
  end

  describe 'polymorphic pageable' do
    let(:site) { build :site }
    let(:page) { build :page, site: site }

    it do
      page.pageable = site
      expect(page.pageable_type).to eq 'Comfy::Cms::Site'
      expect(page.pageable_id).to eq site.id
    end
  end

  describe '#ordered_blocks' do
    let(:page) { create :page }

    subject { page.ordered_blocks.first }

    it do
      is_expected.to be_kind_of Comfy::Cms::Block
    end
  end

  describe '#pageable_attributes' do
    let(:page) { create :page, pageable: pageable }
    let(:pageable) { create :layout }

    it do
      page.pageable_attributes = {
        label: 'label Label'
      }

      page.save
      expect(pageable.reload.label).to eq 'label Label'
    end

    context 'when the pageable doesnt have an assigned attribute' do
      it do
        expect do
          page.pageable_attributes = {
            foobar: 'baz  qux'
          }
        end.to_not raise_error
      end
    end

    context 'when the pageable is not there yet' do
      let(:page) { create :page }
      it do
        page.pageable_type = 'Comfy::Cms::Layout'
        page.pageable_attributes = {
          label: 'label Label'
        }
        expect(page.pageable).to be_kind_of(Comfy::Cms::Layout)
      end
    end

  end
end
