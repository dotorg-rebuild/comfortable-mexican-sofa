require 'spec_helper'

describe ComfortableMexicanSofa::FormBuilder::ObjectFieldDateBuilder do
  let(:index) { 1 }
  let(:content) { DateTime.new(2009, 9, 10, 11, 12) }
  let(:tag) { double :tag, identifier: 'start_date', content: content }
  let(:template_struct) { Struct.new(:output_buffer) }
  let(:template) { template_struct.new.
                   extend(ActionView::Helpers::FormHelper).
                   extend(ActionView::Helpers::FormTagHelper).
                   extend(ActionView::Helpers::DateHelper).
                   extend(ActionView::Helpers::FormOptionsHelper) }
  let(:form_builder) { double :form_builder, field_name_for: 'page' }
  let(:builder) { ComfortableMexicanSofa::FormBuilder::ObjectFieldDateBuilder.new(form_builder, template, tag, index) }


  before do
    Timecop.freeze
  end

  describe '#field_name' do
    subject { builder.field_name }

    it { is_expected.to eq 'page' }
  end

  describe '#attr_name' do
    subject { builder.attr_name }

    it { is_expected.to eq 'pageable_attributes][start_date%s' }
  end

  describe '#name' do
    subject { builder.name }
    it { is_expected.to eq 'page[pageable_attributes][start_date]' }
  end

  describe '#value' do
    subject { builder.value }
    it { is_expected.to eq tag.content }

    context 'tag content is blank' do
      let(:content) { nil }
      it { is_expected.to eq DateTime.now }
    end
  end

  describe '#label' do
    subject { builder.label }
    it { is_expected.to eq 'Start Date' }
  end

  describe '#select_tag' do
    subject { builder.select_tag(position) }

    context ':year' do
      let(:position) { :year }
      it { is_expected.to include '<select class="form-control" id="page_pageable_attributes_start_date_1i" name="page[pageable_attributes][start_date(1i)]">' }
    end

    context ':month' do
      let(:position) { :month }
      it { is_expected.to include '<select class="form-control" id="page_pageable_attributes_start_date_2i" name="page[pageable_attributes][start_date(2i)]">' }
    end

    context ':day' do
      let(:position) { :day }
      it { is_expected.to include '<select class="form-control" id="page_pageable_attributes_start_date_3i" name="page[pageable_attributes][start_date(3i)]">' }
    end

    context ':hour' do
      let(:position) { :hour }
      it { is_expected.to include '<select class="form-control" id="page_pageable_attributes_start_date_4i" name="page[pageable_attributes][start_date(4i)]">' }
    end

    context ':minute' do
      let(:position) { :minute }
      it { is_expected.to include '<select class="form-control" id="page_pageable_attributes_start_date_5i" name="page[pageable_attributes][start_date(5i)]">' }
    end
  end

  describe '#attr_name_for_position' do
    subject { builder.attr_name_for_position(:year) }
    it { is_expected.to eq 'pageable_attributes][start_date(1i)' }
  end
end
