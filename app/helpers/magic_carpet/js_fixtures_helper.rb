module MagicCarpet
  module JsFixturesHelper
    attr_accessor :models

    def process_variables(hash)
      hash.each do |key, value|
        hash[key] = process_any(value)
      end
    end

    def process_array(array)
      array.map do |element|
        process_any(element)
      end
    end

    def process_number(hash)
      number = hash[:number]
      hash[:integer] ? number.to_i : number.to_f
    end

    def process_model(hash)
      process_variables(hash)

      model_name = hash.delete(:model)
      model = get_model(model_name)
      model.new(hash)
    end

    private

    def process_any(value)
      if value.is_a?(Array)
        process_array(value)
      elsif model?(value)
        process_model(value)
      elsif number?(value)
        process_number(value)
      elsif hash?(value)
        process_variables(value)
      else
        value
      end
    end

    def get_model(model_name)
      self.models ||= {}
      self.models[model_name] ||= self.class.const_get(model_name)
    end

    def hash?(value)
      value.is_a?(Hash)
    end

    def model?(value)
      hash?(value) && value.key?(:model)
    end

    def number?(value)
      hash?(value) && value.key?(:number)
    end
  end
end
