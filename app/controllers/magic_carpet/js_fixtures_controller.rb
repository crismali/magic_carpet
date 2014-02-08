require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController
    include JsFixturesHelper

    def index
      render text: content
    end

    private

    def content
      controller.render_to_string "#{params[:controller_name]}/#{params[:action_name]}", options
    end

    def controller
      @controller ||= self.class.const_get("#{params[:controller_name]}Controller").new
    end

    def options
      options = {}
      options[:layout] = params[:layout] if params.key?(:layout)
      options[:locals] = process_variables(params[:locals]) if params.key?(:locals)
      options
    end
  end
end
