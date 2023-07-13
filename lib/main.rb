# frozen_string_literal: true

require_relative 'htmlproofer_action'

options = HTMLProoferAction.build_options
puts options
HTMLProoferAction.run_with_checks(options)
