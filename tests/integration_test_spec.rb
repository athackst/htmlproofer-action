# frozen_string_literal: true

require 'rspec'

# Require the file containing the functions you want to test
require_relative '../lib/htmlproofer_action'
# rubocop: disable Metrics/BlockLength
describe HtmlprooferAction do
  before(:each) do
    # Set up any necessary environment for the integration tests
    # This could include creating test files, configuring dependencies, etc.
    @test_directory = 'tests/integration'
  end

  after(:each) do
    # Clean up any resources after each test case
  end

  around(:each) do |example|
    original_env = ENV.to_h.dup # Make a copy of the original ENV variables

    example.run

    ENV.replace(original_env) # Reset the ENV variables to their original state
  end

  def htmlproofer_exit_code(options)
    exit_code = 0
    begin
      HtmlprooferAction.run(options)
    rescue SystemExit => e
      exit_code = e.status
    end
    exit_code
  end

  it 'allows hash href when allow_hash_href option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'hash_href')
    ENV['INPUT_ALLOW_HASH_HREF'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'raises an error when hash href is not allowed and allow_hash_href option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'hash_href')
    ENV['INPUT_ALLOW_HASH_HREF'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'allows missing href when allow_missing_href option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_href')
    ENV['INPUT_ALLOW_MISSING_HREF'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'raises an error when missing href is not allowed and allow_missing_href option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_href')
    ENV['INPUT_ALLOW_MISSING_HREF'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'assumes the extension when assume_extension option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'assume_extension')
    ENV['INPUT_ASSUME_EXTENSION'] = '.html'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'raises an error when assume_extension option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'assume_extension')
    ENV['INPUT_ASSUME_EXTENSION'] = '.htm'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'checks favicon when check_favicon option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'favicon')
    ENV['INPUT_CHECK_FAVICON'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips favicon check when check_favicon option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'favicon')
    ENV['INPUT_CHECK_FAVICON'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks HTTP images when check_images option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'images')
    ENV['INPUT_CHECK_IMAGES'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips HTTP image check when check_images option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'images')
    ENV['INPUT_CHECK_IMAGES'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks HTML when check_links option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'links')
    ENV['INPUT_CHECK_LINKS'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips HTML check when check_links option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'links')
    ENV['INPUT_CHECK_LINKS'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks scripts when check_scripts option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'scripts')
    ENV['INPUT_CHECK_SCRIPTS'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips script check when check_scripts option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'scripts')
    ENV['INPUT_CHECK_SCRIPTS'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks OpenGraph when check_opengraph option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'opengraph')
    ENV['INPUT_CHECK_OPENGRAPH'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips OpenGraph check when check_opengraph option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'opengraph')
    ENV['INPUT_CHECK_OPENGRAPH'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks external hash when check_external_hash option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'external_hash')
    ENV['INPUT_CHECK_EXTERNAL_HASH'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips external hash check when check_external_hash option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'external_hash')
    ENV['INPUT_CHECK_EXTERNAL_HASH'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks internal hash when check_internal_hash option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'internal_hash')
    ENV['INPUT_CHECK_INTERNAL_HASH'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips internal hash check when check_internal_hash option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'internal_hash')
    ENV['INPUT_CHECK_INTERNAL_HASH'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks Subresource Integrity (SRI) when check_sri option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'sri')
    ENV['INPUT_CHECK_SRI'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips Subresource Integrity (SRI) check when check_sri option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'sri')
    ENV['INPUT_CHECK_SRI'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks directory index file when directory_index_file option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'directory_index')
    ENV['INPUT_DIRECTORY_INDEX_FILE'] = 'home.html'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks directory index file when directory_index_file option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'directory_index')
    ENV['INPUT_DIRECTORY_INDEX_FILE'] = ''
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips external link check when disable_external option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'disable_external')
    ENV['INPUT_DISABLE_EXTERNAL'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks external link when disable_external option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'disable_external')
    ENV['INPUT_DISABLE_EXTERNAL'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'checks HTTPS links when enforce_https option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'enforce_https')
    ENV['INPUT_ENFORCE_HTTPS'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips HTTPS link check when enforce_https option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'enforce_https')
    ENV['INPUT_ENFORCE_HTTPS'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks specified file extensions when extensions option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'extensions')
    ENV['INPUT_EXTENSIONS'] = '.foo,.htm'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'checks specified file extensions when no extensions option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'extensions')
    ENV['INPUT_EXTENSIONS'] = ''
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'catches with ignore_empty_alt option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'runs with ignore_empty_alt option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'catches with ignore_empty_alt option is false and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'catches with empty_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'ignores ignore.html when ignore_files set to ignore.html' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_files')
    ENV['INPUT_IGNORE_FILES'] = '/ignore.html/'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'returns error on ignore.html when ignore_files is none' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_files')
    ENV['INPUT_IGNORE_FILES'] = ''
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips empty mailto link check when ignore_empty_mailto option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_mailto')
    ENV['INPUT_IGNORE_EMPTY_MAILTO'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'checks empty mailto link when ignore_empty_mailto option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_mailto')
    ENV['INPUT_IGNORE_EMPTY_MAILTO'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'runs with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'true'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'catches with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'false'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'ignores specified status codes when ignore_status_codes option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'status_codes')
    ENV['INPUT_IGNORE_STATUS_CODES'] = '404,500'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'catches status codes when ignore_status_codes option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'status_codes')
    ENV['INPUT_IGNORE_STATUS_CODES'] = ''
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'skips specified URLs when ignore_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_urls')
    ENV['INPUT_IGNORE_URLS'] = 'https://example.com,http://example.org'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'catches when ignore_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_urls')
    ENV['INPUT_IGNORE_URLS'] = ''
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end

  it 'swaps URLs with their replacements when swap_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'swap_urls')
    ENV['INPUT_SWAP_URLS'] = '/test:/test.html,/another-test:/test.html'
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(0), "With options #{options}"
  end

  it 'catches if swaps URLs with their replacements when swap_urls option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'swap_urls')
    ENV['INPUT_SWAP_URLS'] = ''
    options = HtmlprooferAction.build_options

    expect(htmlproofer_exit_code(options)).to eq(1), "With options #{options}"
  end
end
# rubocop: enable Metrics/BlockLength
