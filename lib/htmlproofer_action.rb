# frozen_string_literal: true

require 'html-proofer'
require 'json'
require 'uri'

# rubocop: disable Layout/LineLength
CHROME_FROZEN_UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.0.0 Safari/537.36'
# rubocop: enable Layout/LineLength

# Helper functions to get options from the environment variables
module EnvOptions
  # Return the boolean stored in env variable or fallback if it doesn't exist.
  def self.get_bool(name, fallback)
    s = ENV["INPUT_#{name}"]
    return fallback if s.nil? || s.empty?

    case s.downcase
    when /^(t|true)$/i, /^(y|yes)$/i, '1'
      true
    else
      false
    end
  end

  # Return return_name if env variable is true, use fallback for truthy if doesn't exist.
  def self.get_name_if(name, fallback, return_name)
    get_bool(name, fallback) ? return_name : ''
  end

  # Return the int stored in env variable or fallback if it doesn't exist.
  def self.get_int(name, fallback)
    s = ENV["INPUT_#{name}"]
    s.nil? || s.empty? ? fallback : s.to_i
  end

  # Return the string stored in env variable or fallback if it doesn't exist.
  def self.get_str(name, fallback = '')
    s = ENV["INPUT_#{name}"]
    s.nil? ? fallback : s
  end

  # Return a list given a string, split by either commas or new lines.
  def self.get_list(str)
    str.nil? ? [] : str.split(/,|\n/)
  end

  # Convert a string to a regex if it begins and ends with '/'.
  def self.to_regex?(item)
    item.start_with?('/') && item.end_with?('/') ? Regexp.new(item[1...-1]) : item
  end

  # Return a list of either Regex expressions or strings to match.
  def self.get_regex_list(str, as_regex)
    get_list(get_str(str)).map { |s| as_regex ? Regexp.new(s) : to_regex?(s) }
  end

  # Return a dict with a regex expr => string replacement.
  def self.get_swap_map(str)
    output = {}
    get_list(get_str(str)).each do |s|
      splt = s.split(/(?<!\\):/, 2)
      re = splt[0].gsub(/\\:/, ':').strip
      string = splt[1].gsub(/\\:/, ':').strip
      output[Regexp.new(re)] = string
    end
    output
  end
end

# Helper module to get all of the options for htmlproofer
module HtmlprooferAction
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
      allow_missing_href: EnvOptions.get_bool('ALLOW_MISSING_HREF', false),
      check_external_hash: EnvOptions.get_bool('CHECK_EXTERNAL_HASH', true),
      checks: [
        EnvOptions.get_name_if('CHECK_FAVICON', true, 'Favicon'),
        EnvOptions.get_name_if('CHECK_HTML', true, 'Links'),
        EnvOptions.get_name_if('CHECK_IMG_HTTP', true, 'Images'),
        EnvOptions.get_name_if('CHECK_SCRIPTS', true, 'Scripts'),
        EnvOptions.get_name_if('CHECK_OPENGRAPH', true, 'OpenGraph')
      ],
      ignore_empty_alt: EnvOptions.get_bool('EMPTY_ALT_IGNORE', false),
      ignore_missing_alt: EnvOptions.get_bool('MISSING_ALT_IGNORE', false),
      enforce_https: EnvOptions.get_bool('ENFORCE_HTTPS', true),
      hydra: {
        max_concurrency: EnvOptions.get_int('MAX_CONCURRENCY', 50)
      },
      typhoeus: {
        connecttimeout: EnvOptions.get_int('CONNECT_TIMEOUT', 30),
        followlocation: true,
        headers: {
          'User-Agent' => CHROME_FROZEN_UA
        },
        ssl_verifypeer: EnvOptions.get_bool('SSL_VERIFYPEER', false),
        ssl_verifyhost: EnvOptions.get_int('SSL_VERIFYHOST', 0),
        timeout: EnvOptions.get_int('TIMEOUT', 120),
        cookiefile: '.cookies',
        cookiejar: '.cookies'
      },
      ignore_urls: EnvOptions.get_regex_list('URL_IGNORE_RE', true) \
                  + EnvOptions.get_regex_list('URL_IGNORE', false) \
                  + EnvOptions.get_regex_list('IGNORE_URLS', false),
      swap_urls: EnvOptions.get_swap_map('URL_SWAP'),
      ignore_files: EnvOptions.get_regex_list('IGNORE_FILES', false)
    }
  end
  # rubocop: enable Metrics/AbcSize
  # rubocop: enable Metrics/MethodLength
end
