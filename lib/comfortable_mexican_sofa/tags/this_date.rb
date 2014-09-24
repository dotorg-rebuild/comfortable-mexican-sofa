class ComfortableMexicanSofa::Tag::ThisDate
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:this:(#{identifier}):date\s*\}\}/
  end

  def content
    if block.blockable.respond_to? identifier
      block.blockable.send(identifier).try(:strftime, "%B %d, %Y")
    else
      "#{CGI.escapeHTML block.blockable.inspect} has no member '#{identifier}'!"
    end
  end

  def is_cms_block?
    false
  end
end
