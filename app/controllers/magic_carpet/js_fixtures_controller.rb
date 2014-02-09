require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController
    include JsFixturesHelper

    def index
      render text: content
    end

    private

    def content
      controller.render_to_string(*options)
    end

    def set_instance_variables(controller_instance)
      instance_variables_hash = process_variables(params[:instance_variables])
      instance_variables_hash.each do |name, value|
        controller_instance.instance_variable_set("@#{name}", value)
      end
    end

    def controller
      @controller ||= create_controller
    end

    def create_controller
      new_controller = self.class.const_get("#{params[:controller_name]}Controller").new
      new_controller.request = ActionDispatch::TestRequest.new
      set_instance_variables(new_controller) if params.key?(:instance_variables)
      new_controller
    end

    def template_name
      params.fetch(:template, params[:action_name].to_s)
    end

    def options
      options = {}
      options[:layout] = params[:layout] if params.key?(:layout)
      options[:locals] = process_variables(params[:locals]) if params.key?(:locals)
      if params.key?(:partial)
        options[:partial] = params[:partial]
        options[:collection] = process_array(params[:collection]) if params.key?(:collection)
        [options]
      else
        [template_name, options]
      end
    end
  end
end
