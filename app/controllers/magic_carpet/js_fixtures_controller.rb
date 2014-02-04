require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController

    def index
      render text: content
    end

    private

    def content
      controller.new.render_to_string "#{params[:controller_name]}/#{params[:action_name]}", options
    end

    def controller
      @controller ||= self.class.const_get("#{params[:controller_name].capitalize}Controller")
    end

    def options
      options = { }
      options[:layout] = params[:layout] if params.has_key?(:layout)
      options[:locals] = params[:locals] if params.has_key?(:locals)
      options
    end
  end
end
