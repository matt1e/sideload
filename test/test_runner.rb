require "sideload"
require "json"
require "minitest/autorun"

Dir["test/**/*_spec.rb"].each do |f|
  load f
end
