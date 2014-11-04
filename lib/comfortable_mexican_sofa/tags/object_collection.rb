class ComfortableMexicanSofa::Tag::ObjectCollection
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifer = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:object:(#{identifier}):collection:?(.*?)\s*\}\}/
  end

  def render
    return "" if value.blank?
    html = %{<ul class="#{identifier}">}
    value.each do |single_value|
      html += "<li>#{single_value}</li>"
    end
    html += "</ul>"
  end

  def value
    return nil unless blockable.pageable.respond_to?(identifier)
    blockable.pageable.send(identifier)
  end
end
