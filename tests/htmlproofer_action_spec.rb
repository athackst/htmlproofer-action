# frozen_string_literal: true

require 'rspec'

# Require the file containing the functions you want to test
require_relative '../lib/htmlproofer_action'

def regex_or_substring_match(string, pattern)
  pattern.is_a?(Regexp) ? pattern.match?(string) : string.include?(pattern)
end

# rubocop: disable Metrics/BlockLength
describe EnvOptions do
  describe '#get_bool' do
    context 'when the environment variable is set to a truthy value' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('true')
      end

      it 'returns true' do
        expect(EnvOptions.get_bool('test', false)).to eq(true)
      end
    end

    context 'when the environment variable is set to a falsy value' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('false')
      end

      it 'returns false' do
        expect(EnvOptions.get_bool('test', true)).to eq(false)
      end
    end

    context 'when the environment variable is not set' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return(nil)
      end

      it 'returns the fallback value' do
        expect(EnvOptions.get_bool('test', true)).to eq(true)
      end
    end

    context 'when the environment variable is an empty string' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('')
      end

      it 'returns the fallback value' do
        expect(EnvOptions.get_bool('test', false)).to eq(false)
      end
    end
  end

  describe '#get_name_if' do
    context 'when the environment variable is set to a truthy value' do
      before do
        allow(EnvOptions).to receive(:get_bool).with('test', false).and_return(true)
      end

      it 'returns the provided return_name' do
        expect(EnvOptions.get_name_if('test', false, 'CustomName')).to eq('CustomName')
      end
    end

    context 'when the environment variable is not set or set to a falsy value' do
      before do
        allow(EnvOptions).to receive(:get_bool).with('test', false).and_return(false)
      end

      it 'returns an empty string' do
        expect(EnvOptions.get_name_if('test', false, 'CustomName')).to eq('')
      end
    end
  end

  describe '#get_int' do
    context 'when the environment variable is set to a valid integer' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('42')
      end

      it 'returns the parsed integer' do
        expect(EnvOptions.get_int('test', 0)).to eq(42)
      end
    end

    context 'when the environment variable is not set' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return(nil)
      end

      it 'returns the fallback value' do
        expect(EnvOptions.get_int('test', 0)).to eq(0)
      end
    end

    context 'when the environment variable is set to an invalid integer' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('invalid')
      end

      it 'returns the fallback value' do
        expect(EnvOptions.get_int('test', 0)).to eq(0)
      end
    end
  end

  describe '#get_str' do
    context 'when the environment variable is set' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('hello')
      end

      it 'returns the value of the environment variable as a string' do
        expect(EnvOptions.get_str('test')).to eq('hello')
      end
    end

    context 'when the environment variable is not set' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return(nil)
      end

      it 'returns an empty string' do
        expect(EnvOptions.get_str('test')).to eq('')
      end
    end

    context 'when the environment variable is set to an empty string' do
      before do
        allow(ENV).to receive(:[]).with('INPUT_test').and_return('')
      end

      it 'returns an empty string' do
        expect(EnvOptions.get_str('test')).to eq('')
      end
    end
  end

  describe '#get_list' do
    context 'when the value is a comma-separated string' do
      it 'returns an array containing the items' do
        value = 'item1,item2,item3'
        expect(EnvOptions.get_list(value)).to eq(%w[item1 item2 item3])
      end
    end

    context 'when the value is a newline-separated string' do
      it 'returns an array containing the items' do
        value = "item1\nitem2\nitem3"
        expect(EnvOptions.get_list(value)).to eq(%w[item1 item2 item3])
      end
    end

    context 'when the value is a combination of comma-separated and newline-separated strings' do
      it 'returns an array containing all the items' do
        value = "item1,item2\nitem3"
        expect(EnvOptions.get_list(value)).to eq(%w[item1 item2 item3])
      end
    end

    context 'when the value is an empty string' do
      it 'returns an empty array' do
        value = ''
        expect(EnvOptions.get_list(value)).to eq([])
      end
    end
  end

  describe '#to_regex?' do
    context 'when the item starts and ends with forward slashes' do
      it 'returns a Regexp object' do
        item = '/^abc$/'
        expect(EnvOptions.to_regex?(item)).to be_a(Regexp)
        expect(EnvOptions.to_regex?(item)).to eq(/^abc$/)
      end
    end

    context 'when the item does not start and end with forward slashes' do
      it 'returns the item as is' do
        item = 'abc'
        expect(EnvOptions.to_regex?(item)).to eq('abc')
      end
    end
  end

  describe '#get_regex_list' do
    context 'when the environment variable is set with comma-separated values' do
      before do
        allow(EnvOptions).to receive(:get_str).with('test').and_return('/stackoverflow\.com/,github.com')
      end

      it 'returns an array of regular expressions when as_regex is true' do
        result = EnvOptions.get_regex_list('test', true)
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to be_a(Regexp)
        expect(regex_or_substring_match('/stackoverflow.com/', result[0])).to be_truthy
        expect(result[1]).to be_a(Regexp)
        expect(regex_or_substring_match('http://github.com', result[1])).to be_truthy
      end

      it 'returns an array of strings when as_regex is false' do
        result = EnvOptions.get_regex_list('test', false)
        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to be_a(Regexp)
        expect(regex_or_substring_match('http://stackoverflow.com', result[0])).to be_truthy
        expect(result[1]).to be_a(String)
        expect(regex_or_substring_match('http://github.com', result[1])).to be_truthy
      end
    end

    context 'when the environment variable is not set' do
      before do
        allow(EnvOptions).to receive(:get_str).with('test').and_return(nil)
      end

      it 'returns an empty array' do
        result = EnvOptions.get_regex_list('test', true)
        expect(result).to be_an(Array)
        expect(result).to be_empty
      end
    end
  end

  describe '#get_swap_map' do
    it 'returns a hash with regex expression => string replacement with newline' do
      allow(EnvOptions).to receive(:get_str).with('URL_SWAP').and_return("foo:bar\nbaz:qux")

      result = EnvOptions.get_swap_map('URL_SWAP')

      expect(result).to be_a(Hash)
      expect(result.size).to eq(2)
      expect(result[Regexp.new('foo')]).to eq('bar')
      expect(result[Regexp.new('baz')]).to eq('qux')
    end

    it 'returns a hash with regex expression => string replacement with commas' do
      allow(EnvOptions).to receive(:get_str).with('URL_SWAP').and_return('foo:bar,baz:qux')

      result = EnvOptions.get_swap_map('URL_SWAP')

      expect(result).to be_a(Hash)
      expect(result.size).to eq(2)
      expect(result[Regexp.new('foo')]).to eq('bar')
      expect(result[Regexp.new('baz')]).to eq('qux')
    end

    it 'handles escaped colons correctly' do
      allow(EnvOptions).to receive(:get_str).with('URL_SWAP').and_return('colon\\:bar:escape\\:qux')

      result = EnvOptions.get_swap_map('URL_SWAP')

      expect(result).to be_a(Hash)
      expect(result.size).to eq(1)
      expect(result[Regexp.new('colon:bar')]).to eq('escape:qux')
    end
  end
end

describe HtmlprooferAction do
  describe '#run' do
    context 'when options are provided' do
      let(:options) { { checks: ['Links'], log_level: ':debug' } }

      it 'runs HTMLProofer with the provided options' do
        directory = EnvOptions.get_str('DIRECTORY', '/site')
        htmlproofer_double = double('HTMLProofer')
        expect(HTMLProofer).to receive(:check_directory).with(directory, options).and_return(htmlproofer_double)
        expect(htmlproofer_double).to receive(:run)
        HtmlprooferAction.run(options)
      end
    end
  end

  describe '#run_with_checks' do
    context 'when options have checks' do
      let(:options) { { checks: ['Links'], log_level: ':debug' } }

      it 'runs HTMLProofer with the provided options' do
        directory = EnvOptions.get_str('DIRECTORY', '/site')
        htmlproofer_double = double('HTMLProofer')
        expect(HTMLProofer).to receive(:check_directory).with(directory, options).and_return(htmlproofer_double)
        expect(htmlproofer_double).to receive(:run)
        HtmlprooferAction.run_with_checks(options)
      end
    end

    context 'when options have no checks' do
      let(:options) { { checks: [], log_level: ':debug' } }

      it 'aborts the execution' do
        expect { HtmlprooferAction.run_with_checks(options) }.to raise_error(SystemExit)
          .and output("No checks run\n").to_stderr
      end
    end
  end

  describe '#build_options' do
    it 'returns a hash with all the options' do
      allow(EnvOptions).to receive(:get_bool).and_return(true)
      allow(EnvOptions).to receive(:get_int).and_return(50, 30, 0, 120)
      allow(EnvOptions).to receive(:get_str).and_return('/site')
      allow(EnvOptions).to receive(:get_name_if).and_return('Favicon', 'Links', 'Images', 'Scripts', 'OpenGraph')
      allow(EnvOptions).to receive(:get_regex_list).and_return([], [], [])
      allow(EnvOptions).to receive(:get_swap_map).and_return({
                                                               Regexp.new('foo') => 'bar',
                                                               Regexp.new('baz') => 'qux'
                                                             })

      result = HtmlprooferAction.build_options

      expect(result).to be_a(Hash)
      expect(result[:allow_missing_href]).to eq(true)
      expect(result[:check_external_hash]).to eq(true)
      expect(result[:checks]).to eq(%w[Favicon Links Images Scripts OpenGraph])
      expect(result[:ignore_empty_alt]).to eq(true)
      expect(result[:ignore_missing_alt]).to eq(true)
      expect(result[:enforce_https]).to eq(true)
      expect(result[:hydra][:max_concurrency]).to eq(50)
      expect(result[:typhoeus][:connecttimeout]).to eq(30)
      expect(result[:typhoeus][:followlocation]).to eq(true)
      expect(result[:typhoeus][:headers]).to eq({ 'User-Agent' => CHROME_FROZEN_UA })
      expect(result[:typhoeus][:ssl_verifypeer]).to eq(true)
      expect(result[:typhoeus][:ssl_verifyhost]).to eq(0)
      expect(result[:typhoeus][:timeout]).to eq(120)
      expect(result[:typhoeus][:cookiefile]).to eq('.cookies')
      expect(result[:typhoeus][:cookiejar]).to eq('.cookies')
      expect(result[:ignore_urls]).to eq([])
      expect(result[:swap_urls]).to eq({
                                         Regexp.new('foo') => 'bar',
                                         Regexp.new('baz') => 'qux'
                                       })
    end
  end
end
# rubocop: enable Metrics/BlockLength
