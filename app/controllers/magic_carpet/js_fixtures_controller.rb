require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController
    include JsFixturesHelper

    def index
      render text: content
    end

    rescue_from "NameError" do |exception|
      missing_constant = exception.message.split("::").last
      message = "#{missing_constant} not found."
      render json: { error: message }, status: 400
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

    def set_flash(controller_instance)
      params[:flash].each do |type, message|
        controller_instance.flash[type] = message
      end
    end

    def controller
      @controller ||= create_controller
    end

    def create_controller
      new_controller = self.class.const_get("#{params[:controller_name]}Controller").new
      new_controller.request = ActionDispatch::TestRequest.new
      set_instance_variables(new_controller) if params.key?(:instance_variables)
      set_flash(new_controller) if params.key?(:flash)
      new_controller
    end

    def template_name
      params.fetch(:template, params[:action_name].to_s)
    end

    def options
      options = {}
      options[:layout] = params.fetch(:layout, false)
      options[:locals] = process_variables(params[:locals]) if params.key?(:locals)
      if params.key?(:partial)
        [partial_options(options)]
      else
        [template_name, options]
      end
    end

    def partial_options(options)
      options[:partial] = params[:partial]
      options[:collection] = process_array(params[:collection]) if params.key?(:collection)
      options[:as] = params[:as] if params.key?(:as)
      options
    end
  end
end
