require 'spec_helper'

describe Comfy::Admin::Cms::PagesHelper, type: :helper do
  let(:page_id) { 1 }
  let(:page) { double :page, id: page_id, to_param: page_id.to_param, parent_id: 1 }
  before do
    allow(helper).to receive_messages(page: page)
  end

  describe '#category_view' do
    subject { helper.category_view }
    let(:params) { {
      category: category
    } }
    before do
      allow(helper).to receive(:params).and_return(params)
    end

    context 'when params has a category' do
      let(:category) { true }
      it { is_expected.to be_truthy }
    end

    context 'when params category is not present' do
      let(:category) { nil }
      it { is_expected.to be_falsey }
    end
  end

  describe '#children' do
    it 'should get children for the page from controller#pages_by_parent' do
      expect(controller).to receive(:pages_by_parent).with(page)
      helper.children(page)
    end
  end

  describe '#has_siblings?' do
    subject { helper.has_siblings?(page) }
    before do
      allow(helper).to receive(:siblings).with(page).and_return(siblings)
    end

    context 'page has siblings' do
      let(:siblings) { double size: 2 }
      it { is_expected.to be_truthy }
    end

    context 'page has NO siblings' do
      let(:siblings) { double size: 1 }
      it { is_expected.to be_falsey }
    end
  end

  describe '#is_open?' do
    subject { helper.is_open?(page) }
    before do
      allow(helper).to receive_messages(
        list_of_open_page_nodes: list_of_open_page_nodes
      )
      allow(page).to receive_messages(
        id: page_id,
        root?: current_page_is_root?
      )
    end

    context 'the page is one of the open pages' do
      let(:list_of_open_page_nodes) { ['1'] }
      let(:page_id) { 1 }
      let(:current_page_is_root?) { false }
      it { is_expected.to be_truthy }
    end

    context 'the page is the root page' do
      let(:list_of_open_page_nodes) { [] }
      let(:page_id) { 1 }
      let(:current_page_is_root?) { true }
      it { is_expected.to be_truthy }
    end
  end

  describe '#reorderable?' do
    subject { helper.reorderable?(page) }
    before do
      allow(helper).to receive_messages(
        has_siblings?: has_siblings?,
        category_view: category_view,
      )
    end

    truth_table :has_siblings?, :category_view, [
    true,  [     true,           false ],
    false, [     true,           true  ],
    false, [     false,          true  ],
    false, [     false,          false ],
    ]
  end

  describe '#selectable_parent?' do
    subject { helper.selectable_parent?(page) }
    before do
      allow(controller).to receive(:pages_root).and_return(pages_root)
    end

    context "when it's NOT the blog root" do
      let(:pages_root) { "something else" }
      it { is_expected.to be_truthy }
    end

    context "when it is the blog root" do
      let(:pages_root) { page }
      it { is_expected.to be_falsey }
    end
  end

  describe '#show_children?' do
    subject { helper.show_children?(page) }
    before do
      allow(helper).to receive_messages(
        category_view: category_view,
        has_children?: has_children?,
        is_open?: is_open?
      )
    end

    truth_table :category_view, :has_children?, :is_open?, [
    true,     [  false,          true,           true    ],
    false,    [  true,           true,           false   ],
    false,    [  true,           true,           true    ],
    false,    [  true,           false,          false   ],
    false,    [  true,           false,          true    ],
    false,    [  false,          true,           false   ],
    false,    [  false,          false,          false   ],
    false,    [  false,          false,          true    ],
    ]
  end

  describe '#show_toggle?' do
    subject { helper.show_toggle?(page) }
    before do
      allow(helper).to receive_messages(
        category_view: category_view,
        has_children?: has_children?,
        page_root?: page_root?,
      )
    end

    truth_table :category_view, :has_children?, :page_root?, [
    true,  [     false,          true,           false         ],
    false, [     false,          true,           true          ],
    false, [     false,          false,          false         ],
    false, [     false,          false,          true          ],
    false, [     true,           true,           false         ],
    false, [     true,           true,           true          ],
    false, [     true,           false,          false         ],
    false, [     true,           false,          true          ],
    ]
  end

  describe '#siblings' do
    let(:pages) { 'some collection of other pages' }
    subject { helper.siblings(page) }
    before do
      expect(helper).to receive(:pages_by_parent).with(page.parent_id).and_return(pages)
    end

    it { is_expected.to eq pages }
  end
end

