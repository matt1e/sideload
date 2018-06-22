# frozen_string_literal: true

# Navigate to project folder
# execute:
#   $ ruby -Ilib example/basic.rb

require "sideload"

Sideload::Redis.db!(db: 3)
Sideload::Github.credentials = ["e608c053ca8068b09a5fbc7f337cb22f11cf7725", "x-oauth-basic"]

Sideload.logger = Module.new do
  def self.debug; puts "debug: " + yield; end
  def self.error; puts "error: " + yield; end
end

sideloader = Sideload.init do |config|
  config.validate { |c| c =~ /\[\]/ }
  config.source(:path, "sources")
  config.source(:redis, "sources")
  config.source(:path, "sample_sources")
  config.source(:github, ["matthias-geier/sideload", "sample_sources"])
end

sideloader.update! { |file, content| p file, content }
