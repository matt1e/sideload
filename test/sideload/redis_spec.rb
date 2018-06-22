# frozen_string_literal: true

describe "Sideload::Path" do
  after do
    db = Sideload::Redis.db
    db.del("moo/bar", "blu/bar", "s/m.json", "x/m.json")
    Sideload::Redis.remove_instance_variable("@redis")
  end

  describe ".db" do
    it "initiaizes and delivers the same redis instance" do
      assert Sideload::Redis.db.is_a?(Redis)
      assert_equal Sideload::Redis.db, Sideload::Redis.db
    end
  end

  describe ".db!" do
    it "initializes a new redis instance with params" do
      db = Sideload::Redis.db
      Sideload::Redis.db!(db: 3)
      assert Sideload::Redis.db.is_a?(Redis)
      refute_equal db, Sideload::Redis.db
    end
  end

  describe ".read" do
    it "lists keys and contents under a path" do
      db = Sideload::Redis.db
      db.set("moo/bar", "{}")
      db.set("blu/bar", "{}")
      assert_equal({"bar" => "{}"}, Sideload::Redis.read("moo/"))
    end
  end

  describe ".with" do
    it "yields with given params" do
      ran = false
      Sideload::Redis.with(1, 2) do |path, fname|
        ran = true
        assert_equal 1, path
        assert_equal 2, fname
      end
      assert ran
    end
  end

  describe ".write" do
    it "validates against content with block" do
      raised = false
      ran = 0
      begin
        Sideload::Redis.write("s", "m.json", "{}") do |c|
          assert_equal "{}", c
          ran += 1
          true
        end
        Sideload::Redis.write("x", "m.json", "{}") do |c|
          assert_equal "{}", c
          ran += 1
          false
        end
      rescue Sideload::ValidationError
        raised = true
      end
      db = Sideload::Redis.db
      assert_equal "{}", db.get("s/m.json")
      refute db.exists("x/m.json")
      assert raised
      assert_equal 2, ran
    end

    it "writes content to key" do
      Sideload::Redis.write("s", "m.json", "{}")
      assert_equal "{}", Sideload::Redis.db.get("s/m.json")
    end
  end

  describe ".delete" do
    it "deletes a key" do
      db = Sideload::Redis.db
      db.set("s/m.json", "{}")
      Sideload::Redis.delete("s", "m.json")
      refute db.exists("s/m.json")
    end
  end
end
