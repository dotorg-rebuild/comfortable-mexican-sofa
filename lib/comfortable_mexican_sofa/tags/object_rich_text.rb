class ComfortableMexicanSofa::Tag::ObjectFieldRichText
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:object_field:(#{identifier}):rich_text\s*\}\}/
  end

  def content
    return nil unless blockable.pageable.respond_to?(identifier)
    blockable.pageable.send(identifier).to_s
  end

  def is_cms_block?
    true
  end

  def render
    ''
  end
end
