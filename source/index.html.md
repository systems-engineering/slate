---
title: SEC Hub Consumer API
language_tabs:
  - json: JSON
includes:
  - errors
search: true
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
X-Request-Id: f9242d46-b3f9-41c6-8b5d-f25f3d83c8e0
200 OK
```


```json
{
  "data": {
    "id": "d2641cc5-7644-4641-a26c-c5f920f2cfbe",
    "type": "account",
    "attributes": {
      "name": "Account a202656bd637"
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
    "id": "6d3e5cfc-3e7a-47fb-b1cf-63483ae59c17",
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
X-Request-Id: 30f99279-f352-4c7d-8eb4-1eacff3cb49c
200 OK
```


```json
{
  "data": {
    "id": "6d3e5cfc-3e7a-47fb-b1cf-63483ae59c17",
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
X-Request-Id: 574b1756-720e-45c2-b7d4-60cef6618d15
200 OK
```


```json
{
  "data": [
    {
      "id": "9f7df0a8-9631-4e6d-b2d2-581061dd7771",
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
        },
        "contexts": {
          "links": {
            "self": "/contexts?filter[project_id_eq]=9f7df0a8-9631-4e6d-b2d2-581061dd7771"
          }
        }
      }
    },
    {
      "id": "3664276c-3865-43ef-b7c0-5f7ef56a4e57",
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
        },
        "contexts": {
          "links": {
            "self": "/contexts?filter[project_id_eq]=3664276c-3865-43ef-b7c0-5f7ef56a4e57"
          }
        }
      }
    },
    {
      "id": "04b32f28-bbd7-4c23-8a78-3c652e58bc3e",
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
        },
        "contexts": {
          "links": {
            "self": "/contexts?filter[project_id_eq]=04b32f28-bbd7-4c23-8a78-3c652e58bc3e"
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
GET /projects/ad74da37-d6ca-4c59-8a47-ba2693a21ce6
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
X-Request-Id: a5fc38de-d04e-4662-955d-7d792b2adb29
200 OK
```


```json
{
  "data": {
    "id": "ad74da37-d6ca-4c59-8a47-ba2693a21ce6",
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
      },
      "contexts": {
        "links": {
          "self": "/contexts?filter[project_id_eq]=ad74da37-d6ca-4c59-8a47-ba2693a21ce6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/ad74da37-d6ca-4c59-8a47-ba2693a21ce6"
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
PATCH /projects/2d001be7-2200-4502-8ee3-02d55d903977
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
    "id": "2d001be7-2200-4502-8ee3-02d55d903977",
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
X-Request-Id: ec9ce66b-95e9-4bc2-8c1c-8cb849acda3c
200 OK
```


```json
{
  "data": {
    "id": "2d001be7-2200-4502-8ee3-02d55d903977",
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
      },
      "contexts": {
        "links": {
          "self": "/contexts?filter[project_id_eq]=2d001be7-2200-4502-8ee3-02d55d903977"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/2d001be7-2200-4502-8ee3-02d55d903977"
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
X-Request-Id: 42a24348-25d6-46d9-8716-73b6f80ce58d
200 OK
```


```json
{
  "data": [
    {
      "id": "d6805fb6-b446-4c5f-b019-8a9a8f3a589b",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "b88eb357-5d58-405d-a8ad-4b9ac785a2f6",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/b88eb357-5d58-405d-a8ad-4b9ac785a2f6"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=d6805fb6-b446-4c5f-b019-8a9a8f3a589b"
          }
        }
      }
    },
    {
      "id": "30b223a4-73b8-4e98-a2c9-72b0d1a46e9b",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "b88eb357-5d58-405d-a8ad-4b9ac785a2f6",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/b88eb357-5d58-405d-a8ad-4b9ac785a2f6"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=30b223a4-73b8-4e98-a2c9-72b0d1a46e9b"
          }
        }
      }
    },
    {
      "id": "b094b8c5-8a68-402a-b691-3724bcacf38d",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 3",
        "project_id": "98777675-6e96-4809-8be6-c36d1d8716e5",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/98777675-6e96-4809-8be6-c36d1d8716e5"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=b094b8c5-8a68-402a-b691-3724bcacf38d"
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


## List Object Occurrences

List all Object Occurrences. This list will quickly grow quite large, so it's advised to
[use filtering](http://localhost:4567/#json-api) when calling this endpoint.

<aside class="notice">
  Default (and max) page size: 250
</aside>


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
X-Request-Id: e607d979-c0a8-4133-befc-748e0b752d10
200 OK
```


```json
{
  "data": [
    {
      "id": "4f489dff-31d4-4d8f-a92d-b2fbc03ac371",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "de73f36a-c47b-4219-be09-acac17847351",
        "description": null,
        "hex_color": null,
        "name": "OOC 1",
        "number": null,
        "position": null,
        "prefix": null,
        "system_element_relation_id": null
      },
      "relationships": {
        "context": {
          "links": {
            "related": "/contexts/de73f36a-c47b-4219-be09-acac17847351"
          }
        }
      }
    },
    {
      "id": "2933466c-1afe-41ab-b1ab-5e38322868e6",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "de73f36a-c47b-4219-be09-acac17847351",
        "description": null,
        "hex_color": null,
        "name": "OOC 2",
        "number": null,
        "position": null,
        "prefix": null,
        "system_element_relation_id": null
      },
      "relationships": {
        "context": {
          "links": {
            "related": "/contexts/de73f36a-c47b-4219-be09-acac17847351"
          }
        }
      }
    },
    {
      "id": "387ae8f5-10d7-4237-b7c5-4b14b44ee84c",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "de73f36a-c47b-4219-be09-acac17847351",
        "description": null,
        "hex_color": null,
        "name": "OOC 3",
        "number": null,
        "position": null,
        "prefix": null,
        "system_element_relation_id": null
      },
      "relationships": {
        "context": {
          "links": {
            "related": "/contexts/de73f36a-c47b-4219-be09-acac17847351"
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


