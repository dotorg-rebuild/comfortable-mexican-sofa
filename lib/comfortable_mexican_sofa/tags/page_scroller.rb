class ComfortableMexicanSofa::Tag::PageScroller
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):scroller\s*\}\}/
  end

  def content
    block.content
  end
end

