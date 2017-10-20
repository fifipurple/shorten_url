Rails.application.routes.draw do
  get  'urls/list', to: 'urls#list'
  get  '/purple/:short_url', to: 'urls#purple'
  post 'urls/new'
  resources :urls
end
