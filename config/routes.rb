Rails.application.routes.draw do
  root 'agents#index'
  post 'agents/chat', to: 'agents#chat'
end

