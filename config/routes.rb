Rails.application.routes.draw do
  root 'agents#index'
  post 'agents/chat', to: 'agents#chat'
  delete 'agents/:id', to: 'agents#destroy', as: :delete_conversation
end

