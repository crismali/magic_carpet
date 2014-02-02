MagicCarpet::Engine.routes.draw do
  root to: "js_fixtures#index/:fixture_controller/:fixture_action"
end
