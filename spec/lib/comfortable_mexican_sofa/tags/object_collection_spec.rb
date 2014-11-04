require 'spec_helper'

describe ComfortableMexicanSofa::Tag::ObjectCollection do
  let(:tag) { ComfortableMexicanSofa::Tag::ObjectCollection.new }
  let(:pageable) { double :pageable, methodname: collection }
  let(:blockable) { double :page, pageable: pageable }

  describe '#value' do
    before do
      allow(blockable).to receive(:pageable).and_return pageable
      allow(tag).to receive(:identifier).and_return identifier
      allow(tag).to receive(:blockable).and_return blockable
    end
    subject{ tag.value }

    context "identifier isn't a method on pageable" do
      let(:identifier) { :idontexist }
      let(:collection) { [] }

      it 'should return nil' do
        expect(subject).to be_nil
      end
    end

    context "identifier is a method on pageable" do
      let(:identifier) { :methodname }
      let(:collection) { [] }
      it 'should return the collection' do
        expect(subject).to eq collection
      end
    end
  end

  describe '#render' do
    before do
      allow(tag).to receive(:value).and_return(collection)
    end

    subject{ tag.render }

    context 'value returns an empty collection' do
      let(:collection) { [] }

      it "should return empty string" do
        expect(subject).to eq ""
      end
    end

    context 'value returns a populated collection' do
      let(:collection) { [ "Director", "Actor", "Executive Producer" ] }

      it "should surround formatted collection in ul tags" do
        expect(subject).to start_with %{<ul class="">}
        expect(subject).to end_with "</ul>"
      end

      it "should surround formatted collection items in li tags" do
        expect(subject).to eq %{<ul class=""><li>Director</li><li>Actor</li><li>Executive Producer</li></ul>}
      end
    end
  end
end
