# frozen_string_literal: true

require 'json'

module HTMLProoferAction
  # Print a summary of cached URLs after HtmlProofer runs
  module CacheSummary
    def self.print(cache_options = nil)
      path = cache_path(cache_options)
      unless File.exist?(path)
        puts "Expected cache.json at #{path} but none was found"
        return
      end
      data = JSON.parse(File.read(path))
      print_summary(data)
    end

    def self.summarize(data, section)
      items = data.fetch(section, {})
      total = items.length
      failures = items.count do |_, v|
        v.fetch('metadata', []).any? { |meta| meta['found'] == false }
      end
      [total, failures, items.keys]
    end

    def self.print_summary(data)
      print_header
      %w[external internal].each { |section| print_section(data, section) }
      print_footer
    end

    def self.print_header
      puts ''
      puts '<details><summary>HTMLProofer Cache Summary</summary>'
      puts ''
    end

    def self.print_section(data, section)
      total, failures, urls = summarize(data, section)
      puts "#{section} cached: #{total} (failures rechecked: #{failures})"
      urls.first(20).each { |url| puts "  - #{url}" }
      puts ''
      puts "  ... and #{total - 20} more" if total > 20
      puts ''
    end

    def self.print_footer
      puts ''
      puts '</details>'
      puts ''
    end

    def self.cache_path(cache_options)
      storage_dir = cache_options&.fetch(:storage_dir, nil) || HTMLProofer::Cache::DEFAULT_STORAGE_DIR
      cache_file = cache_options&.fetch(:cache_file, nil) || HTMLProofer::Cache::DEFAULT_CACHE_FILE_NAME
      File.join(storage_dir, cache_file)
    end

    private_class_method :summarize, :print_summary, :cache_path, :print_header, :print_section, :print_footer
  end
end
