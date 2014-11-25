class ComfortableMexicanSofa::Tag::ObjectCollection
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifer = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:object:(#{identifier}):collection:?(.*?)\s*\}\}/
  end

  def render
    return "" if value.blank?
    html = %{<ul class="#{identifier}">}
    value.each do |single_value|
      html += "<li>#{single_value}</li>"
    end
    html += "</ul>"
  end

  def value
    if presenter.respond_to?(identifier)
      presenter.send(identifier, pageable)
    elsif pageable.respond_to?(identifier)
      pageable.send(identifier)
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
