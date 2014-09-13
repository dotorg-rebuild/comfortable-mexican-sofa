module HashHelper
  def merge_over_nils other
    dup.tap do |new_hash|
      other.each do |key, value|
        new_hash[key] = value if new_hash[key].blank?
      end
    end
  end

  def has_all_keys? *keys
    keys.flatten.all? { |key| self.has_key? key }
  end
end
