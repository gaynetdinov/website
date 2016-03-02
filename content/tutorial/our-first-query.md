---
title: Our First Query
order: 2
---

The first thing our viewers want is a list of our blog posts, so
that's what we're going to give them. Here's the query we want to
support:

```graphql
# description: A simple query
{
  posts {
    title
    body
  }
}
```

To do this we're going to need a schema. Let's create some basic types
for our schema, starting with a Post. GraphQL has several fundamental
types on top of which all of our types will be built. The
[Object](http://hexdocs.pm/absinthe/Absinthe.Type.Object.html) type is
the right one to use when representing a set of key value pairs.

```elixir
# filename: web/schema/types.ex
defmodule Blog.Schema.Types do
  use Absinthe.Schema.Notation

  object :post do
    field :id, :id
    field :title, :string
    field :body, :string
  end
end
```

<p class="notice">
The GraphQL specification requires that type names be unique, TitleCased words.
Absinthe does this automatically for us, extrapolating from our type identifier
(in this case <code>:post</code> gives us <code>"Post"</code>). If really
needed, we could provide a custom type name as a <code>:name</code> option to
the <code>object</code> macro.
</p>

If you're curious what the type `:id` is used by the `:id` field, see the
[GraphQL spec](https://facebook.github.io/graphql/#sec-ID). It's an opaque
value, and in our case is just the regular Ecto id, but serialized as a string.

With our type completed we can now write a basic schema that will let us query a
set of posts.

```elixir
# filename: web/schema.ex
defmodule Blog.Schema do
  use Absinthe.Schema
  import_types Blog.Schema.Types

  alias Blog.Resolver

  query do
    field :posts, list_of(:post) do
      resolve: &Resolver.Post.all/2
    end
  end

end
```

```elixir
# filename: web/resolver/post.ex
defmodule Blog.Resolver.Post do
  def all(_args, _info) do
    {:ok, Blog.Repo.all(Post)}
  end
end
```

Queries are defined as fields inside the GraphQL object returned by
our `query` function. We created a posts query that has a type
`list_of(:post)` and is resolved by our `Blog.Resolver.Post.all/2`
function. Later we'll get into what the arguments to resolver
functions are; don't worry about it for now. The resolver function can
be anything you like that takes the requisite 2 arguments.

For more information on the macros
available to build a schema, see
definitions see [Absinthe.Schema](http://hexdocs.pm/absinthe/Absinthe.Schema.html)
and [Absinthe.Schema.Notation](http://hexdocs.pm/absinthe/Absinthe.Schema.Notation.html).

The last thing we need to do is configure our Phoenix router to use our newly
created schema.

```elixir
# filename: web/router.ex
defmodule Blog.Web.Router do
  use Phoenix.Router

  forward "/", Absinthe.Plug,
    schema: Blog.Schema
end
```

That's it! We're running GraphQL.

Using `Absinthe.Plug` in your router ensures that your schema is type
checked at compile time. This means that if you misspell a type and do
`list_of(:pots)` you'll be notified that the type you reference in
your schema doesn't exist.
