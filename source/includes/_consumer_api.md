# SEC-Hub Consumer API

This API exposes information that allowes an authenticated client to manipulate the CORE, SIMO,
DOCU, DOMA, and STEM concepts.

This documentation's permalink is: [https://sec-hub.com/docs/consumer/api](https://sec-hub.com/docs/consumer/api)

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
GET /projects?filter[archived]=true
```

All of the list endpoints [support filtering](https://jsonapi.org/format/1.1/#fetching-filtering).

Most of the list endpoints support filtering using query string

```
GET /projects?query=text
```

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

## Caching

The API uses standard <a href="https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control" target="_blank">HTTP Cache-Control</a>.

# Authentication

Authentication happens through <a href="https://auth0.com/docs/quickstarts" target="_blank">Auth0</a>
with a preconfigured OAuth2 Client.

Any client must first be setup to access the <code>subdomain</code>'s Auth0 tenant, and then
authenticate with the Auth0 API to retrieve a bearer token.

When negotiating authentication with Auth0 the client should use the `https://<subdomain>.eu.auth0.com/api/v2` audience.

Then access this API with the bearer token in the Authorization header:

<aside class="notice">
  The client <strong>MUST</strong> send the <code>Authorization</code> header along with every
  request.
</aside>


## Log in


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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1629f3bd-bbaa-480a-a1c5-87461dfbfee5
200 OK
```


```json
{
  "data": {
    "id": "d0d79726-5e5f-4204-8512-59356b20f726",
    "type": "account",
    "attributes": {
      "name": "Account 400bba0b1f31"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects",
          "self": "/projects"
        }
      }
    }
  }
}
```



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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b6e274de-06ed-42d8-bbc0-dd9bae854d24
200 OK
```


```json
{
  "data": {
    "id": "fb9b3114-9294-4d8d-93b1-519521895244",
    "type": "account",
    "attributes": {
      "name": "Account da361279a73d"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects",
          "self": "/projects"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Account name |
| data[relationships][projects] | Related project resources |
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
    "id": "bdbd4b2f-4cb3-4fb5-92f7-cc59fc4a3a38",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name] *required* | Account name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 5a9dccdd-bc50-4ca3-a0ba-023c99ebc3c4
200 OK
```


```json
{
  "data": {
    "id": "bdbd4b2f-4cb3-4fb5-92f7-cc59fc4a3a38",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects",
          "self": "/projects"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Account name |
| data[relationships][projects] | Related project resources |
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[archived]  | filter by archived flag |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 61219bac-a532-4d67-bb21-13888cde6008
200 OK
```


```json
{
  "data": [
    {
      "id": "207bb85e-4b18-4ecd-8107-eedcd69ed193",
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
            "related": "/contexts?filter[project_id_eq]=207bb85e-4b18-4ecd-8107-eedcd69ed193",
            "self": "/projects/207bb85e-4b18-4ecd-8107-eedcd69ed193/relationships/contexts"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/projects",
    "current": "http://example.org/projects?page[number]=1&sort=name"
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
GET /projects/a49bbe75-e2bb-4fc2-8b9b-1a17a249e6a0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: af3ef87a-af37-48c8-9ec5-08e6e9bfb161
200 OK
```


```json
{
  "data": {
    "id": "a49bbe75-e2bb-4fc2-8b9b-1a17a249e6a0",
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
          "related": "/contexts?filter[project_id_eq]=a49bbe75-e2bb-4fc2-8b9b-1a17a249e6a0",
          "self": "/projects/a49bbe75-e2bb-4fc2-8b9b-1a17a249e6a0/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a49bbe75-e2bb-4fc2-8b9b-1a17a249e6a0"
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
PATCH /projects/b89bd004-7b77-44d9-8dc7-a91fb2931cff
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "b89bd004-7b77-44d9-8dc7-a91fb2931cff",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: eae12b8b-b69c-453c-997f-bce61253cb65
200 OK
```


```json
{
  "data": {
    "id": "b89bd004-7b77-44d9-8dc7-a91fb2931cff",
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
          "related": "/contexts?filter[project_id_eq]=b89bd004-7b77-44d9-8dc7-a91fb2931cff",
          "self": "/projects/b89bd004-7b77-44d9-8dc7-a91fb2931cff/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b89bd004-7b77-44d9-8dc7-a91fb2931cff"
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
POST /projects/7e2a3aa7-e0b8-4dd7-a990-88dbcb084f9d/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a2359baf-d44f-444f-a917-fa7041cf82ab
200 OK
```


```json
{
  "data": {
    "id": "7e2a3aa7-e0b8-4dd7-a990-88dbcb084f9d",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-16T19:35:02.811Z",
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
          "related": "/contexts?filter[project_id_eq]=7e2a3aa7-e0b8-4dd7-a990-88dbcb084f9d",
          "self": "/projects/7e2a3aa7-e0b8-4dd7-a990-88dbcb084f9d/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7e2a3aa7-e0b8-4dd7-a990-88dbcb084f9d/archive"
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
DELETE /projects/34b145f6-0276-463e-b575-16e73693fa81
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d7a67cfd-3e4f-496d-9276-bc37a14a22ee
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name, object_occurrences_count |
| query  | search query |
| filter[archived]  | filter by archived flag |
| filter[project_id_eq]  | filter by project_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c079fb98-933c-494e-9bbd-21b1dc300fd6
200 OK
```


```json
{
  "data": [
    {
      "id": "86098fb3-eebe-4c81-b261-79ea0dde8531",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "published_at": null,
        "revision": 0,
        "validation_level": "strict"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/a7dc09c9-561b-4dc4-b5bf-b3d5a901be42"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/95029bef-e14c-48ab-818a-d85b6a551bd3"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/f01e9afe-a824-4838-9797-13eb9f7d43bd"
          }
        }
      }
    },
    {
      "id": "d4851884-30ec-4821-9b67-a64404cda540",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "published_at": null,
        "revision": 0,
        "validation_level": "strict"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/a7dc09c9-561b-4dc4-b5bf-b3d5a901be42"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/600f9156-7a45-4d1f-af35-e81fedd262c0"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/f01e9afe-a824-4838-9797-13eb9f7d43bd"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/contexts",
    "current": "http://example.org/contexts?page[number]=1&sort=name"
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
| data[attributes][validation_level] | Validation level |


## Show


### Request

#### Endpoint

```plaintext
GET /contexts/40b8daa6-e93c-4c14-9886-b3dd981c9c1b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 85cc1ee4-b0c1-4695-aa0b-5f2e4745e3da
200 OK
```


```json
{
  "data": {
    "id": "40b8daa6-e93c-4c14-9886-b3dd981c9c1b",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "published_at": null,
      "revision": 0,
      "validation_level": "strict"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/dcc211e3-7f88-462a-b493-953e8aa632f1"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/7860bdb0-1b54-4f40-a0e3-18317368aab4"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/60ec877e-e457-4467-87d3-d146aaf05378"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/40b8daa6-e93c-4c14-9886-b3dd981c9c1b"
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
| data[attributes][validation_level] | Validation level |


## Update


### Request

#### Endpoint

```plaintext
PATCH /contexts/1016ea84-2c99-42bd-b4aa-aee0d0658dfe
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "1016ea84-2c99-42bd-b4aa-aee0d0658dfe",
    "type": "contexts",
    "attributes": {
      "name": "New context name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New context name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 794cf6ad-f6ad-4284-bcc3-e9a1dd3dff03
200 OK
```


```json
{
  "data": {
    "id": "1016ea84-2c99-42bd-b4aa-aee0d0658dfe",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "New context name",
      "published_at": null,
      "revision": 0,
      "validation_level": "strict"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/7f1dd72e-9717-4071-be9b-159965d06496"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/7c2d3288-101f-4cf5-895a-09290fdf5055"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/674c41e4-4f0a-42b0-9565-d870b4d750ad"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/1016ea84-2c99-42bd-b4aa-aee0d0658dfe"
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
| data[attributes][validation_level] | Validation level |


## Create


### Request

#### Endpoint

```plaintext
POST /projects/f12d93a5-a4c5-4d92-9965-293a1b865c18/relationships/contexts
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:project_id/relationships/contexts`

#### Parameters


```json
{
  "data": {
    "type": "context",
    "attributes": {
      "name": "Context"
    },
    "relationships": {
      "syntax": {
        "data": {
          "type": "syntax",
          "id": "3c9e31f4-3f5c-4a8b-b6b4-523e6f49bc15"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: afd03d6b-087b-4d22-9945-ab5c217df1fd
201 Created
```


```json
{
  "data": {
    "id": "8c86e8f3-4fe9-491a-9102-b492acabc415",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context",
      "published_at": null,
      "revision": 0,
      "validation_level": "strict"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/f12d93a5-a4c5-4d92-9965-293a1b865c18"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/8089670a-5200-4ab9-a1ee-e7a416fb1b63"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/3c9e31f4-3f5c-4a8b-b6b4-523e6f49bc15"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/f12d93a5-a4c5-4d92-9965-293a1b865c18/relationships/contexts"
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
| data[attributes][validation_level] | Validation level |


## Create revision


### Request

#### Endpoint

```plaintext
POST /contexts/cec66f41-72d5-4e56-8a87-19307a328b6b/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/83a00e13725de158b16aa7bc
Content-Type: text/html; charset=utf-8
X-Request-Id: 5c8dd46f-cea8-4d07-853f-a4e37cde13ad
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/83a00e13725de158b16aa7bc">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Context name |
| data[attributes][description] | Context description |
| data[attributes][project_id] | Project ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |
| data[attributes][validation_level] | Validation level |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /contexts/23cdf1fc-eb13-447d-9dc3-0efb54ffb428
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1710fe62-affe-40b5-a02c-3d85f0397851
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Context name |
| data[attributes][description] | Context description |
| data[attributes][project_id] | Project ID |
| data[attributes][archived_at] | Archived date |
| data[attributes][published_at] | Publishing date |
| data[attributes][validation_level] | Validation level |


# Object Occurrences

Object Occurrences represent the occurrence of a System Element in a given Context with a given aspect.


## Add new tag

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/e9a1454e-b60e-4b42-ba77-be5fed3b98fd/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "attributes": {
      "value": "New tag value"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][value] *required* | Tag value |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8c712d8a-e18a-4b4a-b370-781015411d12
201 Created
```


```json
{
  "data": {
    "id": "74ecc580-2e3b-4ccf-9e18-be370a16ce1d",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/e9a1454e-b60e-4b42-ba77-be5fed3b98fd/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Add existing tag

Adds an existing tag to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/9642dd73-d852-4afc-86eb-2e6c1158fc50/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "cac220f6-51a7-48cb-8f90-9d26a36c6f86"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ecc8deab-34f6-4615-b56b-2f398c0b9385
201 Created
```


```json
{
  "data": {
    "id": "cac220f6-51a7-48cb-8f90-9d26a36c6f86",
    "type": "tag",
    "attributes": {
      "value": "tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/9642dd73-d852-4afc-86eb-2e6c1158fc50/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/555c4a69-e586-4708-936a-dba56553b715/relationships/tags/2262a9cb-c3f6-4b28-ad3f-0b9ba2eb7735
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e48684c2-00b4-4b2c-a6e3-9763a300feeb
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/bb85a130-9f3d-4ce8-ba13-82fa6dcf26ea/relationships/owners
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/relationships/owners`

#### Parameters


```json
{
  "data": {
    "type": "owner",
    "attributes": {
      "name": "New owner name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name] *required* | Owner name |
| data[attributes][title]  | Owner title |
| data[attributes][company]  | Owner company |
| data[attributes][primary]  | Make the owner a primary owner (boolean) |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3bc67e6e-6e90-4438-877c-025416342a15
201 Created
```


```json
{
  "data": {
    "id": "bfee2dd3-271d-4fef-ac22-9ace6e24eae3",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/bb85a130-9f3d-4ce8-ba13-82fa6dcf26ea/relationships/owners"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][name] | Owner name |
| data[attributes][title] | Owner title |
| data[attributes][company] | Owner company |


## Add new, primary owner

Adds a new primary owner to the resource.

A primary owner can be the primary owner within a company, or generally on the
resource. This is completely depending on the business interpretation of the client.


### Request

#### Endpoint

```plaintext
POST /object_occurrences/2abd92e8-f742-4f0e-951c-bfab4dcc816b/relationships/owners
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/relationships/owners`

#### Parameters


```json
{
  "data": {
    "type": "owner",
    "attributes": {
      "name": "New owner name",
      "primary": true
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name] *required* | Owner name |
| data[attributes][title]  | Owner title |
| data[attributes][company]  | Owner company |
| data[attributes][primary]  | Make the owner a primary owner (boolean) |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b079d737-e4c5-43e6-9bf1-ee01da2df78a
201 Created
```


```json
{
  "data": {
    "id": "e867cd21-2e7b-4907-8922-17bc8c83fd07",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/2abd92e8-f742-4f0e-951c-bfab4dcc816b/relationships/owners"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][name] | Owner name |
| data[attributes][title] | Owner title |
| data[attributes][company] | Owner company |


## Add existing owner

Adds an existing owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/273c7421-979e-42a7-871d-977602199259/relationships/owners
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/relationships/owners`

#### Parameters


```json
{
  "data": {
    "type": "owner",
    "id": "cda57720-9d12-4770-b7f2-46477bc5f15c"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 9cbd0fec-c57a-4571-9a24-5ccc35d2086d
201 Created
```


```json
{
  "data": {
    "id": "cda57720-9d12-4770-b7f2-46477bc5f15c",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 1",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/273c7421-979e-42a7-871d-977602199259/relationships/owners"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][name] | owner name |
| data[attributes][title] | owner title |
| data[attributes][company] | owner company |


## Remove existing owner


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/009c0c39-d79e-42e2-be96-e82d1711ec3f/relationships/owners/327a6391-63a8-419c-852b-13c0c5782e86
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 56306fe5-a541-4a44-8a11-7859170210b6
204 No Content
```




## List


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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: classification_code, name, number, type |
| query  | search query |
| filter[context_id_eq]  | filter by context id |
| filter[progress_steps_gte]  | filtering by at least one checked step that is ≥ provided value |
| filter[progress_steps_lte]  | filtering by at least one not checked step that is ≤ provided value |
| filter[syntax_element_id_in]  | filter by syntax elements ids |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: d666bcb4-887c-449e-bd32-900072ad5e5b
200 OK
```


```json
{
  "data": [
    {
      "id": "3e109c24-159b-4b09-8941-fe8b2d15185a",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 3",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=3e109c24-159b-4b09-8941-fe8b2d15185a",
            "self": "/object_occurrences/3e109c24-159b-4b09-8941-fe8b2d15185a/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=3e109c24-159b-4b09-8941-fe8b2d15185a&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/3e109c24-159b-4b09-8941-fe8b2d15185a/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/7e7853ef-d695-4359-9733-7b860e261138"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/12e3dffe-5a7a-4bac-b235-e84a81d4167a",
            "self": "/object_occurrences/3e109c24-159b-4b09-8941-fe8b2d15185a/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/3e109c24-159b-4b09-8941-fe8b2d15185a/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=3e109c24-159b-4b09-8941-fe8b2d15185a"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=3e109c24-159b-4b09-8941-fe8b2d15185a"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=3e109c24-159b-4b09-8941-fe8b2d15185a"
          }
        }
      }
    },
    {
      "id": "1b05a2a2-3a07-492f-a50e-b07fc9507160",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 2a",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=1b05a2a2-3a07-492f-a50e-b07fc9507160",
            "self": "/object_occurrences/1b05a2a2-3a07-492f-a50e-b07fc9507160/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=1b05a2a2-3a07-492f-a50e-b07fc9507160&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/1b05a2a2-3a07-492f-a50e-b07fc9507160/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/aa128585-c1f5-4abc-8d8c-36c6c0d278e5"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91",
            "self": "/object_occurrences/1b05a2a2-3a07-492f-a50e-b07fc9507160/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/1b05a2a2-3a07-492f-a50e-b07fc9507160/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=1b05a2a2-3a07-492f-a50e-b07fc9507160"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=1b05a2a2-3a07-492f-a50e-b07fc9507160"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=1b05a2a2-3a07-492f-a50e-b07fc9507160"
          }
        }
      }
    },
    {
      "id": "b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 1",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91",
            "self": "/object_occurrences/b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/aa128585-c1f5-4abc-8d8c-36c6c0d278e5"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/e1edd631-7f46-465f-af98-9d106eb9389d",
            "self": "/object_occurrences/b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "1b05a2a2-3a07-492f-a50e-b07fc9507160",
              "type": "object_occurrence"
            },
            {
              "id": "d844dfee-2a23-4c6d-87a4-ffc06643bcb7",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91"
          }
        }
      }
    },
    {
      "id": "d844dfee-2a23-4c6d-87a4-ffc06643bcb7",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 2",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=d844dfee-2a23-4c6d-87a4-ffc06643bcb7",
            "self": "/object_occurrences/d844dfee-2a23-4c6d-87a4-ffc06643bcb7/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=d844dfee-2a23-4c6d-87a4-ffc06643bcb7&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/d844dfee-2a23-4c6d-87a4-ffc06643bcb7/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/aa128585-c1f5-4abc-8d8c-36c6c0d278e5"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91",
            "self": "/object_occurrences/d844dfee-2a23-4c6d-87a4-ffc06643bcb7/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/d844dfee-2a23-4c6d-87a4-ffc06643bcb7/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=d844dfee-2a23-4c6d-87a4-ffc06643bcb7"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=d844dfee-2a23-4c6d-87a4-ffc06643bcb7"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=d844dfee-2a23-4c6d-87a4-ffc06643bcb7"
          }
        }
      }
    },
    {
      "id": "e1edd631-7f46-465f-af98-9d106eb9389d",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 27fe1b0ff07e",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=e1edd631-7f46-465f-af98-9d106eb9389d",
            "self": "/object_occurrences/e1edd631-7f46-465f-af98-9d106eb9389d/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e1edd631-7f46-465f-af98-9d106eb9389d&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e1edd631-7f46-465f-af98-9d106eb9389d/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/aa128585-c1f5-4abc-8d8c-36c6c0d278e5"
          }
        },
        "components": {
          "data": [
            {
              "id": "b07abcea-aa2f-4a7f-a6b6-68fe1ecf1f91",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/e1edd631-7f46-465f-af98-9d106eb9389d/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e1edd631-7f46-465f-af98-9d106eb9389d"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e1edd631-7f46-465f-af98-9d106eb9389d"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e1edd631-7f46-465f-af98-9d106eb9389d"
          }
        }
      }
    },
    {
      "id": "12e3dffe-5a7a-4bac-b235-e84a81d4167a",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC ecc44eccf57b",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=12e3dffe-5a7a-4bac-b235-e84a81d4167a",
            "self": "/object_occurrences/12e3dffe-5a7a-4bac-b235-e84a81d4167a/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=12e3dffe-5a7a-4bac-b235-e84a81d4167a&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/12e3dffe-5a7a-4bac-b235-e84a81d4167a/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/7e7853ef-d695-4359-9733-7b860e261138"
          }
        },
        "components": {
          "data": [
            {
              "id": "3e109c24-159b-4b09-8941-fe8b2d15185a",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/12e3dffe-5a7a-4bac-b235-e84a81d4167a/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=12e3dffe-5a7a-4bac-b235-e84a81d4167a"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=12e3dffe-5a7a-4bac-b235-e84a81d4167a"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=12e3dffe-5a7a-4bac-b235-e84a81d4167a"
          }
        }
      }
    }
  ],
  "included": [

  ],
  "meta": {
    "total_count": 6
  },
  "links": {
    "self": "http://example.org/object_occurrences",
    "current": "http://example.org/object_occurrences?include=tags,owners&page[number]=1"
  }
}
```



## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/21a2fa8e-d8b0-4f6f-a127-47bccde85f0d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/:id`

#### Parameters



| Name | Description |
|:-----|:------------|
| depth  | Components depth |
| filter[type_eq]  | Only of specific type |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: d7818b32-e327-429a-aae1-0e53b9dbe91d
200 OK
```


```json
{
  "data": {
    "id": "21a2fa8e-d8b0-4f6f-a127-47bccde85f0d",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 1",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": null,
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=21a2fa8e-d8b0-4f6f-a127-47bccde85f0d",
          "self": "/object_occurrences/21a2fa8e-d8b0-4f6f-a127-47bccde85f0d/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=21a2fa8e-d8b0-4f6f-a127-47bccde85f0d&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/21a2fa8e-d8b0-4f6f-a127-47bccde85f0d/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/7f39987e-b03c-431a-959f-11fb1bd78694"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/bed01ea1-a580-4757-a1b1-37c923e7a01c",
          "self": "/object_occurrences/21a2fa8e-d8b0-4f6f-a127-47bccde85f0d/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "5eb0855f-0d7d-431e-b31f-611004c4ab33",
            "type": "object_occurrence"
          },
          {
            "id": "ab14318b-2e27-4204-b3b8-5437d92580cf",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/21a2fa8e-d8b0-4f6f-a127-47bccde85f0d/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=21a2fa8e-d8b0-4f6f-a127-47bccde85f0d"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=21a2fa8e-d8b0-4f6f-a127-47bccde85f0d"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=21a2fa8e-d8b0-4f6f-a127-47bccde85f0d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/21a2fa8e-d8b0-4f6f-a127-47bccde85f0d"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][number] | Reference designation number |
| data[attributes][position] | Custom sorting position within siblings |
| data[attributes][prefix] | Reference designation aspect/prefix |
| data[attributes][type] | Type of Object Occurrence |
| data[relationships][tags] | Tags |
| data[relationships][context] | Parenting Context Resource |
| data[relationships][part_of] | Parenting Object Occurrence Resource |
| data[relationships][components] | Nested Object Occurrence Resources |
| data[relationships][allowed_children_syntax_nodes] | Allowed Syntax Node Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_syntax_elements] | Allowed Syntax Element Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_classification_tables] | Allowed Classification Table Resources when determining component Object Occurrence Resources |


## Create

Create a single Object Occurrence.

<aside class="notice">
  Some of the requirements, which are marked with <em>required</em> isn't always required.
  This is completely dependent on the syntax (if any) that governs the context.
</aside>


### Request

#### Endpoint

```plaintext
POST /object_occurrences/bfd30d83-d2a6-432b-ab51-381f8b439401/relationships/components
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:object_occurrence_id/relationships/components`

#### Parameters


```json
{
  "data": {
    "type": "object_occurrence",
    "attributes": {
      "name": "ooc",
      "classification_code": "XYZ",
      "number": 1,
      "prefix": "="
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][classification_code] *required* | Reference designation classification code |
| data[attributes][description]  | Custom description of the Object Occurrence |
| data[attributes][hex_color]  | Custom color |
| data[attributes][name] *required* | Custom name for the OOC |
| data[attributes][number] *required* | Reference designation number |
| data[attributes][position]  | Custom sorting position within siblings |
| data[attributes][prefix] *required* | Reference designation aspect/prefix |
| data[attributes][type]  | Type of Object Occurrence |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 20580020-8a8c-4c7d-b2a0-7a2208527d69
201 Created
```


```json
{
  "data": {
    "id": "1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
      "description": null,
      "name": "ooc",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": null,
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5",
          "self": "/object_occurrences/1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/e8bc5482-a927-48b9-a7e8-acca23b4d14f"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/bfd30d83-d2a6-432b-ab51-381f8b439401",
          "self": "/object_occurrences/1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=1445a78e-1bc2-4ebd-b2d9-e3fd2f1177b5"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/bfd30d83-d2a6-432b-ab51-381f8b439401/relationships/components"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][number] | Reference designation number |
| data[attributes][position] | Custom sorting position within siblings |
| data[attributes][prefix] | Reference designation aspect/prefix |
| data[attributes][type] | Type of Object Occurrence |
| data[relationships][tags] | Tags |
| data[relationships][context] | Parenting Context Resource |
| data[relationships][part_of] | Parenting Object Occurrence Resource |
| data[relationships][components] | Nested Object Occurrence Resources |
| data[relationships][allowed_children_syntax_nodes] | Allowed Syntax Node Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_syntax_elements] | Allowed Syntax Element Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_classification_tables] | Allowed Classification Table Resources when determining component Object Occurrence Resources |


## Create external

Create a single, external Object Occurrence.

External Object Occurrences represent external systems which this design depends on,
such as GPS or the power grid.


### Request

#### Endpoint

```plaintext
POST /object_occurrences/dd31cfa2-b8f0-40a9-b0de-d6b463dfde72/relationships/components
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:object_occurrence_id/relationships/components`

#### Parameters


```json
{
  "data": {
    "type": "object_occurrence",
    "attributes": {
      "name": "external OOC",
      "type": "external"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][description]  | Custom description of the Object Occurrence |
| data[attributes][hex_color]  | Custom color |
| data[attributes][name] *required* | Custom name for the OOC |
| data[attributes][type] *required* | Type of Object Occurrence |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: cf1b7d3f-3f8d-45d1-acd6-5c7756f6f071
201 Created
```


```json
{
  "data": {
    "id": "71ff2d89-931c-4585-ac81-87d87c57fc6f",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "name": "external OOC",
      "position": 1,
      "prefix": null,
      "reference_designation": null,
      "type": "external",
      "hex_color": null,
      "number": "",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=71ff2d89-931c-4585-ac81-87d87c57fc6f",
          "self": "/object_occurrences/71ff2d89-931c-4585-ac81-87d87c57fc6f/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=71ff2d89-931c-4585-ac81-87d87c57fc6f&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/71ff2d89-931c-4585-ac81-87d87c57fc6f/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/8fdceb66-3b4d-4675-ba57-70c7253874b8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/dd31cfa2-b8f0-40a9-b0de-d6b463dfde72/relationships/components"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][type] | Type of Object Occurrence |


## Update


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/a4386ed4-bd14-4941-bbfd-3d95691da607
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "a4386ed4-bd14-4941-bbfd-3d95691da607",
    "type": "object_occurrence",
    "attributes": {
      "description": "New description",
      "name": "New name",
      "number": 8,
      "position": 2,
      "prefix": "%",
      "type": "regular",
      "hex_color": "#FFA500"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "8b8f7f4a-050e-44cd-bcdc-b723474c50ad"
        }
      }
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][classification_code] *required* | Reference designation classification code |
| data[attributes][description]  | Custom description of the Object Occurrence |
| data[attributes][hex_color]  | Custom color |
| data[attributes][name] *required* | Custom name for the OOC |
| data[attributes][number] *required* | Reference designation number |
| data[attributes][position]  | Custom sorting position within siblings |
| data[attributes][prefix] *required* | Reference designation aspect/prefix |
| data[attributes][type]  | Type of Object Occurrence |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6ad4ab6e-cab2-4b8d-8718-d0a0b7ef2625
200 OK
```


```json
{
  "data": {
    "id": "a4386ed4-bd14-4941-bbfd-3d95691da607",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=a4386ed4-bd14-4941-bbfd-3d95691da607",
          "self": "/object_occurrences/a4386ed4-bd14-4941-bbfd-3d95691da607/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=a4386ed4-bd14-4941-bbfd-3d95691da607&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/a4386ed4-bd14-4941-bbfd-3d95691da607/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/6547ec56-e4fa-4c7d-8ba3-964c1c555893"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/8b8f7f4a-050e-44cd-bcdc-b723474c50ad",
          "self": "/object_occurrences/a4386ed4-bd14-4941-bbfd-3d95691da607/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/a4386ed4-bd14-4941-bbfd-3d95691da607/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=a4386ed4-bd14-4941-bbfd-3d95691da607"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=a4386ed4-bd14-4941-bbfd-3d95691da607"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=a4386ed4-bd14-4941-bbfd-3d95691da607"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a4386ed4-bd14-4941-bbfd-3d95691da607"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][number] | Reference designation number |
| data[attributes][position] | Custom sorting position within siblings |
| data[attributes][prefix] | Reference designation aspect/prefix |
| data[attributes][type] | Type of Object Occurrence |
| data[relationships][tags] | Tags |
| data[relationships][context] | Parenting Context Resource |
| data[relationships][part_of] | Parenting Object Occurrence Resource |
| data[relationships][components] | Nested Object Occurrence Resources |
| data[relationships][allowed_children_syntax_nodes] | Allowed Syntax Node Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_syntax_elements] | Allowed Syntax Element Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_classification_tables] | Allowed Classification Table Resources when determining component Object Occurrence Resources |


## Copy

Copy the (target) Object Occurrence resource (indicated by POST data) and all descendants as
components of the (source)Object Occurrence resource (indicated in URL parameter).

```
A (id 1)
  B (id 2)
C (id 3)

POST /object_occurrences/3/copy
{
  data: {
    "id": 3,
    "type": "object_occurrences"
  }
}

Results in:
A (id 1)
  B (id 2)
C (id 3)
  A (id 4)
    B (id 5)
```


### Request

#### Endpoint

```plaintext
POST /object_occurrences/9c601eb8-57e9-4f0e-9d79-81bcdae39334/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "44444ed9-c6f4-4559-9387-cd7807f2f5d4",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/b4fccfce5c95226aadb2297e
Content-Type: text/html; charset=utf-8
X-Request-Id: 9ac9511a-2ae4-42c7-bf40-a565e9b208cd
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/b4fccfce5c95226aadb2297e">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][number] | Reference designation number |
| data[attributes][position] | Custom sorting position within siblings |
| data[attributes][prefix] | Reference designation aspect/prefix |
| data[attributes][type] | Type of Object Occurrence |
| data[relationships][tags] | Tags |
| data[relationships][context] | Parenting Context Resource |
| data[relationships][part_of] | Parenting Object Occurrence Resource |
| data[relationships][components] | Nested Object Occurrence Resources |
| data[relationships][allowed_children_syntax_nodes] | Allowed Syntax Node Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_syntax_elements] | Allowed Syntax Element Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_classification_tables] | Allowed Classification Table Resources when determining component Object Occurrence Resources |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/38f4d236-c106-4e55-a5b9-ca64f085404e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a949b933-8a50-4db8-ba26-a00d2bbf9383
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/a0b2e61a-8a60-49cf-92e5-ea951d504381/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "f1cdd3de-6c54-4b2e-8235-ee542595d40e",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID of the new parent of the current Object Occurrence |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e787eb31-aed1-43ea-b9dc-8e612d4065f9
200 OK
```


```json
{
  "data": {
    "id": "a0b2e61a-8a60-49cf-92e5-ea951d504381",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 2",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": null,
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=a0b2e61a-8a60-49cf-92e5-ea951d504381",
          "self": "/object_occurrences/a0b2e61a-8a60-49cf-92e5-ea951d504381/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=a0b2e61a-8a60-49cf-92e5-ea951d504381&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/a0b2e61a-8a60-49cf-92e5-ea951d504381/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/bf01122f-28a2-4bc1-ae1f-6681c664d58e"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/f1cdd3de-6c54-4b2e-8235-ee542595d40e",
          "self": "/object_occurrences/a0b2e61a-8a60-49cf-92e5-ea951d504381/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/a0b2e61a-8a60-49cf-92e5-ea951d504381/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=a0b2e61a-8a60-49cf-92e5-ea951d504381"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=a0b2e61a-8a60-49cf-92e5-ea951d504381"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=a0b2e61a-8a60-49cf-92e5-ea951d504381"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a0b2e61a-8a60-49cf-92e5-ea951d504381/relationships/part_of"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][number] | Reference designation number |
| data[attributes][position] | Custom sorting position within siblings |
| data[attributes][prefix] | Reference designation aspect/prefix |
| data[attributes][type] | Type of Object Occurrence |
| data[relationships][tags] | Tags |
| data[relationships][context] | Parenting Context Resource |
| data[relationships][part_of] | Parenting Object Occurrence Resource |
| data[relationships][components] | Nested Object Occurrence Resources |
| data[relationships][allowed_children_syntax_nodes] | Allowed Syntax Node Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_syntax_elements] | Allowed Syntax Element Resources when determining component Object Occurrence Resources |
| data[relationships][allowed_children_classification_tables] | Allowed Classification Table Resources when determining component Object Occurrence Resources |


# Classification Tables

Classification tables represent a strategic breakdown of the company product(s) into a nuanced
and logically separated classification table structure.

Each classification table has multiple classification entries.


## Add new tag

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_tables/04f03373-ce83-423e-9a0b-cda6fd933786/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "attributes": {
      "value": "New tag value"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][value] *required* | Tag value |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4a0d28e7-2fdc-467f-b1d6-2e95dc429f48
201 Created
```


```json
{
  "data": {
    "id": "938d7499-d4ba-4c60-97e2-0b020dfdced9",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/04f03373-ce83-423e-9a0b-cda6fd933786/relationships/tags"
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
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Add existing tag

Adds an existing tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_tables/3836a730-b17a-4dee-a28e-d9854c9e91d9/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "e145bea5-501b-41ec-9429-a8ba067c17d5"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e34a219e-cff1-4a19-9867-3d2ed2a59c4d
201 Created
```


```json
{
  "data": {
    "id": "e145bea5-501b-41ec-9429-a8ba067c17d5",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/3836a730-b17a-4dee-a28e-d9854c9e91d9/relationships/tags"
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
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /classification_tables/9f34ab9e-5c1f-4e55-9b7d-a8c4ff9d95e2/relationships/tags/843998ef-93c8-48e8-bebe-aecdaec96e75
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 56b38e30-1211-4f04-9505-c8818eb11481
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[type_eq]  | filter by type |
| filter[archived]  | filter by archived flag |
| filter[published]  | filter by published flag |
| filter[name_eq]  | filter by name |
| filter[allowed_for_object_occurrence_id_eq]  | filter by allowed for children of OOC with id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ee450d7e-ab82-4027-bbe1-b04a24ee54d3
200 OK
```


```json
{
  "data": [
    {
      "id": "6254675f-3b54-463d-b475-c67450cc9346",
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
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=6254675f-3b54-463d-b475-c67450cc9346",
            "self": "/classification_tables/6254675f-3b54-463d-b475-c67450cc9346/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=6254675f-3b54-463d-b475-c67450cc9346",
            "self": "/classification_tables/6254675f-3b54-463d-b475-c67450cc9346/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "41d7a011-8c5a-4479-b436-92f12640d398",
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
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=41d7a011-8c5a-4479-b436-92f12640d398",
            "self": "/classification_tables/41d7a011-8c5a-4479-b436-92f12640d398/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=41d7a011-8c5a-4479-b436-92f12640d398",
            "self": "/classification_tables/41d7a011-8c5a-4479-b436-92f12640d398/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    }
  ],
  "included": [

  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/classification_tables",
    "current": "http://example.org/classification_tables?include=tags&page[number]=1&sort=name"
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
GET /classification_tables/baad66a5-7a58-41af-9bca-bd23f96e03ad
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ccd3c0aa-86c3-44b8-9396-93b2b52eaedf
200 OK
```


```json
{
  "data": {
    "id": "baad66a5-7a58-41af-9bca-bd23f96e03ad",
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
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=baad66a5-7a58-41af-9bca-bd23f96e03ad",
          "self": "/classification_tables/baad66a5-7a58-41af-9bca-bd23f96e03ad/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=baad66a5-7a58-41af-9bca-bd23f96e03ad",
          "self": "/classification_tables/baad66a5-7a58-41af-9bca-bd23f96e03ad/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/baad66a5-7a58-41af-9bca-bd23f96e03ad"
  },
  "included": [

  ]
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
PATCH /classification_tables/59add2c1-2e37-4e5d-bbce-e175de6a3c1e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "59add2c1-2e37-4e5d-bbce-e175de6a3c1e",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 26cd46cd-ae10-4f7d-9b2e-c1e2619f3be4
200 OK
```


```json
{
  "data": {
    "id": "59add2c1-2e37-4e5d-bbce-e175de6a3c1e",
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
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=59add2c1-2e37-4e5d-bbce-e175de6a3c1e",
          "self": "/classification_tables/59add2c1-2e37-4e5d-bbce-e175de6a3c1e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=59add2c1-2e37-4e5d-bbce-e175de6a3c1e",
          "self": "/classification_tables/59add2c1-2e37-4e5d-bbce-e175de6a3c1e/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/59add2c1-2e37-4e5d-bbce-e175de6a3c1e"
  },
  "included": [

  ]
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
DELETE /classification_tables/2daa4606-d5e4-4fc9-b6b1-74d6c6da7276
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d1c1470c-ad8d-41e6-920a-b12741b242c1
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
POST /classification_tables/e5d7fe01-8dca-4e65-9b16-c3081eef003f/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 01116224-385c-442b-a2ec-85fe6c40162c
200 OK
```


```json
{
  "data": {
    "id": "e5d7fe01-8dca-4e65-9b16-c3081eef003f",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-04-16T19:35:31.842Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=e5d7fe01-8dca-4e65-9b16-c3081eef003f",
          "self": "/classification_tables/e5d7fe01-8dca-4e65-9b16-c3081eef003f/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=e5d7fe01-8dca-4e65-9b16-c3081eef003f",
          "self": "/classification_tables/e5d7fe01-8dca-4e65-9b16-c3081eef003f/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/e5d7fe01-8dca-4e65-9b16-c3081eef003f/publish"
  },
  "included": [

  ]
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
POST /classification_tables/5cfb4c92-4b49-4a72-8b79-a0dc579bbb82/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: afc3811b-c73e-46a5-88b8-c98257fb2e0c
200 OK
```


```json
{
  "data": {
    "id": "5cfb4c92-4b49-4a72-8b79-a0dc579bbb82",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-16T19:35:32.573Z",
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=5cfb4c92-4b49-4a72-8b79-a0dc579bbb82",
          "self": "/classification_tables/5cfb4c92-4b49-4a72-8b79-a0dc579bbb82/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=5cfb4c92-4b49-4a72-8b79-a0dc579bbb82",
          "self": "/classification_tables/5cfb4c92-4b49-4a72-8b79-a0dc579bbb82/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/5cfb4c92-4b49-4a72-8b79-a0dc579bbb82/archive"
  },
  "included": [

  ]
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 796c4ef5-2d9e-438e-8c0e-ee06f1dd23ea
201 Created
```


```json
{
  "data": {
    "id": "b9d5dbeb-bad4-426e-8217-c4a80ba6462e",
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
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=b9d5dbeb-bad4-426e-8217-c4a80ba6462e",
          "self": "/classification_tables/b9d5dbeb-bad4-426e-8217-c4a80ba6462e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=b9d5dbeb-bad4-426e-8217-c4a80ba6462e",
          "self": "/classification_tables/b9d5dbeb-bad4-426e-8217-c4a80ba6462e/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables"
  },
  "included": [

  ]
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


# Classification Entries

Classification entries represent a single classification entry in a Classification Table.


## Add new tag

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_entries/ed59aafa-d4c2-487d-966e-5f5480e3c141/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_entries/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "attributes": {
      "value": "New tag value"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][value] *required* | Tag value |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 758eb226-f7f2-4d05-8bd8-d6304d5775c9
201 Created
```


```json
{
  "data": {
    "id": "d7729f0e-03d5-443a-bff3-d0049d1fe3bd",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/ed59aafa-d4c2-487d-966e-5f5480e3c141/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Add existing tag

Adds an existing tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_entries/e1702c9f-3555-4087-9342-d20606805f46/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_entries/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "8ab4c691-a71e-48d8-ba75-88f3886e3e43"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3013deae-363e-4dc5-aa05-2a9a8e038d11
201 Created
```


```json
{
  "data": {
    "id": "8ab4c691-a71e-48d8-ba75-88f3886e3e43",
    "type": "tag",
    "attributes": {
      "value": "tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/e1702c9f-3555-4087-9342-d20606805f46/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /classification_entries/6befbde3-b046-44c3-8c87-718f72a2de50/relationships/tags/8c32620b-82fe-4b2a-970e-919d3f3aed3f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8a66fcb2-fe14-4698-a10c-1a33ca2ecd31
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## List


### Request

#### Endpoint

```plaintext
GET /classification_entries
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_entries`

#### Parameters



| Name | Description |
|:-----|:------------|
| query  | search query |
| filter[classification_entry_id_eq]  | filter by classification_entry_id |
| filter[classification_table_id_eq]  | filter by classification_table_id |
| filter[classification_table_id_in]  | filter by classification_table_id (multiple) |
| filter[classification_entry_id_blank]  | filter by blank classification_entry_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: bafad130-2bf3-4fe0-9016-83852ec8b385
200 OK
```


```json
{
  "data": [
    {
      "id": "4cacd951-77a5-46c6-8311-33788590e101",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal",
        "name": "CE 1",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=4cacd951-77a5-46c6-8311-33788590e101",
            "self": "/classification_entries/4cacd951-77a5-46c6-8311-33788590e101/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=4cacd951-77a5-46c6-8311-33788590e101",
            "self": "/classification_entries/4cacd951-77a5-46c6-8311-33788590e101/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "2ca2b98f-6c66-44e9-a0fd-64e19496275f",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal",
        "name": "CE 11",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=2ca2b98f-6c66-44e9-a0fd-64e19496275f",
            "self": "/classification_entries/2ca2b98f-6c66-44e9-a0fd-64e19496275f/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "4cacd951-77a5-46c6-8311-33788590e101",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/2ca2b98f-6c66-44e9-a0fd-64e19496275f"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=2ca2b98f-6c66-44e9-a0fd-64e19496275f",
            "self": "/classification_entries/2ca2b98f-6c66-44e9-a0fd-64e19496275f/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "503f9825-8063-4a49-a809-1a9f2bfce256",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal",
        "name": "CE 2",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=503f9825-8063-4a49-a809-1a9f2bfce256",
            "self": "/classification_entries/503f9825-8063-4a49-a809-1a9f2bfce256/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=503f9825-8063-4a49-a809-1a9f2bfce256",
            "self": "/classification_entries/503f9825-8063-4a49-a809-1a9f2bfce256/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    }
  ],
  "included": [

  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/classification_entries",
    "current": "http://example.org/classification_entries?include=tags&page[number]=1&sort=code"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## Show


### Request

#### Endpoint

```plaintext
GET /classification_entries/52d9ca72-6a1b-4d10-a3ff-1bdcc8214506
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1b8f068e-17f5-4e26-bb70-dad46dd9b6ba
200 OK
```


```json
{
  "data": {
    "id": "52d9ca72-6a1b-4d10-a3ff-1bdcc8214506",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "Alarm signal",
      "name": "CE 1",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=52d9ca72-6a1b-4d10-a3ff-1bdcc8214506",
          "self": "/classification_entries/52d9ca72-6a1b-4d10-a3ff-1bdcc8214506/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=52d9ca72-6a1b-4d10-a3ff-1bdcc8214506",
          "self": "/classification_entries/52d9ca72-6a1b-4d10-a3ff-1bdcc8214506/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/52d9ca72-6a1b-4d10-a3ff-1bdcc8214506"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## Update


### Request

#### Endpoint

```plaintext
PATCH /classification_entries/1cf6bc78-3022-42ae-9955-3919ce35a3e9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "1cf6bc78-3022-42ae-9955-3919ce35a3e9",
    "type": "classification_entry",
    "attributes": {
      "name": "New classification entry name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New Classification Table name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2b33c345-8c09-4df0-b434-aceda5c1d920
200 OK
```


```json
{
  "data": {
    "id": "1cf6bc78-3022-42ae-9955-3919ce35a3e9",
    "type": "classification_entry",
    "attributes": {
      "code": "AA",
      "definition": "Alarm signal",
      "name": "New classification entry name",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=1cf6bc78-3022-42ae-9955-3919ce35a3e9",
          "self": "/classification_entries/1cf6bc78-3022-42ae-9955-3919ce35a3e9/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "fdd9d9e8-6f66-4ffe-8647-915447420dc2",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/1cf6bc78-3022-42ae-9955-3919ce35a3e9"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=1cf6bc78-3022-42ae-9955-3919ce35a3e9",
          "self": "/classification_entries/1cf6bc78-3022-42ae-9955-3919ce35a3e9/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/1cf6bc78-3022-42ae-9955-3919ce35a3e9"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /classification_entries/c0c15e6a-2d47-40b7-83e1-cc104ad1514c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d277c2e8-55da-400c-9c9e-7c7716604b4f
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## Create


### Request

#### Endpoint

```plaintext
POST /classification_tables/6ad49a74-2207-403e-8aef-481e1a1ff677/relationships/classification_entries
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:classification_table_id/relationships/classification_entries`

#### Parameters


```json
{
  "data": {
    "type": "classification_entry",
    "attributes": {
      "code": "C",
      "name": "New name",
      "definition": "New definition"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0964cb3a-2f46-490c-a0e8-ae74f98c0b53
201 Created
```


```json
{
  "data": {
    "id": "75375a39-a443-41e3-bfa4-04ea3ca6ed2e",
    "type": "classification_entry",
    "attributes": {
      "code": "C",
      "definition": "New definition",
      "name": "New name",
      "reciprocal_name": null
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=75375a39-a443-41e3-bfa4-04ea3ca6ed2e",
          "self": "/classification_entries/75375a39-a443-41e3-bfa4-04ea3ca6ed2e/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=75375a39-a443-41e3-bfa4-04ea3ca6ed2e",
          "self": "/classification_entries/75375a39-a443-41e3-bfa4-04ea3ca6ed2e/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/6ad49a74-2207-403e-8aef-481e1a1ff677/relationships/classification_entries"
  },
  "included": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[archived]  | filter by archived flag |
| filter[published]  | filter by published flag |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 55a7fd1c-22a1-4f5a-8402-bf87a25edab7
200 OK
```


```json
{
  "data": [
    {
      "id": "99932e35-ba0e-4fb8-8c9d-6ec84dd77a38",
      "type": "syntax",
      "attributes": {
        "account_id": "8442706f-e51b-4122-a9ed-9589a98e49f3",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax bbff113735b5",
        "published": false,
        "published_at": null
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        },
        "syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter[syntax_id_eq]=99932e35-ba0e-4fb8-8c9d-6ec84dd77a38",
            "self": "/syntaxes/99932e35-ba0e-4fb8-8c9d-6ec84dd77a38/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/0e59c67d-4eba-4583-9049-241f1bf19bab",
            "self": "/syntax_nodes/0e59c67d-4eba-4583-9049-241f1bf19bab/relationships/components"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/syntaxes",
    "current": "http://example.org/syntaxes?page[number]=1&sort=name"
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
GET /syntaxes/56cd7032-4a11-49f8-81e5-4dc47d623c6c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1176b70e-40d3-4344-95df-efcc4ac0d0e8
200 OK
```


```json
{
  "data": {
    "id": "56cd7032-4a11-49f8-81e5-4dc47d623c6c",
    "type": "syntax",
    "attributes": {
      "account_id": "9ebd4e7e-822d-4b2e-9d4f-3a722df524b0",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 44e8b11cce8b",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=56cd7032-4a11-49f8-81e5-4dc47d623c6c",
          "self": "/syntaxes/56cd7032-4a11-49f8-81e5-4dc47d623c6c/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/6ea3c2ae-416e-4d9c-8eb3-6dcc6c6a6116",
          "self": "/syntax_nodes/6ea3c2ae-416e-4d9c-8eb3-6dcc6c6a6116/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/56cd7032-4a11-49f8-81e5-4dc47d623c6c"
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3cb914e9-1bca-4d88-991f-bbb8bad91903
201 Created
```


```json
{
  "data": {
    "id": "297da8bd-f20d-4fd3-8963-b041b0575198",
    "type": "syntax",
    "attributes": {
      "account_id": "3b2c5a6c-b101-4958-a70e-cdbc6a8b3883",
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
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=297da8bd-f20d-4fd3-8963-b041b0575198",
          "self": "/syntaxes/297da8bd-f20d-4fd3-8963-b041b0575198/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/ef542b0f-a32c-4ea5-90fc-16329d7814e2",
          "self": "/syntax_nodes/ef542b0f-a32c-4ea5-90fc-16329d7814e2/relationships/components"
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
PATCH /syntaxes/7f272885-7b73-4263-b02b-9f6a223e66ff
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "7f272885-7b73-4263-b02b-9f6a223e66ff",
    "type": "syntax",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4e32622e-3a66-4c56-b514-46f59e997ff3
200 OK
```


```json
{
  "data": {
    "id": "7f272885-7b73-4263-b02b-9f6a223e66ff",
    "type": "syntax",
    "attributes": {
      "account_id": "69bf7387-b0bd-4a90-8d7d-de404f028c4e",
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
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=7f272885-7b73-4263-b02b-9f6a223e66ff",
          "self": "/syntaxes/7f272885-7b73-4263-b02b-9f6a223e66ff/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/e3fbba38-801b-4cc9-ae9b-d6ccecee6568",
          "self": "/syntax_nodes/e3fbba38-801b-4cc9-ae9b-d6ccecee6568/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/7f272885-7b73-4263-b02b-9f6a223e66ff"
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
DELETE /syntaxes/7e01c827-b027-4c8d-b991-83c052b697e8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 819d9de4-a92d-4c9e-b41d-979446be8956
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
POST /syntaxes/de023cc5-7cc2-46d3-929e-3c2441e062a9/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ea25d5d8-c28d-4c8b-bb9e-9be9ace878a2
200 OK
```


```json
{
  "data": {
    "id": "de023cc5-7cc2-46d3-929e-3c2441e062a9",
    "type": "syntax",
    "attributes": {
      "account_id": "8867ab99-1a9a-4be6-aa32-8b5c628fa2df",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax d58ddf365f49",
      "published": true,
      "published_at": "2020-04-16T19:35:43.232Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=de023cc5-7cc2-46d3-929e-3c2441e062a9",
          "self": "/syntaxes/de023cc5-7cc2-46d3-929e-3c2441e062a9/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/fb2024f4-6917-4859-8f36-6056628e09da",
          "self": "/syntax_nodes/fb2024f4-6917-4859-8f36-6056628e09da/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/de023cc5-7cc2-46d3-929e-3c2441e062a9/publish"
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
POST /syntaxes/0c7e44b0-a2e2-490f-9296-5e0af6448559/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a3b4802e-b972-45bf-abb1-82603a5d2054
200 OK
```


```json
{
  "data": {
    "id": "0c7e44b0-a2e2-490f-9296-5e0af6448559",
    "type": "syntax",
    "attributes": {
      "account_id": "a435a14f-7893-49fb-ab04-b9db5afb3c39",
      "archived": true,
      "archived_at": "2020-04-16T19:35:43.949Z",
      "description": "Description",
      "name": "Syntax cba18bb9ceab",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=0c7e44b0-a2e2-490f-9296-5e0af6448559",
          "self": "/syntaxes/0c7e44b0-a2e2-490f-9296-5e0af6448559/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/c09422fd-f213-43be-a7e3-ead2b96d6d1b",
          "self": "/syntax_nodes/c09422fd-f213-43be-a7e3-ead2b96d6d1b/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/0c7e44b0-a2e2-490f-9296-5e0af6448559/archive"
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[syntax_id_eq]  | filter by syntax_id |
| filter[allowed_for_object_occurrence_id_eq]  | filter by allowed for children of OOC with id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e2e83eef-8537-4dea-9f8e-73499ec2beeb
200 OK
```


```json
{
  "data": [
    {
      "id": "712b8cdf-844c-49ec-bcbb-ed3e50f9a64f",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 18",
        "hex_color": "db42ff"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/519b9bee-a77c-4ad3-9393-27c30c85042b"
          }
        },
        "classification_table": {
          "data": {
            "id": "6cc2d3d8-88fc-455e-8212-a35955ba32c7",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/6cc2d3d8-88fc-455e-8212-a35955ba32c7",
            "self": "/syntax_elements/712b8cdf-844c-49ec-bcbb-ed3e50f9a64f/relationships/classification_table"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/syntax_elements",
    "current": "http://example.org/syntax_elements?page[number]=1&sort=name"
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
GET /syntax_elements/efd93cd1-8fca-4688-8844-9c9b1249fd88
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3b220952-6e24-4f97-853d-5a5b9993b60e
200 OK
```


```json
{
  "data": {
    "id": "efd93cd1-8fca-4688-8844-9c9b1249fd88",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 19",
      "hex_color": "4b57db"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/61762eca-d475-4808-9caf-ebf94b5ab203"
        }
      },
      "classification_table": {
        "data": {
          "id": "d4a21cb4-dd29-4339-9590-29792d7dd9c1",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/d4a21cb4-dd29-4339-9590-29792d7dd9c1",
          "self": "/syntax_elements/efd93cd1-8fca-4688-8844-9c9b1249fd88/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/efd93cd1-8fca-4688-8844-9c9b1249fd88"
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
POST /syntaxes/9ec57606-d823-4ad2-94c6-c55ee428680c/relationships/syntax_elements
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:syntax_id/relationships/syntax_elements`

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
      "aspect": "#"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "77fcd5d1-3132-4a51-8a58-6c6e7996d148"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 982c8582-dadb-4eae-b6cd-66bded92da36
201 Created
```


```json
{
  "data": {
    "id": "e1628c64-c8ab-49c4-801e-656736afbcc9",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "hex_color": "001122"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/9ec57606-d823-4ad2-94c6-c55ee428680c"
        }
      },
      "classification_table": {
        "data": {
          "id": "77fcd5d1-3132-4a51-8a58-6c6e7996d148",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/77fcd5d1-3132-4a51-8a58-6c6e7996d148",
          "self": "/syntax_elements/e1628c64-c8ab-49c4-801e-656736afbcc9/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/9ec57606-d823-4ad2-94c6-c55ee428680c/relationships/syntax_elements"
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
PATCH /syntax_elements/5966d9cc-5d0a-4c37-a667-399d43d199fc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "5966d9cc-5d0a-4c37-a667-399d43d199fc",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "738b4d81-b761-40c8-9f5b-9087d648495e"
        }
      }
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 59acafc7-6c86-4f5b-a568-56db29ddccb4
200 OK
```


```json
{
  "data": {
    "id": "5966d9cc-5d0a-4c37-a667-399d43d199fc",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "hex_color": "63ec6c"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/8c7f4ddb-5441-455d-be2a-b71b38e73700"
        }
      },
      "classification_table": {
        "data": {
          "id": "738b4d81-b761-40c8-9f5b-9087d648495e",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/738b4d81-b761-40c8-9f5b-9087d648495e",
          "self": "/syntax_elements/5966d9cc-5d0a-4c37-a667-399d43d199fc/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/5966d9cc-5d0a-4c37-a667-399d43d199fc"
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
DELETE /syntax_elements/fdef1ad5-0a5f-4617-aca4-0b0e5ceed42c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 85d95fd1-50e4-43d6-9c12-53bde1901736
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


## Update classification_table


### Request

#### Endpoint

```plaintext
PATCH /syntax_elements/dd54ba2b-5a5a-492e-b620-8d14863e6111/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "c284c1b5-1209-4438-a6fd-66724319a362",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f5395db7-508f-4a0f-abd2-8430a03ebdca
200 OK
```


```json
{
  "data": {
    "id": "dd54ba2b-5a5a-492e-b620-8d14863e6111",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 23",
      "hex_color": "25b339"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/49a9edba-0da4-40ba-8308-b56d4b373068"
        }
      },
      "classification_table": {
        "data": {
          "id": "c284c1b5-1209-4438-a6fd-66724319a362",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/c284c1b5-1209-4438-a6fd-66724319a362",
          "self": "/syntax_elements/dd54ba2b-5a5a-492e-b620-8d14863e6111/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/dd54ba2b-5a5a-492e-b620-8d14863e6111/relationships/classification_table"
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


## Delete classification_table


### Request

#### Endpoint

```plaintext
DELETE /syntax_elements/94dadb3f-a919-4625-a50a-7b617429ffb0/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7a1b9a93-8c70-4ccb-8a98-f5430ca330ec
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


## List syntax nodes


### Request

#### Endpoint

```plaintext
GET /syntax_nodes
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_nodes`

#### Parameters



| Name | Description |
|:-----|:------------|
| filter[allowed_for_object_occurrence_id_eq]  | filter by allowed for children of OOC with id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 75fa5e00-3801-4bea-8afe-119fb5dd6aad
200 OK
```


```json
{
  "data": [
    {
      "id": "dcf2a385-afa9-4552-9a11-36f61a28d3da",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "components": {
          "data": [
            {
              "id": "02f6ef5c-c614-4ed4-a7b8-42a48e729936",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/dcf2a385-afa9-4552-9a11-36f61a28d3da/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/dcf2a385-afa9-4552-9a11-36f61a28d3da/relationships/parent",
            "related": "/syntax_nodes/dcf2a385-afa9-4552-9a11-36f61a28d3da"
          }
        }
      }
    },
    {
      "id": "1c11dd00-096c-4631-8d19-355efdd2d44a",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/36d527c3-6139-414a-9bf9-94dc0ec9a9ef"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/1c11dd00-096c-4631-8d19-355efdd2d44a/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/1c11dd00-096c-4631-8d19-355efdd2d44a/relationships/parent",
            "related": "/syntax_nodes/1c11dd00-096c-4631-8d19-355efdd2d44a"
          }
        }
      }
    },
    {
      "id": "7ba69dac-7bb0-4ad8-b2a0-e521ac3b527d",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/36d527c3-6139-414a-9bf9-94dc0ec9a9ef"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/7ba69dac-7bb0-4ad8-b2a0-e521ac3b527d/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/7ba69dac-7bb0-4ad8-b2a0-e521ac3b527d/relationships/parent",
            "related": "/syntax_nodes/7ba69dac-7bb0-4ad8-b2a0-e521ac3b527d"
          }
        }
      }
    },
    {
      "id": "3d92aca3-6c10-42b2-b1b4-dbe1838a7d73",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/36d527c3-6139-414a-9bf9-94dc0ec9a9ef"
          }
        },
        "components": {
          "data": [
            {
              "id": "1c11dd00-096c-4631-8d19-355efdd2d44a",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/3d92aca3-6c10-42b2-b1b4-dbe1838a7d73/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/3d92aca3-6c10-42b2-b1b4-dbe1838a7d73/relationships/parent",
            "related": "/syntax_nodes/3d92aca3-6c10-42b2-b1b4-dbe1838a7d73"
          }
        }
      }
    },
    {
      "id": "02f6ef5c-c614-4ed4-a7b8-42a48e729936",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/36d527c3-6139-414a-9bf9-94dc0ec9a9ef"
          }
        },
        "components": {
          "data": [
            {
              "id": "3d92aca3-6c10-42b2-b1b4-dbe1838a7d73",
              "type": "syntax_node"
            },
            {
              "id": "7ba69dac-7bb0-4ad8-b2a0-e521ac3b527d",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/02f6ef5c-c614-4ed4-a7b8-42a48e729936/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/02f6ef5c-c614-4ed4-a7b8-42a48e729936/relationships/parent",
            "related": "/syntax_nodes/02f6ef5c-c614-4ed4-a7b8-42a48e729936"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 5
  },
  "links": {
    "self": "http://example.org/syntax_nodes",
    "current": "http://example.org/syntax_nodes?page[number]=1"
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


## Show


### Request

#### Endpoint

```plaintext
GET /syntax_nodes/fdced59b-4886-4504-8d68-5a46edefdc46?depth=2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_nodes/:id?depth=:depth`

#### Parameters


```json
depth: 2
```


| Name | Description |
|:-----|:------------|
| depth  | Components depth |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a7ca6253-4222-47cc-82a4-5c7b7f9f7e02
200 OK
```


```json
{
  "data": {
    "id": "fdced59b-4886-4504-8d68-5a46edefdc46",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/5b914952-a63e-419d-bd02-75ba9b1b3623"
        }
      },
      "components": {
        "data": [
          {
            "id": "79281800-cc72-46a4-8a33-05218d81fbff",
            "type": "syntax_node"
          },
          {
            "id": "da93af00-68d3-4df6-862b-9f2d4a80dd8a",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/fdced59b-4886-4504-8d68-5a46edefdc46/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/fdced59b-4886-4504-8d68-5a46edefdc46/relationships/parent",
          "related": "/syntax_nodes/fdced59b-4886-4504-8d68-5a46edefdc46"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/fdced59b-4886-4504-8d68-5a46edefdc46?depth=2"
  },
  "included": [
    {
      "id": "da93af00-68d3-4df6-862b-9f2d4a80dd8a",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/5b914952-a63e-419d-bd02-75ba9b1b3623"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/da93af00-68d3-4df6-862b-9f2d4a80dd8a/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/da93af00-68d3-4df6-862b-9f2d4a80dd8a/relationships/parent",
            "related": "/syntax_nodes/da93af00-68d3-4df6-862b-9f2d4a80dd8a"
          }
        }
      }
    },
    {
      "id": "79281800-cc72-46a4-8a33-05218d81fbff",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/5b914952-a63e-419d-bd02-75ba9b1b3623"
          }
        },
        "components": {
          "data": [
            {
              "id": "590d8feb-3ec7-4a93-89be-2f304e64618b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/79281800-cc72-46a4-8a33-05218d81fbff/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/79281800-cc72-46a4-8a33-05218d81fbff/relationships/parent",
            "related": "/syntax_nodes/79281800-cc72-46a4-8a33-05218d81fbff"
          }
        }
      }
    },
    {
      "id": "590d8feb-3ec7-4a93-89be-2f304e64618b",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/5b914952-a63e-419d-bd02-75ba9b1b3623"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/590d8feb-3ec7-4a93-89be-2f304e64618b/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/590d8feb-3ec7-4a93-89be-2f304e64618b/relationships/parent",
            "related": "/syntax_nodes/590d8feb-3ec7-4a93-89be-2f304e64618b"
          }
        }
      }
    }
  ]
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
POST /syntax_nodes/f25bb58b-9288-4f73-b764-46f9af3102cb/relationships/components
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntax_nodes/:syntax_node_id/relationships/components`

#### Parameters


```json
{
  "data": {
    "type": "syntax_node",
    "attributes": {
      "position": 9,
      "min_depth": 1,
      "max_depth": 5
    },
    "relationships": {
      "syntax_element": {
        "data": {
          "type": "syntax_element",
          "id": "dc165a59-31f8-4d97-9c43-399b0f577989"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a7a13112-1dbe-411b-b36e-2696c4b95e38
201 Created
```


```json
{
  "data": {
    "id": "83a73fdb-5e48-4394-a795-67c2ae7f8721",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/dc165a59-31f8-4d97-9c43-399b0f577989"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/83a73fdb-5e48-4394-a795-67c2ae7f8721/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/83a73fdb-5e48-4394-a795-67c2ae7f8721/relationships/parent",
          "related": "/syntax_nodes/83a73fdb-5e48-4394-a795-67c2ae7f8721"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/f25bb58b-9288-4f73-b764-46f9af3102cb/relationships/components"
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


## Change parentage


### Request

#### Endpoint

```plaintext
PATCH /syntax_nodes/54876da5-82db-40ea-a5c4-c08851e83fbc/relationships/parent
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:syntax_node_id/relationships/parent`

#### Parameters


```json
{
  "data": {
    "type": "syntax_node",
    "id": "7a175c4b-58f2-4d53-b353-8417e1df99bf"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 5adc03f6-6c59-4d96-99ba-6b5165237a65
200 OK
```


```json
{
  "data": {
    "id": "54876da5-82db-40ea-a5c4-c08851e83fbc",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/8682ddcf-08ad-43be-ba9d-4527ff086404"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/54876da5-82db-40ea-a5c4-c08851e83fbc/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/54876da5-82db-40ea-a5c4-c08851e83fbc/relationships/parent",
          "related": "/syntax_nodes/54876da5-82db-40ea-a5c4-c08851e83fbc"
        }
      }
    }
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
PATCH /syntax_nodes/409e9c7f-2b21-4fc8-bf16-0f29477d3d10
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "409e9c7f-2b21-4fc8-bf16-0f29477d3d10",
    "type": "syntax_node",
    "attributes": {
      "min_depth": 1,
      "max_depth": 2,
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: bd7cc758-492a-4981-abd7-2e7a0446b988
200 OK
```


```json
{
  "data": {
    "id": "409e9c7f-2b21-4fc8-bf16-0f29477d3d10",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/da455b20-f470-45ca-87d1-3a073a49d501"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/409e9c7f-2b21-4fc8-bf16-0f29477d3d10/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/409e9c7f-2b21-4fc8-bf16-0f29477d3d10/relationships/parent",
          "related": "/syntax_nodes/409e9c7f-2b21-4fc8-bf16-0f29477d3d10"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/409e9c7f-2b21-4fc8-bf16-0f29477d3d10"
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
DELETE /syntax_nodes/e119fc2e-b5a9-4de0-9c2f-c092792b4277
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 437ca0ad-8be4-4d0f-b452-9ab763cc6cae
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


# Progress Models

Progress models represent a set of progress steps.


## List


### Request

#### Endpoint

```plaintext
GET /progress_models
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_models`

#### Parameters



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[published]  | filter by published flag |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: bddd9c85-6429-41fa-99e2-e2947c9e88c0
200 OK
```


```json
{
  "data": [
    {
      "id": "5c7e3b89-1896-4a52-aa68-1a4b72dd4579",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-04-16T19:35:54.179Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=5c7e3b89-1896-4a52-aa68-1a4b72dd4579",
            "self": "/progress_models/5c7e3b89-1896-4a52-aa68-1a4b72dd4579/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "b1975e81-5cf1-475a-8b33-c00716057ab8",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 2",
        "order": 2,
        "published": false,
        "published_at": null,
        "type": "object_occurrence_relation"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b1975e81-5cf1-475a-8b33-c00716057ab8",
            "self": "/progress_models/b1975e81-5cf1-475a-8b33-c00716057ab8/relationships/progress_steps"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/progress_models",
    "current": "http://example.org/progress_models?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## Show


### Request

#### Endpoint

```plaintext
GET /progress_models/5e0a0db7-a688-4332-bd03-3b41503a506a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7e8754dc-aa6f-4c02-b0a5-b5022fd24e22
200 OK
```


```json
{
  "data": {
    "id": "5e0a0db7-a688-4332-bd03-3b41503a506a",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-04-16T19:35:54.926Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=5e0a0db7-a688-4332-bd03-3b41503a506a",
          "self": "/progress_models/5e0a0db7-a688-4332-bd03-3b41503a506a/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/5e0a0db7-a688-4332-bd03-3b41503a506a"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## Update


### Request

#### Endpoint

```plaintext
PATCH /progress_models/1a9dc885-dcf9-4277-9189-b56932af476b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "1a9dc885-dcf9-4277-9189-b56932af476b",
    "type": "progress_model",
    "attributes": {
      "name": "New progress model name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New progress model name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 41ff2ced-a734-4738-bf9b-e67854a20fad
200 OK
```


```json
{
  "data": {
    "id": "1a9dc885-dcf9-4277-9189-b56932af476b",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 6,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=1a9dc885-dcf9-4277-9189-b56932af476b",
          "self": "/progress_models/1a9dc885-dcf9-4277-9189-b56932af476b/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/1a9dc885-dcf9-4277-9189-b56932af476b"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /progress_models/03cb18d1-e52b-4789-a86e-c6216f75c857
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 578a304c-e423-4bd7-b96a-383063cb055e
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## Publish


### Request

#### Endpoint

```plaintext
POST /progress_models/a446ffc7-7fb2-41ea-bd86-52c12113717e/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6d6089b9-f01e-497e-a8eb-dfe3bb84ac41
200 OK
```


```json
{
  "data": {
    "id": "a446ffc7-7fb2-41ea-bd86-52c12113717e",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-04-16T19:35:57.278Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a446ffc7-7fb2-41ea-bd86-52c12113717e",
          "self": "/progress_models/a446ffc7-7fb2-41ea-bd86-52c12113717e/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/a446ffc7-7fb2-41ea-bd86-52c12113717e/publish"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## Archive


### Request

#### Endpoint

```plaintext
POST /progress_models/1cf07f51-0e33-4c1a-8fe5-6028f262869a/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 74c9da60-38e7-492c-981e-a3510a11ca95
200 OK
```


```json
{
  "data": {
    "id": "1cf07f51-0e33-4c1a-8fe5-6028f262869a",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-16T19:35:57.878Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=1cf07f51-0e33-4c1a-8fe5-6028f262869a",
          "self": "/progress_models/1cf07f51-0e33-4c1a-8fe5-6028f262869a/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/1cf07f51-0e33-4c1a-8fe5-6028f262869a/archive"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## Create


### Request

#### Endpoint

```plaintext
POST /progress_models
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models`

#### Parameters


```json
{
  "data": {
    "type": "progress_model",
    "attributes": {
      "name": "New progress model name",
      "order": 1,
      "type": "Project"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f4b2847e-c194-42d5-bcfe-7b56ffa990e3
201 Created
```


```json
{
  "data": {
    "id": "33fbcce7-7cd4-4008-8aa1-47bcd0d165a8",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 1,
      "published": false,
      "published_at": null,
      "type": "project"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=33fbcce7-7cd4-4008-8aa1-47bcd0d165a8",
          "self": "/progress_models/33fbcce7-7cd4-4008-8aa1-47bcd0d165a8/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


# Progress Steps

Progress steps represent a list of all steps assigned to the progress model.


## List


### Request

#### Endpoint

```plaintext
GET /progress_steps
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_steps`

#### Parameters



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[progress_model_id_eq]  | filter by progress_model_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 93730c3b-37fb-4c0c-8434-e926d9e5126e
200 OK
```


```json
{
  "data": [
    {
      "id": "dfccaf4a-2fba-4ce2-918f-436a4718b5bf",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1,
        "hex_color": "91db18"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/c334ed6c-206c-4409-bfda-25f44e868e5c"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/progress_steps",
    "current": "http://example.org/progress_steps?page[number]=1&sort=order"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## Show


### Request

#### Endpoint

```plaintext
GET /progress_steps/be73c7a6-d11f-4cf4-a78b-0fa4412322be
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 69cac2ac-bacb-439f-9540-ab008b3145f0
200 OK
```


```json
{
  "data": {
    "id": "be73c7a6-d11f-4cf4-a78b-0fa4412322be",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2,
      "hex_color": "32eb90"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/334c46dc-416c-4e75-9d49-d87408ac843e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/be73c7a6-d11f-4cf4-a78b-0fa4412322be"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## Update


### Request

#### Endpoint

```plaintext
PATCH /progress_steps/da288944-5680-461d-a6a7-91a3a984155d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "da288944-5680-461d-a6a7-91a3a984155d",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "hex_color": "#444444"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New progress step name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 36c11c8b-1f26-458a-ad1e-8500b96075bf
200 OK
```


```json
{
  "data": {
    "id": "da288944-5680-461d-a6a7-91a3a984155d",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3,
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/544d11eb-d424-454a-b838-0bcea6883872"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/da288944-5680-461d-a6a7-91a3a984155d"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /progress_steps/3797cc81-872c-49e0-9ba6-040b76a98903
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 40fbc735-bdbc-4b61-aff7-e317ea6e86f9
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## Create


### Request

#### Endpoint

```plaintext
POST /progress_models/342570a9-5e4b-47a7-ab1f-93dcc47efe33/relationships/progress_steps
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models/:progress_model_id/relationships/progress_steps`

#### Parameters


```json
{
  "data": {
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 5ba5afcc-fbfe-4ff2-8192-b03751b334eb
201 Created
```


```json
{
  "data": {
    "id": "e66e42e4-bb2c-47b2-8362-00563774db60",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/342570a9-5e4b-47a7-ab1f-93dcc47efe33"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/342570a9-5e4b-47a7-ab1f-93dcc47efe33/relationships/progress_steps"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


# Progress

Progress endpoints handles the information stored in the progress_step_checked table.
They allows to manage which steps of the progress model have been completed.


## List


### Request

#### Endpoint

```plaintext
GET /progress
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress`

#### Parameters



| Name | Description |
|:-----|:------------|
| filter[target_id_eq]  | filter by target_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8cca8583-79b5-422e-857d-25f2377a90aa
200 OK
```


```json
{
  "data": [
    {
      "id": "81eb39dd-1e46-4aba-8c3b-e845da285110",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/399514a9-cc12-4f68-9a32-57f9ff76be88"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/554f41b8-f3be-4ff0-ae2f-8444fc8954d6"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/progress",
    "current": "http://example.org/progress?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][progress_step] | Progress step |
| data[attributes][target] | Target |


## Show


### Request

#### Endpoint

```plaintext
GET /progress/176ea6af-a3ae-47e1-a696-2cf8fcebc091
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ca3bde89-6d4d-4477-810e-3ed0a6a7f6c4
200 OK
```


```json
{
  "data": {
    "id": "176ea6af-a3ae-47e1-a696-2cf8fcebc091",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/f1bab812-8630-487b-92cb-f4fbc9dc218d"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/5458be2c-6b77-44fd-b4a4-5592c0ac3077"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/176ea6af-a3ae-47e1-a696-2cf8fcebc091"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][progress_step] | Progress step |
| data[attributes][target] | Target |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /progress/06a6b580-bfcf-4904-a274-8702a7fd5ed1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 07630753-581c-4dd0-8eb0-7ea18a689590
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][progress_step] | Progress step |
| data[attributes][target] | Target |


## Create


### Request

#### Endpoint

```plaintext
POST /progress
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress`

#### Parameters


```json
{
  "data": {
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "type": "progress_step",
          "id": "d45dad8d-1cf7-430f-86b5-a4b62156c6fd"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "9ca7da0d-e5d8-4eeb-99b8-8d3f8b138085"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2d94c096-7ba4-4f26-871d-2e879bf79090
201 Created
```


```json
{
  "data": {
    "id": "21c3a292-733d-455c-814e-ce356df926dd",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/d45dad8d-1cf7-430f-86b5-a4b62156c6fd"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/9ca7da0d-e5d8-4eeb-99b8-8d3f8b138085"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][progress_step] | Progress step |
| data[attributes][target] | Target |


# Project settings

Project settings represent meta-information about the project, which is enforced against any nested structures.


## List


### Request

#### Endpoint

```plaintext
GET /project_settings
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /project_settings`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8df56da7-da27-46f8-b7d3-e5b3fe87b340
200 OK
```


```json
{
  "data": [
    {
      "id": "fa381de8-dba1-43a0-af04-1be92b31b2fe",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "9f3e5bec-2148-44e4-8e29-c433966a3e1c"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/9f3e5bec-2148-44e4-8e29-c433966a3e1c"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/project_settings",
    "current": "http://example.org/project_settings?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


## Show


### Request

#### Endpoint

```plaintext
GET /projects/bfb35247-9ecd-40bf-bbac-bb5b8562b75b/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:project_id/relationships/project_setting`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1d2e878a-1580-470f-be6f-8494dda14b6e
200 OK
```


```json
{
  "data": {
    "id": "1dde62bc-1d65-41bd-99ab-9a26efd2282b",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "bfb35247-9ecd-40bf-bbac-bb5b8562b75b"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/bfb35247-9ecd-40bf-bbac-bb5b8562b75b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/bfb35247-9ecd-40bf-bbac-bb5b8562b75b/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


## Update


### Request

#### Endpoint

```plaintext
PATCH /projects/492f666a-a5f0-4cfe-b269-1c4f50ad698d/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "492f666a-a5f0-4cfe-b269-1c4f50ad698d",
    "type": "project_settings",
    "attributes": {
      "contexts_limit": 2,
      "context_revisions_to_keep": 1
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][contexts_limit]  | New number system context limit |
| data[attributes][context_revisions_to_keep]  | New number context revisions to keep |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4b77b091-4e9b-4364-b298-186f3626e624
200 OK
```


```json
{
  "data": {
    "id": "b42cdc89-fa4e-4c8e-bbad-271ca2aa4ebc",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "492f666a-a5f0-4cfe-b269-1c4f50ad698d"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/492f666a-a5f0-4cfe-b269-1c4f50ad698d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/492f666a-a5f0-4cfe-b269-1c4f50ad698d/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


# System Elements

A System Element is a conceptual structure that groups Object Occurrences across Contexts.
A System Element can only consist of Object Occurrences from distinctly different Contexts.
In other words one Object Occurrence per Context per System Element.


## List


### Request

#### Endpoint

```plaintext
GET /system_elements
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /system_elements`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0202e3a4-e37a-466d-acbb-88a6f393c1c5
200 OK
```


```json
{
  "data": [
    {
      "id": "da23e1d6-b767-4571-b18b-70dc8b3a6835",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/da23e1d6-b767-4571-b18b-70dc8b3a6835"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/da23e1d6-b767-4571-b18b-70dc8b3a6835"
          }
        }
      }
    },
    {
      "id": "9799feff-8b61-4c5c-87af-90823a5c795c",
      "type": "system_element",
      "attributes": {
        "name": "OOC c88fed427be4-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/9799feff-8b61-4c5c-87af-90823a5c795c"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/9799feff-8b61-4c5c-87af-90823a5c795c"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/system_elements",
    "current": "http://example.org/system_elements?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


## Show


### Request

#### Endpoint

```plaintext
GET /system_elements/947aa101-8862-4988-b693-d2720c92973f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0346da7d-952a-49e8-9f1f-f4137682a67e
200 OK
```


```json
{
  "data": {
    "id": "947aa101-8862-4988-b693-d2720c92973f",
    "type": "system_element",
    "attributes": {
      "name": "OOC cd89413567b5-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/947aa101-8862-4988-b693-d2720c92973f"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/947aa101-8862-4988-b693-d2720c92973f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/947aa101-8862-4988-b693-d2720c92973f"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


## Create


### Request

#### Endpoint

```plaintext
POST /object_occurrences/93e3ebf6-a96f-41f6-bd09-3834111881e7/relationships/system_elements
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:object_occurrence_id/relationships/system_elements`

#### Parameters


```json
{
  "data": {
    "type": "system_element",
    "attributes": {
      "ambiguous": true,
      "target_id": "d2ec37af-7d28-4697-aa85-bb560f9e4df9"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 95831ee8-7121-4456-ac05-5e2a8ce7aeb9
201 Created
```


```json
{
  "data": {
    "id": "64c3831e-0390-4356-9b6e-b064cfcb4243",
    "type": "system_element",
    "attributes": {
      "name": "OOC d59b7dc300e8-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/64c3831e-0390-4356-9b6e-b064cfcb4243"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/64c3831e-0390-4356-9b6e-b064cfcb4243"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/93e3ebf6-a96f-41f6-bd09-3834111881e7/relationships/system_elements"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/9e0a8a09-b7ef-4e4c-ad67-353c67c0446b/relationships/system_elements/f6a3e661-e174-4907-8c09-b9cc0b4d7413
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c8008535-c729-4c38-bc14-7beae30d5a12
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


# User settings

User settings represent meta-information about the User


## Show


### Request

#### Endpoint

```plaintext
GET /user_settings
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_settings`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: efb0d3f9-d6ff-47bc-a270-3226fb9edbcb
200 OK
```


```json
{
  "data": {
    "id": "822b404d-fb33-4d03-93ae-552d750dce67",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "6e5c81f5-da05-4bbb-9d22-cc78d455b225"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/6e5c81f5-da05-4bbb-9d22-cc78d455b225"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][newsletter] | Value which tell if user give consent for neewsletter. |


## Update


### Request

#### Endpoint

```plaintext
PATCH /user_settings
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /user_settings`

#### Parameters


```json
{
  "data": {
    "type": "user_settings",
    "attributes": {
      "newsletter": true
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][newsletter]  | Value which tell if user give consent for neewsletter. |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 46405f43-0df1-4cad-96e0-7bd8fe753f75
200 OK
```


```json
{
  "data": {
    "id": "981aa114-7970-45d7-89b0-69067b46d5a6",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "54b20ec4-41b9-4927-aafc-f179dfb6cad4"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/54b20ec4-41b9-4927-aafc-f179dfb6cad4"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][newsletter] | Value which tell if user give consent for neewsletter. |


# Object Occurrence Relations

Object Occurrence Relations between Object Occurrences.


## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrence_relations/e6cec140-7bb9-40c2-84ac-5a41b2986a2f/relationships/owners
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrence_relations/:id/relationships/owners`

#### Parameters


```json
{
  "data": {
    "type": "owner",
    "attributes": {
      "name": "New owner name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name] *required* | Owner name |
| data[attributes][title]  | Owner title |
| data[attributes][company]  | Owner company |
| data[attributes][primary]  | Make the owner a primary owner (boolean) |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7eba5f74-d1d0-46b6-9f64-0431ef4b363c
201 Created
```


```json
{
  "data": {
    "id": "9cf9dce1-bc87-402c-b21d-d57ac6fae7e8",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/e6cec140-7bb9-40c2-84ac-5a41b2986a2f/relationships/owners"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][name] | Owner name |
| data[attributes][title] | Owner title |
| data[attributes][company] | Owner company |


## Add new, primary owner

Adds a new primary owner to the resource.

A primary owner can be the primary owner within a company, or generally on the
resource. This is completely depending on the business interpretation of the client.


### Request

#### Endpoint

```plaintext
POST /object_occurrence_relations/fc4b8d32-aaf1-43f2-bf76-8a3fecd64e70/relationships/owners
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrence_relations/:id/relationships/owners`

#### Parameters


```json
{
  "data": {
    "type": "owner",
    "attributes": {
      "name": "New owner name",
      "primary": true
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name] *required* | Owner name |
| data[attributes][title]  | Owner title |
| data[attributes][company]  | Owner company |
| data[attributes][primary]  | Make the owner a primary owner (boolean) |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 041b8769-cec6-4bdc-8703-7644423ae809
201 Created
```


```json
{
  "data": {
    "id": "a4456b0e-903c-4a5d-aa9e-daba5050b293",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/fc4b8d32-aaf1-43f2-bf76-8a3fecd64e70/relationships/owners"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][name] | Owner name |
| data[attributes][title] | Owner title |
| data[attributes][company] | Owner company |


## Add existing owner

Adds an existing owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrence_relations/d02ba0b0-dd5b-4ae1-b4d6-34ad3efc5a51/relationships/owners
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrence_relations/:id/relationships/owners`

#### Parameters


```json
{
  "data": {
    "type": "owner",
    "id": "0de1e73e-a869-4fd6-9048-0db01d16082a"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 5345d35c-0618-4a61-8921-ebc762d7dc83
201 Created
```


```json
{
  "data": {
    "id": "0de1e73e-a869-4fd6-9048-0db01d16082a",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 3",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/d02ba0b0-dd5b-4ae1-b4d6-34ad3efc5a51/relationships/owners"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][name] | owner name |
| data[attributes][title] | owner title |
| data[attributes][company] | owner company |


## Remove existing owner


### Request

#### Endpoint

```plaintext
DELETE /object_occurrence_relations/4d80d145-7d51-496b-9625-66c81abf5b93/relationships/owners/610e1dab-efea-4c51-b0c8-78f874f23891
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b64fee57-3a57-4e16-aaae-33fec01e99de
204 No Content
```




## List


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0dc0dc12-4716-4aa4-bbb9-336c548af3f8
200 OK
```


```json
{
  "data": [
    {
      "id": "952ba149-2b3c-429a-b166-ac8345409d69",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR ae2375e3bf4b",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=952ba149-2b3c-429a-b166-ac8345409d69",
            "self": "/object_occurrence_relations/952ba149-2b3c-429a-b166-ac8345409d69/relationships/tags"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=952ba149-2b3c-429a-b166-ac8345409d69"
          }
        },
        "classification_entry": {
          "data": {
            "id": "a878606c-11b8-4c01-8dc8-33851c26a570",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/a878606c-11b8-4c01-8dc8-33851c26a570",
            "self": "/object_occurrence_relations/952ba149-2b3c-429a-b166-ac8345409d69/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "6eeb7d87-632f-42d7-86fd-cbd474066c42",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6eeb7d87-632f-42d7-86fd-cbd474066c42",
            "self": "/object_occurrence_relations/952ba149-2b3c-429a-b166-ac8345409d69/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "6967ac7d-bbf5-42af-89fd-91cb2a8f4744",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6967ac7d-bbf5-42af-89fd-91cb2a8f4744",
            "self": "/object_occurrence_relations/952ba149-2b3c-429a-b166-ac8345409d69/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "a878606c-11b8-4c01-8dc8-33851c26a570",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 7c09537a03e9",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=a878606c-11b8-4c01-8dc8-33851c26a570",
            "self": "/classification_entries/a878606c-11b8-4c01-8dc8-33851c26a570/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=a878606c-11b8-4c01-8dc8-33851c26a570",
            "self": "/classification_entries/a878606c-11b8-4c01-8dc8-33851c26a570/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations",
    "current": "http://example.org/object_occurrence_relations?include=tags,owners,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Filter by object_occurrence_source_ids_cont and object_occurrence_target_ids_cont


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=e5be61f7-cd8e-4448-850f-c383236fb094&amp;filter[object_occurrence_source_ids_cont][]=b432c290-378e-41ce-8d84-c371d6973d8b&amp;filter[object_occurrence_target_ids_cont][]=f9ec6220-b80d-4d63-a88c-6fcd3c5f4ad9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;e5be61f7-cd8e-4448-850f-c383236fb094&quot;, &quot;b432c290-378e-41ce-8d84-c371d6973d8b&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;f9ec6220-b80d-4d63-a88c-6fcd3c5f4ad9&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 61617ce4-fb4d-45e3-bc9c-c077244f59d8
200 OK
```


```json
{
  "data": [
    {
      "id": "624bbaae-592c-4f40-a93b-32e947112ff2",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR f421f8375108",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=624bbaae-592c-4f40-a93b-32e947112ff2",
            "self": "/object_occurrence_relations/624bbaae-592c-4f40-a93b-32e947112ff2/relationships/tags"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=624bbaae-592c-4f40-a93b-32e947112ff2"
          }
        },
        "classification_entry": {
          "data": {
            "id": "57514541-33a9-4350-be2a-6218c0614ffc",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/57514541-33a9-4350-be2a-6218c0614ffc",
            "self": "/object_occurrence_relations/624bbaae-592c-4f40-a93b-32e947112ff2/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "f9ec6220-b80d-4d63-a88c-6fcd3c5f4ad9",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/f9ec6220-b80d-4d63-a88c-6fcd3c5f4ad9",
            "self": "/object_occurrence_relations/624bbaae-592c-4f40-a93b-32e947112ff2/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "e5be61f7-cd8e-4448-850f-c383236fb094",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/e5be61f7-cd8e-4448-850f-c383236fb094",
            "self": "/object_occurrence_relations/624bbaae-592c-4f40-a93b-32e947112ff2/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "57514541-33a9-4350-be2a-6218c0614ffc",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm ccf9695a43fc",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=57514541-33a9-4350-be2a-6218c0614ffc",
            "self": "/classification_entries/57514541-33a9-4350-be2a-6218c0614ffc/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=57514541-33a9-4350-be2a-6218c0614ffc",
            "self": "/classification_entries/57514541-33a9-4350-be2a-6218c0614ffc/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=e5be61f7-cd8e-4448-850f-c383236fb094&filter[object_occurrence_source_ids_cont][]=b432c290-378e-41ce-8d84-c371d6973d8b&filter[object_occurrence_target_ids_cont][]=f9ec6220-b80d-4d63-a88c-6fcd3c5f4ad9",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=e5be61f7-cd8e-4448-850f-c383236fb094&filter[object_occurrence_source_ids_cont][]=b432c290-378e-41ce-8d84-c371d6973d8b&filter[object_occurrence_target_ids_cont][]=f9ec6220-b80d-4d63-a88c-6fcd3c5f4ad9&include=tags,owners,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/170d6e24-a23c-49d2-b5e1-0137e8dea37d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 5245ed1b-970c-4562-ac1a-1e68467cfc09
200 OK
```


```json
{
  "data": {
    "id": "170d6e24-a23c-49d2-b5e1-0137e8dea37d",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "OOR e2a01f6aa411",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=170d6e24-a23c-49d2-b5e1-0137e8dea37d",
          "self": "/object_occurrence_relations/170d6e24-a23c-49d2-b5e1-0137e8dea37d/relationships/tags"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=170d6e24-a23c-49d2-b5e1-0137e8dea37d"
        }
      },
      "classification_entry": {
        "data": {
          "id": "cd890923-0048-49b8-a214-fb35f0b74749",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/cd890923-0048-49b8-a214-fb35f0b74749",
          "self": "/object_occurrence_relations/170d6e24-a23c-49d2-b5e1-0137e8dea37d/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "12bd7973-f639-4ff9-8665-65581534fdf2",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/12bd7973-f639-4ff9-8665-65581534fdf2",
          "self": "/object_occurrence_relations/170d6e24-a23c-49d2-b5e1-0137e8dea37d/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "8d11b968-9c61-400b-8dd7-3d2262e9acfb",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/8d11b968-9c61-400b-8dd7-3d2262e9acfb",
          "self": "/object_occurrence_relations/170d6e24-a23c-49d2-b5e1-0137e8dea37d/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/170d6e24-a23c-49d2-b5e1-0137e8dea37d"
  },
  "included": [

  ]
}
```



# Object Occurrences - Classification Entries Stats

Aggregated view of Object Occurrencs groupped by Classification Entry


## ClassificationEntries stats


### Request

#### Endpoint

```plaintext
GET /object_occurrences/classification_entries_stats
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/classification_entries_stats`

#### Parameters



| Name | Description |
|:-----|:------------|
| query  | search query |
| filter[context_id_eq]  | filter by context id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 08948254-0fbb-4f02-9486-f40e66024578
200 OK
```


```json
{
  "data": [
    {
      "id": "5487f7bf318ca5794c662dca9192c62095941bc5a5a2c616f37464783475b823",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "b0cfb424-cd28-4f55-b71d-cc3e0a0d4c84",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b0cfb424-cd28-4f55-b71d-cc3e0a0d4c84"
          }
        }
      }
    },
    {
      "id": "993d8a5821a021430ea5489a9193a7d1f9780a73431be7cac7d9b5a699cbaf8a",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "779e77bf-883e-4501-9084-a2b02fe2a24a",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/779e77bf-883e-4501-9084-a2b02fe2a24a"
          }
        }
      }
    },
    {
      "id": "c85c7e3a35f08578e252522e2fdc4251879556189e3ada58bb24a4c0d421b2da",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "9e213476-c6a6-45df-b75d-c77b7dac665f",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/9e213476-c6a6-45df-b75d-c77b7dac665f"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/object_occurrences/classification_entries_stats",
    "current": "http://example.org/object_occurrences/classification_entries_stats?page[number]=1&sort=code"
  }
}
```



# Object Occurrence Relations - Classification Entries Stats

Aggregated view of Object Occurrence Relations groupped by Classification Entry


## ClassificationEntries stats


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/classification_entries_stats
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations/classification_entries_stats`

#### Parameters



| Name | Description |
|:-----|:------------|
| query  | search query |
| filter[context_id_eq]  | filter by context id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8c5a8ccb-760f-461d-9fcb-f9ef93898422
200 OK
```


```json
{
  "data": [
    {
      "id": "c5d119e8cf46998803233f972fbfd523945e680b500038fe9e5979caf7c72af4",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "197e6818-c909-4301-b264-18d4655f9c58",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/197e6818-c909-4301-b264-18d4655f9c58"
          }
        }
      }
    },
    {
      "id": "f1f7f9da041019bcb03eacb7f967905da2e92415b2ea5f8462090257ed92f2a7",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "1c51a593-9ec5-4316-8042-b001e20e3ab1",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/1c51a593-9ec5-4316-8042-b001e20e3ab1"
          }
        }
      }
    },
    {
      "id": "524f99356698c8179bfccb0890517badff14f7adf72902199cff7a5127af03d8",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "cd476804-b622-456b-9289-3ea6f18e1326",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/cd476804-b622-456b-9289-3ea6f18e1326"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/classification_entries_stats",
    "current": "http://example.org/object_occurrence_relations/classification_entries_stats?page[number]=1&sort=code"
  }
}
```



# Tags

Lists all tags


## List


### Request

#### Endpoint

```plaintext
GET /tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /tags`

#### Parameters



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| filter  | available filters: target_id_eq |
| query  | search query |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f21f90bf-58bd-4dd2-8526-3095864a5092
200 OK
```


```json
{
  "data": [
    {
      "id": "76f4c299-baaf-4a07-af50-bade4c38679c",
      "type": "tag",
      "attributes": {
        "value": "tag value 7"
      },
      "relationships": {
      }
    },
    {
      "id": "f7cc28a7-bb46-4d21-8b5d-d648af61c531",
      "type": "tag",
      "attributes": {
        "value": "tag value 8"
      },
      "relationships": {
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/tags",
    "current": "http://example.org/tags?page[number]=1&sort=value"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][value] | Tag value |


# Permissions

A Permission represents a single permission which can be assigned to a User.


## List


### Request

#### Endpoint

```plaintext
GET /permissions
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /permissions`

#### Parameters



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 89908a76-4993-4592-bfb3-c163ef8e30c3
200 OK
```


```json
{
  "meta": {
    "total_count": 0
  },
  "links": {
    "self": "http://example.org/permissions",
    "current": "http://example.org/permissions?page[number]=1"
  },
  "data": [

  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Permission name |
| data[attributes][description] | Permission description |


# Utils

Events is a way to track which changes and events has happened to resources.

<aside class="warning">
  We only support this endpoint for <code>from_type</code> and <code>to_type</code> which are
  stored in the Neo4j database. We're currently working on making this available for all data
  types.
</aside>


## Look up path


### Request

#### Endpoint

```plaintext
GET /utils/path/from/object_occurrence/323bdc5d-b00d-4447-ae5f-6c1ee04ff083/to/object_occurrence/6bf4b88a-fada-497f-a5fa-82778e9a6193
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /utils/path/from/:from_type/:from_id/to/:to_type/:to_id`

#### Parameters



| Name | Description |
|:-----|:------------|
| from_type  | Type of object to start from |
| from_id  | ID of object to start from |
| to_type  | Type of object to calculate path to |
| to_id  | ID of object to calculate path to |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fb6c1155-1bae-4b57-9270-3ed9d6ca70f0
200 OK
```


```json
[
  {
    "id": "323bdc5d-b00d-4447-ae5f-6c1ee04ff083",
    "type": "object_occurrence"
  },
  {
    "id": "ca4e593c-4c24-4551-b22c-230d3b0d4bbd",
    "type": "object_occurrence"
  },
  {
    "id": "8da0accc-1785-4472-8b35-132c7cf4c2a4",
    "type": "object_occurrence"
  },
  {
    "id": "65d9e3a8-2dd1-4aae-8a95-ab6159568214",
    "type": "object_occurrence"
  },
  {
    "id": "2d82ec99-241d-45c8-8d01-b13de7f5e60c",
    "type": "object_occurrence"
  },
  {
    "id": "c411e366-4f79-4f88-9645-fcb3e3418401",
    "type": "object_occurrence"
  },
  {
    "id": "6bf4b88a-fada-497f-a5fa-82778e9a6193",
    "type": "object_occurrence"
  }
]
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][event] | Event name |


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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: created_at |
| filter[item_id_eq]  | filter by item_id |
| filter[item_type_eq]  | filter by item_type |
| filter[user_id_eq]  | filter by user_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 33f33e39-1351-433e-bb18-72b524d99a27
200 OK
```


```json
{
  "data": [
    {
      "id": "3c3b2d88-7c33-4dd4-a8dd-540660809e5a",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/67e268ee-a1c2-4403-afb0-3e00bebf9a18"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/ec75d3f3-6143-4f90-a889-90d0839d66a7"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
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
Content-Type: text/plain; charset=utf-8
X-Request-Id: d6b46422-740d-4c7c-8ced-d4348b9c7d4b
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



