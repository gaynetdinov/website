## INSTALL

```
bundle install
npm install
```

## Developing

```
gulp
```

## Publishing

### Setting it up

First, make sure your `output/` directory is gone:

```
rm -fR output
```

Then, clone the publishing repository to `output/`:

```
git clone git@github.com:absinthe-graphql/absinthe-graphql.github.io.git output
```

### Deploying changes

After running `gulp build` or `gulp serve` as usual, simply:

```
cd output
git commit -am "A nice commit message"
git push origin master
```

Then, check out
 http://absinthe-graphql.org/ ]( http://absinthe-graphql.org/ )
and make sure you haven't screwed anything up. :-)
