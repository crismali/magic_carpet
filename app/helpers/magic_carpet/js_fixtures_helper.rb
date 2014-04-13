module MagicCarpet
  module JsFixturesHelper
    attr_accessor :models
    NIL = "nil"

    def hydrate(value)
      if array?(value)
        hydrate_array(value)
      elsif date?(value)
        hydrate_date(value)
      elsif time?(value)
        hydrate_time(value)
      elsif datetime?(value)
        hydrate_datetime(value)
      elsif model?(value)
        hydrate_model(value)
      elsif number?(value)
        hydrate_number(value)
      elsif array_as_hash?(value)
        hydrate_array(value.values)
      elsif hash?(value)
        hydrate_hash(value)
      elsif is_nil?(value)
        nil
      elsif true?(value)
        true
      elsif false?(value)
        false
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

    def hydrate_date(hash)
      Date.parse(hash[:date])
    end

    def hydrate_time(hash)
      time = Time.parse(hash[:time])
      time = time.utc if hash.key?(:utc)
      time
    end

    def hydrate_datetime(hash)
      DateTime.parse(hash[:datetime])
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
      hash_with_key?(value, :model)
    end

    def number?(value)
      hash_with_key?(value, :number)
    end

    def date?(value)
      hash_with_key?(value, :date)
    end

    def time?(value)
      hash_with_key?(value, :time)
    end

    def datetime?(value)
      hash_with_key?(value, :datetime)
    end

    def hash_with_key?(value, key)
      hash?(value) && value.key?(key)
    end

    def is_nil?(value)
      same_string?(value, NIL)
    end

    def true?(value)
      same_string?(value, true)
    end

    def false?(value)
      same_string?(value, false)
    end

    def same_string?(value, string)
      value.is_a?(String) && value == string.to_s
    end
  end
end
