Rails.application.routes.draw do

  resources :users

  resources :wishes

  mount MagicCarpet::Engine => "/magic_carpet"
end
