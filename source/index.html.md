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

## Multi-language support

```
GET /resources
Accept-Language: da-DK

200 OK
{
  "data": {
    "id": "12e17944-c3ac-4488-a930-8a00f237c759"
  },

  "meta": {
    "locales": [
      "en",
      "da",
      "fr",
      "de"
    ],
    "current_locale": "da"
  }
}
```

Changing the `Accept-Language` header will prompt the API to attempt to serve or manipulate the
resource in the specified language. If the API doesn't have the resource in a localized form it
will be returned in English.

Information about the current locale is present in the meta block for the resource. This will
contain all the locales that the resource is available in, and the current locale that it's
being served in.

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
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi
:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5b093f84-a7f8-4ce8-8786-16f3c63651a4
200 OK
```


```json
{
  "data": {
    "id": "3a2358fa-57c5-413f-9489-36e75363f96f",
    "type": "account",
    "attributes": {
      "name": "Account 4c811eacfe5a"
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
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi
:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`PATCH /`

#### Parameters


```json
{
  "data": {
    "id": "3385b8d0-90d5-48a7-a88f-77ebf9992ef8",
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
X-Request-Id: 55c815d3-c161-4415-8200-e1cc3ee15ad0
200 OK
```


```json
{
  "data": {
    "id": "3385b8d0-90d5-48a7-a88f-77ebf9992ef8",
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
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /projects`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4e17cdd0-469a-45b3-b360-9a0bed1ca188
200 OK
```


```json
{
  "data": [
    {
      "id": "4f3e4c52-1617-40f6-b36f-fd874cfdd548",
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
            "self": "/contexts?filter[project_id_eq]=4f3e4c52-1617-40f6-b36f-fd874cfdd548"
          }
        }
      }
    },
    {
      "id": "96d309a9-e632-440c-8f55-5206367b8956",
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
            "self": "/contexts?filter[project_id_eq]=96d309a9-e632-440c-8f55-5206367b8956"
          }
        }
      }
    },
    {
      "id": "313f9ed8-63f6-4384-9d55-038f7381369f",
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
            "self": "/contexts?filter[project_id_eq]=313f9ed8-63f6-4384-9d55-038f7381369f"
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
GET /projects/30d1cf08-9772-440e-a2aa-c02dd65368e1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6da51597-95f7-4ec1-b08f-bfbb70d15d0c
200 OK
```


```json
{
  "data": {
    "id": "30d1cf08-9772-440e-a2aa-c02dd65368e1",
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
          "self": "/contexts?filter[project_id_eq]=30d1cf08-9772-440e-a2aa-c02dd65368e1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/30d1cf08-9772-440e-a2aa-c02dd65368e1"
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
PATCH /projects/c4d2924f-2769-48cc-9d55-ddeef3b58527
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "c4d2924f-2769-48cc-9d55-ddeef3b58527",
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
X-Request-Id: ed825581-2771-4c74-9b5e-3802b0152f20
200 OK
```


```json
{
  "data": {
    "id": "c4d2924f-2769-48cc-9d55-ddeef3b58527",
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
          "self": "/contexts?filter[project_id_eq]=c4d2924f-2769-48cc-9d55-ddeef3b58527"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/c4d2924f-2769-48cc-9d55-ddeef3b58527"
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
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /contexts`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 98ce7e36-e85a-41e4-ad53-07e1b5c8f0b7
200 OK
```


```json
{
  "data": [
    {
      "id": "773f73b3-0602-46b3-b628-388012d169d3",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "45dfb9a4-9c35-4f3a-b79d-a556f7a2044d",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/45dfb9a4-9c35-4f3a-b79d-a556f7a2044d"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=773f73b3-0602-46b3-b628-388012d169d3"
          }
        }
      }
    },
    {
      "id": "a91fe996-8983-4b86-9ae0-b5b36939b032",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "45dfb9a4-9c35-4f3a-b79d-a556f7a2044d",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/45dfb9a4-9c35-4f3a-b79d-a556f7a2044d"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=a91fe996-8983-4b86-9ae0-b5b36939b032"
          }
        }
      }
    },
    {
      "id": "1d5f165e-f9eb-4ea6-b9c5-1535f122e414",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 3",
        "project_id": "6dd02fd9-2e5f-4fcb-8065-154cde19f7c2",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "self": "/projects/6dd02fd9-2e5f-4fcb-8065-154cde19f7c2"
          }
        },
        "object_occurrences": {
          "links": {
            "self": "/object_occurrences?filter[context_id_eq]=1d5f165e-f9eb-4ea6-b9c5-1535f122e414"
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
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /object_occurrences`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e23a303e-9723-490e-b99f-23c5470d0b5b
200 OK
```


```json
{
  "data": [
    {
      "id": "d1c184af-d385-48b0-ad8e-64cca04d2794",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "fa107aeb-e045-48ce-b681-d9452f58c9c4",
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
            "related": "/contexts/fa107aeb-e045-48ce-b681-d9452f58c9c4"
          }
        }
      }
    },
    {
      "id": "f70123bd-ecb2-44dd-a3c2-8c9d467d80de",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "fa107aeb-e045-48ce-b681-d9452f58c9c4",
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
            "related": "/contexts/fa107aeb-e045-48ce-b681-d9452f58c9c4"
          }
        }
      }
    },
    {
      "id": "f714dfee-8821-45db-85a9-6a113dc946b3",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "fa107aeb-e045-48ce-b681-d9452f58c9c4",
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
            "related": "/contexts/fa107aeb-e045-48ce-b681-d9452f58c9c4"
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


# Classification Tables

Classification tables represent a strategic breakdown of the company product(s) into a nuanced
and logically separated classification table structure.

Each classification table has multiple classification entries.


## List


### Request

#### Endpoint

```plaintext
GET /classification_tables
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /classification_tables`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f895efdc-2399-4399-81f9-821392b20512
200 OK
```


```json
{
  "data": [
    {
      "id": "7da3559b-2228-468f-b578-873f1c96a124",
      "type": "classification_table",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "CT 1",
        "published": false,
        "published_at": null,
        "type": "core"
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
      "id": "a200fb93-ad3b-4a08-afa4-e3bcf7196b68",
      "type": "classification_table",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "CT 2",
        "published": false,
        "published_at": null,
        "type": "core"
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
    "self": "http://example.org/classification_tables",
    "current": "http://example.org/classification_tables?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Common name |
| data[attributes][archived_at] | Archived date |
| data[attributes][archived] | Archived |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][type] | Type |


## Get details


### Request

#### Endpoint

```plaintext
GET /classification_tables/a58ca7f7-8e18-4d7d-ac94-28c1f765f552
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fbeac84b-5905-4459-becc-3fa8d6e56063
200 OK
```


```json
{
  "data": {
    "id": "a58ca7f7-8e18-4d7d-ac94-28c1f765f552",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core"
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
    "self": "http://example.org/classification_tables/a58ca7f7-8e18-4d7d-ac94-28c1f765f552"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Common name |
| data[attributes][archived_at] | Archived date |
| data[attributes][archived] | Archived |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][type] | Type |


## Update details


### Request

#### Endpoint

```plaintext
PATCH /classification_tables/2a517ba9-9d2c-4d54-ae9d-24cbc3e48b79
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "2a517ba9-9d2c-4d54-ae9d-24cbc3e48b79",
    "type": "classification_table",
    "attributes": {
      "name": "New classification table name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New Classification Table name |



### Response

```plaintext
X-Request-Id: af8e4282-e64a-4894-bcb3-3f1fc395b23c
200 OK
```


```json
{
  "data": {
    "id": "2a517ba9-9d2c-4d54-ae9d-24cbc3e48b79",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "New classification table name",
      "published": false,
      "published_at": null,
      "type": "core"
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
    "self": "http://example.org/classification_tables/2a517ba9-9d2c-4d54-ae9d-24cbc3e48b79"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Common name |
| data[attributes][archived_at] | Archived date |
| data[attributes][archived] | Archived |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][type] | Type |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /classification_tables/a6970ced-0d9c-4574-9de8-0ba3b5a48ce2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 427829f6-b4e7-4265-9a3c-2b7f04e43f15
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Common name |
| data[attributes][archived_at] | Archived date |
| data[attributes][archived] | Archived |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][type] | Type |


## Publish


### Request

#### Endpoint

```plaintext
POST /classification_tables/60ba1feb-c893-4563-8e6f-c62a178093b2/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 955d65b5-2a8b-4380-82a1-79b9a4c0fc45
200 OK
```


```json
{
  "data": {
    "id": "60ba1feb-c893-4563-8e6f-c62a178093b2",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2019-11-07T18:25:44.785Z",
      "type": "core"
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
    "self": "http://example.org/classification_tables/60ba1feb-c893-4563-8e6f-c62a178093b2/publish"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Common name |
| data[attributes][archived_at] | Archived date |
| data[attributes][archived] | Archived |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][type] | Type |


## Create


### Request

#### Endpoint

```plaintext
POST /classification_tables
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Proxy-Authorization: Basic YjI2ZTJhNWYtNTM0MC00ZTM1LWI4MGUtZWVmNzkxZmE4ZjZi:Y2xpZW50X3NlY3JldA==
Authorization: Bearer 1/mZ1edKKACtPAb7zGlwSzvs72PvhAbGmB8K1ZrGxpcNM
```

`POST /classification_tables`

#### Parameters


```json
{
  "data": {
    "type": "classification_table",
    "attributes": {
      "name": "New classification table name",
      "description": "New description"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 47abc319-806e-4440-b96b-2f33f5f6255d
201 Created
```


```json
{
  "data": {
    "id": "04f76948-b1a1-4135-b2e6-5debbe951436",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "New description",
      "name": "New classification table name",
      "published": false,
      "published_at": null,
      "type": "core"
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
    "self": "http://example.org/classification_tables"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Common name |
| data[attributes][archived_at] | Archived date |
| data[attributes][archived] | Archived |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][type] | Type |


