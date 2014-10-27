class ComfortableMexicanSofa::FormBuilder::ObjectFieldDateBuilder
  DATETIME_ARGS = [:year, :month, :day, :hour, :minute]

  attr_reader :builder, :tag, :index

  def initialize(builder, template, tag, index)
    @builder, @tag, @index = builder, tag, index
    @template = template
    @result = ''
  end

  def field_name
    builder.field_name_for(tag)
  end

  def attr_name
    "pageable_attributes][#{tag.identifier}%s"
  end

  def name
    "#{field_name}[#{attr_name % ''}]"
  end

  def value
    tag.content || DateTime.now
  end

  def label
    tag.identifier.titleize
  end

  def select_tag(position, options = {})
    @template.send("select_#{position}",
                   value.send(position),
                   {
                     field_name: attr_name_for_position(position),
                     prefix: field_name
                   }.merge(options), class: 'form-control')
  end

  def select_timezone
    name = "#{builder.field_name_for(tag)}[pageable_attributes][#{tag.identifier}_time_zone]"
    builder.form_group(:label => {:text => "#{label} Time Zone"}) do
      @template.select_tag name,
        @template.options_from_collection_for_select(
          ActiveSupport::TimeZone.all,
          :to_s,
          :to_s,
          selected: tag.zone),
          :class => 'form-control'
    end
  end

  def datetime_arg position
    "(#{DATETIME_ARGS.index(position)+1}i)"
  end

  def attr_name_for_position position
    attr_name % datetime_arg(position)
  end

  def datetime_select_tags
    [
      select_tag(:year),
      select_tag(:month),
      select_tag(:day),
      ' — ',
      select_tag(:hour, ampm: true),
      ' : ',
      select_tag(:minute)
    ].join.html_safe
  end

  def select_date_and_time
    builder.form_group(:label => {:text => label}) do
      @template.content_tag(:div, datetime_select_tags, class: 'rails-bootstrap-forms-datetime-select')
    end
  end

  def build
    @result << select_date_and_time
    @result << select_timezone if tag.has_zone?
    @result.html_safe
  end
end
