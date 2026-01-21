# frozen_string_literal: true

require 'spec_helper'
require 'html_proofer_action/env_options'

describe HTMLProoferAction::EnvOptions do
  subject(:env_options) { described_class }

  before do
    stub_const('ENV', ENV.to_hash.dup)
  end

  describe '.get_env' do
    it 'returns the value for a single env var' do
      ENV['INPUT_FOO'] = 'bar'
      expect(env_options.get_env('FOO')).to eq('bar')
    end

    it 'returns the first non-empty value for a list of names' do
      ENV['INPUT_SECOND'] = 'value2'
      ENV['INPUT_FIRST'] = ''
      expect(env_options.get_env(%w[FIRST SECOND])).to eq('value2')
    end

    it 'returns nil if all are missing or empty' do
      expect(env_options.get_env(%w[MISSING EMPTY])).to be_nil
    end
  end

  describe '.get_bool' do
    it 'returns true for various truthy inputs' do
      %w[true t yes y 1].each do |val|
        ENV['INPUT_TEST'] = val
        expect(env_options.get_bool('TEST', false)).to be(true)
      end
    end

    it 'returns false for various falsy inputs' do
      %w[false f no n 0].each do |val|
        ENV['INPUT_TEST'] = val
        expect(env_options.get_bool('TEST', true)).to be(false)
      end
    end

    it 'returns fallback for unknown values' do
      ENV['INPUT_TEST'] = 'maybe'
      expect(env_options.get_bool('TEST', true)).to be(true)
    end
  end

  describe '.return_value_if' do
    it 'returns return_name if env var is truthy' do
      ENV['INPUT_CHECK_THIS'] = 'true'
      expect(env_options.return_value_if('CHECK_THIS', false, 'Something')).to eq('Something')
    end

    it 'returns empty string if env var is falsy' do
      ENV['INPUT_CHECK_THIS'] = 'false'
      expect(env_options.return_value_if('CHECK_THIS', true, 'Something')).to eq('')
    end
  end

  describe '.get_int' do
    it 'returns integer value from env' do
      ENV['INPUT_NUMBER'] = '42'
      expect(env_options.get_int('NUMBER', 5)).to eq(42)
    end

    it 'returns fallback if missing or empty' do
      expect(env_options.get_int('MISSING', 7)).to eq(7)
    end
  end

  describe '.get_str' do
    it 'returns the string from env' do
      ENV['INPUT_PATH'] = '/my/path'
      expect(env_options.get_str('PATH')).to eq('/my/path')
    end

    it 'returns fallback if not present' do
      expect(env_options.get_str('NOPE', 'default')).to eq('default')
    end
  end

  describe '.get_list' do
    it 'splits by comma and newline' do
      ENV['INPUT_LIST'] = "a,b\nc"
      expect(env_options.get_list('LIST')).to eq(%w[a b c])
    end
  end

  describe '.get_int_list' do
    it 'parses comma and newline separated integers' do
      ENV['INPUT_NUMS'] = "1,2\n3"
      expect(env_options.get_int_list('NUMS')).to eq([1, 2, 3])
    end
  end

  describe '.to_regex?' do
    it 'converts string with slashes to regex' do
      expect(env_options.to_regex?('/abc/')).to eq(/abc/)
    end

    it 'returns original string if not regex-like' do
      expect(env_options.to_regex?('abc')).to eq('abc')
    end
  end

  describe '.get_only_regex_list' do
    it 'returns list of regexes' do
      ENV['INPUT_PATTERNS'] = "abc\n123"
      expect(env_options.get_only_regex_list('PATTERNS')).to all(be_a(Regexp))
    end
  end

  describe '.get_regex_list' do
    it 'returns mixed regex and string list' do
      ENV['INPUT_MIX'] = '/abc/,plain'
      result = env_options.get_regex_list('MIX')
      expect(result).to include(/abc/, 'plain')
    end
  end

  describe '.append_swap_map' do
    it 'parses regex to replacement map' do
      ENV['INPUT_SWAP_URLS'] = "foo:bar\nbaz:qux"
      result = env_options.append_swap_map('SWAP_URLS', {})
      expect(result).to eq({ /foo/ => 'bar', /baz/ => 'qux' })
    end

    it 'returns a hash with regex expression => string replacement with commas' do
      ENV['INPUT_SWAP_URLS'] = 'foo:bar,baz:qux'
      result = env_options.append_swap_map('SWAP_URLS', {})
      expect(result).to eq({ /foo/ => 'bar', /baz/ => 'qux' })
    end

    it 'handles escaped colons correctly' do
      ENV['INPUT_SWAP_URLS'] = 'colon\\:bar:escape\\:qux'
      result = env_options.append_swap_map('SWAP_URLS', {})
      expect(result).to eq({ /colon:bar/ => 'escape:qux' })
    end
  end
end
