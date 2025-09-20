require 'prometheus/client/registry'
begin
  require 'sidekiq'
rescue LoadError
end

require_relative 'prome/version'
require_relative 'prome/rails'
require_relative 'prome/sidekiq'
require_relative 'prome/registry'

module Prome
  mattr_reader :registry do
    r = Prome::Registry.new
    
    # rails
    unless defined?(::Sidekiq) && ::Sidekiq.server?
      r.counter(:rails_requests_total, docstring: "A counter of the total number of HTTP requests rails processed.", labels: [ :controller, :action, :status, :format, :method])
      r.histogram(:rails_request_duration_seconds, docstring: "A histogram of the response latency.")
      r.histogram(:rails_view_runtime_seconds, docstring: "A histogram of the view rendering time.")
      r.histogram(:rails_db_runtime_seconds, docstring: "A histogram of the activerecord execution time.")
    end

    # sidekiq
    if defined?(::Sidekiq)
      if ::Sidekiq.server?
        r.counter(:sidekiq_jobs_executed_total, docstring: "A counter of the total number of jobs sidekiq executed.", labels: [:queue, :worker])
        r.counter(:sidekiq_jobs_success_total, docstring: "A counter of the total number of jobs successfully processed by sidekiq.", labels: [:queue, :worker])
        r.counter(:sidekiq_jobs_failed_total, docstring: "A counter of the total number of jobs failed in sidekiq.", labels: [:queue, :worker])
        r.histogram(:sidekiq_job_runtime_seconds, docstring: "A histogram of the job execution time.", labels: [:queue, :worker])
      else
        r.counter(:sidekiq_jobs_enqueued_total, docstring: "A counter of the total number of jobs sidekiq enqueued.", labels: [:queue])
        r.gauge(:sidekiq_jobs_waiting_count, docstring: "The number of jobs waiting to process in sidekiq.", labels: [:queue])
      end
    end

    r
  end

  mattr_reader :config do
    Prometheus::Client.config
  end

  mattr_accessor :sidekiq_metrics_host do
    "0.0.0.0"
  end
  
  mattr_accessor :sidekiq_metrics_port do
    9310
  end

  class << self
    delegate :counter, :gauge, :histogram, :summary, :get, to: :registry
    delegate :data_store, :to :config 

    def configure
      yield self
    end
  end
end

Prome::Rails.install!
Prome::Sidekiq.install!