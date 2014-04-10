module MagicCarpet
  module JsFixturesHelper
    attr_accessor :models

    def hydrate(value)
      if array?(value)
        hydrate_array(value)
      elsif model?(value)
        hydrate_model(value)
      elsif number?(value)
        hydrate_number(value)
      elsif array_as_hash?(value)
        hydrate_array(value.values)
      elsif hash?(value)
        hydrate_hash(value)
      else
        value
      end
    end

    private

    def hydrate_hash(hash)
      hash.each do |key, value|
        hash[key] = hydrate(value)
      end
    end

    def hydrate_array(array)
      array.map do |element|
        hydrate(element)
      end
    end

    def hydrate_number(hash)
      number = hash[:number]
      hash[:integer] ? number.to_i : number.to_f
    end

    def hydrate_model(hash)
      hydrate_hash(hash)

      model_name = hash.delete(:model)
      model = get_model(model_name)
      model.new(hash)
    end

    def get_model(model_name)
      self.models ||= {}
      self.models[model_name] ||= self.class.const_get(model_name)
    end

    def hash?(value)
      value.is_a?(Hash)
    end

    def array?(value)
      value.is_a?(Array)
    end

    def array_as_hash?(value)
      if hash?(value) && value.present?
        keys = value.keys.sort
        keys.each_with_index.all? do |key, i|
          key.to_s == i.to_s
        end
      else
        false
      end
    end

    def model?(value)
      hash?(value) && value.key?(:model)
    end

    def number?(value)
      hash?(value) && value.key?(:number)
    end
  end
end
