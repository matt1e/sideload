module Sideload
  module Redis
    extend self

    def db!(**config)
      @redis = ::Redis.new(**config)
    end

    def db
      @redis || db!
    end

    def read(path)
      return db.keys(path + "*").map do |key|
        [key.sub(path, ""), db.get(key)]
      end.to_h
    end

    def with(path, fname)
      yield(path, fname)
    end

    def write(full_path, target, content)
      if block_given? && !yield(content)
        raise ValidationError.new(self, "#{full_path}#{target}", content)
      end
      db.set(File.join(full_path, target), content)
    end

    def delete(full_path, target)
      db.del(File.join(full_path, target))
    end
  end
end
