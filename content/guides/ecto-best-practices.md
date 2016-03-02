---
title: Ecto Best Practices
order: 10
---
This guide is going to grow as we develop more tooling around Ecto integrations,
but there are some important things to keep in mind already.

## Avoiding N+1

In general, you want to make sure that when accessing ecto associations that you
preload the data in the top level resolver functions to avoid N+1 queries.

Suppose you have posts and categories. Categories can have a parent category. You
want to list all categories, and if they have a parent, include that along with its name.

```graphql
#description "Example query"
{
  categories {
    parent {
      name
    }
  }
}
```

If you write your schema like this, you're going to have a bad time:
```elixir
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

What this schema will do when presented with the aforementioned graphql query is
run `Category |> Repo.all` which will retrieve some N categories. Then for each
N category it will resolve its child fields, which runs our `query_parent(category)`
function, resulting in N+1 calls to the database.

Instead, structure your schema in such a way that you preload all desired data

```elixir
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

Now we always just make 2 calls to the database. Once to load all queries, and then
another to handle the preload.

Astute readers will note that there's a downside here. If the graphQL query doesn't
ask for the parent, we'll still load it from the database anyway. While Abinsthe
will make sure that the parent field isn't sent back in the response, it'd be nice
if we could only query the database when the parent is asked for.

This is on the roadmap! Internally we have a function `derive_preloads/1` that lets us do
```elixir
query do
  field :categories, list_of(:category) do
    resolve fn _, execution ->
      preloads = derive_preloads(execution)
      Category
      |> Ecto.Query.preload(^preloads)
      |> Repo.all
    end
  end
end
```
That second argument you see `execution` is a [Absinthe.Execution.Field](https://hexdocs.pm/absinthe/Absinthe.Execution.Field.html)
struct, which allows us to look at the AST of the query and derive precisely what
needs preloaded.

We hope to be able to release this as a general feature here soon.
