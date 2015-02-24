require "sequel/plugins/serialization"
require "json"

module Sequel
module Plugins

module GeojsonSerialization
  def self.configure(model, name)
    model.class_eval do
      plugin :after_initialize
      plugin :serialization, :geojson, name

      set_dataset select_append { ST_AsGeoJSON(name).as(name) }

      define_method(:after_initialize) { self.send(name) }
      define_method(:after_save)       { self[name] = self.send(name) }
    end
  end

  module Serializer
    def self.call(value)
      Sequel.lit("ST_GeomFromGeoJSON('#{value}')")
    end
  end

  module Deserializer
    def self.call(value)
      value
    end
  end

  Serialization.register_format(:geojson, Serializer, Deserializer)
end

end
end
