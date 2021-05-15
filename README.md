# Buildpack CI Run-Tests

Have you enjoyed the convenience that [buildpacks](https://devcenter.heroku.com/articles/buildpacks) give you when deploying on platforms that support it, such as [Heroku](https://www.heroku.com/)?  Have you wished you can have the same convenience for your CI/CD pipeline without have to dig for the steps that you need to get everything running properly?  You are not alone!

Buildpack CI is an action on [GitHub Actions](https://github.com/features/actions) that uses buildpacks and [Herokuish](https://github.com/gliderlabs/herokuish) to give us this convenience on the GitHub platform.  In the simplest case, adding one line to your GitHub Actions [workflow](https://help.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow) will build and run unit tests for your app.  Ready to give it a shot?

  * [Usage](#usage)
  * [Supported Languages](#supported-languages)
    + [Natively-Supported Languages](#natively-supported-languages)
    + [Custom Buildpack Languages](#custom-buildpack-languages)
  * [Examples](#examples)
    + [Basic Usage](#basic-usage)
    + [Custom Buildpack](#custom-buildpack)
    + [Multiple Buildpacks](#multiple-buildpacks)
    + [Rails Apps](#rails-apps)
    + [Django Apps](#django-apps)
    + [Some Example Workflows](#some-example-workflows)
  * [Rationale](#rationale)
  * [References](#references)

## Usage

Super-simple.  Just add the following line to your workflow.  See examples below.

```
    - uses: buildpack-ci/run-tests@v1
```


## Supported Languages

### Natively-Supported Languages

Run-Tests rely on the `bin/test` and `bin/test-compile` scripts within buildpacks to build and trigger the unit tests.  The following languages (which use [Heroku officially-supported buildpacks](https://elements.heroku.com/buildpacks)) will work out of the box.

1. Ruby
1. Java
1. Scala
1. Golang
1. NodeJS

### Custom Buildpack Languages

The "native" buildpacks for some languages don't include the necessary scripts (i.e. `bin/test` and `bin/test-compile`), so one will have to create your own buildpack to get the scripts added.  The following buildpacks have been forked to add the necessary scripts.

1. https://github.com/vincetse/heroku-buildpack-python.git (PR heroku/heroku-buildpack-python#982 submitted to add scripts)
1. https://github.com/buildpack-ci/heroku-buildpack-multi.git
1. https://github.com/buildpack-ci/null-buildpack.git


## Examples

### Basic Usage

Here is [an example](https://github.com/buildpack-ci/nodejs-example/blob/main/.github/workflows/ci.yml) of the most basic usage with an app that does not require a database server component.

```
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Clone code repo
      uses: actions/checkout@v2
    - name: Build and run unit tests with Buildpack CI
      uses: buildpack-ci/run-tests@v1
```

### Custom Buildpack

Need to use a custom buildpack?  You can do so by setting the `BUILDPACK_URL` environment variable to the URL of the buildpack that you need for your application.  This example builds a Perl app which isn't supported natively by Herokuish.

```
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - name: Clone code repo
      uses: actions/checkout@v2
    - name: Build and run unit tests with Buildpack CI
      uses: buildpack-ci/run-tests@v1
      env:
        BUILDPACK_URL: https://github.com/vincetse/heroku-buildpack-python.git
```

### Multiple Buildpacks

If your application uses multiple buildpacks, you will need to do 2 things:

1. Use the [buildpack-ci/heroku-buildpack-multi] as the custom buildpack by setting the environment variable `BUILDPACK_URL` to a value of `https://github.com/buildpack-ci/heroku-buildpack-multi.git`.
1. At the root of your application directory, create a file named `.buildpacks` with the URL of each buildpack you want to use for your application.  [Dokku](http://dokku.viewdocs.io/dokku/) has the best [documentation](http://dokku.viewdocs.io/dokku~v0.11.1/deployment/methods/buildpacks/#specifying-a-custom-buildpack) I can find on this topic.

Note that if one of the buildpacks does not support tests (i.e. have the `bin/test` and `bin/test-compile` scripts), you can skip over those buildpacks by defining the `BUILDPACK_MULTI_PASS_IF_MISSING_TEST_SCRIPTS` variable to a value of `true`.

The [buildpack-ci/django-app-multi-buildpack](https://github.com/buildpack-ci/django-app-multi-buildpack) example application demonstrates such a configuration in its [CI configuration](https://github.com/buildpack-ci/django-app-multi-buildpack/blob/main/.github/workflows/ci.yml).


### Rails Apps

This Rails app demonstrates how to use a Postgresql container during the build & test process by [using a service within the workflow](https://github.com/buildpack-ci/rails-example/blob/main/.github/workflows/ci.yml#L7-L19).

```
name: CI
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
    - name: Clone code repo
      uses: actions/checkout@v2
    - name: Build and run unit tests with Buildpack CI
      uses: buildpack-ci/run-tests@v1
        env:
          DATABASE_URL: postgres://postgres:postgres@postgres:5432/test
          RAILS_ENV: test
          DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL: true
```

### Django Apps

Running a Django app on Heroku requires the app to read database credentials from the `DATABASE_URL` environment variable, and we have stuck with that convention for this example.  The [dj-database-url](https://github.com/jacobian/dj-database-url) Python package makes it very convenient to use `DATABASE_URL` to pass database credentials to the application.

```
name: CI
on: [push, pull_request]
jobs:
  test:
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
    - name: Clone code repo
      uses: actions/checkout@v2
    - name: Build and run unit tests with Buildpack CI
      uses: buildpack-ci/run-tests@v1
      env:
        BUILDPACK_URL: https://github.com/vincetse/heroku-buildpack-python
        DATABASE_URL: postgres://postgres:postgres@postgres:5432/test
```

### Some Example Workflows

The following are a bunch of GitHub Actions workflows for example apps.  Make sure to check out the workflow files too.

1. https://github.com/buildpack-ci/django-example/actions/runs/119584374
1. https://github.com/buildpack-ci/nodejs-example/actions/runs/119944160
1. https://github.com/buildpack-ci/rails-example/actions/runs/119767216
1. https://github.com/buildpack-ci/django-app-multi-buildpack/actions/runs/120027240


## Rationale

Configuring CI for frameworks such as Ruby-on-Rails or Django is pretty straightforward, but may involve several steps that require referring to a manual to jolt one's memory on how to configure the setup.  [GitLab Auto DevOps](https://about.gitlab.com/stages-devops-lifecycle/auto-devops/) simplifies the CI for developers with a zero-configuration functionality, but one will have to go off-platform for the convenience.  This tool aims to provide a low-effort option right on the GitHub platform.

This tool was conceived while the author was sheltering in place in New York City during the COVID-19 pandemic, and process of designing and assembling the pieces provided a fun project in these tough times.  Hopefully, it will delight the GitHub community too.


## Passing Thoughts

* [Cloud Native Buildpacks](https://buildpacks.io/) are really cool!  They are probably going to be the future, and one should really explore them.  They don't support running unit tests automatically right now, but one can probably work around that.
* [Heroku CI](https://www.heroku.com/continuous-integration) looks pretty sweet for those already paying Heroku.  Some would argue lock-in is a concern, but speaking from past experience, most of us are more worried about lock-in than we should be since most of us will never exercise other options any way.
* [GitLab Auto DevOps](https://about.gitlab.com/stages-devops-lifecycle/auto-devops/) is a very nice feature.  Why hasn't GitHub also launched such functionality?
* Google Cloud, AWS, and Microsoft Azure have similar functionality too, right?  I can't remember.


## References

1. https://github.com/gliderlabs/herokuish/issues/349
1. https://github.com/heroku/heroku-buildpack-python/issues/477
1. https://gitlab.com/gitlab-org/gitlab-foss/-/issues/26941
1. https://www.heroku.com/continuous-integration
1. https://buildpacks.io/
