# frozen_string_literal: true

describe "Sideload::Path" do
  describe ".read" do
    it "reads files on a given path" do
      assert_equal({"toot.json" => "[]\n"},
        Sideload::Path.read("sample_sources/"))
    end
  end

  describe ".with" do
    it "creates and clears missing folders for the target" do
      refute File.exist?("sample_sources/cookie")
      Sideload::Path.with("sample_sources/", "cookie/joe.json") do |_path, file|
        assert File.exist?("sample_sources/cookie")
        assert_equal "joe.json", file
      end
      refute File.exist?("sample_sources/cookie")
    end
  end

  describe ".write" do
    it "validates against content with block" do
      m = Module.new { def self.print(_); end }
      File.stub(:open, nil, m) do
        raised = false
        ran = 0
        begin
          Sideload::Path.write("", "", "{}") do |c|
            assert_equal "{}", c
            ran += 1
            true
          end
          Sideload::Path.write("", "", "{}") do |c|
            assert_equal "{}", c
            ran += 1
            false
          end
        rescue Sideload::ValidationError
          raised = true
        end
        assert raised
        assert_equal 2, ran
      end
    end

    it "writes content to a file" do
      m = Module.new { def self.print(c); @ran = 1; @content = c; end }
      File.stub(:open, nil, m) do
        Sideload::Path.write("", "", "{}")
      end
      assert_equal 1, m.instance_variable_get("@ran")
      assert_equal "{}", m.instance_variable_get("@content")
    end
  end

  describe ".delete" do
    it "deletes a file" do
      File.stub(:delete, ->(path) { assert_equal "s/m.json", path }) do
        Sideload::Path.delete("s", "m.json")
      end
    end
  end
end
