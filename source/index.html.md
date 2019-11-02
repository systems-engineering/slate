---
title: SEC Hub Consumer API
language_tabs:
  - json: JSON
  - shell: cURL
---

# SEC-Hub Consumer API

This API exposes information that allowes an authenticated client to manipulate the CORE, SIMO,
DOCU, DOMA, and STEM concepts.

This documentation's permalink is: [https://sec-hub.com/docs/consumer/api](https://sec-hub.com/docs/consumer/api)

## Client authentication

```ruby
require "net/http"
require "openssl"
require "base64"

uri = URI "https://subdomain.sec-hub.com"
http = Net::HTTP.new uri.host, uri.port
request = Net::HTTP::Get.new uri.request_uri
hashed_client_id = Base64.encode64 "client-id"
hashed_client_secret = Base64.encode64 "client-secret"
proxy_header = "Basic #{hashed_client_id}:#{hashed_client_secret}"
request["HTTP_PROXY_AUTHORIZATION"] = proxy_header
response = http.request request
```

The client application must authenticate it self in addition to the actual user access token.
This is because accounts can determine the level of authentication needed, and this can preclude
some clients.

A simple example of the client authenticating it self using the Proxy-Authorization header.

<aside class="notice">
  The client <strong>MUST</strong> replace <code>subdomain</code>, <code>client-id</code>, and
  <code>client-secret</code> with the actual, preshared values.
</aside>

## User authentication

```ruby
bearer_token = retrieve_bearer_token
auth_header = "Bearer #{bearer_token}"
request["HTTP_AUTHORIZATION"] = auth_header
response = http.request request
```

<aside class="notice">
  The client <strong>MUST</strong> implement a flow to retrieve an OAuth2 bearer token.
</aside>

Based on the settings for the account, the client can either use username/password (with 2FA) or
OAuth for authentication.

In either case, the Client will end up with an AccessToken, which it must send with each request
using the `Authorization` header.

## User permissions

Each user has certain [permissions](https://syseng.atlassian.net/wiki/spaces/VCA/pages/950289/Permissions).
Permissions govern what actions the client can take on the data on behalft of the user.

If the client attempts an action which the user doesn't have permissions for the API will
respond with a 403 Forbidden response.

It's strongly advised that, based on the [permissions](https://syseng.atlassian.net/wiki/spaces/VCA/pages/950289/Permissions),
the client builds a predictable solution for governing what actions are available to the user.

## JSON:API

```ruby
request["HTTP_CONTENT_TYPE"] = "application/vnd.api+json"
request["HTTP_ACCEPT"] = "application/vnd.api+json"
response = http.request request
```

This API uses [JSON:API](https://jsonapi.org) to format the JSON.

<aside class="notice">
  The client <strong>MUST</strong> send "application/vnd.api+json" in the <code>Content-Type</code> and
  <code>Accept</code> headers.
</aside>

### Profiles

```
GET /resources
Accept: application/vnd.api+json; profile="https://sec-hub.com/docs/api/versions#2019-10-01"
```

We use version 1.1 of the JSON:API standard which allows us to use
[profiles](https://jsonapi.org/format/1.1/#profiles). Profiles allow clients to specifically
request additioinal semantics and formatting from the API.

In the example, the profile indicates that the client wants the JSON formatted as per version
2019-10-01. Versioning is applied in a similar fasion to
[how Stripe does it](https://stripe.com/es-us/blog/api-versioning).

### Filtering

```
GET /projects?filter[name_or_description_matches_any]=some%20text
```

All of the list endpoints [support filtering](https://jsonapi.org/format/1.1/#fetching-filtering).
The filtering is implemented using [Ransack matchers](https://github.com/activerecord-hackery/ransack#search-matchers)

### Sorting

```
GET /resources?sort=-id,name
```

All of the list endpoints [support sorting](https://jsonapi.org/format/1.1/#fetching-sorting).

This example sorts by IDs descending and name ascendnig.

### Sparse fieldset

```
GET /resources?fields=name
```

All of the list endpoints [support sparse fieldsets](https://jsonapi.org/format/1.1/#fetching-sparse-fieldsets).

This example returns only the `name` first-class property of the resources.

### Pagination

```
GET /resources?page[number]=2&page[size]=20
```

The `number` indicates the page number, and `size` indicates the number of items on the page
(the page size).

<aside class="notice">
  The default (and max) page size is 30. Some endpoints may change this, in that case this will
  be indicated in the specific documentation.
</aside>

# Account

The Account is the first entrypoint into the API. This represents the company (the account)
that ultimately owns all the data.

There is only a single account resource per subdomain.


## Show account information


### Request

#### Endpoint

```plaintext
GET /
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2a69783e-8cd5-4834-88b6-6a253ca73762
200 OK
```


```json
{
  "data": {
    "id": "265eee20-2653-4e98-a84f-76bff98f9fcc",
    "type": "account",
    "attributes": {
      "name": "Account 88d20601d897"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Account name |


## Update account information


### Request

#### Endpoint

```plaintext
PATCH /
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`PATCH /`

#### Parameters


```json
{
  "data": {
    "id": "6b0b3273-fc82-4939-861f-dab552efd906",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New account name |



### Response

```plaintext
X-Request-Id: b2de4c3c-b695-499b-891d-93d4c6ac0c75
200 OK
```


```json
{
  "data": {
    "id": "6b0b3273-fc82-4939-861f-dab552efd906",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Account name |


# Projects

Projects are grouping of Contexts. The specific grouping is left up to the company consuming
the API.

A Project has a progerss which is decoupled from the derived progress of the nested contexts.
This allows the project's manager to indepedenly indicate the progress of the project.


## List projects


### Request

#### Endpoint

```plaintext
GET /projects
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /projects`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 92f3373c-5b4d-42b8-bdd7-6eef008158f7
200 OK
```


```json
{
  "data": [
    {
      "id": "30e5e333-8157-42fa-95a5-9573294af605",
      "type": "project",
      "attributes": {
        "archived_at": null,
        "description": "Project description",
        "name": "project 1"
      },
      "relationships": {
        "account": {
          "links": {
            "self": "/"
          }
        }
      }
    },
    {
      "id": "a816cd56-c9a8-406c-a674-00b64d5dd713",
      "type": "project",
      "attributes": {
        "archived_at": null,
        "description": "Project description",
        "name": "project 2"
      },
      "relationships": {
        "account": {
          "links": {
            "self": "/"
          }
        }
      }
    },
    {
      "id": "c0c4dd14-189e-4af3-ae44-9ff184b93cea",
      "type": "project",
      "attributes": {
        "archived_at": null,
        "description": "Project description",
        "name": "project 3"
      },
      "relationships": {
        "account": {
          "links": {
            "self": "/"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/projects",
    "current": "http://example.org/projects?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Project information


### Request

#### Endpoint

```plaintext
GET /projects/d96b84c1-7c07-46a3-bf02-d82216db88df
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7de84e44-5998-40bb-8620-180819bdc462
200 OK
```


```json
{
  "data": {
    "id": "d96b84c1-7c07-46a3-bf02-d82216db88df",
    "type": "project",
    "attributes": {
      "archived_at": null,
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "account": {
        "links": {
          "self": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/d96b84c1-7c07-46a3-bf02-d82216db88df"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Update project information


### Request

#### Endpoint

```plaintext
PATCH /projects/7982fdbd-0a34-468d-ba5d-d2bf3775f896
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "7982fdbd-0a34-468d-ba5d-d2bf3775f896",
    "type": "projects",
    "attributes": {
      "name": "New project name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New project name |



### Response

```plaintext
X-Request-Id: 66c66e76-aa94-4c3e-8bdf-4754ad2ce3e7
200 OK
```


```json
{
  "data": {
    "id": "7982fdbd-0a34-468d-ba5d-d2bf3775f896",
    "type": "project",
    "attributes": {
      "archived_at": null,
      "description": "Project description",
      "name": "New project name"
    },
    "relationships": {
      "account": {
        "links": {
          "self": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7982fdbd-0a34-468d-ba5d-d2bf3775f896"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


# Contexts

Contexts represent a perspective on the object you're designing.

Usually this would be functional, location or similar, but it's possible to have contexts
switches in a Context's Object Occurrences.


## List contexts


### Request

#### Endpoint

```plaintext
GET /contexts
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /contexts`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1a047b8a-7641-482b-86a7-5ea75e7105f3
200 OK
```


```json
{
  "data": [
    {
      "id": "87a0d502-0ca0-46ef-ac16-23b5dd8e99df",
      "type": "context",
      "attributes": {
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "d07b1051-2396-47e2-87c2-7cb6beeafe9e",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/d07b1051-2396-47e2-87c2-7cb6beeafe9e"
          }
        }
      }
    },
    {
      "id": "8e791860-d77d-4684-bb01-ae5d113c8b1d",
      "type": "context",
      "attributes": {
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "d07b1051-2396-47e2-87c2-7cb6beeafe9e",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/d07b1051-2396-47e2-87c2-7cb6beeafe9e"
          }
        }
      }
    },
    {
      "id": "33362bad-bfe5-4026-b80e-cb853ad1af1b",
      "type": "context",
      "attributes": {
        "archived_at": null,
        "description": null,
        "name": "Context 3",
        "project_id": "582c99bc-56e9-4aba-b806-5479ae3c66b5",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/582c99bc-56e9-4aba-b806-5479ae3c66b5"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/contexts",
    "current": "http://example.org/contexts?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Context name |
| data[attributes][description] | Context description |
| data[attributes][project_id] | Project ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


# Object Occurrences

Object Occurrences represent the occurrence of a System Element in a given Context with a given aspect.

<aside class="notice">
  Default (and max) page size: 1000
</aside>


## List Object Occurrences


### Request

#### Endpoint

```plaintext
GET /object_occurrences
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic Y2xpZW50X2lk:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /object_occurrences`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 13cfaf5c-13e6-45e4-bc5a-5430bc040ea6
200 OK
```


```json
{
  "data": [
    {
      "id": "72be370b-3704-4d03-9d4b-1c1777e4427f",
      "type": "object_occurrence",
      "attributes": {
        "name": "OOC 1"
      },
      "relationships": {
        "context": {
          "links": {
            "related": "/contexts/3726e858-474d-47b3-a588-cf139903f66a"
          }
        }
      }
    },
    {
      "id": "5bbf1944-0dda-44ae-95db-41d6ed895d20",
      "type": "object_occurrence",
      "attributes": {
        "name": "OOC 2"
      },
      "relationships": {
        "context": {
          "links": {
            "related": "/contexts/3726e858-474d-47b3-a588-cf139903f66a"
          }
        }
      }
    },
    {
      "id": "db456014-72f6-44c4-b6d8-3575a201cc49",
      "type": "object_occurrence",
      "attributes": {
        "name": "OOC 3"
      },
      "relationships": {
        "context": {
          "links": {
            "related": "/contexts/3726e858-474d-47b3-a588-cf139903f66a"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/object_occurrences",
    "current": "http://example.org/object_occurrences?page[number]=1&sort=name"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


