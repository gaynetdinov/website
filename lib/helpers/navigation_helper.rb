module NavigationHelper

  def nav_link(target, opts={})
    if target.is_a?(String)
      # Lookup the item by a pattern
      the_item = items[target]
      unless the_item
        raise "Could not find item matching pattern: #{target}"
      end
    else
      the_item = target
    end
    if opts[:descendants]
      opts[:pattern] = the_item.identifier.without_ext + "{.*,/**/*.*}"
    end
    if opts[:pattern]
      # The current page matches a pattern
      is_active = item.identifier =~ opts[:pattern]
    else
      # The current page is the target page
      is_active = the_item == item
    end
    attrs = is_active ? ' class="active"' : ''
    title = opts[:title] || the_item[:title]
    "<a href='#{the_item.path}'#{attrs}>#{title}</a>"
  end

end
