require_relative './page_file'

class ComfortableMexicanSofa::Tag::FieldFiles
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:field_files:(#{identifier}):?(.*?)\s*\}\}/
  end

  def render
    ''
  end
end
