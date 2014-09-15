require 'spec_helper'

describe ComfortableMexicanSofa::Tag::PageAccordion do
  let(:tag) { ComfortableMexicanSofa::Tag::PageAccordion.new }

  describe '#content' do
    let(:block) { double :block, content: source_data }
    before do
      allow(tag).to receive(:block).and_return(block)
    end

    subject { tag.content }

    context 'with non-json data' do
      let(:source_data) { 'gobledegook' }
      it 'should eq DEFAULT_FIELDS' do
        is_expected.to eq ComfortableMexicanSofa::Tag::PageAccordion::DEFAULT_FIELDS.to_json
      end
    end

    context 'with some json all up in that' do
      let(:source_data) { { 'foo' => 'bar'}.to_json }
      it "should eq DEFAULT_FIELDS" do
        is_expected.to eq(ComfortableMexicanSofa::Tag::PageAccordion::DEFAULT_FIELDS.to_json)
      end
    end

    context 'with nil data' do
      let(:source_data) { nil }
      it "should eq DEFAULT_FIELDS" do
        is_expected.to eq(ComfortableMexicanSofa::Tag::PageAccordion::DEFAULT_FIELDS.to_json)
      end
    end
  end

  describe '#render' do
    subject { tag.render }
    let(:template) { double :template, render: '' }
    before do
      allow(tag).to receive(:json).and_return(json)
      allow(tag).to receive(:template).and_return(template)
    end

    context 'with incorrecly shaped json' do
      let(:json) { { bad: 'data' } }
      before { subject }
      it "should not try to render the template" do
        expect(template).to_not have_received(:render)
      end
    end
  end
end
