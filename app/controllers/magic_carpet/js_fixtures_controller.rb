require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController
    def index
      # require "pry";binding.pry
      # main_app.scope.view_renderer.render(self, template: "#{params[:fixture_controller]}/#{params[:fixture_action]}")
      render template: "wishes/plain"
    end
  end
end
