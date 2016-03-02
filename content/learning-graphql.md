---
title: Learning GraphQL
---

GraphQL is a query language created by Facebook in 2012 to provide a
common interface between clients and servers by defining their data
capabilities and requirements.

While GraphQL is commonly thought of as an API technology for
frontend applications (especially [Relay](https://facebook.github.io/relay/)),
it's generally applicable.

## Example

Here's an example GraphQL query document that you might send to a
server to query for specific user information:

```graphql
{
  user(id: 123) {
    first_name
    last_name
    avatar_url(size: "thumb")
    friends(limit: 3) {
      first_name
    }
  }
}
```

Provided that the server's GraphQL schema supported the fields you've
requested, you'd get back exactly what you want:

```json
{
  "data": {
    "user": {
      "first_name": "Jane",
      "last_name": "Avery",
      "avatar_url": "http://example.absinthe-graphql.org/img/users/123-thumb.jpg",
      "friends": [
        {"first_name": "John"},
        {"first_name": "Jack"},
        {"first_name": "Jill"},
      ]
    }
  }
}
```

If we requested fields that weren't supported by the schema defined on
the server, forgot required arguments, or passed arguments that were
invalid, the server would let us know via helpful error messages, all
without manual, custom-written intervention by the schema writer.

Plus, the schema [can be introspected](/guides/introspection) by clients.

## Resources

Before using Absinthe, you should familiarize yourself with GraphQL in
general. (Just keep in mind you'll be writing Elixir, not JavaScript!)

Here are some resources that you may find useful:

* ["GraphQL Introduction"](https://facebook.github.io/react/blog/2015/05/01/graphql-introduction.html) and ["GraphQL: A data query language"](https://code.facebook.com/posts/1691455094417024/graphql-a-data-query-language/) posts from Facebook.
* The ["Your First GraphQL Server"](https://medium.com/@clayallsopp/your-first-graphql-server-3c766ab4f0a2#.m78ybemas) Medium post by Clay Allsopp.
* ["Learn GraphQL"](https://learngraphql.com) by Kadira.
* The [JavaScript GraphQL reference implementation](https://github.com/graphql/graphql-js).
* The ["graphql" StackOverflow tag](http://stackoverflow.com/questions/tagged/graphql).

## Specification

The current version of the specification is the [October 2015 Working Draft](https://facebook.github.io/graphql/).
