# frozen_string_literal: true

require_relative '../scripts/site_url_swaps'

RSpec.describe SiteUrlSwaps do
  describe '.build' do
    subject(:swaps) { described_class.build(env) }

    let(:env) do
      {
        'INPUT_HOST' => 'example.github.io',
        'INPUT_BASE_PATH' => '/project'
      }
    end

    it 'generates host and base-path swaps by default' do
      expect(swaps.lines(chomp: true)).to eq([
                                               '^/project(?=/|$):',
                                               '^https?\\://example\\.github\\.io/project(?=/|$):'
                                             ])
    end

    it 'appends user-provided swaps after generated swaps' do
      env['INPUT_SWAP_URLS'] = '^/version:'

      expect(swaps.lines(chomp: true).last).to eq('^/version:')
    end

    it 'preserves the deprecated URL_SWAP input' do
      env['INPUT_URL_SWAP'] = '^/legacy:'

      expect(swaps.lines(chomp: true).last).to eq('^/legacy:')
    end

    it 'returns only user-provided swaps when site URL swaps are disabled' do
      env['INPUT_SITE_URL_SWAP'] = 'false'
      env['INPUT_SWAP_URLS'] = '^/version:'

      expect(swaps).to eq('^/version:')
    end

    it 'does not generate swaps without a host' do
      env.clear

      expect(swaps).to eq('')
    end

    it 'strips only the host when the base path is root' do
      env['INPUT_HOST'] = 'https://example.com/'
      env['INPUT_BASE_PATH'] = '/'

      expect(swaps).to eq('^https\\://example\\.com(?=/|$):')
    end
  end
end
