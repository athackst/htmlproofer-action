# frozen_string_literal: true

require 'html-proofer'
require 'json'
require 'uri'

require_relative 'cache_summary'
require_relative 'env_options'
require_relative 'git_helpers'

module HTMLProoferAction
  # Helper module to get all of the options for HTMLProofer
  module Runner
    def self.run(options = nil)
      options ||= build_options
      directory = EnvOptions.get_str('DIRECTORY', '.')
      print_options(directory, options)
      abort('No checks run') if options[:checks].empty?
      run_proofer(directory, options)
      CacheSummary.print(options[:cache]) if options.key?(:cache)
    end

    def self.print_options(directory, options)
      puts '<details><summary>HTMLProofer Options</summary>'
      puts "Running in directory: #{File.expand_path(directory)}"
      puts ''
      puts '```json'
      puts JSON.pretty_generate(options)
      puts '```'
      puts '</details>'
      puts ''
    end

    def self.run_proofer(directory, options)
      HTMLProofer.check_directory(directory, options).run
    end

    def self.build_swap_urls
      EnvOptions.append_swap_map(%w[SWAP_URLS URL_SWAP], default_swap)
    end

    def self.build_ignore_urls
      EnvOptions.get_only_regex_list('URL_IGNORE_RE', []) +
        EnvOptions.get_regex_list(%w[IGNORE_URLS URL_IGNORE], []) +
        ignore_new_files
    end

    def self.default_swap
      output = {}
      host_url = EnvOptions.get_str('HOST')
      base_name = EnvOptions.get_str('BASE_PATH')
      # Create regex host_url/base_name and /base_name
      if !host_url.empty? && !base_name.empty?
        output[Regexp.new("^.*#{host_url}#{base_name}")] = ''
        output[Regexp.new("^#{base_name}")] = ''
      end
      output
    end

    def self.ignore_new_files
      return [] unless EnvOptions.get_bool('IGNORE_NEW_FILES', false)

      new_files = GitHelpers.detect_new_files

      return [] if new_files.nil?

      new_files.map do |filename|
        basename = Regexp.escape(File.basename(filename, File.extname(filename)))
        original_ext = Regexp.escape(File.extname(filename).sub(/^\./, '')) # no dot
        Regexp.new(".*#{basename}(/index)?\\.(#{original_ext}|html?)$", Regexp::IGNORECASE)
      end
    end

    # rubocop: disable Metrics/AbcSize
    # rubocop: disable Metrics/MethodLength
    # This function just builds options.  It's easier to read them all together than to separate them up.
    def self.build_options
      options = {
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
        ignore_urls: build_ignore_urls,
        swap_urls: build_swap_urls,
        hydra: {
          max_concurrency: EnvOptions.get_int('MAX_CONCURRENCY', 50)
        },
        typhoeus: {
          connecttimeout: EnvOptions.get_int('CONNECT_TIMEOUT', 30),
          followlocation: EnvOptions.get_bool('FOLLOWLOCATION', true),
          ssl_verifypeer: EnvOptions.get_bool('SSL_VERIFYPEER', false),
          ssl_verifyhost: EnvOptions.get_int('SSL_VERIFYHOST', 0),
          timeout: EnvOptions.get_int('TIMEOUT', 120),
          cookiefile: '.cookies',
          cookiejar: '.cookies'
        }
      }
      cache_options = EnvOptions.get_json('CACHE')
      options[:cache] = cache_options unless cache_options.nil?
      options
    end
    # rubocop: enable Metrics/AbcSize
    # rubocop: enable Metrics/MethodLength

    private_class_method :print_options, :run_proofer
  end
end
