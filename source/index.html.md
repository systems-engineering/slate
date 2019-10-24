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
X-Request-Id: 2b8f11f4-f2be-44fe-ba4c-66f0b43755d5
200 OK
```


```json
{
  "data": {
    "id": "608407ef-dd40-4ced-b95f-a0366b1c71a9",
    "type": "account",
    "attributes": {
      "name": "Account e923848ed153"
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
    "id": "101a9a39-5525-4a67-a574-8d4483ffbe3a",
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
X-Request-Id: cfe2ba79-1fed-4dfe-979c-6cac7ea4fef6
200 OK
```


```json
{
  "data": {
    "id": "101a9a39-5525-4a67-a574-8d4483ffbe3a",
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
X-Request-Id: ed942b36-82ec-448a-b6bf-972874935a2e
200 OK
```


```json
{
  "data": [
    {
      "id": "116d0c93-3b70-4005-81a7-e20d67f165b8",
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
      "id": "8e7539a7-ec36-4985-af9f-187d1cd2bda5",
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
      "id": "d29dec6d-ac39-42ec-af02-98039490708c",
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
GET /projects/88d6cacf-88a6-4976-a06a-87552fcbdefe
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
X-Request-Id: e083084b-f288-49c0-a476-c124309af88f
200 OK
```


```json
{
  "data": {
    "id": "88d6cacf-88a6-4976-a06a-87552fcbdefe",
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
    "self": "http://example.org/projects/88d6cacf-88a6-4976-a06a-87552fcbdefe"
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
PATCH /projects/fd5c127c-987f-4fe0-8747-e2fe623096d2
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
    "id": "fd5c127c-987f-4fe0-8747-e2fe623096d2",
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
X-Request-Id: 20bfec09-4064-4802-85b9-9a14a6cc9c2e
200 OK
```


```json
{
  "data": {
    "id": "fd5c127c-987f-4fe0-8747-e2fe623096d2",
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
    "self": "http://example.org/projects/fd5c127c-987f-4fe0-8747-e2fe623096d2"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


