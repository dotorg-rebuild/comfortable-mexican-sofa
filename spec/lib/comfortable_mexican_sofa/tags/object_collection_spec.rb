require 'spec_helper'

describe ComfortableMexicanSofa::Tag::ObjectCollection do
  let(:tag) { ComfortableMexicanSofa::Tag::ObjectCollection.new }
  let(:blockable) { double :page, pageable: pageable }
  let(:pageable) { double :pageable, methodname: pageable_collection }
  let(:presenter) { double :presenter, methodname: presented_collection }
  let(:pageable_collection) { [] }
  let(:presented_collection) { [] }
  let(:identifier) { :methodname }

  describe '#value' do
    subject{ tag.value }

    before do
      allow(tag).to receive(:blockable).and_return blockable
      allow(tag).to receive(:identifier).and_return identifier
      allow(tag).to receive(:presenter).and_return presenter
    end

    context "identifier isn't a method on pageable" do
      let(:identifier) { :idontexist }

      it 'should return nil' do
        expect(subject).to be_nil
      end
    end

    context "identifier is a method on pageable" do
      it 'should return the collection' do
        expect(subject).to eq presented_collection
      end
    end
  end

  describe '#presenter' do
    subject { tag.presenter }
    let(:pageable) { double :pageable, class: hoob_class.class }
    let(:hoob_class) { double 'Hoob' }
    let(:hoob_presenter) { 'badname' }

    before do
      allow(tag).to receive(:presenter_name).and_return(hoob_presenter)
    end

    context 'when pageable_type presenter exists' do
      let(:hoob_presenter) { double 'HoobPresenter', constantize: 'HoobPresenterConst' }

      it 'should return name of presenter as constant' do
        expect(subject).to eq 'HoobPresenterConst'
      end
    end

    context 'when pageable_type presenter does NOT exist' do
      it 'should return pageable' do
        expect(subject).to eq nil
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
