require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController
    include JsFixturesHelper

    def index
      render text: content
    end

    private

    def content
      set_instance_variables if params.key?(:instance_variables)
      controller.render_to_string "#{params[:controller_name]}/#{params[:action_name]}", options
    end

    def set_instance_variables
      instance_variables_hash = process_variables(params[:instance_variables])
      instance_variables_hash.each do |name, value|
        controller.instance_variable_set("@#{name}", value)
      end
    end

    def controller
      @controller ||= create_controller
    end

    def create_controller
      new_controller = self.class.const_get("#{params[:controller_name]}Controller").new
      new_controller.request = ActionDispatch::TestRequest.new
      new_controller
    end

    def options
      options = {}
      options[:layout] = params[:layout] if params.key?(:layout)
      options[:locals] = process_variables(params[:locals]) if params.key?(:locals)
      options
    end
  end
end
