class ComfortableMexicanSofa::Tag::PageBlogshowcase
  include ComfortableMexicanSofa::Tag

  def self.regex_tag_signature(identifier = nil)
    identifier ||= IDENTIFIER_REGEX
    /\{\{\s*cms:page:(#{identifier}):blogshowcase\s*\}\}/
  end

  def render
    template.render(ActionView::Base.new, blog_posts: top_blog_posts)
  end

  def top_blog_posts
    #
  end

  def show_path
    Rails.root.join("app/views/#{self.class.to_s.underscore}/_show.html.haml")
  end

  def template
    Haml::Engine.new(::File.read(show_path))
  end
end
