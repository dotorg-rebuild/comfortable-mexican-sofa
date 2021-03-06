class ComfortableMexicanSofa::Tag::PageBanner
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):banner\s*\}\}/
  end

  def content
    block.content
  end
end

