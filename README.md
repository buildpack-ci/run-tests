# Herokuish GitHub Action

A GitHub Action that builds an application like [Heroku](https://www.heroku.com/) would by using the [Herokuish](https://github.com/gliderlabs/herokuish) container to emulate the Heroku build process.

## Usage

### Basic Usage

Here is [an example GitHub Workflow](https://github.com/vincetse/node-js-getting-started/blob/master/.github/workflows/ci.yml) that uses the `master` branch of this action.

```
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: vincetse/herokuish-action@master
```

### Custom Buildpack

Need to use a custom buildpack?  You can do so by setting the `buildpack_url` input parameter.

```
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: vincetse/herokuish-action@master
      env:
        BUILDPACK_URL: https://github.com/heroku/heroku-buildpack-nodejs.git
```

### Multiple Buildpacks

The Herokuish container used supports multiple buildpacks being defined in a file named `.buildpacks` at the root of the repo being built.  [Dokku](http://dokku.viewdocs.io/dokku/) has the best [documentation](http://dokku.viewdocs.io/dokku~v0.11.1/deployment/methods/buildpacks/#specifying-a-custom-buildpack) I can find on this topic.

### Building a Rails App

Here is [an example GitHub Workflow](https://github.com/vincetse/todos-api/blob/master/.github/workflows/herokuish-build.yml) that builds a Rails app with a Postgresql database.

```
name: CI via Herokuish
on: [push, pull_request]
jobs:
  ci:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:11
        env:
          POSTGRES_USER: postgres
          POSTGRES_DB: test
          POSTGRES_PASSWORD: postgres
        ports:
          - "5432:5432"
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v2

      - uses: vincetse/herokuish-action@master
        env:
          DATABASE_URL: postgres://postgres:postgres@postgres:5432/test
          RAILS_ENV: test
          DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL: true
```

## Sample Run

You can see [a sample run](https://github.com/vincetse/node-js-getting-started/runs/648336858?check_suite_focus=true) here.

![sample run](img/sample.png)
