class ComfortableMexicanSofa::Tag::PageCollapsible
  include ComfortableMexicanSofa::Tag
  DEFAULT_FIELDS = { header: '', summary: '', description: '' }.stringify_keys

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):collapsible\s*\}\}/
  end

  def content
    if json_is_valid
      block.content
    else
      DEFAULT_FIELDS.to_json
    end
  end

  def json_is_valid
    DEFAULT_FIELDS.keys.all? do |key|
      json.has_key?(key)
    end
  end

  def render
    return '' unless json_is_valid
    template.render(Object.new, json)
  end

  def edit_path
    "#{self.class.to_s.underscore}/edit"
  end

  def show_path
    Rails.root.join("app/views/#{self.class.to_s.underscore}/_show.html.haml")
  end

  private
  def json
    JSON.parse(block.content)
  rescue JSON::ParserError
    {}
  end

  def template
    Haml::Engine.new(::File.read(show_path))
  end
end
