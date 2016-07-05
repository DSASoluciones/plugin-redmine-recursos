# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#get 'projects/:id/calendario', :to => 'calendario#index', as: :index_action
#post 'projects/:id/calendario', :to => 'calendario#index', as: :index_action
match 'projects/:id/calendario'        => 'calendario#index',  :as => :index_action,        via: [:get, :post]
#get 'calendario/fechas', to: 'calendario#mostrar'