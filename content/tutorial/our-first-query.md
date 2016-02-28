---
title: Our First Query
order: 1
---

The first thing our viewers want is a list of our blog posts, so that's what we're going to give them. Here's the query we want to support

```
{
  posts {
    title
    body
  }
}
```

To do this we're going to need a schema. Let's create some basic types for our schema, starting with a Post. GraphQL has several fundamental types on top of which all of our types will be built. The [Object](http://hexdocs.pm/absinthe/Absinthe.Type.Object.html) type is the right one to use when representing a set of key value pairs.

```elixir
# web/schema/types.ex
defmodule Blog.Schema.Types do
  use Absinthe.Type.Definitions
  alias Absinthe.Type

  @absinthe :type
  def post do
    %Type.Object{
      fields: fields(
        id: [type: :id],
        title: [type: :string],
        body: [type: :string]
      )
    }
  end
end
```

You'll notice we use the `fields()` function to define the fields on our Post object. This is just a convenience function that fills out a bit of GraphQL boilerplate for each of the fields we define. See [Absinthe.Type.Definitions](http://hexdocs.pm/absinthe/Absinthe.Type.Definitions.html#fields/1) for more information.

If you're curious what the type `:id` is used by the `:id` field, see the [GraphQL spec](https://facebook.github.io/graphql/#sec-ID). In our case it's our regular Ecto id, but always serialized as a string.

With our type completed we can now write a basic schema that will let us query a set of posts.

```elixir
# web/schema.ex
defmodule Blog.Schema do
  use Absinthe.Schema, type_modules: [Blog.Schema.Types]
  alias Absinthe.Type
  alias Blog.Resolver

  def query do
    %Type.Object{
      fields: fields(
        posts: [
          type: list_of(:post),
          resolve: &Resolver.Post.all/3
        ]
      )
    }
  end
end

# web/resolver/post.ex
defmodule Blog.Resolver.Post do
  def all(_obj, _args, _exe) do
    {:ok, Blog.Repo.all(Post)}
  end
end
```

Queries are defined as fields inside the GraphQL object returned by our `query` function. We created a posts query that has a type `list_of(:post)` and is resolved by our `Blog.Resolver.Post.all` function. Later we'll get into what the arguments to resolver functions are; don't worry about it for now. The resolver function can be anything you like that takes the requisite 3 arguments. By convention we recommend organizing your resolvers under `web/resolver/foo.ex`

By default, the atom name of the type (in this case `:post`) is determined by the name of the function which defines it. For more information on type definitions see [Absinthe.Type.Definitions](http://hexdocs.pm/absinthe/Absinthe.Type.Definitions.html).

The last thing we need to do is configure our phoenix router to use our newly created schema.

```elixir
defmodule Blog.Web.Router do
  use Phoenix.Router

  forward "/", Absinthe.Plug,
    schema: Blog.Schema
end
```

That's it! We're running GraphQL.

Using Absinthe.Plug in your router ensures that your schema is type checked at compile time. This means that if you misspell a type and do `list_of(:pots)` you'll be notified that the type you reference in your schema doesn't exist.
