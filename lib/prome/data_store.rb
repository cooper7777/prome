require 'prometheus/client/data_stores/direct_file_store'

module Prome
    class DataStore < Prometheus::Client::DataStores::DirectFileStore
        klass = self.const_get(:MetricStore)
        MetricStore = Class.new(klass) do
            private def store_key(labels)
                labels.to_a.sort.map{|k,v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')
            end
        end
    end
end