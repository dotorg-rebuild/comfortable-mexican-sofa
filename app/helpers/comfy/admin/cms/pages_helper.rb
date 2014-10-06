module Comfy::Admin::Cms::PagesHelper
  def category_view
    params[:category].present?
  end

  def children(page)
    pages_by_parent page
  end

  def has_children?(page)
    children(page).present?
  end

  def has_siblings?(page)
    siblings(page).size > 1
  end

  def is_open?(page)
    list_of_open_page_nodes.member?(page.id.to_s) || page.root?
  end

  def is_published?(page)
    page.is_published?
  end

  def list_of_open_page_nodes
    session[:cms_page_tree] || []
  end

  def page_root?(page)
    page.root?
  end

  def pages_by_parent(page)
    controller.pages_by_parent(page)
  end

  def reorderable?(page)
    !category_view && has_siblings?(page)
  end

  def selectable_parent?(page)
    !(page == controller.pages_root)
  end

  def show_children?(page)
    !category_view && has_children?(page) && is_open?(page)
  end

  def show_toggle?(page)
    !category_view && has_children?(page) && !page_root?(page)
  end

  def siblings(page)
    pages_by_parent(page.parent_id)
  end
end
