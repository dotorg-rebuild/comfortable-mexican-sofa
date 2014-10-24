class ComfortableMexicanSofa::Tag::ObjectFieldSelect
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= /[\w\/\-]+/
    /\{\{\s*cms:object_field:(#{identifier}):select:(.*?)\s*\}\}/
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
