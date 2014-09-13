module TruthTableHelper
  # truth_table :category_view, :has_children?, :page_root?, [
  #    true,  [ false,          true,           false        ],
  #    false, [ false,          true,           true         ],

  def truth_table *args
    table = args.pop
    keys = args
    context "truth table" do
      table.in_groups_of(2) do |row|
        expected, values = row
        row_mapping = keys.zip(values)

        context "when #{Hash[row_mapping].inspect}" do
          row_mapping.each do |variable, value|
            let(variable) { value }
          end
          it { is_expected.to eq expected }
        end
      end
    end
  end
end
