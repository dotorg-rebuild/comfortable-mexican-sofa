require 'spec_helper'

describe ComfortableMexicanSofa::FormBuilder do
  describe '#object_field_date' do
    let(:template_struct) { Struct.new(:output_buffer) }
    let(:template) { template_struct.new.
                     extend(ActionView::Helpers::FormHelper).
                     extend(ActionView::Helpers::FormTagHelper).
                     extend(ActionView::Helpers::DateHelper).
                     extend(ActionView::Helpers::FormOptionsHelper) }
    let(:page)     { double :page, pageable: event }
    let(:form)     { ComfortableMexicanSofa::FormBuilder.new(:page, page, template, {}) }
    let(:event)    { double :event }
    let(:content)  { DateTime.new(1999, 12, 31, 23, 59) }
    let(:has_zone) { true }
    let(:tag)      { double(:tag, {
                     blockable: page,
                     content: content,
                     has_zone?: has_zone,
                     identifier: 'start_date',
                     zone: 'Zone',
                   })}
    subject { form.object_field_date(tag, 1) }

    it do
      is_expected.to include '<select class="form-control" id="double_pageable_attributes_start_date_1i" name="double[pageable_attributes][start_date(1i)]">'
      is_expected.to include '<option selected="selected" value="1999">1999</option>'
    end

    it do
      is_expected.to include '<select class="form-control" id="double_pageable_attributes_start_date_2i" name="double[pageable_attributes][start_date(2i)]">'
      is_expected.to include '<option selected="selected" value="12">December</option>'
    end

    it do
      is_expected.to include '<select class="form-control" id="double_pageable_attributes_start_date_3i" name="double[pageable_attributes][start_date(3i)]">'
      is_expected.to include '<option selected="selected" value="31">31</option>'
    end

    it do
      is_expected.to include '<select class="form-control" id="double_pageable_attributes_start_date_4i" name="double[pageable_attributes][start_date(4i)]">'
      is_expected.to include '<option selected="selected" value="23">11 PM</option>'
    end

    it do
      is_expected.to include '<select class="form-control" id="double_pageable_attributes_start_date_5i" name="double[pageable_attributes][start_date(5i)]">'
      is_expected.to include '<option selected="selected" value="59">59</option>'
    end

    it do
      is_expected.to include '<select class="form-control" id="double_pageable_attributes_start_date_time_zone" name="double[pageable_attributes][start_date_time_zone]">'
      is_expected.to include '<option value="(GMT+08:00) Perth">(GMT+08:00) Perth</option>'
    end

    context 'with a non-date tag content' do
      let(:content) { nil }
      it 'should not error out' do
        expect do
          subject
        end.to_not raise_error
      end
    end

    context 'if the tag has no zone' do
      let(:has_zone) { false }
      it do
        is_expected.to_not include '<select class="form-control" id="double_pageable_attributes_start_date_time_zone" name="double[pageable_attributes][start_date_time_zone]">'
        is_expected.to_not include '<option value="(GMT+08:00) Perth">(GMT+08:00) Perth</option>'
      end
    end
  end
end
