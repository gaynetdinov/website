---
title: Query Arguments
order: 4
---

Our blog needs users, and the ability to look up users by id. Here's
the query we want to support:

```graphql
{
  user(id: "1") {
    name
    email
  }
}
```

This query includes arguments, which are the key value pairs contained
within the parenthesis. To support this, we'll create first create a
user type, and then create a query in our schema that takes an id
argument.


```elixir
# in web/schema/types

@absinthe :type
def user do
  %Type.Object{
    fields: fields(
      id: [type: :id],
      name: [type: :string],
      email: [type: :string],
      posts: [type: :post]
    )
  }
end

@absinthe :type
def post do
  %Type.Object{
    fields: fields(
      title: [type: :string],
      body: [type: :string],
      author: [type: :user],
    )
  }
end

# in web/schema.ex
def query do
  %Type.Object{
    fields: fields(
      posts: [
        type: list_of(:post),
        resolve: &Resolver.Post.all/3
      ]
      user: [
        type: :user,
        args: args(
          id: [type: non_null(:id)]
        )
        resolve: &Resolver.User.find/3
      ]
    )
  }
end
```

In GraphQL you define your arguments ahead of time just like your
return values. This powers a number of very helpful features. To see
them at work, let's look at our resolver.

```elixir
# web/resolver/user.ex
defmodule Blog.Resolver.User do
  def find(_obj, %{id: id}, _exe) do
    case Blog.Repo.get(User, id) do
      nil  -> {:error, "User id #{id} not found"}
      user -> {:ok, user}
    end
  end
end
```

The second argument to every resolve function contains the GraphQL
arguments of the query / mutation. Our schema marks the id argument as
`non_null`, so we can be certain we will receive it and just pattern
match directly. If the id is left out of the query, Absinthe will
return an informative error to the user, and the resolve function will
not be called.

Note also that the id parameter is an atom, and not a binary like
ordinary phoenix parameters. Absinthe knows what arguments will be
used ahead of time, and will cull any extraneous arguments given to a
query. This means that all arguments can be supplied to the resolve
functions with atom keys.

Finally you'll see that we need to handle the possibility that the
query, while valid from GraphQL's perspective, may still ask for a
user that does not exist.
