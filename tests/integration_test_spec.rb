# frozen_string_literal: true

require 'rspec'

# Require the file containing the functions you want to test
require_relative '../lib/htmlproofer_action'

describe HTMLProoferAction do
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

  # rubocop: disable Metrics/MethodLength
  def capture_output
    original_stderr = $stderr
    original_stdout = $stdout
    $stderr = captured_stderr = StringIO.new
    $stdout = captured_stdout = StringIO.new
    yield
    {
      stderr: captured_stderr.string,
      stdout: captured_stdout.string
    }
  ensure
    $stderr = original_stderr
    $stdout = original_stdout
  end
  # rubocop: enable Metrics/MethodLength

  def htmlproofer_exit_code(options)
    exit_code = 0
    begin
      HTMLProoferAction.run(options)
    rescue SystemExit => e
      exit_code = e.status
    end
    exit_code
  end

  it 'allows hash href when allow_hash_href option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'hash_href')
    ENV['INPUT_ALLOW_HASH_HREF'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'raises an error when hash href is not allowed and allow_hash_href option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'hash_href')
    ENV['INPUT_ALLOW_HASH_HREF'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options: #{options}"
    expect(output[:stderr]).to include('linking to internal hash #')
  end

  it 'allows missing href when allow_missing_href option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_href')
    ENV['INPUT_ALLOW_MISSING_HREF'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'raises an error when missing href is not allowed and allow_missing_href option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_href')
    ENV['INPUT_ALLOW_MISSING_HREF'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('tag is missing a reference')
  end

  it 'assumes the extension when assume_extension option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'assume_extension')
    ENV['INPUT_ASSUME_EXTENSION'] = '.html'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'raises an error when assume_extension option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'assume_extension')
    ENV['INPUT_ASSUME_EXTENSION'] = '.htm'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internally linking to link1, which does not exist')
  end

  it 'checks favicon when check_favicon option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'favicon')
    ENV['INPUT_CHECK_FAVICON'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('no favicon provided')
  end

  it 'skips favicon check when check_favicon option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'favicon')
    ENV['INPUT_CHECK_FAVICON'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks HTTP images when check_images option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'images')
    ENV['INPUT_CHECK_IMAGES'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('example.com/image.jpg failed:')
  end

  it 'skips HTTP image check when check_images option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'images')
    ENV['INPUT_CHECK_IMAGES'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks HTML when check_links option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'links')
    ENV['INPUT_CHECK_LINKS'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internally linking to not-a-link.html, which does not exist')
  end

  it 'skips HTML check when check_links option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'links')
    ENV['INPUT_CHECK_LINKS'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks scripts when check_scripts option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'scripts')
    ENV['INPUT_CHECK_SCRIPTS'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internal script reference script2.js does not exist')
  end

  it 'skips script check when check_scripts option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'scripts')
    ENV['INPUT_CHECK_SCRIPTS'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks OpenGraph when check_opengraph option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'opengraph')
    ENV['INPUT_CHECK_OPENGRAPH'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internal open graph image.jpg does not exist')
  end

  it 'skips OpenGraph check when check_opengraph option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'opengraph')
    ENV['INPUT_CHECK_OPENGRAPH'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks external hash when check_external_hash option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'external_hash')
    ENV['INPUT_CHECK_EXTERNAL_HASH'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include("but the hash 'not-a-section' does not (status code 200)")
  end

  it 'skips external hash check when check_external_hash option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'external_hash')
    ENV['INPUT_CHECK_EXTERNAL_HASH'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks internal hash when check_internal_hash option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'internal_hash')
    ENV['INPUT_CHECK_INTERNAL_HASH'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include("the file exists, but the hash 'section2' does not")
  end

  it 'skips internal hash check when check_internal_hash option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'internal_hash')
    ENV['INPUT_CHECK_INTERNAL_HASH'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks Subresource Integrity (SRI) when check_sri option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'sri')
    ENV['INPUT_CHECK_SRI'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('CORS not provided for external resource')
  end

  it 'skips Subresource Integrity (SRI) check when check_sri option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'sri')
    ENV['INPUT_CHECK_SRI'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks directory index file when directory_index_file option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'directory_index')
    ENV['INPUT_DIRECTORY_INDEX_FILE'] = 'home.html'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks directory index file when directory_index_file option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'directory_index')
    ENV['INPUT_DIRECTORY_INDEX_FILE'] = ''
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internally linking to directory/, which does not exist')
  end

  it 'skips external link check when disable_external option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'disable_external')
    ENV['INPUT_DISABLE_EXTERNAL'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks external link when disable_external option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'disable_external')
    ENV['INPUT_DISABLE_EXTERNAL'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('www.althack.dev/not-a-link.html failed (status code 404)')
  end

  it 'checks HTTPS links when enforce_https option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'enforce_https')
    ENV['INPUT_ENFORCE_HTTPS'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('is not an HTTPS link')
  end

  it 'skips HTTPS link check when enforce_https option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'enforce_https')
    ENV['INPUT_ENFORCE_HTTPS'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(output[:stderr]).to be_empty
    expect(exit_code).to eq(0), "With options #{options}"
  end

  it 'checks specified file extensions when extensions option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'extensions')
    ENV['INPUT_EXTENSIONS'] = '.foo,.htm'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internally linking to not-a-link.html, which does not exist')
  end

  it 'checks specified file extensions when no extensions option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'extensions')
    ENV['INPUT_EXTENSIONS'] = ''
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'catches with ignore_empty_alt option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('has an alt attribute, but no content')
  end

  it 'runs with ignore_empty_alt option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'catches with ignore_empty_alt option is false and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('does not have an alt attribute')
  end

  it 'catches with empty_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('does not have an alt attribute')
  end

  it 'ignores ignore.html when ignore_files set to ignore.html' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_files')
    ENV['INPUT_IGNORE_FILES'] = '/ignore.html/'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'returns error on ignore.html when ignore_files is none' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_files')
    ENV['INPUT_IGNORE_FILES'] = ''
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('does not have an alt attribute')
  end

  it 'skips empty mailto link check when ignore_empty_mailto option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_mailto')
    ENV['INPUT_IGNORE_EMPTY_MAILTO'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'checks empty mailto link when ignore_empty_mailto option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_mailto')
    ENV['INPUT_IGNORE_EMPTY_MAILTO'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('mailto: contains no email address')
  end

  it 'runs with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'true'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'catches with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'false'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('does not have an alt attribute')
  end

  it 'ignores specified status codes when ignore_status_codes option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'status_codes')
    ENV['INPUT_IGNORE_STATUS_CODES'] = '404,500'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'catches status codes when ignore_status_codes option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'status_codes')
    ENV['INPUT_IGNORE_STATUS_CODES'] = ''
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('failed (status code 404)')
  end

  it 'skips specified URLs when ignore_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_urls')
    ENV['INPUT_IGNORE_URLS'] = 'https://example.com,http://example.org'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'catches when ignore_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'ignore_urls')
    ENV['INPUT_IGNORE_URLS'] = ''
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('is not an HTTPS link')
  end

  it 'swaps URLs with their replacements when swap_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'swap_urls')
    ENV['INPUT_SWAP_URLS'] = '/test:/test.html,/another-test:/test.html'
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(0), "With options #{options}"
    expect(output[:stderr]).to be_empty
  end

  it 'catches if swaps URLs with their replacements when swap_urls option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'swap_urls')
    ENV['INPUT_SWAP_URLS'] = ''
    options = HTMLProoferAction.build_options
    exit_code = nil
    output = capture_output do
      exit_code = htmlproofer_exit_code(options)
    end

    expect(exit_code).to eq(1), "With options #{options}"
    expect(output[:stderr]).to include('internally linking to /another-test, which does not exist')
  end
end
