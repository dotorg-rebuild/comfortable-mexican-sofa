class Comfy::Admin::Cms::PagesController < Comfy::Admin::Cms::BaseController

  before_action :check_for_layouts, :only => [:new, :edit]
  before_action :build_cms_page,    :only => [:new, :create]
  before_action :load_cms_page,     :only => [:edit, :update, :destroy]
  before_action :preview_cms_page,  :only => [:create, :update]
  before_action :build_file,        :only => [:new, :edit]

  def index
    return redirect_to :action => :new if @site.pages.count == 0
    if params[:category].present?
      @pages = collection_source.includes(:categories).for_category(params[:category]).order('label')
    else
      @pages = [pages_root].compact
    end
  end

  def collection_source
    @site.pages
  end

  def pages_root
    @site.pages.root
  end

  def new
    render
  end

  def edit
    respond_to do |fmt|
      fmt.html
      fmt.json do
        render json: Comfy::Cms::Page.referable_autocomplete_candidates(params[:query])
      end
    end
  end

  def create
    @page.save!
    flash[:success] = t(:created)
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = t(:creation_failure)
    render :action => :new
  end

  def update
    @page.save!
    flash[:success] = t(:updated)
    redirect_to :action => :edit, :id => @page
  rescue ActiveRecord::RecordInvalid
    flash.now[:danger] = t(:update_failure)
    render :action => :edit
  end

  def destroy
    @page.destroy
    flash[:success] = t(:deleted)
    redirect_to :action => :index
  end

  def t thing
    I18n.t("#{translate_base}.#{thing}")
  end

  def translate_base
    'comfy.admin.cms.pages'
  end

  def form_blocks
    @page = @site.pages.find_by_id(params[:id]) || @site.pages.new
    @page.layout = @site.layouts.find_by_id(params[:layout_id])
  end

  def toggle_branch
    @page = @site.pages.find(params[:id])
    s   = (session[:cms_page_tree] ||= [])
    id  = @page.id.to_s
    s.member?(id) ? s.delete(id) : s << id
  rescue ActiveRecord::RecordNotFound
    # do nothing
  end

  def reorder
    (params[:comfy_cms_page] || []).each_with_index do |id, index|
      ::Comfy::Cms::Page.where(:id => id).update_all(:position => index)
    end
    render :nothing => true
  end

  def pages_by_parent(page_id)
    page_id = page_id.to_param.try(:to_i)
    return unless all_parents.include? page_id
    @_pages_by_parent ||= {}
    @_pages_by_parent[page_id] ||= @site.pages.where(parent: page_id).includes(:categories, :site)
  end


protected

  def all_parents
    @_all_parents ||= Comfy::Cms::Page.unscoped.distinct(:parent_id).pluck(:parent_id)
  end

  def check_for_layouts
    if @site.layouts.count == 0
      flash[:danger] = I18n.t('comfy.admin.cms.pages.layout_not_found')
      redirect_to new_comfy_admin_cms_site_layout_path(@site)
    end
  end

  def build_cms_page
    @page = @site.pages.new(page_params)
    @page.parent ||= (@site.pages.find_by_id(params[:parent_id]) || pages_root)
    @page.layout ||= default_layout
  end

  def default_layout
    (@page.parent && @page.parent.layout || @site.layouts.first)
  end

  def build_file
    @file = Comfy::Cms::File.new
  end

  def load_cms_page
    @page = @site.pages.find(params[:id])
    @page.attributes = page_params
    @page.layout ||= (@page.parent && @page.parent.layout || @site.layouts.first)
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.pages.not_found')
    redirect_to :action => :index
  end

  def preview_cms_page
    if params[:preview]
      layout = @page.layout.app_layout.blank?? false : @page.layout.app_layout
      @cms_site   = @page.site
      @cms_layout = @page.layout
      @cms_page   = @page

      # Chrome chokes on content with iframes. Issue #434
      response.headers['X-XSS-Protection'] = '0'

      render :inline => @page.render, :layout => layout, :content_type => 'text/html'
    end
  end

  def page_params
    params.fetch(:page, {}).permit!
  end
end
