# frozen_string_literal: true

require 'spec_helper'
require 'html_proofer_action/git_helpers'
require 'json'

describe HTMLProoferAction::GitHelpers do
  subject(:git_helpers) { described_class }

  before do
    stub_const('ENV', ENV.to_hash.dup)
  end

  describe '.detect_base_sha' do
    let(:event_data) { { 'pull_request' => { 'base' => { 'sha' => 'abc123' } } } }

    context 'when event is a pull request with event path' do
      before do
        ENV['GITHUB_EVENT_NAME'] = 'pull_request'
        ENV['GITHUB_EVENT_PATH'] = 'event.json'
        allow(File).to receive(:read).with('event.json').and_return(event_data.to_json)
      end

      it 'returns the base sha from the event file' do
        expect(git_helpers.detect_base_sha).to eq('abc123')
      end
    end

    context 'when event is a push with GITHUB_EVENT_BEFORE set' do
      before do
        ENV['GITHUB_EVENT_NAME'] = 'push'
        ENV['GITHUB_EVENT_BEFORE'] = 'def456'
      end

      it 'returns the GITHUB_EVENT_BEFORE sha' do
        expect(git_helpers.detect_base_sha).to eq('def456')
      end
    end

    context 'when running locally without GitHub env vars' do
      before do
        ENV['BASE_BRANCH'] = 'origin/test-branch'
        allow(Open3).to receive(:capture3).with('git merge-base origin/test-branch HEAD')
                                          .and_return(['xyz789', '', instance_double(Process::Status, success?: true)])
      end

      it 'returns the git merge-base sha' do
        expect(git_helpers.detect_base_sha).to eq('xyz789')
      end
    end

    context 'when git merge-base fails' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', 'fatal error', instance_double(Process::Status, success?: false)])
      end

      it 'returns empty string and warns' do
        expect(git_helpers.detect_base_sha).to eq('')
      end
    end
  end

  describe '.new_files' do
    context 'when git diff returns new files' do
      before do
        allow(Open3).to receive(:capture3)
          .with('git diff -z --name-only --diff-filter=AR base123')
          .and_return(["foo.html\0bar.html\0", '', instance_double(Process::Status, success?: true)])
      end

      it 'returns the list of new file names' do
        expect(git_helpers.new_files('base123')).to eq(['foo.html', 'bar.html'])
      end
    end

    context 'when git diff fails' do
      before do
        allow(Open3).to receive(:capture3)
          .with('git diff -z --name-only --diff-filter=AR base123')
          .and_return(['', 'fatal error', instance_double(Process::Status, success?: false)])
      end

      it 'returns nil and warns' do
        expect(git_helpers.new_files('base123')).to be_nil
      end
    end
  end
end
