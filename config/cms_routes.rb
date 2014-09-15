ComfortableMexicanSofa::Application.routes.draw do

  comfy_route :cms_admin
  comfy_route :cms, :sitemap => true

  get '/secret/:secret', controller: 'comfy/cms/content', action: :secret

end
