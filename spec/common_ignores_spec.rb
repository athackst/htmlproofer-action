# frozen_string_literal: true

require_relative '../scripts/common_ignores'

RSpec.describe CommonIgnores do
  describe '.build' do
    subject(:ignores) { described_class.build(env) }

    let(:env) { {} }

    it 'includes common URLs by default' do
      expect(ignores).to eq('https://fonts.gstatic.com')
    end

    it 'appends user-provided ignores' do
      env['INPUT_IGNORE_URLS'] = 'https://example.com'

      expect(ignores.lines(chomp: true)).to eq([
                                                 'https://fonts.gstatic.com',
                                                 'https://example.com'
                                               ])
    end

    it 'preserves the deprecated URL_IGNORE input' do
      env['INPUT_URL_IGNORE'] = 'https://example.com'

      expect(ignores.lines(chomp: true).last).to eq('https://example.com')
    end

    it 'returns only user-provided ignores when common ignores are disabled' do
      env['INPUT_IGNORE_COMMON'] = 'false'
      env['INPUT_IGNORE_URLS'] = 'https://example.com'

      expect(ignores).to eq('https://example.com')
    end

    it 'returns an empty value when disabled without user ignores' do
      env['INPUT_IGNORE_COMMON'] = 'false'

      expect(ignores).to eq('')
    end
  end
end
