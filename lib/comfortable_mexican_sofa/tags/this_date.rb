class ComfortableMexicanSofa::Tag::ThisDate < ComfortableMexicanSofa::Tag::ObjectDate
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:this:(#{identifier}):date:?(.*?)\s*\}\}/
  end

  def value
    blockable.send(identifier)
  end
end
