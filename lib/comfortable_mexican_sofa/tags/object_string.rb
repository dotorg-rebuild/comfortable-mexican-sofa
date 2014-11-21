class ComfortableMexicanSofa::Tag::ObjectString
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:object:(#{identifier})\s*\}\}/
  end

  def content
    return unless blockable.pageable.respond_to?(identifier)
    blockable.pageable.send(identifier).to_s
  end
end
