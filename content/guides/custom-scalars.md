---
title: Custom Scalars
order: 2
---

One of the strengths of GraphQL is its extensibility -- which doesn't end with
its object types, but is present all the way down to the scalar value level.

Sometimes it makes sense to build custom scalar types to better model your
domain. Here's how to do it.

## Defining a scalar

Supporting additional scalar types is as easy as using the `scalar` macro and
providing `parse` and `serialize` functions.

Here's a simple scalar definition:

```elixir
scalar :time, description: "ISOz time" do
  parse &Timex.DateFormat.parse(&1, "{ISOz}")
  serialize &Timex.DateFormat.format!(&1, "{ISOz}")
end
```

This creates a new scalar type, `:time` that converts between external string
times in ISOz format and internal [Timex](https://github.com/bitwalker/timex)
structs.

<p class="note">
 By default, types defined in Absinthe schemas are automatically given TitleCased
 names for use in GraphQL documents. To give a type a custom name, pass a
 `:name` option. In this example, our scalar type is automatically assigned `Time`).
 </p>

This method of definining scalars isn't anything special, either. It's exactly
how the built-in scalars `Int`, `String`, `Float`, `ID`, and `Boolean` are defined.

### The parse function

The function provided to `parse` takes the raw value from GraphQL and returns a
tuple -- either `{:ok, value}` or `{:error, reason}`. Any errors during parsing
will be returned to the user as part of the response.

In the `:time` example above, `Timex.DateFormat.parse/2` handles this for us; we
just wrap it and provide the date format (`ISOz').

### The serialize function

The function provided to `serialize` takes the internal value and serializes it
to the type that will be inserted into the result.

In the `:time` example above, `Time.DateFormat.format!` handles us for this,
serializing it to the same format that `parse` expects as input.

### Don't forget your description

Descriptions are especially useful for scalars, as users may not be familiar
with the constraints your `parse` function may place on incoming values.

Be nice and tell them:

```elixir
@desc """
The `Time` scalar type represents time values provided in the ISOz
datetime format (that is, the ISO 8601 format without the timezone offset, eg,
"2015-06-24T04:50:34Z").
"""
scalar :time, description: "ISOz time" do
  parse &Timex.DateFormat.parse(&1, "{ISOz}")
  serialize &Timex.DateFormat.format!(&1, "{ISOz}")
end
```

## As query document variables

Once you have a scalar type defined, you can use it in [query document variables](https://facebook.github.io/graphql/#sec-Language.Query-Document.Variables),
just like any other input type.

Here's a query document that marks a post as read, requiring a non-null `Time` value:

```graphql
mutation MarkPostAsRead($postID: ID!, $when: Time!) {
  markRead(id: $postID, readAt: $when)
}
```

## Further reading

* The `scalar` macro is defined in [Absinthe.Schema.Notation](https://hexdocs.pm/absinthe/Absinthe.Schema.Notation.html).
* The built-in scalars are defined in [Absithe.Type.BuiltIns.Scalars](https://hexdocs.pm/absinthe/Absinthe.Type.BuiltIns.Scalars.html).
