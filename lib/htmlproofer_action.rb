# frozen_string_literal: true

require 'html-proofer'
require 'json'
require 'uri'

# rubocop: disable Layout/LineLength
CHROME_FROZEN_UA = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36'
# rubocop: enable Layout/LineLength

# Helper functions to get options from the environment variables
module EnvOptions
  # Return the environment variable value from a name or from a list of names (first non-nill)
  def self.get_env(name)
    # Ensure that names is an array
    names = Array(name)
    # Loop through and get the value of the variable.
    names.each do |var|
      value = ENV["INPUT_#{var}"]
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

  # Return a list given an env varialbe, split by either commas or new lines.
  def self.get_list(name, fallback = [])
    s = get_env(name)
    s.nil? ? fallback : s.split(/,|\n/)
  end

  # Return a list of ints given an env varialbe, split by either commas or new lines.
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
  def self.get_swap_map(name)
    output = {}
    get_list(name).each do |s|
      splt = s.split(/(?<!\\):/, 2)
      re = splt[0].gsub(/\\:/, ':').strip
      string = splt[1].gsub(/\\:/, ':').strip
      output[Regexp.new(re)] = string
    end
    output
  end
end

# Helper module to get all of the options for htmlproofer
module HTMLProoferAction
  def self.run(options)
    directory = EnvOptions.get_str('DIRECTORY', '/site')
    HTMLProofer.check_directory(directory, options).run
  end

  def self.run_with_checks(options)
    abort('No checks run') if options[:checks].empty?
    run(options)
  end

  # rubocop: disable Metrics/AbcSize
  # rubocop: disable Metrics/MethodLength
  # This function just builds options.  It's easier to read them all together than to separate them up.
  def self.build_options
    {
      allow_hash_href: EnvOptions.get_bool('ALLOW_HASH_HREF', true),
      allow_missing_href: EnvOptions.get_bool('ALLOW_MISSING_HREF', false),
      assume_extension: EnvOptions.get_str('ASSUME_EXTENSION', '.html'),
      checks: [
        EnvOptions.return_value_if('CHECK_FAVICON', false, 'Favicon'),
        EnvOptions.return_value_if(%w[CHECK_LINKS CHECK_HTML], true, 'Links'),
        EnvOptions.return_value_if(%w[CHECK_IMAGES CHECK_IMG_HTTP], true, 'Images'),
        EnvOptions.return_value_if('CHECK_SCRIPTS', true, 'Scripts'),
        EnvOptions.return_value_if('CHECK_OPENGRAPH', false, 'OpenGraph')
      ],
      check_external_hash: EnvOptions.get_bool('CHECK_EXTERNAL_HASH', true),
      check_internal_hash: EnvOptions.get_bool('CHECK_INTERNAL_HASH', true),
      check_sri: EnvOptions.get_bool('CHECK_SRI', false),
      directory_index_file: EnvOptions.get_str('DIRECTORY_INDEX_FILE', 'index.html'),
      disable_external: EnvOptions.get_bool('DISABLE_EXTERNAL', false),
      enforce_https: EnvOptions.get_bool('ENFORCE_HTTPS', true),
      extensions: EnvOptions.get_list('EXTENSIONS', ['.html']),
      ignore_empty_alt: EnvOptions.get_bool(%w[IGNORE_EMPTY_ALT EMPTY_ALT_IGNORE], true),
      ignore_files: EnvOptions.get_regex_list('IGNORE_FILES', []),
      ignore_empty_mailto: EnvOptions.get_bool('IGNORE_EMPTY_MAILTO', false),
      ignore_missing_alt: EnvOptions.get_bool(%w[IGNORE_MISSING_ALT MISSING_ALT_IGNORE], false),
      ignore_status_codes: EnvOptions.get_int_list('IGNORE_STATUS_CODES', []),
      ignore_urls: EnvOptions.get_only_regex_list('URL_IGNORE_RE', []) \
                  + EnvOptions.get_regex_list(%w[IGNORE_URLS URL_IGNORE], []),
      swap_urls: EnvOptions.get_swap_map(%w[SWAP_URLS URL_SWAP]),
      hydra: {
        max_concurrency: EnvOptions.get_int('MAX_CONCURRENCY', 50)
      },
      typhoeus: {
        connecttimeout: EnvOptions.get_int('CONNECT_TIMEOUT', 30),
        followlocation: EnvOptions.get_bool('FOLLOWLOCATION', true),
        headers: {
          'User-Agent' => CHROME_FROZEN_UA
        },
        ssl_verifypeer: EnvOptions.get_bool('SSL_VERIFYPEER', false),
        ssl_verifyhost: EnvOptions.get_int('SSL_VERIFYHOST', 0),
        timeout: EnvOptions.get_int('TIMEOUT', 120),
        cookiefile: '.cookies',
        cookiejar: '.cookies'
      }
    }
  end
  # rubocop: enable Metrics/AbcSize
  # rubocop: enable Metrics/MethodLength
end
