module Prome
  module Rails
    def self.ms2s(ms)
      (ms.to_f / 1000).round(3)
    end

    def self.install!
      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, ending, _, payload|
        labels = {
          controller: payload[:params]["controller"],
          action: payload[:params]["action"],
          status: payload[:status],
          format: payload[:format],
          method: payload[:method].downcase
        }
        duration = ending - start

        Prome.get(:rails_requests_total).increment(labels: labels)
        Prome.get(:rails_request_duration_seconds).observe(ms2s(duration), labels: labels)
        Prome.get(:rails_view_runtime_seconds).observe(ms2s(payload[:view_runtime]), labels: labels)
        Prome.get(:rails_db_runtime_seconds).observe(ms2s(payload[:db_runtime]), labels: labels)
      end
    end
  end
end