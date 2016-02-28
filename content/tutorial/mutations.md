---
title: Mutations
order: 5
---

A blog is no good without new content. We want to support a mutation
to create a blog post:

```
mutation CreatePost {
  post(title: "Second", body: "We're off to a great start!") {
    id
  }
}
```

Fortunately for us we don't need to make any changes to our types
file. We do however need a new function in our schema and resolver

```elixir
# in web/schema.ex
def mutation do
  %Type.Object{
    fields: fields(
      post: [
        type: :post,
        args: args(
          title: [type: non_null(:string)],
          body: [type: non_null(:string)],
          posted_at: [type: non_null(:string)],
        ),
        resolve: &Resolver.Post.create/3,
      ]
    )
  }
end
```

```elixir
# in web/resolver/post.ex
def create(_obj, args, _exe) do
  %Post{}
  |> Post.changeset(args)
  |> Blog.Repo.insert
end
```

Simple enough!
