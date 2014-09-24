# encoding: utf-8

require_relative '../../test_helper'

class FixturePagesTest < ActiveSupport::TestCase

  def test_update
    page = comfy_cms_pages(:default)
    page.update_column(:updated_at, 10.years.ago)
    assert_equal 'Default Page', page.label

    child = comfy_cms_pages(:child)
    child.update_column(:slug, 'old')

    assert_no_difference 'Comfy::Cms::Page.count' do
      ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!

      page.reload
      assert_equal 'Home Fixture Page', page.label

      assert_nil Comfy::Cms::Page.where(:slug => 'old').first
    end
  end

  def test_update_ignore
    Comfy::Cms::Page.destroy_all

    page = comfy_cms_sites(:default).pages.create!(
      :label  => 'Test',
      :layout => comfy_cms_layouts(:default),
      :blocks_attributes => [ { :identifier => 'content', :content => 'test content' } ]
    )

    page_path         = File.join(ComfortableMexicanSofa.config.fixtures_path, 'sample-site', 'pages', 'index')
    attr_file_path    = File.join(page_path, 'attributes.yml')
    content_file_path = File.join(page_path, 'content.html')

    assert page.updated_at >= File.mtime(attr_file_path)
    assert page.updated_at >= File.mtime(content_file_path)

    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
    page.reload

    assert_equal nil, page.slug
    assert_equal 'Test', page.label
    block = page.blocks.where(:identifier => 'content').first
    assert_equal 'test content', block.content
  end

  def test_update_force
    page = comfy_cms_pages(:default)
    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
    page.reload
    assert_equal 'Default Page', page.label

    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site', :forced).import!
    page.reload
    assert_equal 'Home Fixture Page', page.label
  end

  def test_update_removing_deleted_blocks
    Comfy::Cms::Page.destroy_all

    page = comfy_cms_sites(:default).pages.create!(
      :label  => 'Test',
      :layout => comfy_cms_layouts(:default),
      :blocks_attributes => [ { :identifier => 'to_delete', :content => 'test content' } ]
    )
    page.update_column(:updated_at, 10.years.ago)

    ComfortableMexicanSofa::Fixture::Page::Importer.new('sample-site', 'default-site').import!
    page.reload

    block = page.blocks.where(:identifier => 'content').first
    assert_equal "Home Page Fixture Contént\n{{ cms:snippet:default }}", block.content

    assert !page.blocks.where(:identifier => 'to_delete').first
  end
end
