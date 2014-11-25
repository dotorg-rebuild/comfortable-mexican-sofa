class ComfortableMexicanSofa::Tag::ObjectString
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:object:(#{identifier})\s*\}\}/
  end

  def content
    if presenter.respond_to?(identifier)
      presenter.send(identifier, pageable).to_s
    elsif pageable.respond_to?(identifier)
      pageable.send(identifier).to_s
    end
  end

  def pageable
    blockable.pageable
  end

  def presenter
    begin
      presenter_name.constantize
    rescue NameError
      nil
    end
  end

  def presenter_name
    "#{pageable.class.to_s}Presenter"
  end
end
