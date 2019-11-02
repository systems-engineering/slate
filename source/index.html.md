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
X-Request-Id: 35814ada-1afd-4489-8560-c99182a92b4e
200 OK
```


```json
{
  "data": {
    "id": "64d1059a-39d2-4451-8861-d4e9a1c63295",
    "type": "account",
    "attributes": {
      "name": "Account 46343cab2c57"
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
    "id": "b8b2e7e1-1b99-4885-bd8e-a622b8469bf5",
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
X-Request-Id: b610b1bc-b036-40c0-affa-73789d47792b
200 OK
```


```json
{
  "data": {
    "id": "b8b2e7e1-1b99-4885-bd8e-a622b8469bf5",
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
X-Request-Id: 9abedee3-2dda-4ba8-bd6a-6b167781592f
200 OK
```


```json
{
  "data": [
    {
      "id": "7d29caad-f9d3-449c-9b4c-1d80f14cc7e4",
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
            "self": "/contexts?filter[project_id_eq]=7d29caad-f9d3-449c-9b4c-1d80f14cc7e4"
          }
        }
      }
    },
    {
      "id": "d382b479-3483-474f-8741-e586daadec7d",
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
            "self": "/contexts?filter[project_id_eq]=d382b479-3483-474f-8741-e586daadec7d"
          }
        }
      }
    },
    {
      "id": "f64ffd00-f872-4f4f-ad6b-fc84d97deaf2",
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
            "self": "/contexts?filter[project_id_eq]=f64ffd00-f872-4f4f-ad6b-fc84d97deaf2"
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
GET /projects/3603836a-c24f-4315-94b2-ee2e6ee03c86
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
X-Request-Id: 4367eeea-4e31-483b-8f82-67de1a8a2c1f
200 OK
```


```json
{
  "data": {
    "id": "3603836a-c24f-4315-94b2-ee2e6ee03c86",
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
          "self": "/contexts?filter[project_id_eq]=3603836a-c24f-4315-94b2-ee2e6ee03c86"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/3603836a-c24f-4315-94b2-ee2e6ee03c86"
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
PATCH /projects/24e73663-c148-4627-b137-ca5eecb02199
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
    "id": "24e73663-c148-4627-b137-ca5eecb02199",
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
X-Request-Id: 1842d532-d7cc-4219-b9d0-f7cf5b2bbf2b
200 OK
```


```json
{
  "data": {
    "id": "24e73663-c148-4627-b137-ca5eecb02199",
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
          "self": "/contexts?filter[project_id_eq]=24e73663-c148-4627-b137-ca5eecb02199"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/24e73663-c148-4627-b137-ca5eecb02199"
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
X-Request-Id: 309a0f51-9812-4a41-9f24-a86423eb57bd
200 OK
```


```json
{
  "data": [
    {
      "id": "07a2be90-c8a0-41f1-97a4-6af6255e1b89",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "bc3d69aa-3982-43b7-b83d-ef939081bc5c",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/bc3d69aa-3982-43b7-b83d-ef939081bc5c"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=07a2be90-c8a0-41f1-97a4-6af6255e1b89"
          }
        }
      }
    },
    {
      "id": "0a7dab1a-6b06-4476-8218-4688cd1a2041",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "bc3d69aa-3982-43b7-b83d-ef939081bc5c",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/bc3d69aa-3982-43b7-b83d-ef939081bc5c"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=0a7dab1a-6b06-4476-8218-4688cd1a2041"
          }
        }
      }
    },
    {
      "id": "540eb9c6-5ffd-46e0-b036-dd8784850168",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 3",
        "project_id": "c235a4f9-0fb3-4589-bcca-bb2e66e8fe8b",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/c235a4f9-0fb3-4589-bcca-bb2e66e8fe8b"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=540eb9c6-5ffd-46e0-b036-dd8784850168"
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
X-Request-Id: 55c5317f-b100-4196-a13b-2ce2b90e5c76
200 OK
```


```json
{
  "data": [
    {
      "id": "26da8b59-bbc9-490b-bc6c-1eb947e6e831",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "5b413417-3c5b-45c6-90f4-b45cd40736bd",
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
            "related": "/contexts/5b413417-3c5b-45c6-90f4-b45cd40736bd"
          }
        }
      }
    },
    {
      "id": "9cd1413e-d404-46fe-96c5-714488f276c6",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "5b413417-3c5b-45c6-90f4-b45cd40736bd",
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
            "related": "/contexts/5b413417-3c5b-45c6-90f4-b45cd40736bd"
          }
        }
      }
    },
    {
      "id": "fc3c9882-69b6-4b85-b730-42e157580485",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "5b413417-3c5b-45c6-90f4-b45cd40736bd",
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
            "related": "/contexts/5b413417-3c5b-45c6-90f4-b45cd40736bd"
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


