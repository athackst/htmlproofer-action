# frozen_string_literal: true

# Builds the URL substitutions derived from the action's site inputs.
module SiteUrlSwaps
  FALSE_VALUES = %w[0 f false n no].freeze

  def self.build(env = ENV)
    user_swaps = first_present(env['INPUT_SWAP_URLS'], env['INPUT_URL_SWAP'])
    return user_swaps unless enabled?(env['INPUT_SITE_URL_SWAP'])

    host = env.fetch('INPUT_HOST', '').chomp('/')
    return user_swaps if host.empty?

    generated_swaps = swaps_for(host, normalize_base_path(env.fetch('INPUT_BASE_PATH', '')))
    (generated_swaps + [user_swaps]).reject(&:empty?).join("\n")
  end

  def self.enabled?(value)
    !FALSE_VALUES.include?(value.to_s.downcase)
  end

  def self.first_present(*values)
    values.find { |value| !value.nil? && !value.empty? }.to_s
  end

  def self.swaps_for(host, base_path)
    host_pattern = if host.match?(%r{^https?://})
                     Regexp.escape(host)
                   else
                     "https?://#{Regexp.escape(host)}"
                   end

    patterns = if base_path.empty?
                 ["^#{host_pattern}(?=/|$)"]
               else
                 escaped_base = Regexp.escape(base_path)
                 ["^#{escaped_base}(?=/|$)", "^#{host_pattern}#{escaped_base}(?=/|$)"]
               end

    patterns.map { |pattern| "#{pattern.gsub(':', '\\:')}:" }
  end

  def self.normalize_base_path(base_path)
    return '' if base_path.empty? || base_path == '/'

    base_path = "/#{base_path}" unless base_path.start_with?('/')
    base_path.chomp('/')
  end

  private_class_method :enabled?, :first_present, :swaps_for, :normalize_base_path
end

puts SiteUrlSwaps.build if $PROGRAM_NAME == __FILE__
