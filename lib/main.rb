# frozen_string_literal: true

require_relative 'htmlproofer_action'

options = HtmlprooferAction.build_options
puts options
HtmlprooferAction.run_with_checks(options)