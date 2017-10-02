module Sideload
  class ValidationError < RuntimeError
    def initialize(klass, path, content)
      super("validation error in #{klass}: #{path}\n#{content}")
    end
  end
end
