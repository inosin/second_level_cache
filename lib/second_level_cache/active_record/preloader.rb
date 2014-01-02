# -*- encoding : utf-8 -*-
module SecondLevelCache
  module ActiveRecord
    module Associations
      class Preloader
        module Association
          extend ActiveSupport::Concern

          included do
            class_eval do
              alias_method_chain :records_for, :second_level_cache
            end
          end

          def records_for_with_second_level_cache(ids)
            ids.map! &:to_i
            return records_for_without_second_level_cache(ids) unless klass.second_level_cache_enabled?

            map_cache_keys = ids.map{|id| klass.second_level_cache_key(id)}
            records_from_cache = ::SecondLevelCache.cache_store.get_multi(*map_cache_keys)

            # NOTICE 
            # Rails.cache.read_multi return hash that has keys only hitted.
            # eg. Rails.cache.read_multi(1,2,3) => {2 => hit_value, 3 => hit_value}
            hitted_ids = records_from_cache.map(&:id) unless records_from_cache.empty?
            missed_ids = ids - (hitted_ids || [])

            ::SecondLevelCache::Config.logger.info "\nids -> #{ids} | hitted ids -> #{hitted_ids.inspect} | missed ids -> #{missed_ids.inspect}"

            if missed_ids.empty?
              records_from_cache
            else
              records_from_db = records_for_without_second_level_cache(missed_ids)
              records_from_db.map{|record| write_cache(record); record} + records_from_cache
            end
          end

          private

          def write_cache(record)
            record.write_second_level_cache
          end
        end
      end
    end 
  end
end
