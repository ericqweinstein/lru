# A simple little LRU cache in Crystal.
module LRU
  # Most LRU caches rely on two data structures: a linked list
  # to preserve insertion order and a backing hash to guarantee
  # O(1) lookup time. Since Crystal's Hashes are ordered by
  # insertion time, we can use this to get ordered, constant-
  # time lookup with one data structure (a Hash).
  class Cache
    getter :items, :max

    # Creates a new LRU cache.
    def initialize(@options)
      @max = @options[:max]
      @items = {} of Symbol => String
    end

    # Retrieves a key from the hash.
    def get(k)
      key = k
      value = @items.delete(k)

      @items[key] = value if value
      value || ""
    end

    # Adds a key to the hash.
    def set(k, v)
      if @items.size == @max
        # Since Hashes are ordered by insertion,
        # the pair at index 0 is the LRU pair.
        @items.delete_if do |k, v|
          @items.key_index(k) == 0
        end
      end

      @items[k] = v
    end

    # Shows a key from the hash without
    # "touching" it (that is, without
    # affecting its recency.)
    def peek(k)
      @items.fetch(k, "")
    end

    # Clears the cache.
    def reset!
      @items.clear
    end

    # Checks whether the cache
    # includes the given key.
    def include?(k)
      !peek(k).empty?
    end

    # Gets a list of all keys in the cache.
    def keys
      @items.keys
    end

    # Gets a list of all values in the cache.
    def values
      @items.values
    end

    # Gets highest-used index in the cache.
    def highest_index
      @items.size - 1
    end
  end
end
