# frozen_string_literal: true

require 'spec_helper'
require 'html_proofer_action/runner'
require 'html_proofer_action/env_options'

EnvOptions = HTMLProoferAction::EnvOptions

RSpec.describe HTMLProoferAction::Runner do
  subject(:runner) { described_class }

  describe '.run' do
    context 'when options are provided' do
      let(:options) { { checks: ['Links'], log_level: ':debug' } }
      let(:directory) { EnvOptions.get_str('DIRECTORY', '/site') }
      let(:htmlproofer_double) { instance_double(HTMLProofer::Runner, run: nil) }

      before do
        allow(HTMLProofer).to receive(:check_directory).with(directory, options).and_return(htmlproofer_double)
      end

      it 'runs HTMLProofer with the provided options' do
        runner.run(options)
        expect(htmlproofer_double).to have_received(:run)
      end
    end

    context 'when options have no checks' do
      let(:options) { { checks: [], log_level: ':debug' } }

      it 'aborts the execution' do
        expect { described_class.run(options) }.to raise_error(SystemExit)
          .and output("No checks run\n").to_stderr
      end
    end
  end

  describe '.build_ignore_urls' do
    before do
      allow(EnvOptions).to receive_messages(
        get_only_regex_list: [/skip/],
        get_regex_list: [/ignore-this/]
      )
    end

    it 'combines ignore regex lists' do
      result = described_class.build_ignore_urls
      expect(result).to eq([/skip/, /ignore-this/])
    end
  end

  describe '.build_swap_urls' do
    let(:captured_defaults) { {} }

    before do
      allow(EnvOptions).to receive(:get_str).with('HOST').and_return('http://example.com')
      allow(EnvOptions).to receive(:get_str).with('BASE_PATH').and_return('/blog')
      allow(EnvOptions).to receive(:append_swap_map).with(%w[SWAP_URLS URL_SWAP], anything)
                                                    .and_wrap_original do |_method, _keys, defaults|
        captured_defaults.merge!(defaults)
        {}
      end

      described_class.build_swap_urls
    end

    it 'calls append_swap_map with default_swap keys as regex' do
      expect(captured_defaults.keys).to all(be_a(Regexp))
    end

    it 'calls append_swap_map with values as empty strings' do
      expect(captured_defaults.values).to all(eq(''))
    end
  end

  describe '.build_options' do
    before do
      allow(EnvOptions).to receive(:get_bool).with('ALLOW_HASH_HREF', true).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('ALLOW_MISSING_HREF', false).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('CHECK_EXTERNAL_HASH', true).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('CHECK_INTERNAL_HASH', true).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('CHECK_SRI', false).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('DISABLE_EXTERNAL', false).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('ENFORCE_HTTPS', true).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with(%w[IGNORE_EMPTY_ALT EMPTY_ALT_IGNORE], true).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('IGNORE_EMPTY_MAILTO', false).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with(%w[IGNORE_MISSING_ALT MISSING_ALT_IGNORE], false).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('FOLLOWLOCATION', true).and_return(true)
      allow(EnvOptions).to receive(:get_bool).with('SSL_VERIFYPEER', false).and_return(true)

      allow(EnvOptions).to receive(:get_int).with('MAX_CONCURRENCY', 50).and_return(50)
      allow(EnvOptions).to receive(:get_int).with('CONNECT_TIMEOUT', 30).and_return(30)
      allow(EnvOptions).to receive(:get_int).with('SSL_VERIFYHOST', 0).and_return(0)
      allow(EnvOptions).to receive(:get_int).with('TIMEOUT', 120).and_return(120)

      allow(EnvOptions).to receive(:get_str).with('DIRECTORY', '/site').and_return('/site')
      allow(EnvOptions).to receive(:get_str).with('ASSUME_EXTENSION', '.html').and_return('.html')
      allow(EnvOptions).to receive(:get_str).with('DIRECTORY_INDEX_FILE', 'index.html').and_return('index.html')
      allow(EnvOptions).to receive(:get_str).with('BASE_PATH').and_return('')
      allow(EnvOptions).to receive(:get_str).with('HOST').and_return('')

      allow(EnvOptions).to receive(:return_value_if).with('CHECK_FAVICON', false, 'Favicon').and_return('Favicon')
      allow(EnvOptions).to receive(:return_value_if).with(%w[CHECK_LINKS CHECK_HTML], true, 'Links').and_return('Links')
      allow(EnvOptions).to receive(:return_value_if).with(%w[CHECK_IMAGES CHECK_IMG_HTTP], true, 'Images').and_return('Images')
      allow(EnvOptions).to receive(:return_value_if).with('CHECK_SCRIPTS', true, 'Scripts').and_return('Scripts')
      allow(EnvOptions).to receive(:return_value_if).with('CHECK_OPENGRAPH', false, 'OpenGraph').and_return('OpenGraph')

      allow(EnvOptions).to receive(:get_regex_list).with('IGNORE_FILES', []).and_return(['404.html', /foo/])
      allow(EnvOptions).to receive(:get_regex_list).with(%w[IGNORE_URLS URL_IGNORE], []).and_return([])
      allow(EnvOptions).to receive(:get_only_regex_list).with('URL_IGNORE_RE', []).and_return([])
      allow(EnvOptions).to receive(:get_int_list).with('IGNORE_STATUS_CODES', []).and_return([])
      allow(EnvOptions).to receive(:append_swap_map).with(%w[SWAP_URLS URL_SWAP], anything).and_return({
                                                                                                         /foo/ => 'bar',
                                                                                                         /baz/ => 'qux'
                                                                                                       })
    end

    let(:result) { described_class.build_options }

    it 'includes allow_missing_href as true' do
      expect(result[:allow_missing_href]).to be(true)
    end

    it 'includes check_external_hash as true' do
      expect(result[:check_external_hash]).to be(true)
    end

    it 'includes ignore_empty_alt as true' do
      expect(result[:ignore_empty_alt]).to be(true)
    end

    it 'includes ignore_missing_alt as true' do
      expect(result[:ignore_missing_alt]).to be(true)
    end

    it 'includes enforce_https as true' do
      expect(result[:enforce_https]).to be(true)
    end

    it 'includes expected checks' do
      expect(result[:checks]).to eq(%w[Favicon Links Images Scripts OpenGraph])
    end

    it 'includes ignore_files' do
      expect(result[:ignore_files]).to eq(['404.html', /foo/])
    end

    it 'includes ignore_urls' do
      expect(result[:ignore_urls]).to eq([])
    end

    it 'includes swap_urls' do
      expect(result[:swap_urls]).to eq({ /foo/ => 'bar', /baz/ => 'qux' })
    end

    it 'includes hydra max_concurrency' do
      expect(result[:hydra][:max_concurrency]).to eq(50)
    end

    it 'includes typhoeus connecttimeout' do
      expect(result[:typhoeus][:connecttimeout]).to eq(30)
    end

    it 'includes typhoeus followlocation' do
      expect(result[:typhoeus][:followlocation]).to be(true)
    end

    it 'includes typhoeus ssl_verifypeer' do
      expect(result[:typhoeus][:ssl_verifypeer]).to be(true)
    end

    it 'includes typhoeus ssl_verifyhost' do
      expect(result[:typhoeus][:ssl_verifyhost]).to eq(0)
    end

    it 'includes typhoeus timeout' do
      expect(result[:typhoeus][:timeout]).to eq(120)
    end

    it 'includes typhoeus cookiefile' do
      expect(result[:typhoeus][:cookiefile]).to eq('.cookies')
    end

    it 'includes typhoeus cookiejar' do
      expect(result[:typhoeus][:cookiejar]).to eq('.cookies')
    end
  end
end
