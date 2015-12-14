require "spec"
require "../../src/lru"

def default_cache
  LRU::Cache.new({ max: 3 })
end

describe LRU::Cache do
  describe "#initialize" do
    it "creates a new cache" do
      cache = default_cache

      cache.items.should be_a Hash(Symbol, String)
    end

    it "creates a cache of the correct size" do
      cache = default_cache

      cache.max.should eq 3
    end
  end

  describe "#get" do
    it "gets the value associated with the key" do
      cache = default_cache
      cache.set(:foo, "bar")

      cache.get(:foo).should eq "bar"
    end

    it "updates a key's most-recently-used-ness" do
      cache = default_cache
      cache.set(:foo, "bar")
      cache.set(:baz, "quux")

      cache.get(:baz)

      # { :baz => "quux" } should be most recent
      cache.items.key_index(:baz).should eq cache.highest_index

      cache.get(:foo)

      # { :foo => "bar" } should be most recent
      cache.items.key_index(:foo).should eq cache.highest_index
    end

    it "returns an empty value if the key DNE" do
      cache = default_cache

      cache.get(:foo).should eq ""
    end
  end

  describe "#set" do
    it "sets a key in the cache" do
      cache = default_cache
      cache.set(:foo, "bar")

      cache.get(:foo).should eq "bar"
    end

    it "evicts the LRU key when the cache is full" do
      cache = default_cache

      cache.set(:un, "uno")
      cache.set(:deux, "two")
      cache.set(:trois, "three")
      cache.set(:quatre, "four")

      cache.include?(:un).should be_false
      cache.include?(:deux).should be_true
      cache.include?(:trois).should be_true
      cache.include?(:quatre).should be_true
      cache.items.size.should eq 3
    end
  end

  describe "#peek" do
    it "gets the value associated with the key" do
      cache = default_cache
      cache.set(:foo, "bar")

      cache.peek(:foo).should eq "bar"
    end

    it "does not update a key's most-recently-used-ness" do
      cache = default_cache
      cache.set(:foo, "bar")
      # Insert a more recent key
      cache.set(:baz, "quux")
      cache.get(:baz)

      cache.peek(:foo)
      # { :baz => "quux" } should still be most recent
      cache.items.key_index(:baz).should eq cache.highest_index
    end

    it "returns an empty value if the key DNE" do
      cache = default_cache

      cache.peek(:foo).should eq ""
    end
  end

  describe "#reset!" do
    it "resets the cache" do
      cache = default_cache
      cache.set(:foo, "bar")
      cache.reset!

      cache.items.should eq({} of Symbol => String)
    end
  end

  describe "#include?" do
    it "is true when the key exists in the cache" do
      cache = default_cache
      cache.set(:foo, "bar")

      cache.include?(:foo).should be_true
    end

    it "is false when the key is not in the cache" do
      cache = default_cache
      cache.include?(:bar).should be_false
    end

    it "does not update a key's most-recently-used-ness" do
      cache = default_cache
      cache.set(:foo, "bar")
      cache.set(:baz, "quux")
      cache.get(:baz)
      # { :baz => "quux" } is the most recent

      cache.include?(:foo)

      cache.items.key_index(:baz).should eq cache.highest_index
    end
  end

  describe "#keys" do
    it "gets a list of all keys in the cache" do
      cache = default_cache
      cache.set(:foo, "bar")
      cache.set(:baz, "quux")

      cache.keys.should eq [:foo, :baz]
    end
  end

  describe "#values" do
    it "gets a list of all values in the cache" do
      cache = default_cache
      cache.set(:foo, "bar")
      cache.set(:baz, "quux")

      cache.values.should eq ["bar", "quux"]
    end
  end
end
