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
      options = {}
      options[:layout] = params[:layout] if params.key?(:layout)
      options[:locals] = processed_locals if params.key?(:locals)
      options
    end

    def processed_locals
      params[:locals].each_with_object({}) do |(local_name, value), memo|
        memo[local_name.to_sym] = process_value(value)
      end
    end

    def process_value(value)
      return value unless value.is_a?(Hash)
      if value[:model_name]
        process_model(value)
      elsif value[:number]
        process_number(value)
      else
        value
      end
    end

    def process_number(number_info)
      number_types = {
        "Float" => :to_f,
        "Integer" => :to_i
      }
      number_info[:number].send(number_types[number_info[:type].capitalize])
    end

    def process_model(model_info)
      model = self.class.const_get(model_info.delete(:model_name))
      model.new(model_info)
    end
  end
end
