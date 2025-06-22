# frozen_string_literal: true

require 'spec_helper'
require 'html_proofer_action/git_helpers'
require 'json'

describe HTMLProoferAction::GitHelpers do
  subject(:git_helpers) { described_class }

  before do
    stub_const('ENV', ENV.to_hash.dup)
  end

  describe '.detect_new_files' do
    context 'when pull_request event' do
      before do
        ENV['GITHUB_BASE_REF'] = 'main'
        ENV['GITHUB_HEAD_REF'] = 'feature-branch'
        ENV['GITHUB_REPOSITORY'] = 'user/repo'
        ENV['GITHUB_TOKEN'] = 'testtoken'

        allow(Open3).to receive(:capture3)
          .with(
            "gh api repos/user/repo/compare/main...feature-branch --jq '.files[] | select(.status == \"added\" or .status == \"renamed\") | .filename'",
            { 'GH_TOKEN' => 'testtoken' }
          ).and_return(["file1.html\nfile2.html", '', instance_double(Process::Status, success?: true)])
      end

      it 'returns list of files from the GitHub compare API' do
        expect(git_helpers.new_files_from_pull_request_event).to eq(['file1.html', 'file2.html'])
      end
    end

    context 'when push event' do
      before do
        ENV['GITHUB_EVENT_NAME'] = 'push'
        ENV['GITHUB_EVENT_BEFORE'] = 'abc123'

        allow(Open3).to receive(:capture3)
          .with('git diff -z --name-only --diff-filter=AR abc123')
          .and_return(["foo.html\0bar.html\0", '', instance_double(Process::Status, success?: true)])
      end

      it 'returns list of new files from git diff' do
        expect(git_helpers.detect_new_files).to eq(['foo.html', 'bar.html'])
      end
    end

    context 'when fallback used (no PR or push)' do
      before do
        ENV.delete('GITHUB_EVENT_NAME')
        ENV['BASE_BRANCH'] = 'origin/main'

        allow(Open3).to receive(:capture3)
          .with('git merge-base origin/main HEAD')
          .and_return(['base123', '', instance_double(Process::Status, success?: true)])

        allow(Open3).to receive(:capture3)
          .with('git diff -z --name-only --diff-filter=AR base123')
          .and_return(["new1.html\0new2.html\0", '', instance_double(Process::Status, success?: true)])
      end

      it 'returns list of new files from fallback diff' do
        expect(git_helpers.detect_new_files).to eq(['new1.html', 'new2.html'])
      end
    end

    context 'when all methods fail gracefully' do
      before do
        ENV['GITHUB_EVENT_NAME'] = 'push'
        ENV['GITHUB_EVENT_BEFORE'] = 'badsha'

        allow(Open3).to receive(:capture3)
          .with('git diff -z --name-only --diff-filter=AR badsha')
          .and_return(['', 'fatal: bad object', instance_double(Process::Status, success?: false)])
      end

      it 'returns empty array on failure' do
        expect(git_helpers.detect_new_files).to eq([])
      end
    end
  end

  describe '.pr_context_values' do
    context 'with all required env vars present' do
      before do
        ENV['GITHUB_BASE_REF'] = 'main'
        ENV['GITHUB_HEAD_REF'] = 'feature-branch'
        ENV['GITHUB_REPOSITORY'] = 'user/repo'
        ENV['GITHUB_TOKEN'] = 'testtoken'
      end

      it 'returns pr_number, repo, and token' do
        output = git_helpers.pr_context_values
        expect(output).to eq({ base_ref: 'main', head_ref: 'feature-branch', repo: 'user/repo', token: 'testtoken' })
      end
    end

    context 'with missing repo or token' do
      before do
        ENV['GITHUB_BASE_REF'] = 'main'
        ENV['GITHUB_HEAD_REF'] = 'feature-branch'
        ENV.delete('GITHUB_REPOSITORY')
        ENV.delete('GITHUB_TOKEN')
        ENV.delete('GH_TOKEN')
      end

      it 'logs a warning' do
        expect do
          described_class.pr_context_values
        end.to output(/WARN: Missing GitHub context to fetch PR files/).to_stderr
      end

      it 'returns nils for missing values' do
        output = described_class.pr_context_values
        expect(output).to eq({ base_ref: 'main', head_ref: 'feature-branch', repo: nil, token: nil })
      end
    end
  end
end
