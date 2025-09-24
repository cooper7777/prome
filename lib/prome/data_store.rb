require 'prometheus/client/data_stores/direct_file_store'

module Prome
    MetricStore = Prometheus::Client::DataStores::DirectFileStore.const_get(:MetricStore)
    MetricStore.define_method(:store_key) do |labels|
        labels.to_a.sort.map{|k,v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')
    end
    MetricStore.send(:private, :store_key)
    DataStore = Class.new(Prometheus::Client::DataStores::DirectFileStore)
    DataStore.const_set(:MetricStore, MetricStore)
end