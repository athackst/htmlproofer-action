require "html-proofer"
require "json"
require "uri"

CHROME_FROZEN_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.0.0 Safari/537.36"

def get_bool(name, fallback)
  s = ENV["INPUT_#{name}"]
  return fallback if s.nil? or s == ""
  case s
  when /^t/i # matches "t", "true", "True"
    true
  when /^y/i # matches "y", "yes", "Yes"
    true
  when "1"
    true
  else
    false
  end
end

def get_name(value, name)
  if value
    return name = "\n"
  end
  return ""
end

def get_int(name, fallback)
  s = ENV["INPUT_#{name}"]
  return fallback if s.nil? or s == ""
  s.to_i
end

def get_str(name)
  s = ENV["INPUT_#{name}"]
  s.nil? ? "" : s
end

def get_list(name)
  get_str(name).split("\n").concat
end

url_ignore_re = get_str("URL_IGNORE_RE").split("\n").map { |s| Regexp.new s }
url_ignore = get_str("URL_IGNORE").split("\n").concat url_ignore_re

options = {
  :check_external_hash => get_bool("CHECK_EXTERNAL_HASH", true),
  :checks => get_list(get_name(get_bool("CHECK_FAVICON", true), "Favicon") + 
                      get_name(get_bool("CHECK_HTML", true), "Links") + 
                      get_name(get_bool("CHECK_IMG_HTTP", true), "Images") + 
                      get_name(get_bool("CHECK_SCRIPTS", true), "Scripts") +
                      get_name(get_bool("CHECK_OPENGRAPH", true), "OpenGraph")),
  :ignore_empty_alt => get_bool("EMPTY_ALT_IGNORE", false),
  :enforce_https => get_bool("ENFORCE_HTTPS", true),
  :hydra => {
    :max_concurrency => get_int("MAX_CONCURRENCY", 50),
  },
  :parallel => { :in_processes => get_int("MAX_PARALLEL", 3) },
  :typhoeus => {
    :connecttimeout => get_int("CONNECT_TIMEOUT", 30),
    :followlocation => true,
    :headers => {
      "User-Agent" => CHROME_FROZEN_UA,
    },
    :ssl_verifypeer => get_bool("SSL_VERIFYPEER", false),
    :ssl_verifyhost => get_int("SSL_VERIFYHOST", 0),
    :timeout => get_int("TIMEOUT", 120),
  },
  :ignore_urls => url_ignore,
}

options[:url_swap] = {}
get_list("URL_SWAP").each do |s|
  splt = s.split(/(?<!\\):/, 2)

  re = splt[0].gsub(/\\:/, ":")
  string = splt[1].gsub(/\\:/, ":")
  options[:url_swap][Regexp.new(re)] = string
end

puts options

HTMLProofer.check_directory(get_str("DIRECTORY"), options).run