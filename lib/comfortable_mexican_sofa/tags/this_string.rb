require_relative 'object_string'

class ComfortableMexicanSofa::Tag::ThisString < ComfortableMexicanSofa::Tag::ObjectString
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:this:(#{identifier})\s*\}\}/
  end

  def content
    return nil unless blockable.respond_to?(identifier)
    blockable.send(identifier).to_s
  end
end
