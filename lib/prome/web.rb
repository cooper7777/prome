require 'prometheus/middleware/exporter'

module Prome
  class Web
    class << self
      def call(env)
        refresh
        exporter = Prometheus::Middleware::Exporter.new(nil, registry: Prome.registry, path: "/")
        exporter.call(env)
      end

      def refresh
        if defined?(::Sidekiq)
          stats = ::Sidekiq::Stats.new
          stats.queues.each do |k, v|
            Prome.get(:sidekiq_jobs_waiting_count).set(v, labels: {queue: k})
          end
        end
      end
    end
  end
end