# frozen_string_literal: true

require 'json'
require 'open3'

module HTMLProoferAction
  # Helper functions to determine new files in git/GitHub context
  module GitHelpers
    def self.detect_new_files
      return new_files_from_pull_request_event if pull_request_event?
      return new_files_from_push_event if push_event?

      fallback_new_files_from_diff
    end

    def self.pull_request_event?
      ENV['GITHUB_EVENT_NAME'] == 'pull_request'
    end

    def self.push_event?
      ENV['GITHUB_EVENT_NAME'] == 'push'
    end

    def self.new_files_from_pull_request_event
      ctx = pr_context_values
      return [] unless ctx.values.all?

      puts "Fetching file list via compare: #{ctx[:base_ref]}...#{ctx[:head_ref]}"

      ENV['GH_TOKEN'] = ctx[:token] # Set token globally for this process

      output, err, status = Open3.capture3(
        "gh api repos/#{ctx[:repo]}/compare/#{ctx[:base_ref]}...#{ctx[:head_ref]} --jq '.files[] | select(.status == \"added\" or .status == \"renamed\") | .filename'" # rubocop:disable Layout/LineLength
      )

      return output.split("\n") if status.success?

      warn "WARN: Failed to fetch PR file diff: #{err.strip}"
      []
    end

    def self.pr_context_values
      base_ref, head_ref, repo = ENV.values_at('GITHUB_BASE_REF', 'GITHUB_HEAD_REF', 'GITHUB_REPOSITORY')
      token = ENV['INPUT_GH_TOKEN'] || ENV['GITHUB_TOKEN'] || ENV.fetch('GH_TOKEN', nil)

      warn 'WARN: Missing GitHub context to fetch PR files' unless base_ref && head_ref && repo && token

      {
        base_ref: base_ref,
        head_ref: head_ref,
        repo: repo,
        token: token
      }
    end

    def self.new_files_from_push_event
      before_sha = ENV['GITHUB_EVENT_BEFORE'] || ''
      return [] if before_sha.empty?

      puts "Fetching new files from push diff (before SHA: #{before_sha})..."

      output, err, status = Open3.capture3("git diff -z --name-only --diff-filter=AR #{before_sha}")
      return output.split("\0") if status.success?

      warn "WARN: Failed to get diff for push event: #{err.strip}"
      []
    end

    def self.fallback_new_files_from_diff
      base_branch = ENV['GITHUB_REF'] || 'origin/main'
      sha, _err, status = Open3.capture3("git merge-base #{base_branch} HEAD")
      base_sha = sha.strip

      return [] if base_sha.empty? || !status.success?

      puts "Fetching new files from fallback diff (base SHA: #{base_sha})..."

      output, err, status = Open3.capture3("git diff -z --name-only --diff-filter=AR #{base_sha}")
      return output.split("\0") if status.success?

      warn "WARN: Failed to get fallback diff: #{err.strip}"
      []
    end
  end
end
