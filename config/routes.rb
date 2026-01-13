Rails.application.routes.draw do
  root 'pages#home'
  get 'about', to: 'pages#about', as: :about
  get 'chat', to: 'agents#index', as: :chat
  post 'agents/chat', to: 'agents#chat'
  delete 'agents/:id', to: 'agents#destroy', as: :delete_conversation
end

