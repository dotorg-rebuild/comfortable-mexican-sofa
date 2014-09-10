class ComfortableMexicanSofa::Tag::PageAccordion
  include ComfortableMexicanSofa::Tag
  DEFAULT_FIELDS = {
    ribs: [
      {title: '', description: ''}.stringify_keys
    ]
  }.stringify_keys

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):accordion\s*\}\}/
  end

  def content
    if json_is_valid?
      block.content
    else
      DEFAULT_FIELDS.to_json
    end
  end

  def render
    return '' unless json_is_valid?
    template.render(Object.new, json)
  end

  def edit_path
    "#{self.class.to_s.underscore}/edit"
  end

  private
  def json_is_valid?
    json.has_all_keys?(DEFAULT_FIELDS.keys) and
      json['ribs'].all? { |obj| obj.has_all_keys?(DEFAULT_FIELDS['ribs'].first.keys) }
  end

  def template
    Haml::Engine.new(::File.read(show_path))
  end

  def json
    JSON.parse(block.content)
  rescue JSON::ParserError
    {}
  end

  def show_path
    Rails.root.join("app/views/#{self.class.to_s.underscore}/_show.html.haml")
  end
end
