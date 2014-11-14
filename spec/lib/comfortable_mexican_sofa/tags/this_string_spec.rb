require 'spec_helper'

describe ComfortableMexicanSofa::Tag::ThisString do
  let(:tag) { described_class.new }
  let(:some_string_attribute) { 'foobar' }
  let(:blockable) { double :comfy_page, some_string_attribute: some_string_attribute }

  before do
    allow(tag).to receive(:identifier).and_return(identifier)
    allow(tag).to receive(:blockable).and_return(blockable)
  end

  describe '#render' do
    context 'with an attribute that is present on Comfy::Cms::Page' do
      let(:identifier) { 'some_string_attribute' }
      it 'returns the string value of the named attribute' do
        expect(tag.render).to eq some_string_attribute
      end
    end
    context 'with an attribute that does not exist' do
      let(:identifier) { 'not_an_attribute_on_the_page' }
      it 'returns blank' do
        expect(tag.render).to be_blank
      end
    end
  end
end