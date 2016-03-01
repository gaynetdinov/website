---
title: Mutations
order: 5
---

A blog is no good without new content. We want to support a mutation
to create a blog post:

```graphql
# description: Create a post and return the new post ID.
mutation CreatePost {
  post(title: "Second", body: "We're off to a great start!") {
    id
  }
}
```

Now we just need to define a `mutation` portion of our schema and
a `:post` field:

```elixir
# filename: web/schema.ex
mutation do
  field :post, type: :post do
    arg :title, non_null(:string)
    arg :body, non_null(:string)
    arg :posted_at, non_null(:string)
    resolve &Resolver.Post.create/2
  end
end
```

The resolver in this case is responsible for making any changes and returning
an `{:ok, post}` tuple matching the `:post` type we defined earlier:

```elixir
# filename: web/resolver/post.ex
def create(args, _info) do
  %Post{}
  |> Post.changeset(args)
  |> Blog.Repo.insert
end
```

With this in place, we can accept posts!
