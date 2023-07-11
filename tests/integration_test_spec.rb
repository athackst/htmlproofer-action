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

  def htmlproofer_exit_code(options)
    exit_code = 0
    begin
      HtmlprooferAction.run(options)
    rescue SystemExit => e
      exit_code = e.status
    end
    exit_code
  end

  it 'catches with empty_alt_ignore option set to false' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_alt')
    # Set the EMPTY_ALT_IGNORE environment variable to true
    ENV['INPUT_EMPTY_ALT_IGNORE'] = 'false'

    # Execute the code under test
    options = HtmlprooferAction.build_options
    expect(htmlproofer_exit_code(options)).to eq(1)
  end

  it 'runs with empty_alt_ignore option set to true' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'empty_alt')
    # Set the EMPTY_ALT_IGNORE environment variable to true
    ENV['INPUT_EMPTY_ALT_IGNORE'] = 'true'

    # Execute the code under test
    options = HtmlprooferAction.build_options
    expect(htmlproofer_exit_code(options)).to eq(0)
  end

  it 'catches with empty_alt_ignore option is true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    # Set the EMPTY_ALT_IGNORE environment variable to true
    ENV['INPUT_EMPTY_ALT_IGNORE'] = 'false'

    # Execute the code under test
    options = HtmlprooferAction.build_options
    expect(htmlproofer_exit_code(options)).to eq(1)
  end

  it 'catches with empty_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')
    # Set the EMPTY_ALT_IGNORE environment variable to true
    ENV['INPUT_EMPTY_ALT_IGNORE'] = 'true'

    # Execute the code under test
    options = HtmlprooferAction.build_options
    expect(htmlproofer_exit_code(options)).to eq(1)
  end

  it 'runs with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')

    # Set the EMPTY_ALT_IGNORE environment variable to true
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'true'

    # Execute the code under test
    options = HtmlprooferAction.build_options
    expect(htmlproofer_exit_code(options)).to eq(0)
  end

  it 'catches with missing_alt_ignore option set to true and alt is missing' do
    ENV['INPUT_DIRECTORY'] = File.join(@test_directory, 'missing_alt')

    # Set the EMPTY_ALT_IGNORE environment variable to true
    ENV['INPUT_MISSING_ALT_IGNORE'] = 'false'

    # Execute the code under test
    options = HtmlprooferAction.build_options
    expect(htmlproofer_exit_code(options)).to eq(1)
  end
end
# rubocop: enable Metrics/BlockLength
