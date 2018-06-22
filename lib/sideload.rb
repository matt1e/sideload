# frozen_string_literal: true

require "redis"
require "sideload/validation_error"
require "sideload/config"
require "sideload/redis"
require "sideload/path"
require "sideload/github"

module Sideload
  extend self

  def logger=(logger)
    @logger = logger
  end

  def init
    c = Config.new
    yield(c)
    return c
  end

  def update!(sources)
    scope, arg, _config, validate = sources.shift
    mod = const_get(scope.to_s.capitalize)
    contents = mod.read(*arg)
    unless sources.empty?
      next_layer = update!(sources)
      unless next_layer.nil?
        (contents.keys | next_layer.keys).each do |key|
          if !next_layer.has_key?(key)
            mod.with(arg, key) do |fp, t|
              mod.delete(fp, t)
            end
          else
            mod.with(arg, key) do |fp, t|
              mod.write(fp, t, next_layer[key], &validate)
            end
          end
        end
        contents = mod.read(arg)
      end
    end
    contents.each(&Proc.new) if block_given?
    return contents
  rescue ValidationError => e
    if @logger
      @logger.error { [e.class, e.message].inspect }
      @logger.debug { e.backtrace.join("\n") }
    end
    return nil
  end
end
