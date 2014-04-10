Rails.application.routes.draw do

  resources :users

  resources :wishes

  mount MagicCarpet::Engine => "/magic_carpet" if defined?(MagicCarpet)
  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
end
