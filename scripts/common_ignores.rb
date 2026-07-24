# frozen_string_literal: true

# Adds the action's commonly ignored URLs to user-provided ignores.
module CommonIgnores
  COMMON_URLS = ['https://fonts.gstatic.com'].freeze
  FALSE_VALUES = %w[0 f false n no].freeze

  def self.build(env = ENV)
    user_ignores = first_present(env['INPUT_IGNORE_URLS'], env['INPUT_URL_IGNORE'])
    return user_ignores unless enabled?(env['INPUT_IGNORE_COMMON'])

    (COMMON_URLS + [user_ignores]).reject(&:empty?).join("\n")
  end

  def self.enabled?(value)
    !FALSE_VALUES.include?(value.to_s.downcase)
  end

  def self.first_present(*values)
    values.find { |value| !value.nil? && !value.empty? }.to_s
  end

  private_class_method :enabled?, :first_present
end

puts CommonIgnores.build if $PROGRAM_NAME == __FILE__
