class ComfortableMexicanSofa::Tag::ObjectDate
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:object:(#{identifier}):date:?(.*?)\s*\}\}/
  end

  def content
    value.to_s
  end

  def render
    return if value.method(:to_s).arity.zero? # don't call to_s with a param on anything except date and time types!
    fmt = params.first.try(:to_sym) || :long # date formats expect symbols only!?
    value.try(:to_s, fmt)
  end

  def value
    blockable.pageable.send(identifier)
  end
end
