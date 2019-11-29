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
X-Request-Id: 5acaf8e0-2910-4d6e-8071-40f1da9ea1da
200 OK
```


```json
{
  "data": {
    "id": "00218ba6-5ad8-4bab-834a-ef3957ffa999",
    "type": "account",
    "attributes": {
      "name": "Account da24be732938"
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
    "id": "53a28388-9d6e-4a69-baae-5cb0dd07eb22",
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
X-Request-Id: 724bd1e3-6e33-41eb-9fc1-325c6caced34
200 OK
```


```json
{
  "data": {
    "id": "53a28388-9d6e-4a69-baae-5cb0dd07eb22",
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
X-Request-Id: c36dea10-0c3a-4a94-9293-8da6157f6e1b
200 OK
```


```json
{
  "data": [
    {
      "id": "8ee575d4-3e75-432d-80c0-09c9e924cfb6",
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
            "related": "/contexts?filter[project_id_eq]=8ee575d4-3e75-432d-80c0-09c9e924cfb6"
          }
        }
      }
    },
    {
      "id": "f1fa86da-b8a2-4aef-8980-4283ba811eb7",
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
            "related": "/contexts?filter[project_id_eq]=f1fa86da-b8a2-4aef-8980-4283ba811eb7"
          }
        }
      }
    },
    {
      "id": "304fc6c3-6f1d-4539-9d02-3e7986d8e47e",
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
            "related": "/contexts?filter[project_id_eq]=304fc6c3-6f1d-4539-9d02-3e7986d8e47e"
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
GET /projects/a66f055c-a749-450f-8d29-f165cfd3771f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3c5e97d9-8a93-438a-8ccb-c99e1a89268f
200 OK
```


```json
{
  "data": {
    "id": "a66f055c-a749-450f-8d29-f165cfd3771f",
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
          "related": "/contexts?filter[project_id_eq]=a66f055c-a749-450f-8d29-f165cfd3771f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a66f055c-a749-450f-8d29-f165cfd3771f"
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
PATCH /projects/6ac645bd-4f82-489c-8222-2fb619c8e095
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "6ac645bd-4f82-489c-8222-2fb619c8e095",
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
X-Request-Id: 016e3e53-091c-4a82-9bc0-06072785d93c
200 OK
```


```json
{
  "data": {
    "id": "6ac645bd-4f82-489c-8222-2fb619c8e095",
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
          "related": "/contexts?filter[project_id_eq]=6ac645bd-4f82-489c-8222-2fb619c8e095"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/6ac645bd-4f82-489c-8222-2fb619c8e095"
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
POST /projects/8c957482-52fd-4997-ab8b-e48286defd23/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 62ffd39a-ece9-4e42-9c4e-ec4bdd3f1aae
200 OK
```


```json
{
  "data": {
    "id": "8c957482-52fd-4997-ab8b-e48286defd23",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2019-11-29T08:22:45.639Z",
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
          "related": "/contexts?filter[project_id_eq]=8c957482-52fd-4997-ab8b-e48286defd23"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/8c957482-52fd-4997-ab8b-e48286defd23/archive"
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
DELETE /projects/5a53b084-1651-4649-8fc4-9e48f96c941c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f1ad28dc-873c-4d69-a614-7d897960170c
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
X-Request-Id: d5adfa1c-e053-426a-a956-1d268c542754
200 OK
```


```json
{
  "data": [
    {
      "id": "ff94e490-fa2f-41f5-870c-2beae7afc691",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "89d813a7-747f-4e65-b3fb-dc70ecd48c75",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/89d813a7-747f-4e65-b3fb-dc70ecd48c75"
          }
        },
        "object_occurrences": {
          "links": {
            "related": "/object_occurrences?filter[context_id_eq]=ff94e490-fa2f-41f5-870c-2beae7afc691"
          }
        }
      }
    },
    {
      "id": "fad6fa63-a23e-43cb-96f1-716fb3bbd1e0",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "89d813a7-747f-4e65-b3fb-dc70ecd48c75",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/89d813a7-747f-4e65-b3fb-dc70ecd48c75"
          }
        },
        "object_occurrences": {
          "links": {
            "related": "/object_occurrences?filter[context_id_eq]=fad6fa63-a23e-43cb-96f1-716fb3bbd1e0"
          }
        }
      }
    },
    {
      "id": "26156245-09bc-45fb-acd3-c7a3e00efd90",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 3",
        "project_id": "1c5c7da6-e106-4f16-9546-efe992bddf04",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/1c5c7da6-e106-4f16-9546-efe992bddf04"
          }
        },
        "object_occurrences": {
          "links": {
            "related": "/object_occurrences?filter[context_id_eq]=26156245-09bc-45fb-acd3-c7a3e00efd90"
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
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: be3fb4eb-79a2-40b7-9f7d-31efe9ae85a1
200 OK
```


```json
{
  "data": [
    {
      "id": "ecdbd3ff-4d23-4275-85da-929907b024c2",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "7cb63387-fe6c-4660-8f0e-b74e49a97f0f",
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
            "related": "/contexts/7cb63387-fe6c-4660-8f0e-b74e49a97f0f"
          }
        }
      }
    },
    {
      "id": "f3d782be-b810-45d6-9cec-d81a83142842",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "7cb63387-fe6c-4660-8f0e-b74e49a97f0f",
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
            "related": "/contexts/7cb63387-fe6c-4660-8f0e-b74e49a97f0f"
          }
        }
      }
    },
    {
      "id": "e2b3dbb2-f5bf-405a-91ff-f7238ffb5f4a",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": null,
        "context_id": "7cb63387-fe6c-4660-8f0e-b74e49a97f0f",
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
            "related": "/contexts/7cb63387-fe6c-4660-8f0e-b74e49a97f0f"
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
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e3016e81-a8f3-4d1f-adfa-1b3eb45d78f8
200 OK
```


```json
{
  "data": [
    {
      "id": "69907d97-f357-49c3-9f5d-57d682e58ba1",
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
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=69907d97-f357-49c3-9f5d-57d682e58ba1"
          }
        }
      }
    },
    {
      "id": "5a61ae89-c295-4766-a132-ea9af7e81098",
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
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=5a61ae89-c295-4766-a132-ea9af7e81098"
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
GET /classification_tables/b8e7635e-24ea-4297-9e66-a3b4bd939d3f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 31b10341-9758-4d19-a932-b94df6bde17b
200 OK
```


```json
{
  "data": {
    "id": "b8e7635e-24ea-4297-9e66-a3b4bd939d3f",
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
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=b8e7635e-24ea-4297-9e66-a3b4bd939d3f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/b8e7635e-24ea-4297-9e66-a3b4bd939d3f"
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
PATCH /classification_tables/647e7473-6d8d-4d45-b17f-3cbf00e3e2b7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "647e7473-6d8d-4d45-b17f-3cbf00e3e2b7",
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
X-Request-Id: 2c7cd9c9-d124-4450-99ff-4774e516554c
200 OK
```


```json
{
  "data": {
    "id": "647e7473-6d8d-4d45-b17f-3cbf00e3e2b7",
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
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=647e7473-6d8d-4d45-b17f-3cbf00e3e2b7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/647e7473-6d8d-4d45-b17f-3cbf00e3e2b7"
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
DELETE /classification_tables/c39ab236-6c14-463a-9af4-f52d93cf410e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c71f5d92-8221-4274-bd8f-f88515a3d087
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
POST /classification_tables/57895796-9616-4084-9187-49473b161987/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6225175a-cbe6-454f-81cd-1c1b83ad88b0
200 OK
```


```json
{
  "data": {
    "id": "57895796-9616-4084-9187-49473b161987",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2019-11-29T08:22:48.573Z",
      "type": "core"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=57895796-9616-4084-9187-49473b161987"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/57895796-9616-4084-9187-49473b161987/publish"
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
POST /classification_tables/ee51c7b6-481e-49f6-ad2e-d1621216938f/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e2858a4b-7310-4e38-acf9-69bbb9c5c03b
200 OK
```


```json
{
  "data": {
    "id": "ee51c7b6-481e-49f6-ad2e-d1621216938f",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2019-11-29T08:22:48.887Z",
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=ee51c7b6-481e-49f6-ad2e-d1621216938f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ee51c7b6-481e-49f6-ad2e-d1621216938f/archive"
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
X-Request-Id: 3884dc70-39f2-446b-a56e-c4cbbff868d5
201 Created
```


```json
{
  "data": {
    "id": "494c6743-c6d2-4956-92a4-eae8f0a48e66",
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
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=494c6743-c6d2-4956-92a4-eae8f0a48e66"
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
X-Request-Id: 64b5d024-a0cb-46f1-86a3-e648678646f7
200 OK
```


```json
{
  "data": [
    {
      "id": "ef4001d6-9c2f-40a0-8caf-32dfcb12fdf9",
      "type": "syntax",
      "attributes": {
        "account_id": "ddc3fcdb-e344-4d7e-8d45-cf477d4ca51e",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax f394a9d22cfd",
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
GET /syntaxes/b49e1d1f-d9af-40ec-b35c-bb208b6fa7fb
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d1abd930-78dc-49bf-8121-4a950c8ad8e0
200 OK
```


```json
{
  "data": {
    "id": "b49e1d1f-d9af-40ec-b35c-bb208b6fa7fb",
    "type": "syntax",
    "attributes": {
      "account_id": "f53eeed1-3f69-4e5d-b65a-4d1d542d531a",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax d11721ddee08",
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
    "self": "http://example.org/syntaxes/b49e1d1f-d9af-40ec-b35c-bb208b6fa7fb"
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
X-Request-Id: fafc3b82-5a43-41c0-af98-a9e6d15fb0d6
201 Created
```


```json
{
  "data": {
    "id": "aec48d4f-a12f-4252-9794-92fb304ef116",
    "type": "syntax",
    "attributes": {
      "account_id": "14017d59-a654-4b62-9195-e0a946e6ef59",
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
PATCH /syntaxes/edcaa78e-7078-4e97-a218-77dc322374b2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "edcaa78e-7078-4e97-a218-77dc322374b2",
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
X-Request-Id: 391d3569-b9b0-4d9c-a5ca-5edebf07ded3
200 OK
```


```json
{
  "data": {
    "id": "edcaa78e-7078-4e97-a218-77dc322374b2",
    "type": "syntax",
    "attributes": {
      "account_id": "5ae5ba93-e98b-40d9-b705-462e4d6ecb00",
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
    "self": "http://example.org/syntaxes/edcaa78e-7078-4e97-a218-77dc322374b2"
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
DELETE /syntaxes/160662bb-f7a0-47c5-8396-bb2aae0af0a8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3d9024bb-1434-42f2-a235-c7c85d475c4f
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
POST /syntaxes/37eecf30-ac96-48bf-b852-d67b9de81dad/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 84e6f5b9-1400-4dff-a34a-89a8883ce40e
200 OK
```


```json
{
  "data": {
    "id": "37eecf30-ac96-48bf-b852-d67b9de81dad",
    "type": "syntax",
    "attributes": {
      "account_id": "4834a747-dc67-4744-a2c2-46e6af2b57f7",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 9ab5429298dd",
      "published": true,
      "published_at": "2019-11-29T08:22:50.823Z"
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
    "self": "http://example.org/syntaxes/37eecf30-ac96-48bf-b852-d67b9de81dad/publish"
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
POST /syntaxes/5cb707cf-5623-4e75-b9be-032b0a7d39fd/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7e538c4f-45e0-482b-9c66-b8fd08e5efd7
200 OK
```


```json
{
  "data": {
    "id": "5cb707cf-5623-4e75-b9be-032b0a7d39fd",
    "type": "syntax",
    "attributes": {
      "account_id": "ddad66c7-517e-4127-90bb-bea417746b66",
      "archived": true,
      "archived_at": "2019-11-29T08:22:51.074Z",
      "description": "Description",
      "name": "Syntax 7ca62e8b992a",
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
    "self": "http://example.org/syntaxes/5cb707cf-5623-4e75-b9be-032b0a7d39fd/archive"
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
X-Request-Id: 16333ecd-6d73-4cfc-af3f-b8fc58fbea95
200 OK
```


```json
{
  "data": [
    {
      "id": "3dee1ab6-3ebd-4ca6-a4d1-82333a2b1ff6",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "769c38ab-afa4-4d9c-90d4-055fff540ae9",
        "hex_color": "721379",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element e07d354bd001",
        "syntax_id": "03ae29df-b121-4b8d-b27b-077d2cb65e97"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/03ae29df-b121-4b8d-b27b-077d2cb65e97"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/769c38ab-afa4-4d9c-90d4-055fff540ae9"
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
GET /syntax_elements/453652b0-0f89-493e-bc22-998af2c1c732
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3f54e7a2-439f-4b5a-b689-a8d3013cf9ae
200 OK
```


```json
{
  "data": {
    "id": "453652b0-0f89-493e-bc22-998af2c1c732",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "19ad3d82-7a43-4384-8b5b-71f88411e001",
      "hex_color": "2c9090",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element bf356bf14334",
      "syntax_id": "05ff4643-3d8e-414e-8c9c-d01d61ced19a"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/05ff4643-3d8e-414e-8c9c-d01d61ced19a"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/19ad3d82-7a43-4384-8b5b-71f88411e001"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/453652b0-0f89-493e-bc22-998af2c1c732"
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
      "syntax_id": "ee827a26-51dd-459f-a040-55e873c3f473",
      "classification_table_id": "ee14c48a-cd6b-47de-ab64-496d09b8c679"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: f584dfc9-a89e-457f-9221-fd96ae50f0f5
201 Created
```


```json
{
  "data": {
    "id": "8a089d52-bd30-4d9b-b2d7-00ac54ff188a",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "ee14c48a-cd6b-47de-ab64-496d09b8c679",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "syntax_id": "ee827a26-51dd-459f-a040-55e873c3f473"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/ee827a26-51dd-459f-a040-55e873c3f473"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/ee14c48a-cd6b-47de-ab64-496d09b8c679"
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
PATCH /syntax_elements/d29ac2d2-d264-4716-bacf-c10ca8b5df5c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "d29ac2d2-d264-4716-bacf-c10ca8b5df5c",
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
X-Request-Id: 65afba12-acd0-4b74-88c5-3b0a5fff1efb
200 OK
```


```json
{
  "data": {
    "id": "d29ac2d2-d264-4716-bacf-c10ca8b5df5c",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "dae7e04a-d55c-4fb0-b40d-a73acf034315",
      "hex_color": "7df432",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "syntax_id": "08c27166-77d1-44df-9dae-8304fa782c7f"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/08c27166-77d1-44df-9dae-8304fa782c7f"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/dae7e04a-d55c-4fb0-b40d-a73acf034315"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/d29ac2d2-d264-4716-bacf-c10ca8b5df5c"
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
DELETE /syntax_elements/8c8068b6-7187-4aed-a3d8-9beac663f527
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9da9c460-d6fe-4028-94f8-46830c15caca
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
X-Request-Id: 0cd0f12e-9870-471c-9811-05d49ee9bef2
200 OK
```


```json
{
  "data": [
    {
      "id": "282c94b4-b3e9-41c4-a04c-4f687b93ba9e",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/fa535ded-d128-4895-9daf-6dda70297dfe"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/afc7b668-cf5b-4e79-a4f6-1a0dc00c2f57"
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


# Syntax nodes

Syntax Nodes is the structure, in which Contexts are allowed to represent Syntax Elements. Syntax Nodes make up a graph tree.


## Show


### Request

#### Endpoint

```plaintext
GET /syntax_nodes/f1aa537e-19ae-41f5-a415-c469ff296914
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
X-Request-Id: f1551b77-6391-4417-b353-1f104206de09
200 OK
```


```json
{
  "data": {
    "id": "f1aa537e-19ae-41f5-a415-c469ff296914",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1,
      "syntax_element_id": "11be5023-7038-4675-9e47-cb69356d12d5"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/11be5023-7038-4675-9e47-cb69356d12d5"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/f1aa537e-19ae-41f5-a415-c469ff296914"
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
      "syntax_element_id": "b3e60be5-bf16-4c48-901f-f55f10e8bd8b"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 44f85f1e-0b4e-4983-a820-5e9ae38c3886
201 Created
```


```json
{
  "data": {
    "id": "a6d40db4-5164-4755-b21b-ae5b8e792fb1",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9,
      "syntax_element_id": "b3e60be5-bf16-4c48-901f-f55f10e8bd8b"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/b3e60be5-bf16-4c48-901f-f55f10e8bd8b"
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
PATCH /syntax_nodes/a0b87bbb-7ab5-4720-a150-8829616ad6c6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "a0b87bbb-7ab5-4720-a150-8829616ad6c6",
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
X-Request-Id: 85eacb97-333c-4455-979a-dbc9bcda87e3
200 OK
```


```json
{
  "data": {
    "id": "a0b87bbb-7ab5-4720-a150-8829616ad6c6",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5,
      "syntax_element_id": "e52e4bcc-ca16-41ea-854c-42a794a6c197"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/e52e4bcc-ca16-41ea-854c-42a794a6c197"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/a0b87bbb-7ab5-4720-a150-8829616ad6c6"
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
DELETE /syntax_nodes/5deb762c-1fff-42a0-95d8-8b231d7a6390
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 24825ce0-69c0-4a95-bc46-7399b0400c02
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


