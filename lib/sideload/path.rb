# frozen_string_literal: true

module Sideload
  module Path
    extend self

    def read(path)
      dir = File.expand_path(path)
      return Dir[dir + "/**/*.*"].map do |fname|
        [fname.sub(dir + "/", ""), File.open(fname) { |f| f.read }]
      end.to_h
    end

    def with(path, fname)
      *dirs, target = fname.split("/")
      full_path = dirs.reduce(File.expand_path(path)) do |acc, dir|
        f = File.join(acc, dir)
        Dir.mkdir(f) unless File.directory?(f)
        next f
      end
      yield(full_path, target)
      dirs.reverse.each do |dir|
        break if File.basename(full_path) != dir
        break unless Dir[full_path + "/*.*"].empty?
        Dir.rmdir(full_path)
        full_path = File.dirname(full_path)
      end
    end

    def write(full_path, target, content)
      if block_given? && !yield(content)
        raise ValidationError.new(self, "#{full_path}/#{target}", content)
      end
      File.open(File.join(full_path, target), "w") { |f| f.print content }
    end

    def delete(full_path, target)
      File.delete(File.join(full_path, target))
    end
  end
end
