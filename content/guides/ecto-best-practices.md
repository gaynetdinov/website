---
title: Ecto Best Practices
order: 10
---

This guide is going to grow as we develop more tooling around Ecto integrations
(it's a priority on [our roadmap](/roadmap), but there are some important things
we can point out now that might be helpful.

## Avoiding N+1 Queries

In general, you want to make sure that when accessing Ecto associations that you
preload the data in the top level resolver functions to avoid N+1 queries.

Imagine this scenario: You have posts and categories. Categories can have a
parent category. You want to list all categories, and if they have a parent,
include that along with its name.

```graphql
# description: A deceptively simple query.
{
  categories {
    parent {
      name
    }
  }
}
```

If you write your schema like this, you're going to have a _bad_ time:

```elixir
# description: A naive approach, subject to N+1 issues.
object :category do
  @desc "Parent category to the existing category"
  field :parent, :category do
    resolve fn _, %{source: category} ->
      # exact mechanism unimportant
      query_parent(category)
    end
  end
end

query do
  field :categories, list_of(:category) do
    resolve fn _, _ ->
      Category |> Repo.all
    end
  end
end
```

What this schema will do when presented with the GraphQL query is
run `Category |> Repo.all`, which will retrieve _N_ categories. Then for each
_N_ category it will resolve child fields, which runs our `query_parent(category)`
function, resulting in _N+1_ calls to the database.

Instead, structure your schema in such a way that you can preload all desired
data:

```elixir
# description: Always preloading the parent.
object :category do
  @desc "Parent category to the existing category"
  field :parent, :category
end

query do
  field :categories, list_of(:category) do
    resolve fn _, _ ->
      Category
      |> Ecto.Query.preload(:parent)
      |> Repo.all
    end
  end
end
```

Now we always make 2 calls to the database; once to load all queries, and then
a second time to handle the preload.

Astute readers will note that there's a downside here. We load the parent from
the database regardless of whether the GraphQL query asks for it (and,
therefore, regardless of whether Absinthe will return it in the response).

It'd be nice if we could only query the database when the parent is asked for.

## It's DIY (For Now)

Supporting this feature more automatically is on the [roadmap](/roadmap), but
here's the approach:

```elixir
# description: The sneaky approach. Coming soon!
query do
  field :categories, list_of(:category) do
    resolve fn _, info ->
      preloads = derive_preloads(info)
      Category
      |> Ecto.Query.preload(^preloads)
      |> Repo.all
    end
  end
end
```

In this example, `derive_preloads/1` takes the second argument to the resolver
(a [Absinthe.Execution.Field](https://hexdocs.pm/absinthe/Absinthe.Execution.Field.html)
struct), which contains the current `ast_node` -- using this, we can peek ahead
and see what child fields will be asked for, then return the preloads that are
actually needed.

Sounds simple, right? The devil is in the details, but we hope to be able to
release this soon as part of a new `Absinthe.Ecto` project.
