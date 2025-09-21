require 'prometheus/client'

module Prome
  class Registry
    @@registry = Prometheus::Client.registry

    def initialize
      @@registry
    end
    
    def method_missing(name, *args)
      @@registry.send(name, *args)
    end
  end
end