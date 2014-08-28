class ComfortableMexicanSofa::Tag::PageAccordion
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):accordion\s*\}\}/
  end

  def content
    block.content || default_fields.to_json
  end

  def default_fields
    @default_fields || {
      ribs: [
        {title: '', description: ''}
      ]
    }
  end

  def render
    template.render(Object.new, json)
  end

  def json
    JSON.parse(content)
  end

  def edit_path
    "#{self.class.to_s.underscore}/edit"
  end

  def show_path
    Rails.root.join("app/views/#{self.class.to_s.underscore}/_show.html.haml")
  end

  def template
    Haml::Engine.new(::File.read(show_path))
  end
end
