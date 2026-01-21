# frozen_string_literal: true

require 'json'

module HTMLProoferAction
  # Helper functions to get options from the environment variables
  module EnvOptions
    # Return the environment variable value from a name or from a list of names (first non-nill)
    def self.get_env(name)
      # Ensure that names is an array
      names = Array(name)
      # Loop through and get the value of the variable.
      names.each do |var|
        value = ENV.fetch("INPUT_#{var}", nil)
        return value unless value.nil? || value.empty?
      end
      nil
    end

    # Return the boolean stored in env variable or fallback if it doesn't exist.
    def self.get_bool(name, fallback)
      value = get_env(name)

      case value
      when true, 'true', /^(t|true)$/i, /^(y|yes)$/i, '1'
        true
      when false, 'false', /^(f|false)$/i, /^(n|no)$/i, '0'
        false
      else
        fallback
      end
    end

    # Return return_name if env variable is true, use fallback for truthy if doesn't exist.
    def self.return_value_if(name, fallback, return_name)
      get_bool(name, fallback) ? return_name : ''
    end

    # Return the int stored in env variable or fallback if it doesn't exist.
    def self.get_int(name, fallback)
      s = get_env(name)
      s.nil? || s.empty? ? fallback : s.to_i
    end

    # Return the string stored in env variable or fallback if it doesn't exist.
    def self.get_str(name, fallback = '')
      s = get_env(name)
      s.nil? ? fallback : s
    end

    # Return a list given an env variable, split by either commas or new lines.
    def self.get_list(name, fallback = [])
      s = get_env(name)
      s.nil? ? fallback : s.split(/,|\n/)
    end

    # Return a list of ints given an env variable, split by either commas or new lines.
    def self.get_int_list(name, fallback = [])
      s = get_env(name)
      s.nil? ? fallback : s.split(/,|\n/).map(&:to_i)
    end

    # Convert a string to a regex if it begins and ends with '/'.
    def self.to_regex?(item)
      item.start_with?('/') && item.end_with?('/') ? Regexp.new(item[1...-1]) : item
    end

    # Return a list of either Regex expressions or strings to match.
    def self.get_only_regex_list(name, fallback = [])
      get_list(name, fallback).map { |s| Regexp.new(s) }
    end

    # Return a list of either Regex expressions or strings to match.
    def self.get_regex_list(name, fallback = [])
      get_list(name, fallback).map { |s| to_regex?(s) }
    end

    # Return a dict with a regex expr => string replacement.
    def self.append_swap_map(name, output)
      get_list(name).each do |s|
        splt = s.split(/(?<!\\):/, 2)
        re = splt[0].gsub('\\:', ':').strip
        string = splt[1].gsub('\\:', ':').strip
        output[Regexp.new(re)] = string
      end
      output
    end

    def self.get_json(name, fallback = nil)
      s = get_env(name)
      return fallback if s.nil? || s.empty?

      data = JSON.parse(s)
      symbolize_keys(data)
    rescue JSON::ParserError
      fallback
    end

    def self.symbolize_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, val), acc|
          acc[key.to_sym] = symbolize_keys(val)
        end
      when Array
        value.map { |item| symbolize_keys(item) }
      else
        value
      end
    end
  end
end
