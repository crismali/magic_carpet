require_dependency "magic_carpet/application_controller"

module MagicCarpet
  class JsFixturesController < ApplicationController
    include JsFixturesHelper

    def index
      render text: content
    end

    rescue_from "NameError" do |exception|
      if exception.name
        message_fragment = exception.message.split(" for ").first
        message = "#{message_fragment} for '#{template_name}' template."
      else
        missing_constant = exception.message.split("::").last
        message = "#{missing_constant} not found."
      end
      log_error(exception, message)
      render_error(message)
    end

    rescue_from "NoMethodError" do |exception|
      line_info = exception.backtrace.find { |line| line.match(/app\/views\/.*\.html\./) }
      message = "#{exception.class}: #{exception.message}\n#{line_info}"
      log_error(exception, message)
      render_error(message)
    end

    rescue_from "ActionView::MissingTemplate" do |exception|
      log_error(exception)
      render_error(exception.message)
    end

    private

    def log_error(exception, message = exception.message)
      message_with_backtrace = ([message] + exception.backtrace).join("\n\s\s\s\s")
      logger.error(message_with_backtrace)
    end

    def render_error(message)
      render json: { error: message }, status: 400
    end

    def content
      controller.render_to_string(*options)
    end

    def set_instance_variables(controller_instance)
      instance_variables_hash = hydrate(params[:instance_variables])
      instance_variables_hash.each do |name, value|
        controller_instance.instance_variable_set("@#{name}", value)
      end
    end

    def set_controller_hashes(controller_instance)
      [:flash, :params, :session, :cookies].each do |hash_name|
        if params.key?(hash_name)
          set_controller_hash(controller_instance.send(hash_name), hash_name)
        end
      end
    end

    def set_controller_hash(controller_hash, hash_name)
      params[hash_name].each do |key, value|
        controller_hash[key] = value
      end
    end

    def controller
      @controller ||= create_controller
    end

    def create_controller
      new_controller = self.class.const_get("#{params[:controller_name]}Controller").new
      new_controller.request = ActionDispatch::TestRequest.new
      set_instance_variables(new_controller) if params.key?(:instance_variables)
      set_controller_hashes(new_controller)
      new_controller
    end

    def template_name
      params.fetch(:template, params[:action_name].to_s)
    end

    def options
      options = {}
      options[:layout] = params.fetch(:layout, false)
      options[:locals] = hydrate(params[:locals]) if params.key?(:locals)
      if params.key?(:partial)
        [partial_options(options)]
      else
        [template_name, options]
      end
    end

    def partial_options(options)
      options[:partial] = params[:partial]
      options[:collection] = hydrate(params[:collection]) if params.key?(:collection)
      options[:as] = params[:as] if params.key?(:as)
      options
    end
  end
end
