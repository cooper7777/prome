require 'prometheus/client'

module Prome
  class Registry
    @@registry = Prometheus::Client.registry

    def initialize
      @@registry
    end

    def register(metric)
      @@registry.register(metric)
    end
  end
end