require_relative '../../raw_oar'
module ActiveRecord
  # Adding functionality to ActiveRecord::Relation to make
  #   optars method available for all relations,
  #   returning array of `OAR`s which we generate
  module RelationExtender
    DEFAULT_QUERY_OPTIONS = {
      symbolize_keys:    true,  # Returns attributes with symbolized keys
      as:                :hash, # Returns rows as Hash objects
      cast_booleans:     true,  # Typecasts TINYINT columns
      database_timezone: ActiveRecord::Base.default_timezone,
      cache_rows:        false
      # Disabled because iteration happens only once allowing GC to cleanup
    }.freeze

    def optars(options = {})
      attrs = options[:attrs] || []
      validate_columns(attrs)
      select_attrs = ([primary_key] + attrs).uniq
      sql_query = except(:select).select(select_attrs).to_sql
      fetch_objects(sql_query, select_attrs)
    end

    def raw_optars(options = {})
      attrs = options[:attrs] || []
      validate_columns(attrs)
      select_attrs = ([primary_key] + attrs).uniq
      sql_query = except(:select).select(select_attrs).to_sql
      query_options = DEFAULT_QUERY_OPTIONS.dup.merge(as: :array)
      fetch_raw_content(sql_query, query_options)
    end

    alias opt_ar_objects optars

    private

    def fetch_objects(query, requested_attributes)
      res = fetch_sql_rows(query, DEFAULT_QUERY_OPTIONS)
      res.map do |row|
        OptAR::OAR.init_manual(row, klass, requested_attributes)
      end
    end

    def fetch_raw_content(query, options)
      result = fetch_sql_rows(query, options)

      columns = result.fields
      rows = result.to_a
      OptAR::RawOAR.new(columns, rows)
    end

    def fetch_sql_rows(query, options)
      client = connection.raw_connection
      connection.send(:log, query, "OptAR - #{klass.name}") do
        client.query(query, options)
      end
    end

    def validate_columns(attrs)
      klass_attrs = klass.column_names.map(&:to_sym)
      valid = (attrs - klass_attrs).empty?
      raise OptAR::Errors::UnknownARColumnError unless valid
    end
  end
end
