---
title: Fragments
order: 7
---

What is a blog without insightful and constructive commentary? Let's
give the people a voice!

There's a twist here though. In the spirit of fostering quality online
dialog, we're going to allow comments both directly on the post, as
well as on other comments. For mutations we'll want to accept both
post and comment arguments. For querying a comment, we're going to
need some fancier GraphQL features.

```graphql
# description: Operations we want to support
mutation CreateComment {
  comment(post: {id: "1"})
}
mutation CreateReply {
  comment(comment: {id: "1"})
}

query UserComments {
  user(id: "1") {
    comments {
      subject {
        id
        ... on Post {
          title
        }
        ... on Comment {
          body
          author {
            name
          }
        }
      }
    }
  }
}
```

Each comment has a subject. That subject can be either a post or another comment.
