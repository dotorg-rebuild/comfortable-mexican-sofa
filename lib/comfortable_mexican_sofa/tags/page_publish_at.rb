class ComfortableMexicanSofa::Tag::PagePublishAt
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:publish_at\s*\}\}/
  end

  def identifier
    'publish_at'
  end

  def content
    block.blockable.publish_at.strftime("%B %d, %Y")
  end

  def is_cms_block?
    false
  end
end
