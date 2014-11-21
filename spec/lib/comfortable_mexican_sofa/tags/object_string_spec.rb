require 'spec_helper'

describe ComfortableMexicanSofa::Tag::ObjectString do
  let(:tag) { ComfortableMexicanSofa::Tag::ObjectString.new }
  let(:pageable) { double :pageable, methodname: pageable_string }
  let(:presenter) { double :presenter, methodname: presented_string }
  let(:blockable) { double :page, pageable: pageable }
  let(:pageable_string) { 'pageable string' }
  let(:presented_string) { 'presenter string' }
  let(:identifier) { :methodname }


  describe '#content' do
    subject{ tag.content }

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
      it 'should return the string' do
        expect(subject).to eq presented_string
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
end
