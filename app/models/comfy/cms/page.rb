# encoding: utf-8

class Comfy::Cms::Page < ActiveRecord::Base
  SECRET_COLUMN = 'full_path'

  self.table_name = 'comfy_cms_pages'

  cms_acts_as_tree :counter_cache => :children_count
  cms_is_categorized
  cms_is_mirrored
  cms_manageable
  cms_has_revisions_for :blocks_attributes

  delegate :label, to: :parent, prefix: true

  cattr_accessor :referable_classes
  self.referable_classes = []

  # -- Relationhips --------------------------------------------------------
  belongs_to :site
  belongs_to :layout
  belongs_to :target_page,
    :class_name => 'Comfy::Cms::Page'
  belongs_to :pageable, :polymorphic => true, :autosave => true

  has_many :page_referables

  # -- Callbacks ------------------------------------------------------------
  before_validation :assigns_label,
                    :assign_parent,
                    :escape_slug,
                    :assign_full_path
  before_create     :assign_position
  after_save        :sync_child_full_paths!
  after_find        :unescape_slug_and_path

  # -- Validations ----------------------------------------------------------
  validates :site_id,
    :presence   => true
  validates :label,
    :presence   => true
  validates :slug,
    :format     => /\A[^.]*\z/,
    :presence   => true,
    :uniqueness => { :scope => :parent_id },
    :unless     => lambda{ |p| p.site && (p.site.pages.count == 0 || p.site.pages.root == self) }
  validates :layout,
    :presence   => true
  validate :validate_target_page
  validate :validate_format_of_unescaped_slug

  # -- Scopes ---------------------------------------------------------------
  default_scope -> { order('comfy_cms_pages.position') }
  scope :published, -> { where('comfy_cms_pages.publish_at <= ?', Time.now) }

  scope :not_pageable, -> { where(pageable_type: nil) }

  # -- Class Methods --------------------------------------------------------
  # Tree-like structure for pages
  def self.options_for_select(site, page = nil, current_page = nil, depth = 0, exclude_self = true, spacer = '. . ')
    return [] if (current_page ||= site.pages.root) == page && exclude_self || !current_page
    out = []
    out << [ "#{spacer*depth}#{current_page.label}", current_page.id ] unless current_page == page
    current_page.children.not_pageable.each do |child|
      out += options_for_select(site, page, child, depth + 1, exclude_self, spacer)
    end if current_page.children_count.nonzero?
    return out.compact
  end

  def self.find_by_secret thing
    thing = sanitize(thing)
    secret_sql = <<-END
      SELECT *
        FROM #{table_name}
       WHERE MD5(#{table_name}.#{SECRET_COLUMN}) = #{thing}
    END
    result = Comfy::Cms::Page.find_by_sql(secret_sql.strip).first
    raise ActiveRecord::RecordNotFound unless result
    result
  end

  def self.referable_autocomplete_candidates string
    referable_classes.map do |klass|
      klass.autocomplete_candidates(string)
    end.flatten
  end

  def self.find_referable_from_referable_classes string
    referable_classes.each do |klass|
      if object = klass.find_reference(string)
        yield object
      end
    end
  end

  # -- Instance Methods -----------------------------------------------------
  # For previewing purposes sometimes we need to have full_path set. This
  # full path take care of the pages and its childs but not of the site path
  def full_path
    self.read_attribute(:full_path) || self.assign_full_path
  end

  # Somewhat unique method of identifying a page that is not a full_path
  def identifier
    self.parent_id.blank?? 'index' : self.full_path[1..-1].slugify
  end

  def refers_to= array_of_strings
    self.page_referables = []
    array_of_strings.each do |string|
      add_reference! string
    end
  end

  def add_reference! string
    string.strip!
    reference = page_referables.build referable_reference_name: string
    self.class.find_referable_from_referable_classes string do |object|
      reference.referable = object
      reference.referable_reference_name = object.reference_name
    end
    reference.save
  end

  def refers_to
    page_referables.pluck(:referable_reference_name).join(', ')
  end

  def referred_objects
    page_referables.map &:referable
  end

  # Full url for a page
  def url
    "//" + "#{self.site.hostname}/#{self.site.path}/#{self.full_path}".squeeze("/")
  end

  def secret_secret
    Digest::MD5.hexdigest(self[SECRET_COLUMN].to_s)
  end

  def secret_url
    "//" + "#{self.site.hostname}/#{secret_path}".squeeze("/")
  end

  def secret_path
    "/secret/#{secret_secret}"
  end

  def is_published?
    publish_at.try(:past?)
  end
  alias_method :is_published, :is_published?

  def read_page_attribute name
    blocks.find_by(identifier: name).try(:content)
  end

  def write_page_attribute name, value
    blocks.find_or_create_by(identifier: name).update_attributes(content: value)
  end

  def read_page_files name
    blocks.find_by(identifier: name).try(:files).try(:map, &:file)
  end

  def read_page_file name
    blocks.find_by(identifier: name).try_chain(:files, :first, :file)
  end

  def append_page_file! name, file
    blocks.find_or_create_by(identifier: name).files.create!(file: file, site: site)
  end

  def pageable_attributes= hash
    if pageable.nil? && pageable_type
      self.pageable = pageable_type.classify.constantize.new
      quietly_update_pageable_attributes hash
    elsif pageable.present?
      quietly_update_pageable_attributes hash
    end
  end

  # silently ignores attributes which the pageable object
  # doesn't respond to
  def quietly_update_pageable_attributes hash
    hash.reject! do |key, value|
      if key.respond_to?(:gsub)
        !pageable.attributes.include?(key.gsub(/\([^)]*\)/, ''))
      else
        setter = "#{key}="
        pageable.send(setter, value) if pageable.respond_to?(setter)
        true # if set through the setter, prevent it from being set again below
      end
    end
    pageable.attributes = hash
  end

  def site_base_url
    'http://' + site.hostname + '/'
  end

protected

  def assigns_label
    self.label = self.label.blank?? self.slug.try(:titleize) : self.label
  end

  def assign_parent
    return unless site
    self.parent ||= site.pages.root unless self == site.pages.root || site.pages.count == 0
  end

  def assign_full_path
    self.full_path = self.parent ? "#{CGI::escape(self.parent.full_path).gsub('%2F', '/')}/#{self.slug}".squeeze('/') : '/'
  end

  def assign_position
    return unless self.parent
    return if self.position.to_i > 0
    max = self.parent.children.maximum(:position)
    self.position = max ? max + 1 : 0
  end

  def validate_target_page
    return unless self.target_page
    p = self
    while p.target_page do
      return self.errors.add(:target_page_id, 'Invalid Redirect') if (p = p.target_page) == self
    end
  end

  def validate_format_of_unescaped_slug
    return unless slug.present?
    unescaped_slug = CGI::unescape(self.slug)
    errors.add(:slug, :invalid) unless unescaped_slug =~ /^\p{Alnum}[\.\p{Alnum}\p{Mark}_-]*$/i
  end

  # Forcing re-saves for child pages so they can update full_paths
  def sync_child_full_paths!
    return unless full_path_changed?
    children.each do |p|
      p.update_column(:full_path, p.send(:assign_full_path))
      p.send(:sync_child_full_paths!)
    end
  end

  # Escape slug unless it's nonexistent (root)
  def escape_slug
    self.slug = CGI::escape(self.slug) unless self.slug.nil?
  end

  # Unescape the slug and full path back into their original forms unless they're nonexistent
  def unescape_slug_and_path
    self.slug       = CGI::unescape(self.slug)      unless self.slug.nil?
    self.full_path  = CGI::unescape(self.full_path) unless self.full_path.nil?
  end

end
