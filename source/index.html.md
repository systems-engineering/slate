# SEC Hub - Consumer API

This API is the main API for the consumer (primary user) facing applications.

[Documentation lives in Confluence](https://syseng.atlassian.net/wiki/spaces/VCA/overview), and a
[Systems Engineering Concept (SEC) guide for developers](https://syseng.atlassian.net/wiki/spaces/SFD/overview) also exists.

## Development

We use Docker to containerize the application. This means that starting the API locally is as easy
as running `docker-compose up` and the API is available at http://localhost:3000.

You can [download docker here](https://www.docker.com/products/docker-desktop).

### Remote dev AWS environment

For some of the resources, such as the Neptune database, which are very specialized and doesn't run
well on local machines, we offer a direct connection to the spawned development environment.

When you push your changes to git, the system automatically run all the tests (including performance
tests). In development CI/CD _will_ deploy your code to your remote dev environment regardless of
the pass/fail of the tests. When your branch has been processed  by the CI/CD it will be available
at: `<branchname>`.dev.sec-hub.com.

## Testing

Execute `bundle exec rspec` to run the test suite locally.

By default tests with the `performance` tag isn't run. To explicitly call these run
`bundle exec rspec --tag performance`

## Documentation

Documentation is generated and deployed by the CI/CD pipeline, but to make sure that the
documentation for your feature looks good, please run `bundle exec docs:generate`. This will
generate `tmp/doc/index.html.md`, which is a Slate style document, which can then be viewed in the
[Consumer API Documentation](https://github.com/systems-engineering/sec-hub-consumer-api-documentation) project.

## Good reads

* [JSON API implementation guides](https://jsonapi-resources.com/v0.10/guide) (see also `config/initializers/jsonapi_resources.rb`)

## ENV variables

This table enumerates the environment variables available to the application.

| Name | Description |
| ---- | ----------- |
| SENTRY_DSN | Sentry identifier for exception logging |
| PRIVATE_REDIS_URL | Private Redis DB connection URL |
| PUBLIC_REDIS_URL | Public Redis DB connection URL |
| DATABASE_URL | Postgres connection URL |
| NEPTUNE_URL | Neptune connection URL |
