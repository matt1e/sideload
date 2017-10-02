# Navigate to project folder
# execute:
#   $ ruby -Ilib example/basic.rb

require "sideload"

Sideload::Redis.db!(db: 3)

Sideload.logger = Module.new do
  def self.debug; puts "debug: " + yield; end
  def self.error; puts "error: " + yield; end
end

sideloader = Sideload.init do |config|
  config.validate { |c| c =~ /\[\]/ }
  config.source(:path, "sources/")
  config.source(:redis, "sources/")
  config.source(:path, "sample_sources/")
end

sideloader.update! { |file, content| p file, content }
