# frozen_string_literal: true

require 'json'
require 'open3'

module HTMLProoferAction
  # Helper function to get files from git
  module GitHelpers
    # Return the base sha for the files
    def self.detect_base_sha
      return pr_base_sha_from_event if pull_request_event?
      return push_before_sha if push_event?

      fallback_base_sha
    end

    def self.new_files(base)
      output, err, status = Open3.capture3("git diff -z --name-only --diff-filter=AR #{base}")
      puts 'Getting new files...'
      puts output
      return output.split("\0") if status.success?

      warn "WARN: Failed to get diff of new files. Git error: #{err.strip}"
      nil
    end

    def self.pull_request_event?
      ENV['GITHUB_EVENT_NAME'] == 'pull_request' && ENV.fetch('GITHUB_EVENT_PATH', nil)
    end

    def self.push_event?
      ENV['GITHUB_EVENT_NAME'] == 'push' && ENV.fetch('GITHUB_EVENT_BEFORE', nil)
    end

    def self.pr_base_sha_from_event
      event = JSON.parse(File.read(ENV.fetch('GITHUB_EVENT_PATH', nil)))
      event.dig('pull_request', 'base', 'sha') || ''
    rescue JSON::ParserError, Errno::ENOENT => e
      warn "WARN: Failed to parse PR event JSON: #{e.message}"
      ''
    end

    def self.push_before_sha
      ENV['GITHUB_EVENT_BEFORE'] || ''
    end

    def self.fallback_base_sha
      base_branch = ENV['BASE_BRANCH'] || 'origin/main'
      sha, err, status = Open3.capture3("git merge-base #{base_branch} HEAD")
      return sha.strip if status.success?

      warn "WARN: Failed to determine base SHA using git. #{err.strip}"
      ''
    end
  end
end
