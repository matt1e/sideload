# frozen_string_literal: true

describe "Sideload::Config" do
  before do
    @config = Sideload::Config.new
  end

  after do
    @config = nil
  end

  describe ".new" do
    it "initializes with empty sources" do
      assert_equal [], @config.sources
    end

    it "initializes with forwarding packer and unpacker" do
      assert_equal 25, @config.packer.call(25)
      assert_equal 25, @config.unpacker.call(25)
    end
  end

  describe "#pack" do
    it "overrides the packer with proc" do
      blk = ->(f) { f * 2 }
      assert_equal 25, @config.packer.call(25)
      @config.pack(&blk)
      assert_equal 50, @config.packer.call(25)
    end
  end

  describe "#unpack" do
    it "overrides the unpacker with proc" do
      blk = ->(f) { f * 2 }
      assert_equal 25, @config.unpacker.call(25)
      @config.unpack(&blk)
      assert_equal 50, @config.unpacker.call(25)
    end
  end

  describe "#source" do
    it "allows path, web and redis as scopes" do
      %i[path github redis].each do |scope|
        raised = false
        begin
          @config.source(scope, *["arg"])
        rescue
          raised = true
        end
        refute raised
      end
    end

    it "fails on any other scope" do
      raised = false
      begin
        @config.source(:nuu, "arg")
      rescue
        raised = true
      end
      assert raised
    end

    it "stores at the back of sources" do
      @config.source(:path, "first/")
      assert_equal [[:path, "first/", {}, nil]], @config.sources
      @config.source(:path, "second/")
      assert_equal [[:path, "first/", {}, nil], [:path, "second/", {}, nil]],
        @config.sources
    end

    it "stores any config opts" do
      @config.source(:path, "first/", any: "opt", with: 1)
      assert_equal [[:path, "first/", {any: "opt", with: 1}, nil]],
        @config.sources
    end

    it "uses a generic validate when available, otherwise given block" do
      @config.validate { |f| f == 25 }
      @config.source(:path, nil)
      validator = @config.sources.last.last
      assert validator.call(25)
      refute validator.call(26)
      @config.source(:path, nil) { |f| f == 26 }
      validator = @config.sources.last.last
      assert validator.call(26)
      refute validator.call(25)
    end
  end

  describe "#update!" do
    it "forwards a block and the sources array to sideload" do
      @config.source(:path, nil)
      ran = 0
      test_val = Proc.new do |sources|
        assert_equal @config.sources, sources
        ran += 1
      end
      Sideload.stub(:update!, test_val, 25) do
        @config.update!
        @config.update! do |f|
          assert_equal 25, f
          ran += 1
        end
      end
      assert_equal 3, ran
    end
  end
end
