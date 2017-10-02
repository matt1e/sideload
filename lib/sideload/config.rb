
module Sideload
  class Config
    ALLOWED = %i[path web redis]

    attr_reader :sources, :packer, :unpacker

    def initialize
      @sources = []
      @packer = ->(f) { f }
      @unpacker = ->(f) { f }
    end

    def pack
      @packer = Proc.new
    end

    def unpack
      @unpacker = Proc.new
    end

    def validate
      @validate = Proc.new
    end

    def source(scope, arg, **config)
      if !ALLOWED.include?(scope)
        raise "scope #{scope.inspect} not in #{ALLOWED.inspect}"
      end
      @sources << [
        scope,
        arg,
        config,
        (block_given? ? Proc.new : nil) || @validate
      ]
    end

    def update!
      Sideload.update!(@sources.dup, &(block_given? ? Proc.new : nil))
    end
  end
end
