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

## Authentication

```
GET /resource
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

Authentication happens through <a href="https://auth0.com/docs/quickstarts" target="_blank">Auth0</a>
with a preconfigured OAuth2 Client.

Any client must first be setup to access the <code>subdomain</code>'s Auth0 tenant, and then
authenticate with the Auth0 API to retrieve a bearer token.

Then access this API with the bearer token in the Authorization header:

<aside class="notice">
  The client <strong>MUST</strong> send the <code>Authorization</code> header along with every
  request.
</aside>

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

## Deprecating fields

```
GET /resources/12e17944-c3ac-4488-a930-8a00f237c759

200 OK
{
  "data": {
    "id": "12e17944-c3ac-4488-a930-8a00f237c759",
    "type": "resource",
    "attributes": {
      "name": "Some name",
      "field1": "Some value"
    },
    "relationships": {
      "some_relation": {
        "links": {
          "related": "/old/path/to/related/resource"
        }
      },
      "new_relation": {
        "links": {
          "related": "/new/path/to/related/resource"
        }
      }
    },
    "meta": {
      "deprecations": {
        "data.attributes.field1": {
          "replacement": null,
          "removal_date": "Wed, 21 Oct 2020 07:28:00 GMT"
        },
        "data.relationships.some_relation": {
          "replacement": "data.relationships.new_relation",
          "removal_date": "Wed, 21 Oct 2020 07:28:00 GMT"
        }
      }
    }
  }
}
```

Because of the nature of APIs and clients, we need a way to gracefully deprecate fields and
relations on resources. This will be done using the resource's meta block.

The <code>deprecation</code> field uses JSON paths to indicate the field/relation that's being
deprecated.

Deprecations will ususally happen 6 months in advance.

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


## Show


### Request

#### Endpoint

```plaintext
GET /
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 18db86af-c5d9-4d8e-bccd-17b601ac5967
200 OK
```


```json
{
  "data": {
    "id": "7674df0f-1e5d-419d-bdd6-385a5574d0fc",
    "type": "account",
    "attributes": {
      "name": "Account 5b4941ead682"
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


## Update


### Request

#### Endpoint

```plaintext
PATCH /
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /`

#### Parameters


```json
{
  "data": {
    "id": "090e895f-2dc2-4168-848a-cf09f69f58cb",
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
X-Request-Id: e7eae04d-3eb2-4ba8-9866-f220bb1aad80
200 OK
```


```json
{
  "data": {
    "id": "090e895f-2dc2-4168-848a-cf09f69f58cb",
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


## List


### Request

#### Endpoint

```plaintext
GET /projects
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 92b27f4d-4ba5-435c-b327-bb66af9a126f
200 OK
```


```json
{
  "data": [
    {
      "id": "98cf0890-c32b-4c68-82bf-7d716c124f0e",
      "type": "project",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": "Project description",
        "name": "project 1"
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=98cf0890-c32b-4c68-82bf-7d716c124f0e"
          }
        }
      }
    },
    {
      "id": "ccd312a4-dd94-44b4-b9da-ab6d4ecbc613",
      "type": "project",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": "Project description",
        "name": "project 2"
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=ccd312a4-dd94-44b4-b9da-ab6d4ecbc613"
          }
        }
      }
    },
    {
      "id": "c4008e08-d32f-4c1b-9225-b3b984a21e2b",
      "type": "project",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": "Project description",
        "name": "project 3"
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=c4008e08-d32f-4c1b-9225-b3b984a21e2b"
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


## Show


### Request

#### Endpoint

```plaintext
GET /projects/98c26716-bab4-4064-953e-b6959c130387
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c36f90d2-e075-4072-b7b9-eadceef1be7d
200 OK
```


```json
{
  "data": {
    "id": "98c26716-bab4-4064-953e-b6959c130387",
    "type": "project",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=98c26716-bab4-4064-953e-b6959c130387"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/98c26716-bab4-4064-953e-b6959c130387"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Update


### Request

#### Endpoint

```plaintext
PATCH /projects/b2d545df-9bee-48a7-b67d-0b37ccac3346
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "b2d545df-9bee-48a7-b67d-0b37ccac3346",
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
X-Request-Id: 52c610a8-09cf-4309-a58e-680330e4fa91
200 OK
```


```json
{
  "data": {
    "id": "b2d545df-9bee-48a7-b67d-0b37ccac3346",
    "type": "project",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "Project description",
      "name": "New project name"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=b2d545df-9bee-48a7-b67d-0b37ccac3346"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b2d545df-9bee-48a7-b67d-0b37ccac3346"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Archive


### Request

#### Endpoint

```plaintext
POST /projects/80d0aed2-febc-4f03-a9a8-1f200c345616/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5ebec1cb-3fe2-47a1-adbd-fc9acb5a6e67
200 OK
```


```json
{
  "data": {
    "id": "80d0aed2-febc-4f03-a9a8-1f200c345616",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2019-12-05T12:01:35.052Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=80d0aed2-febc-4f03-a9a8-1f200c345616"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/80d0aed2-febc-4f03-a9a8-1f200c345616/archive"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Destroy


### Request

#### Endpoint

```plaintext
DELETE /projects/d1f78355-cec7-411e-8772-410200c25b7f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 72cd62dd-ce00-4315-9bf4-af89afe15482
204 No Content
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
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 26531a97-d8dc-46c9-bb0c-9d000d0f2aa5
200 OK
```


```json
{
  "data": [
    {
      "id": "23ea7295-c6d0-4845-a29a-7bac53a1fd7c",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "d577441e-3be8-4cb8-ab0e-a516eba47cb0",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/d577441e-3be8-4cb8-ab0e-a516eba47cb0"
          }
        }
      }
    },
    {
      "id": "bfd2c0fa-ef23-47ab-8baf-c14fa07cbd48",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "d577441e-3be8-4cb8-ab0e-a516eba47cb0",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/d577441e-3be8-4cb8-ab0e-a516eba47cb0"
          }
        }
      }
    },
    {
      "id": "c8397ac4-bd0f-4317-9d78-17e2cf00ebfb",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 3",
        "project_id": "febda159-f0e5-4894-9df7-c7069e8f88df",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/febda159-f0e5-4894-9df7-c7069e8f88df"
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


## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/d741c7bc-3e93-491b-9909-715bc19c9844
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/:id`

#### Parameters



| Name | Description |
|:-----|:------------|
| depth  | Components depth |



### Response

```plaintext
X-Request-Id: 52aaf00a-b0be-4b87-99ed-ee1bc251ee63
200 OK
```


```json
{
  "data": {
    "id": "d741c7bc-3e93-491b-9909-715bc19c9844",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "6dc3114d-3458-4c26-aa01-1a3ea2da72fc",
      "description": null,
      "hex_color": null,
      "name": "OOC 1",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": ""
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/6dc3114d-3458-4c26-aa01-1a3ea2da72fc"
        }
      },
      "components": {
        "data": [
          {
            "id": "86fcf618-fc09-40e2-a83a-86a4a019c19d",
            "type": "object_occurrence"
          }
        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d741c7bc-3e93-491b-9909-715bc19c9844"
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
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 89595af0-4b4a-4bea-9322-70f3c21c74b5
200 OK
```


```json
{
  "data": [
    {
      "id": "6f587ff0-39f2-4405-8050-b5b76d2b2b15",
      "type": "classification_table",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "CT 1",
        "published": false,
        "published_at": null,
        "type": "core",
        "max_classification_entries_depth": 3
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=6f587ff0-39f2-4405-8050-b5b76d2b2b15"
          }
        }
      }
    },
    {
      "id": "063456da-d14b-4e01-bf41-384ed8da7a75",
      "type": "classification_table",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "CT 2",
        "published": false,
        "published_at": null,
        "type": "core",
        "max_classification_entries_depth": 3
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=063456da-d14b-4e01-bf41-384ed8da7a75"
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


## Show


### Request

#### Endpoint

```plaintext
GET /classification_tables/0cec2cdc-6e4e-4a26-9c0c-8f10a20f7396
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 008c1004-87fa-41af-b8e5-f80bf7da3706
200 OK
```


```json
{
  "data": {
    "id": "0cec2cdc-6e4e-4a26-9c0c-8f10a20f7396",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=0cec2cdc-6e4e-4a26-9c0c-8f10a20f7396"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0cec2cdc-6e4e-4a26-9c0c-8f10a20f7396"
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


## Update


### Request

#### Endpoint

```plaintext
PATCH /classification_tables/8fb63739-b438-4e76-9d28-fa7e0326ac42
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "8fb63739-b438-4e76-9d28-fa7e0326ac42",
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
X-Request-Id: 0377a33e-2607-41d6-8c8b-b98c77f77fa0
200 OK
```


```json
{
  "data": {
    "id": "8fb63739-b438-4e76-9d28-fa7e0326ac42",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "New classification table name",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=8fb63739-b438-4e76-9d28-fa7e0326ac42"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/8fb63739-b438-4e76-9d28-fa7e0326ac42"
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
DELETE /classification_tables/feacdb89-fdb7-4b3b-a853-22e2f9dd890f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3fb1b126-0444-475e-8edd-d9e7015d43ca
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
POST /classification_tables/afd3dbdd-b328-472b-adee-2b3627bd91b2/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1856bfae-df0a-4d8d-8f2b-d35023923b11
200 OK
```


```json
{
  "data": {
    "id": "afd3dbdd-b328-472b-adee-2b3627bd91b2",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2019-12-05T12:01:38.011Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=afd3dbdd-b328-472b-adee-2b3627bd91b2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/afd3dbdd-b328-472b-adee-2b3627bd91b2/publish"
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


## Archive


### Request

#### Endpoint

```plaintext
POST /classification_tables/3dfdf1b8-8c64-40b2-9419-96a86d6da364/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f17108cd-712d-431b-a111-f00737ca658c
200 OK
```


```json
{
  "data": {
    "id": "3dfdf1b8-8c64-40b2-9419-96a86d6da364",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2019-12-05T12:01:38.279Z",
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=3dfdf1b8-8c64-40b2-9419-96a86d6da364"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/3dfdf1b8-8c64-40b2-9419-96a86d6da364/archive"
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
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
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
X-Request-Id: e5b2aa75-cd17-4f6c-9361-c728ee1db315
201 Created
```


```json
{
  "data": {
    "id": "f2f00510-d7e7-4fed-8a93-ac603975e1f1",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "New description",
      "name": "New classification table name",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=f2f00510-d7e7-4fed-8a93-ac603975e1f1"
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


# Syntaxes

A Syntax is a way of expressing the structure (a set of positioning rules) that Object Occurrences can take within a Context.
Effectively this guides how the Object Occurrence tree structure inside the Contexts may look like.

A Syntax consists of Syntax Elements and Syntax Nodes.
The Syntax Elements represent the building blocks, e.i. the abstraction levels.
The Syntax Nodes represent the combination of these abstraction layers (Syntax Elements).


## List


### Request

#### Endpoint

```plaintext
GET /syntaxes
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 86661dbd-1e34-4b0a-b118-b168fbb463ad
200 OK
```


```json
{
  "data": [
    {
      "id": "e03fc852-2d6c-4a58-aff8-aa857944a305",
      "type": "syntax",
      "attributes": {
        "account_id": "bb270e9c-038b-4d1c-ac8b-f22487cc4c76",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 40c1b45a0e43",
        "published": false,
        "published_at": null
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/syntaxes",
    "current": "http://example.org/syntaxes?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


## Show


### Request

#### Endpoint

```plaintext
GET /syntaxes/7392a1c6-58e4-429b-ade5-058e158c237f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7948cd09-2cfa-4928-80dd-7f8951734649
200 OK
```


```json
{
  "data": {
    "id": "7392a1c6-58e4-429b-ade5-058e158c237f",
    "type": "syntax",
    "attributes": {
      "account_id": "1ee7fcbe-ec3c-4783-8d75-bffb5d2687f6",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax b7b6633b3214",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/7392a1c6-58e4-429b-ade5-058e158c237f"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


## Create


### Request

#### Endpoint

```plaintext
POST /syntaxes
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes`

#### Parameters


```json
{
  "data": {
    "type": "syntax",
    "attributes": {
      "name": "Syntax",
      "description": "Description"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 8a7596b2-b3a7-4c10-9a29-8f9b39fc66ee
201 Created
```


```json
{
  "data": {
    "id": "d001528e-a439-406c-8f1f-6598b9ea2506",
    "type": "syntax",
    "attributes": {
      "account_id": "22d42434-4f55-4d9c-ac0c-c54d867c4861",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


## Update


### Request

#### Endpoint

```plaintext
PATCH /syntaxes/c85f08c3-54a2-45f7-929a-33cf080dfffd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "c85f08c3-54a2-45f7-929a-33cf080dfffd",
    "type": "syntaxes",
    "attributes": {
      "name": "New name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New name |



### Response

```plaintext
X-Request-Id: b5762555-ad65-413c-bbaf-013b45772194
200 OK
```


```json
{
  "data": {
    "id": "c85f08c3-54a2-45f7-929a-33cf080dfffd",
    "type": "syntax",
    "attributes": {
      "account_id": "2745c5e5-1020-4dc3-b033-2de1cb470663",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "New name",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/c85f08c3-54a2-45f7-929a-33cf080dfffd"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /syntaxes/585e501a-e970-42d1-81bc-13bb9ecc199d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4adb7985-43bc-4c9b-aad0-d9c55ac63e01
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


## Publish


### Request

#### Endpoint

```plaintext
POST /syntaxes/4f81bbd0-a5f1-460d-be12-0f675412e3d9/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 186b2ba4-e6fe-4c0d-9264-0bfa31f2ea99
200 OK
```


```json
{
  "data": {
    "id": "4f81bbd0-a5f1-460d-be12-0f675412e3d9",
    "type": "syntax",
    "attributes": {
      "account_id": "45472451-41ae-478c-9791-0b855b1c63cf",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 652b738282ae",
      "published": true,
      "published_at": "2019-12-05T12:01:40.086Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/4f81bbd0-a5f1-460d-be12-0f675412e3d9/publish"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


## Archive


### Request

#### Endpoint

```plaintext
POST /syntaxes/255c7065-5958-492a-9ecb-c05a210ba49f/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e5e034ca-6cc5-4e7f-bd7f-de86f065c44e
200 OK
```


```json
{
  "data": {
    "id": "255c7065-5958-492a-9ecb-c05a210ba49f",
    "type": "syntax",
    "attributes": {
      "account_id": "5d1d9565-5fbc-4fae-95e7-af6475632072",
      "archived": true,
      "archived_at": "2019-12-05T12:01:40.351Z",
      "description": "Description",
      "name": "Syntax 623139fbeeb2",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/255c7065-5958-492a-9ecb-c05a210ba49f/archive"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax name |
| data[attributes][description] | Syntax description |
| data[attributes][account_id] | Account ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |


# Syntax Elements

Syntax Elements represent the abstraction levels of the syntax; the principle abstractions levels of the Context.


## List syntax elements


### Request

#### Endpoint

```plaintext
GET /syntax_elements
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3adc17de-9a5d-470d-967a-4f26d20012d7
200 OK
```


```json
{
  "data": [
    {
      "id": "8eab66eb-919a-425d-96fc-5c0592227228",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "811b6683-9810-43cf-b1a2-29cd6f17bb1c",
        "hex_color": "7ea449",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 8324f2112347",
        "syntax_id": "0d76649a-c6d2-491d-932e-38a2fc1dd361"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/0d76649a-c6d2-491d-932e-38a2fc1dd361"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/811b6683-9810-43cf-b1a2-29cd6f17bb1c"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/syntax_elements",
    "current": "http://example.org/syntax_elements?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax element name |
| data[attributes][min_number] | Minimum OOC numbering in leaf |
| data[attributes][max_number] | Maximum OOC numbering in leaf |
| data[attributes][hex_color] | Hexadecimal value which represents color. I.e 001122 - without hash(#) sign. |
| data[attributes][aspect] | It represents type of aspect (e.g. functional, location, electrical, or other) and it's a prefix for the OOC's |
| data[attributes][syntax_id] | Syntax ID |
| data[attributes][classification_table_id] | Classification Table ID |


## Syntax element information


### Request

#### Endpoint

```plaintext
GET /syntax_elements/edb9d9d6-1e6c-47a9-8dbd-66d7f4411c39
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a1f89d6a-892b-4b78-bc7d-baa40db9b6cc
200 OK
```


```json
{
  "data": {
    "id": "edb9d9d6-1e6c-47a9-8dbd-66d7f4411c39",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "33daeb35-fd62-4793-ad72-e9a99f4fce29",
      "hex_color": "87538f",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element d3a994346307",
      "syntax_id": "acc0bfea-328d-4668-b9d9-c43dceba0dc0"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/acc0bfea-328d-4668-b9d9-c43dceba0dc0"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/33daeb35-fd62-4793-ad72-e9a99f4fce29"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/edb9d9d6-1e6c-47a9-8dbd-66d7f4411c39"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax element name |
| data[attributes][min_number] | Minimum OOC numbering in leaf |
| data[attributes][max_number] | Maximum OOC numbering in leaf |
| data[attributes][hex_color] | Hexadecimal value which represents color. I.e 001122 - without hash(#) sign. |
| data[attributes][aspect] | It represents type of aspect (e.g. functional, location, electrical, or other) and it's a prefix for the OOC's |
| data[attributes][syntax_id] | Syntax ID |
| data[attributes][classification_table_id] | Classification Table ID |


## Create


### Request

#### Endpoint

```plaintext
POST /syntax_elements
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntax_elements`

#### Parameters


```json
{
  "data": {
    "type": "syntax_element",
    "attributes": {
      "name": "Element",
      "min_number": 1,
      "max_number": 5,
      "hex_color": "001122",
      "aspect": "#",
      "syntax_id": "7925b605-22e1-4663-8f8d-74cbdbd88e2d",
      "classification_table_id": "669fb6c5-3b0d-442b-bb2c-358e25fb2240"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 609efce4-3a4b-4e4f-83bd-e167cfe63cea
201 Created
```


```json
{
  "data": {
    "id": "a4dfd498-f3d1-4e97-a292-05ddcfd8c398",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "669fb6c5-3b0d-442b-bb2c-358e25fb2240",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "syntax_id": "7925b605-22e1-4663-8f8d-74cbdbd88e2d"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/7925b605-22e1-4663-8f8d-74cbdbd88e2d"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/669fb6c5-3b0d-442b-bb2c-358e25fb2240"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax element name |
| data[attributes][min_number] | Minimum OOC numbering in leaf |
| data[attributes][max_number] | Maximum OOC numbering in leaf |
| data[attributes][hex_color] | Hexadecimal value which represents color. I.e 001122 - without hash(#) sign. |
| data[attributes][aspect] | It represents type of aspect (e.g. functional, location, electrical, or other) and it's a prefix for the OOC's |
| data[attributes][syntax_id] | Syntax ID |
| data[attributes][classification_table_id] | Classification Table ID |


## Update


### Request

#### Endpoint

```plaintext
PATCH /syntax_elements/28714239-6316-4f45-8fae-751948cbc351
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "28714239-6316-4f45-8fae-751948cbc351",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New name |



### Response

```plaintext
X-Request-Id: ad4f3bb5-d6bd-4663-9b48-3f2ddf7ee671
200 OK
```


```json
{
  "data": {
    "id": "28714239-6316-4f45-8fae-751948cbc351",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "ee4ba0e4-894a-4e82-ae41-e870f5de9d6d",
      "hex_color": "deb349",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "syntax_id": "7e498dfa-2884-4601-a53e-cac472eeff59"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/7e498dfa-2884-4601-a53e-cac472eeff59"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/ee4ba0e4-894a-4e82-ae41-e870f5de9d6d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/28714239-6316-4f45-8fae-751948cbc351"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax element name |
| data[attributes][min_number] | Minimum OOC numbering in leaf |
| data[attributes][max_number] | Maximum OOC numbering in leaf |
| data[attributes][hex_color] | Hexadecimal value which represents color. I.e 001122 - without hash(#) sign. |
| data[attributes][aspect] | It represents type of aspect (e.g. functional, location, electrical, or other) and it's a prefix for the OOC's |
| data[attributes][syntax_id] | Syntax ID |
| data[attributes][classification_table_id] | Classification Table ID |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /syntax_elements/6daf6e86-07bd-4e3a-84e7-1e985cf0c6f4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 67de1434-9a21-491e-b843-ee13439c2d14
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Syntax element name |
| data[attributes][min_number] | Minimum OOC numbering in leaf |
| data[attributes][max_number] | Maximum OOC numbering in leaf |
| data[attributes][hex_color] | Hexadecimal value which represents color. I.e 001122 - without hash(#) sign. |
| data[attributes][aspect] | It represents type of aspect (e.g. functional, location, electrical, or other) and it's a prefix for the OOC's |
| data[attributes][syntax_id] | Syntax ID |
| data[attributes][classification_table_id] | Classification Table ID |


# Syntax nodes

Syntax Nodes is the structure, in which Contexts are allowed to represent Syntax Elements. Syntax Nodes make up a graph tree.


## Show


### Request

#### Endpoint

```plaintext
GET /syntax_nodes/9b632589-e756-49d4-96cb-0b830d4e2e49
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_nodes/:id`

#### Parameters



| Name | Description |
|:-----|:------------|
| depth  | Components depth |



### Response

```plaintext
X-Request-Id: 3d88ba11-6459-4801-9047-c6ba563d0b82
200 OK
```


```json
{
  "data": {
    "id": "9b632589-e756-49d4-96cb-0b830d4e2e49",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1,
      "syntax_element_id": "9f76b589-99bd-4822-9971-d24470325310"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/9f76b589-99bd-4822-9971-d24470325310"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/9b632589-e756-49d4-96cb-0b830d4e2e49"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


## Create


### Request

#### Endpoint

```plaintext
POST /syntax_nodes
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntax_nodes`

#### Parameters


```json
{
  "data": {
    "type": "syntax_node",
    "attributes": {
      "position": 9,
      "min_depth": 1,
      "max_depth": 5,
      "syntax_element_id": "6cc07c8c-1c65-4fb9-9883-b54696271ce8"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: a3cdc08f-7420-4889-a5d7-bc12d2dc9fc2
201 Created
```


```json
{
  "data": {
    "id": "82d2fe00-8dca-42c7-a5d3-daba3ba3a690",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9,
      "syntax_element_id": "6cc07c8c-1c65-4fb9-9883-b54696271ce8"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/6cc07c8c-1c65-4fb9-9883-b54696271ce8"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


## Update


### Request

#### Endpoint

```plaintext
PATCH /syntax_nodes/ce095abe-f726-4652-a804-9e8afb9b49ef
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "ce095abe-f726-4652-a804-9e8afb9b49ef",
    "type": "syntax_node",
    "attributes": {
      "position": 5
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][position]  | New position |



### Response

```plaintext
X-Request-Id: 299b6aa1-8513-4d8e-8f78-9ad04dc54786
200 OK
```


```json
{
  "data": {
    "id": "ce095abe-f726-4652-a804-9e8afb9b49ef",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5,
      "syntax_element_id": "ba660738-3506-4e7a-8a1d-27106f579edf"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/ba660738-3506-4e7a-8a1d-27106f579edf"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/ce095abe-f726-4652-a804-9e8afb9b49ef"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /syntax_nodes/9365f904-595f-4d33-8c08-fe4cce5e86c0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a86cf778-08da-476f-bbab-317c23c1ad4b
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


# Heartbeat

Check the runtime health of the application.


## OK


### Request

#### Endpoint

```plaintext
GET /heartbeat

```

`GET /heartbeat`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 569d774c-7aa9-4507-9650-7a49c3998d4f
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



# Events

Events is a way to track which changes and events has happened to resources.


## List


### Request

#### Endpoint

```plaintext
GET /events
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /events`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1f6be2f3-0fb9-4866-99c3-911ac08e8875
200 OK
```


```json
{
  "data": [
    {
      "id": "dd1cc491-da06-4bb8-b9e9-9d1ea34e68bd",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/bf6edac1-9697-41a1-b913-3cd6dedb061d"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/717d5d3c-868e-47ee-9b75-2d786d64113a"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/events",
    "current": "http://example.org/events?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][event] | Event name |


