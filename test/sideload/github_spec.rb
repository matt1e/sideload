describe "Sideload::Github" do
  after do
    Sideload::Github.instance_variable_set("@user", nil)
    Sideload::Github.instance_variable_set("@pass", nil)
  end

  describe ".credentials=" do
    it "sets credentials for github" do
      Sideload::Github.credentials = ["moo", "bar"]
      assert_equal "moo", Sideload::Github.instance_variable_get("@user")
      assert_equal "bar", Sideload::Github.instance_variable_get("@pass")
    end
  end

  describe ".read" do
    it "raises when no credentials are set" do
      raised = false
      begin
        Sideload::Github.read("matthias-geier/sideload", "sample_sources")
      rescue RuntimeError => e
        assert_equal "no github credentials set", e.message
        raised = true
      end
      assert raised
    end

    it "lists keys and contents under a path" do
      Sideload::Github.credentials = ["e608c053ca8068b09a5fbc7f337cb22f11cf7725", "x-oauth-basic"]
      assert_equal({"toot.json" => "[]\n"}, Sideload::Github.
        read("matthias-geier/sideload", "sample_sources"))
    end
  end
end
