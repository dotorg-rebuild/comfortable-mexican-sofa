class ComfortableMexicanSofa::Tag::PageBreadcrumbs
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):breadcrumbs\s*\}\}/
  end

  def render
    template.render(ActionView::Base.new, page: block.blockable)
  end

  def show_path
    Rails.root.join("app/views/#{self.class.to_s.underscore}/_show.html.haml")
  end

  def template
    Haml::Engine.new(::File.read(show_path))
  end
end
