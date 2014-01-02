# -*- encoding : utf-8 -*-
require 'rubygems'
require 'bundler/setup'
require 'second_level_cache'
require 'test/unit'
require 'database_cleaner'
# require 'dalli'
# require 'memcached'
# require 'redis'

DatabaseCleaner[:active_record].strategy = :transaction

SecondLevelCache.configure do |config|
  config.cache_store = SecondLevelCache::Store::Memory.new(50)
#  config.cache_store = SecondLevelCache::Store::Dalli.new(::Dalli::Client.new('127.0.0.1:11211'))
#  config.cache_store = SecondLevelCache::Store::Memcached.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
#  config.cache_store = SecondLevelCache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
end

SecondLevelCache.logger.level = Logger::INFO
