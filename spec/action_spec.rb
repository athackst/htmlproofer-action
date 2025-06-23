# frozen_string_literal: true

require 'yaml'

RSpec.describe 'action.yml input-to-env mapping' do # rubocop:disable RSpec/DescribeClass
  let(:action) { YAML.load_file('action.yml') }

  # All active (non-deprecated) inputs
  let(:active_inputs) do
    action['inputs'].reject { |_, config| config.key?('deprecationMessage') }.keys
  end

  let(:expected_env_map) do
    active_inputs.to_h { |input| ["INPUT_#{input.upcase}", input] }
  end

  let(:actual_env_map) do
    env = action['runs']['steps']
          .find { |step| step['name'].match?(/Run Htmlproofer/i) }
          .fetch('env', {})

    env.select { |key, _| key.start_with?('INPUT_') }
  end

  it 'has an INPUT_ env var for each active input, with correct casing' do
    expected_keys = expected_env_map.keys
    actual_keys = actual_env_map.keys

    missing_keys = expected_keys - actual_keys
    expect(missing_keys).to be_empty, "Missing env mappings: #{missing_keys.join(', ')}"
  end

  it 'has correctly cased input references in env values' do # rubocop:disable RSpec/ExampleLength
    mismatched = []

    expected_env_map.each do |env_key, input_key|
      next unless actual_env_map.key?(env_key)

      expected_value = "${{ inputs.#{input_key} }}"
      actual_value = actual_env_map[env_key]

      mismatched << "#{env_key}=#{actual_value.inspect}, expected #{expected_value.inspect}" if actual_value != expected_value
    end

    expect(mismatched).to be_empty, "Mismatched env values:\n#{mismatched.join("\n")}"
  end

  it 'does not include unexpected env mappings for non-inputs' do
    # Valid env var names from non-deprecated inputs
    expected_env_keys = active_inputs.map { |input| "INPUT_#{input.upcase}" }

    # All actual INPUT_* keys from the env section
    actual_env_keys = actual_env_map.keys.select { |key| key.start_with?('INPUT_') }

    extra_keys = actual_env_keys - expected_env_keys

    expect(extra_keys).to be_empty, "Unexpected env mappings with no matching input: #{extra_keys.join(', ')}"
  end
end
