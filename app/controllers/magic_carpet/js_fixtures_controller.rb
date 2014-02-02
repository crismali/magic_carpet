require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController

    def index
      controller = self.class.const_get("#{params[:fixture_controller].capitalize}Controller")
      options = { }
      options[:layout] = params[:layout] if params.has_key?(:layout)
      content = controller.new.render_to_string "#{params[:fixture_controller]}/#{params[:fixture_action]}", options
      render text: content
    end
  end
end
