require 'spec_helper'

# included into Hash in config/initializers/core_ext.rb
describe HashHelper do
  describe '#merge_over_nils' do
    let(:defaults) { { a: 1, b: 2 } }
    let(:other) { { a: nil, b: 3 } }

    subject { other.merge_over_nils(defaults) }

    it { is_expected.to match(a: 1, b: 3) }
    specify { subject; expect(defaults).to match(a: 1, b: 2) }
  end

  describe '#has_all_keys?' do
    let(:hash) { { foo: 'baz', baz: 'qux' } }
    subject { hash.has_all_keys? keys }

    context 'with an array of keys' do
      let(:other_hash) { { foo: 'bar' } }
      let(:keys) { other_hash.keys }
      it { is_expected.to be_truthy }
    end

    context 'with multiple key arguments' do
      subject { hash.has_all_keys? :foo, :baz }
      it { is_expected.to be_truthy }
    end
  end
end
