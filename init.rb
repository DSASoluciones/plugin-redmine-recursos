Redmine::Plugin.register :recursos do
  name 'Recursos plugin'
  author 'Daniel Villegas'
  description 'Esto es un plugin para Redmine'
  version '0.0.1'
  url 'http://www.dsasoluciones.com'
  author_url 'http://www.dsasoluciones.com'

  
  #permission :Recursos, { :calendario => [:index] }, :public => false
  project_module :recursos do
    permission :ver_recursos, :calendario => :index
  end
  menu :project_menu, :calendario, { :controller => 'calendario', :action => 'index' }, :caption => 'Recursos', :after => :files#, :param => :project_id
  #permission :ver_recursos, :calendario => :index
  #menu :top_menu, :calendario, { :controller => 'calendario', :action => 'index' }, :caption => 'Recursos'
end
