class ComfortableMexicanSofa::FormBuilder < BootstrapForm::FormBuilder
  require_relative 'form_builder/object_field_date_builder'

  attr_reader :template

  def field_name_for(tag)
    tag.blockable.class.name.demodulize.underscore.gsub(/\//,'_')
  end

  # -- Tag Field Fields -----------------------------------------------------
  def default_tag_field(tag, index, method = :text_field_tag, options = {})

    label       = tag.blockable.class.human_attribute_name(tag.identifier.to_s)
    css_class   = tag.class.to_s.demodulize.underscore
    content     = ''
    fieldname   = field_name_for(tag)
    case method
    when :file_field_tag
      input_params = {:id => nil}
      name = "#{fieldname}[blocks_attributes][#{index}][content]"

      if options.delete(:multiple)
        input_params.merge!(:multiple => true)
        name << '[]'
      end

      if coach = options.delete(:coach)
        label << " (#{coach})"
      end

      content << template.send(method, name, input_params)
      content << template.render(:partial => 'comfy/admin/cms/files/page_form', :object => tag.block)
    else
      options[:class] = ' form-control'
      content << template.send(method, "#{fieldname}[blocks_attributes][#{index}][content]", tag.content, options)
    end
    content << template.hidden_field_tag("#{fieldname}[blocks_attributes][#{index}][identifier]", tag.identifier, :id => nil)

    form_group :label => {:text => label} do
      content.html_safe
    end
  end

  def field_date_time(tag, index)
    default_tag_field(tag, index, :text_field_tag, :data => {'cms-datetime' => true})
  end

  def field_integer(tag, index)
    default_tag_field(tag, index, :number_field_tag)
  end

  def field_string(tag, index)
    default_tag_field(tag, index)
  end

  def field_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-cm-mode' => 'text/html'})
  end

  def field_rich_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-rich-text' => true})
  end

  def field_boolean(tag, index)
    fieldname = field_name_for(tag)
    content = template.hidden_field_tag("#{fieldname}[blocks_attributes][#{index}][content]", '', :id => nil)
    content << template.check_box_tag("#{fieldname}[blocks_attributes][#{index}][content]", '1', tag.content.present?, :id => nil)
    content << template.hidden_field_tag("#{fieldname}[blocks_attributes][#{index}][identifier]", tag.identifier, :id => nil)
    form_group :label => {:text => tag.identifier.titleize + "?"} do
      content
    end
  end

  def page_breadcrumbs tag, index
    # no editing experience
  end

  def page_carousel tag, index
    render_editor tag.class.edit_path, tag, index
  end

  def page_scroller tag, index
    render_editor 'widget/scroller/editor', tag, index
  end

  def page_banner tag, index
    render_editor 'widget/banner/editor', tag, index
  end

  def page_collapsible tag, index
    render_editor tag.edit_path, tag, index
  end

  def page_blog_showcase tag, index
    render_editor tag.edit_path, tag, index
  end

  def page_blog_landing tag, index
    # no editing experience
  end

  def page_accordion tag, index
    render_editor tag.edit_path, tag, index
  end

  def page_news_and_stories(tag, index)
    render_editor tag.edit_path, tag, index
  end

  def page_artist_scroller(tag, index)
    render_editor tag.edit_path, tag, index
  end

  def page_events(tag, index)
    render_editor tag.edit_path, tag, index
  end

  def page_date_time(tag, index)
    default_tag_field(tag, index, :text_field_tag, :data => {'cms-datetime' => true})
  end

  def page_integer(tag, index)
    default_tag_field(tag, index, :number_field_tag)
  end

  def page_string(tag, index)
    default_tag_field(tag, index)
  end

  def page_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-cm-mode' => 'text/html'})
  end

  def page_rich_text(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-rich-text' => true})
  end

  def page_file(tag, index)
    default_tag_field(tag, index, :file_field_tag, coach: tag.coach_tip)
  end

  def page_files(tag, index)
    default_tag_field(tag, index, :file_field_tag, :multiple => true)
  end

  def field_file(tag, index)
    default_tag_field(tag, index, :file_field_tag)
  end

  def field_files(tag, index)
    default_tag_field(tag, index, :file_field_tag, :multiple => true)
  end

  def page_markdown(tag, index)
    default_tag_field(tag, index, :text_area_tag, :data => {'cms-cm-mode' => 'text/x-markdown'})
  end

  def page_event_grid(tag, index)
    # no editor experience
  end

  def object_string(tag, index)
    # no editor experience
  end

  def page_searchbox(tag, index)
    # no editor experience
  end

  def object_field_select(tag, index)
    return if tag.blockable.pageable.nil?
    name = "#{field_name_for(tag)}[pageable_attributes][#{tag.identifier}]"
    value = tag.content
    label = tag.identifier.titleize

    form_group :label => {:text => label} do
      template.select_tag name,
        template.options_for_select(tag.params, tag.content), class: 'form-control'
    end
  end

  def object_field_string(tag, index)
    return if tag.blockable.pageable.nil?
    name = "#{field_name_for(tag)}[pageable_attributes][#{tag.identifier}]"
    value = tag.content
    label = tag.identifier.titleize

    form_group :label => {:text => label} do
      template.text_field_tag name, value, class: 'form-control'
    end
  end

  def object_field_date(tag, index)
    return if tag.blockable.pageable.nil?
    ObjectFieldDateBuilder.new(self, template, tag, index).build
  end

  def collection(tag, index)
    options = [["---- Select #{tag.collection_class.titleize} ----", nil]] +
      tag.collection_objects.collect do |m|
      [m.send(tag.collection_title), m.send(tag.collection_identifier)]
    end

    fieldname = field_name_for(tag)
    content = template.select_tag(
      "#{fieldname}[blocks_attributes][#{index}][content]",
      template.options_for_select(options, :selected => tag.content),
      :id => nil
    )
    content << template.hidden_field_tag("#{fieldname}[blocks_attributes][#{index}][identifier]", tag.identifier, :id => nil)
    form_group :label => {:text => tag.identifier.titleize}, :class => tag.class.to_s.demodulize.underscore do
      content
    end
  end

  def human_attribute_name tag
    tag.blockable.class.human_attribute_name(tag.identifier.to_s)
  end

  def render_editor path, tag, index
    fieldname          = field_name_for(tag)
    identifier         = tag.identifier.to_s
    label              = human_attribute_name(tag)
    content_field_name = "#{fieldname}[blocks_attributes][#{index}][content]"
    content            = ''

    content << template.render(partial: path, locals: { comfy_tag: tag, content_field_name: content_field_name, value: tag.content })
    content << template.hidden_field_tag("#{fieldname}[blocks_attributes][#{index}][identifier]", tag.identifier, :id => nil)

    form_group label: { text: label } do
      content.html_safe
    end
  end
end
