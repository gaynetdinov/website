module CollectionHelper

  class ItemCollection

    include Enumerable

    def initialize(item, items)
      @item = item
      @items = items
    end

    def name
      @item.identifier.without_ext[/\/([^\/]+)/, 1]
    end

    def pattern
      @pattern ||= "/#{name}{.md,/**/*.md}"
    end

    def data
      @data ||= @items.find_all(pattern).sort_by { |i|
        [i[:order] || 0, i[:title]]
      }
    end

    def each(&block)
      data.each(&block)
    end

    def next_item
      return @next_item if defined?(@next_item)
      @next_item = data[data.index(@item) + 1]
    end

  end

  def item_collection
    @item_collection ||= ItemCollection.new(item, items)
  end

end
