# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength

require 'spec_helper'
require 'open3'
require 'tmpdir'
require 'fileutils'

require 'html_proofer_action'

RSpec.describe HTMLProoferAction do
  subject(:action) { described_class }

  let(:fixtures_path) { File.join(__dir__, 'fixtures') }
  let(:env_backup) { ENV.to_h.dup }

  around do |example|
    original_env = ENV.to_h.dup
    example.run
    ENV.replace(original_env)
  end

  def htmlproofer_status_output # rubocop:disable Metrics/MethodLength
    stdout_io = StringIO.new
    stderr_io = StringIO.new
    status = 0

    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = stdout_io
    $stderr = stderr_io

    begin
      HTMLProoferAction.run
    rescue SystemExit => e
      status = e.status
    end

    {
      status: status,
      stdout: stdout_io.string,
      stderr: stderr_io.string
    }
  ensure
    $stdout = original_stdout
    $stderr = original_stderr
  end

  it 'allows hash href when allow_hash_href option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'hash_href')
    ENV['INPUT_ALLOW_HASH_HREF'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'raises an error when hash href is not allowed and allow_hash_href option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'hash_href')
    ENV['INPUT_ALLOW_HASH_HREF'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('linking to internal hash #, which points to nowhere'),
      stdout: a_string_including('')
    )
  end

  it 'allows missing href when allow_missing_href option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'missing_href')
    ENV['INPUT_ALLOW_MISSING_HREF'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'raises an error when missing href is not allowed and allow_missing_href option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'missing_href')
    ENV['INPUT_ALLOW_MISSING_HREF'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('tag is missing a reference'),
      stdout: a_string_including('')
    )
  end

  it 'assumes the extension when assume_extension option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'assume_extension')
    ENV['INPUT_ASSUME_EXTENSION'] = '.html'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'raises an error when assume_extension option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'assume_extension')
    ENV['INPUT_ASSUME_EXTENSION'] = '.htm'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internally linking to link1, which does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'checks favicon when check_favicon option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'favicon')
    ENV['INPUT_CHECK_FAVICON'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('no favicon provided'),
      stdout: a_string_including('')
    )
  end

  it 'skips favicon check when check_favicon option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'favicon')
    ENV['INPUT_CHECK_FAVICON'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks HTTP images when check_images option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'images')
    ENV['INPUT_CHECK_IMAGES'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('example.com/image.jpg failed:'),
      stdout: a_string_including('')
    )
  end

  it 'skips HTTP image check when check_images option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'images')
    ENV['INPUT_CHECK_IMAGES'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks HTML when check_links option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'links')
    ENV['INPUT_CHECK_LINKS'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internally linking to not-a-link.html, which does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'skips HTML check when check_links option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'links')
    ENV['INPUT_CHECK_LINKS'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks scripts when check_scripts option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'scripts')
    ENV['INPUT_CHECK_SCRIPTS'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internal script reference script2.js does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'skips script check when check_scripts option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'scripts')
    ENV['INPUT_CHECK_SCRIPTS'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks OpenGraph when check_opengraph option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'opengraph')
    ENV['INPUT_CHECK_OPENGRAPH'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internal open graph image.jpg does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'skips OpenGraph check when check_opengraph option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'opengraph')
    ENV['INPUT_CHECK_OPENGRAPH'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks external hash when check_external_hash option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'external_hash')
    ENV['INPUT_CHECK_EXTERNAL_HASH'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including("but the hash 'not-a-section' does not (status code 200)"),
      stdout: a_string_including('')
    )
  end

  it 'skips external hash check when check_external_hash option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'external_hash')
    ENV['INPUT_CHECK_EXTERNAL_HASH'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks internal hash when check_internal_hash option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'internal_hash')
    ENV['INPUT_CHECK_INTERNAL_HASH'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including("the file exists, but the hash 'section2' does not"),
      stdout: a_string_including('')
    )
  end

  it 'skips internal hash check when check_internal_hash option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'internal_hash')
    ENV['INPUT_CHECK_INTERNAL_HASH'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks Subresource Integrity (SRI) when check_sri option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'sri')
    ENV['INPUT_CHECK_SRI'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('CORS not provided for external resource'),
      stdout: a_string_including('')
    )
  end

  it 'skips Subresource Integrity (SRI) check when check_sri option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'sri')
    ENV['INPUT_CHECK_SRI'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks directory index file when directory_index_file option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'directory_index')
    ENV['INPUT_DIRECTORY_INDEX_FILE'] = 'home.html'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks directory index file when directory_index_file option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'directory_index')
    ENV['INPUT_DIRECTORY_INDEX_FILE'] = ''
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internally linking to directory/, which does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'skips external link check when disable_external option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'disable_external')
    ENV['INPUT_DISABLE_EXTERNAL'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks external link when disable_external option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'disable_external')
    ENV['INPUT_DISABLE_EXTERNAL'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('www.althack.dev/not-a-link.html failed (status code 404)'),
      stdout: a_string_including('')
    )
  end

  it 'checks HTTPS links when enforce_https option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'enforce_https')
    ENV['INPUT_ENFORCE_HTTPS'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('is not an HTTPS link'),
      stdout: a_string_including('')
    )
  end

  it 'skips HTTPS link check when enforce_https option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'enforce_https')
    ENV['INPUT_ENFORCE_HTTPS'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks specified file extensions when extensions option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'extensions')
    ENV['INPUT_EXTENSIONS'] = '.foo,.htm'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internally linking to not-a-link.html, which does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'checks specified file extensions when no extensions option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'extensions')
    ENV['INPUT_EXTENSIONS'] = ''
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'catches with ignore_empty_alt option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'empty_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('has an alt attribute, but no content'),
      stdout: a_string_including('')
    )
  end

  it 'runs with ignore_empty_alt option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'empty_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'catches with ignore_empty_alt option is false and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'missing_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('does not have an alt attribute'),
      stdout: a_string_including('')
    )
  end

  it 'catches with empty_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'missing_alt')
    ENV['INPUT_IGNORE_EMPTY_ALT'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('does not have an alt attribute'),
      stdout: a_string_including('')
    )
  end

  it 'ignores ignore.html when ignore_files set to ignore.html' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'ignore_files')
    ENV['INPUT_IGNORE_FILES'] = '/ignore.html/'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'returns error on ignore.html when ignore_files is none' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'ignore_files')
    ENV['INPUT_IGNORE_FILES'] = ''
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('does not have an alt attribute'),
      stdout: a_string_including('')
    )
  end

  it 'skips empty mailto link check when ignore_empty_mailto option is set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'empty_mailto')
    ENV['INPUT_IGNORE_EMPTY_MAILTO'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'checks empty mailto link when ignore_empty_mailto option is set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'empty_mailto')
    ENV['INPUT_IGNORE_EMPTY_MAILTO'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('mailto: contains no email address'),
      stdout: a_string_including('')
    )
  end

  it 'runs with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'missing_alt')
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'true'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'catches with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'missing_alt')
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'false'
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('does not have an alt attribute'),
      stdout: a_string_including('')
    )
  end

  it 'ignores specified status codes when ignore_status_codes option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'status_codes')
    ENV['INPUT_IGNORE_STATUS_CODES'] = '404,500'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'catches status codes when ignore_status_codes option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'status_codes')
    ENV['INPUT_IGNORE_STATUS_CODES'] = ''
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('failed (status code 404)'),
      stdout: a_string_including('')
    )
  end

  it 'skips specified URLs when ignore_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'ignore_urls')
    ENV['INPUT_IGNORE_URLS'] = 'https://example.com,http://example.org'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'catches when ignore_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'ignore_urls')
    ENV['INPUT_IGNORE_URLS'] = ''
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('is not an HTTPS link'),
      stdout: a_string_including('')
    )
  end

  it 'swaps URLs with their replacements when swap_urls option is set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'swap_urls')
    ENV['INPUT_SWAP_URLS'] = '/test:/test.html,/another-test:/test.html'
    expect(htmlproofer_status_output).to match(
      status: 0,
      stderr: '',
      stdout: a_string_including('finished successfully')
    )
  end

  it 'catches if swaps URLs with their replacements when swap_urls option is not set' do
    ENV['INPUT_DIRECTORY'] = File.join(fixtures_path, 'swap_urls')
    ENV['INPUT_SWAP_URLS'] = ''
    expect(htmlproofer_status_output).to match(
      status: 1,
      stderr: a_string_including('internally linking to /another-test, which does not exist'),
      stdout: a_string_including('')
    )
  end

  it 'ignores links to matching urls for newly added files when IGNORE_NEW_FILES is true' do
    Dir.mktmpdir do |temp_dir|
      # Set up a minimal test site
      source_dir = File.join(fixtures_path, 'minimal_site')
      FileUtils.cp_r("#{source_dir}/.", temp_dir)

      Dir.chdir(temp_dir) do
        # Initialize a git repo with a base commit
        `git init`
        `git config user.email "test@example.com"`
        `git config user.name "Test"`
        `git add .`
        `git commit -m "Initial commit"`
        `git branch -M main`

        # Add a new file that should trigger a warning normally
        File.write('broken.html', '<a href="https://github.com/athackst/htmlproofer-action/broken.html">Invalid link</a>')
        # Add to a new commit
        `git checkout -q -b new`
        `git add .`
        `git commit -m "New commit"`

        # Set environment
        ENV['INPUT_DIRECTORY'] = temp_dir
        ENV['INPUT_IGNORE_NEW_FILES'] = 'true'
        ENV['BASE_BRANCH'] = 'main'

        expect(htmlproofer_status_output).to match(
          status: 0,
          stderr: '',
          stdout: a_string_including('.*broken')
        )
      end
    end
  end

  it 'raises an error on links to matching urls for newly added files when IGNORE_NEW_FILES is false' do
    Dir.mktmpdir do |temp_dir|
      # Set up a minimal test site
      source_dir = File.join(fixtures_path, 'minimal_site')
      FileUtils.cp_r("#{source_dir}/.", temp_dir)

      Dir.chdir(temp_dir) do
        # Initialize a git repo with a base commit
        `git init`
        `git config user.email "test@example.com"`
        `git config user.name "Test"`
        `git add .`
        `git commit -m "Initial commit"`
        `git branch -M main`

        # Add a new file that should trigger a warning normally
        File.write('broken.html', '<a href="https://github.com/athackst/htmlproofer-action/broken.html">Invalid link</a>')
        # Add to a new commit
        `git checkout -q -b new`
        `git add .`
        `git commit -m "New commit"`

        ENV['INPUT_DIRECTORY'] = temp_dir
        ENV['INPUT_IGNORE_NEW_FILES'] = 'false'
        ENV['BASE_BRANCH'] = 'main'

        expect(htmlproofer_status_output).to match(
          status: 1,
          stderr: a_string_including('External link https://github.com/athackst/htmlproofer-action/broken.html failed (status code 404)'),
          stdout: a_kind_of(String)
        )
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
