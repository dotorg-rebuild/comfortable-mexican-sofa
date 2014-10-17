require 'spec_helper'

describe ComfortableMexicanSofa::Tag::ObjectDate do
  let(:tag) { ComfortableMexicanSofa::Tag::ObjectDate.new }
  let(:blockable) { double :comfy_page, pageable: pageable }
  let(:pageable) { double :pageable, start_date: 'now or something' }

  before do
    allow(tag).to receive(:blockable).and_return(blockable)
  end

  describe '#render' do
    let(:params) { [:short] }

    before do
      allow(tag).to receive(:value).and_return(value)
      allow(tag).to receive(:params).and_return(params)
    end

    subject { tag.render }


    context 'with a time object' do
      let(:value) { Time.parse '16 oct 2015 2pm' }
      it { is_expected.to eq '16 Oct 14:00' }
    end

    context 'with a date object' do
      let(:value) { Date.new(2014, 1, 1) }
      it { is_expected.to eq ' 1 Jan' }
    end

    context 'with nil' do
      let(:value) { nil }
      it { is_expected.to be_nil }
    end

    context 'with an object that is not a date' do
      let(:value) { 'some other thing' }
      it { is_expected.to be_nil }
    end
  end

  describe '#value' do
    let(:identifier) { 'start_date' }
    before do
      allow(tag).to receive(:identifier).and_return(identifier)
      tag.value
    end
    subject { pageable }

    context 'delegates to the pageable object' do
      it { is_expected.to have_received(:start_date) }
    end

    context 'doesnt explode if the pageable doesnt have that accessor' do
      subject { tag.value }
      let(:identifier) { 'non_extant_method' }
      it { is_expected.to be_nil }
    end
  end
end
