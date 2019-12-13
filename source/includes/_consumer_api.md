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
X-Request-Id: ba666129-aa56-480e-a372-28ba08f9abbf
200 OK
```


```json
{
  "data": {
    "id": "e049b5bd-a2c5-4e01-97ff-4a10b93f1cc6",
    "type": "account",
    "attributes": {
      "name": "Account ffed4e22af94"
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
    "id": "e2b04b4d-c432-489f-8f26-82b1c878459d",
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
X-Request-Id: 3219797e-0411-46e8-bcdd-62bcf303ede4
200 OK
```


```json
{
  "data": {
    "id": "e2b04b4d-c432-489f-8f26-82b1c878459d",
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
X-Request-Id: 78560853-a075-495b-a1e0-9ebd7db4a056
200 OK
```


```json
{
  "data": [
    {
      "id": "94669c10-1b82-4ca1-b19e-9ec6eec02077",
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
            "related": "/contexts?filter[project_id_eq]=94669c10-1b82-4ca1-b19e-9ec6eec02077"
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
GET /projects/284ae399-e8d2-40a0-a6aa-692488909b65
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b12c6e14-9c14-4298-bddf-09d66a0e5aa0
200 OK
```


```json
{
  "data": {
    "id": "284ae399-e8d2-40a0-a6aa-692488909b65",
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
          "related": "/contexts?filter[project_id_eq]=284ae399-e8d2-40a0-a6aa-692488909b65"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/284ae399-e8d2-40a0-a6aa-692488909b65"
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
PATCH /projects/d6b55847-1d90-48e0-92f9-06b98667cace
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "d6b55847-1d90-48e0-92f9-06b98667cace",
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
X-Request-Id: 58e3944c-9d32-48e3-bfbf-c2d14d530f4a
200 OK
```


```json
{
  "data": {
    "id": "d6b55847-1d90-48e0-92f9-06b98667cace",
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
          "related": "/contexts?filter[project_id_eq]=d6b55847-1d90-48e0-92f9-06b98667cace"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/d6b55847-1d90-48e0-92f9-06b98667cace"
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
POST /projects/ebbdb61f-a64c-444c-9d73-bfb3a5425cf1/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a0754fde-ed09-478a-8a96-dcf9d8e31224
200 OK
```


```json
{
  "data": {
    "id": "ebbdb61f-a64c-444c-9d73-bfb3a5425cf1",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2019-12-13T07:13:50.422Z",
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
          "related": "/contexts?filter[project_id_eq]=ebbdb61f-a64c-444c-9d73-bfb3a5425cf1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/ebbdb61f-a64c-444c-9d73-bfb3a5425cf1/archive"
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
DELETE /projects/469eadbf-f3d4-4ddf-87bc-e133ffff21b3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ee82ea36-9e0d-4de4-8f03-48ea8032fb78
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
X-Request-Id: c64d4d0d-c9ef-48ee-8d61-42ef7a1158af
200 OK
```


```json
{
  "data": [
    {
      "id": "cafdfc9b-54ef-4dc6-a775-6cc1a5f38e4c",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "8b3e658b-be22-497b-aae0-070d0233df64",
        "published_at": null,
        "revision": 0
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/8b3e658b-be22-497b-aae0-070d0233df64"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/e72675a1-a1a1-4ade-8a63-bfe9ecf6c077"
          }
        }
      }
    },
    {
      "id": "c85ff751-45ee-4c9b-95d6-dcad8c3e0daa",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "8b3e658b-be22-497b-aae0-070d0233df64",
        "published_at": null,
        "revision": 0
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/8b3e658b-be22-497b-aae0-070d0233df64"
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


## Show


### Request

#### Endpoint

```plaintext
GET /contexts/888d4ce7-72df-4a2a-9bfb-ca8973cf5947
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 62194b1b-7e41-4e5c-8c36-b7e791f341c3
200 OK
```


```json
{
  "data": {
    "id": "888d4ce7-72df-4a2a-9bfb-ca8973cf5947",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "project_id": "fd504510-8978-4d3f-89b5-7cd1119800c3",
      "published_at": null,
      "revision": 0
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/fd504510-8978-4d3f-89b5-7cd1119800c3"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/0c7111c4-69b5-4b3c-8173-8a1612a9ee34"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/888d4ce7-72df-4a2a-9bfb-ca8973cf5947"
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


## Update


### Request

#### Endpoint

```plaintext
PATCH /contexts/701419dc-ae75-467a-b996-4e04d2f94886
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "701419dc-ae75-467a-b996-4e04d2f94886",
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
X-Request-Id: 34d1f2dd-fcc6-4fd1-8464-a36204d4c86f
200 OK
```


```json
{
  "data": {
    "id": "701419dc-ae75-467a-b996-4e04d2f94886",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "New context name",
      "project_id": "f5b94c3c-5de1-4d90-9876-71e25ec001c5",
      "published_at": null,
      "revision": 0
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/f5b94c3c-5de1-4d90-9876-71e25ec001c5"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/1072028c-a8f1-4e0f-af7c-a7bce7836ff1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/701419dc-ae75-467a-b996-4e04d2f94886"
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


## Create


### Request

#### Endpoint

```plaintext
POST /contexts
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts`

#### Parameters


```json
{
  "data": {
    "type": "context",
    "attributes": {
      "name": "Context",
      "project_id": "cde6163b-8b33-4042-bbc5-75fcfaa19ba0"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 15d9ad5a-05b1-45e3-9e3c-e1605e159e90
201 Created
```


```json
{
  "data": {
    "id": "d4e3334e-c6e8-4f6c-95a6-a8948ee4c5a4",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context",
      "project_id": "cde6163b-8b33-4042-bbc5-75fcfaa19ba0",
      "published_at": null,
      "revision": 0
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/cde6163b-8b33-4042-bbc5-75fcfaa19ba0"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/078954e5-e5c5-4d59-b36d-df5c08b945ec"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts"
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


## Create revision


### Request

#### Endpoint

```plaintext
POST /contexts/21f88985-59ff-4839-8278-2eb50e218dc6/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fed0a391-98af-4c6f-86eb-e03a5804c5f0
201 Created
```


```json
{
  "data": {
    "id": "cfd21510-48de-4ca2-b8bf-02465c68c785",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "project_id": "7a1290a5-edd4-4f51-a535-71fe9013af89",
      "published_at": null,
      "revision": 1
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/7a1290a5-edd4-4f51-a535-71fe9013af89"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/3cdddd24-c2e4-4185-8004-9757fe0da2de"
        }
      },
      "prev_revision": {
        "data": {
          "id": "21f88985-59ff-4839-8278-2eb50e218dc6",
          "type": "context"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/21f88985-59ff-4839-8278-2eb50e218dc6/revision"
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


## Delete


### Request

#### Endpoint

```plaintext
DELETE /contexts/a986dd2d-6d85-4819-8f33-d1cc728e279e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1e6749ab-14ef-4bb9-a7be-35fbebe59da7
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


# Object Occurrences

Object Occurrences represent the occurrence of a System Element in a given Context with a given aspect.


## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/e9d75dcd-141d-4105-9c59-5f219a96e67a
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
X-Request-Id: 43f50f23-ebd7-4f50-942c-a8bd660b549e
200 OK
```


```json
{
  "data": {
    "id": "e9d75dcd-141d-4105-9c59-5f219a96e67a",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "10118fcd-2a2e-4458-b88e-850f482d989c",
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
          "related": "/contexts/10118fcd-2a2e-4458-b88e-850f482d989c"
        }
      },
      "components": {
        "data": [
          {
            "id": "bf8871f0-56e2-4b35-9ff9-626a38ba828f",
            "type": "object_occurrence"
          }
        ]
      },
      "next_revision": {
        "data": null
      },
      "prev_revision": {
        "data": null
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/e9d75dcd-141d-4105-9c59-5f219a96e67a"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Create


### Request

#### Endpoint

```plaintext
POST /object_occurrences
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences`

#### Parameters


```json
{
  "data": {
    "type": "object_occurrence",
    "attributes": {
      "name": "ooc",
      "context_id": "9ea731af-17a1-45f8-9229-5c268039e140"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 5ef7b048-04f5-43db-9389-dfa81bd1005a
201 Created
```


```json
{
  "data": {
    "id": "7554a445-acf4-4d59-bb89-84f9549c815f",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "9ea731af-17a1-45f8-9229-5c268039e140",
      "description": null,
      "hex_color": null,
      "name": "ooc",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": ""
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/9ea731af-17a1-45f8-9229-5c268039e140"
        }
      },
      "components": {
        "data": [

        ]
      },
      "next_revision": {
        "data": null
      },
      "prev_revision": {
        "data": null
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Update


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/f3ef3932-405e-40d8-a511-021275152e1c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "f3ef3932-405e-40d8-a511-021275152e1c",
    "type": "object_occurrence",
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
X-Request-Id: 1ba66462-ef0c-4609-ad4f-2f496458c2fd
200 OK
```


```json
{
  "data": {
    "id": "f3ef3932-405e-40d8-a511-021275152e1c",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "bcceef13-2176-4c1b-a2f0-8a6ea75288f9",
      "description": null,
      "hex_color": null,
      "name": "New name",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": "0"
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/bcceef13-2176-4c1b-a2f0-8a6ea75288f9"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/7b7f5597-e57e-42c2-b461-ec3638cefd5f"
        }
      },
      "components": {
        "data": [

        ]
      },
      "next_revision": {
        "data": null
      },
      "prev_revision": {
        "data": null
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f3ef3932-405e-40d8-a511-021275152e1c"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/70fac073-2aeb-4b55-8540-878ff63cdda0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2966617e-a53e-472a-921b-105fc4bc12eb
204 No Content
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
X-Request-Id: efa32476-5b89-42e1-a3c8-c703cd53b855
200 OK
```


```json
{
  "data": [
    {
      "id": "db975799-3ec8-4882-9d51-0060b0049f97",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=db975799-3ec8-4882-9d51-0060b0049f97"
          }
        }
      }
    },
    {
      "id": "6ee7b324-d001-47c7-9e82-ef41f2a2d37d",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=6ee7b324-d001-47c7-9e82-ef41f2a2d37d"
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
GET /classification_tables/b1d9dc7c-65dc-4980-9e57-8dc15e7fe3c3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f3599f66-bd67-4d6c-8825-06843b9e4ec6
200 OK
```


```json
{
  "data": {
    "id": "b1d9dc7c-65dc-4980-9e57-8dc15e7fe3c3",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=b1d9dc7c-65dc-4980-9e57-8dc15e7fe3c3"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/b1d9dc7c-65dc-4980-9e57-8dc15e7fe3c3"
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
PATCH /classification_tables/57eb51d1-fcac-47a5-bd10-4893a5a8bf28
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "57eb51d1-fcac-47a5-bd10-4893a5a8bf28",
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
X-Request-Id: 7978a1fd-a40b-44de-ad0a-14da05e2f748
200 OK
```


```json
{
  "data": {
    "id": "57eb51d1-fcac-47a5-bd10-4893a5a8bf28",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=57eb51d1-fcac-47a5-bd10-4893a5a8bf28"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/57eb51d1-fcac-47a5-bd10-4893a5a8bf28"
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
DELETE /classification_tables/c3d01d24-73c9-4d9f-aae2-38a6cede6603
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f8446077-a98b-4c6f-89a8-5f48f02e583a
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
POST /classification_tables/d7e03810-a0df-40bd-82d1-1e22695edfc1/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d14ee261-47d3-4d19-9e51-208cdaab243e
200 OK
```


```json
{
  "data": {
    "id": "d7e03810-a0df-40bd-82d1-1e22695edfc1",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2019-12-13T07:13:58.174Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=d7e03810-a0df-40bd-82d1-1e22695edfc1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d7e03810-a0df-40bd-82d1-1e22695edfc1/publish"
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
POST /classification_tables/8bff926e-4176-456e-9809-a1c8d55104a5/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a7abc7d0-aaed-4ba7-9248-6fe7a372e2d8
200 OK
```


```json
{
  "data": {
    "id": "8bff926e-4176-456e-9809-a1c8d55104a5",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2019-12-13T07:13:58.512Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=8bff926e-4176-456e-9809-a1c8d55104a5"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/8bff926e-4176-456e-9809-a1c8d55104a5/archive"
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
X-Request-Id: 03b8f11e-6dcf-4314-ac4e-0dfeaa166b80
201 Created
```


```json
{
  "data": {
    "id": "4304aec6-cdf9-494c-aea8-7b8b650f37c4",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=4304aec6-cdf9-494c-aea8-7b8b650f37c4"
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
X-Request-Id: af57bf35-92c8-413a-ad1b-a5a200151c82
200 OK
```


```json
{
  "data": [
    {
      "id": "9cd9e27b-afe9-4d4d-9dd6-8214e6fb7cdf",
      "type": "syntax",
      "attributes": {
        "account_id": "38917d0b-bcdd-4357-872d-2d3304b37305",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax fe195f14aa03",
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
GET /syntaxes/37643563-9779-4fa9-871f-384f304d7aed
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e5f54e1c-87f8-4f85-a202-4492e2325e96
200 OK
```


```json
{
  "data": {
    "id": "37643563-9779-4fa9-871f-384f304d7aed",
    "type": "syntax",
    "attributes": {
      "account_id": "cdd7f6b5-328b-4f4a-acc8-4d55018025a4",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 53a50ae44692",
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
    "self": "http://example.org/syntaxes/37643563-9779-4fa9-871f-384f304d7aed"
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
X-Request-Id: 94d89b33-f6be-42e6-9da1-71a2f38f5473
201 Created
```


```json
{
  "data": {
    "id": "4296380d-78fa-4803-8289-82c605d92163",
    "type": "syntax",
    "attributes": {
      "account_id": "c8b07730-25cf-4f91-aa01-b25480f772f4",
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
PATCH /syntaxes/16cff30b-4532-4275-834d-a0d52b6c25d6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "16cff30b-4532-4275-834d-a0d52b6c25d6",
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
X-Request-Id: 6d28090c-5ea1-4647-bff9-792f25c44a13
200 OK
```


```json
{
  "data": {
    "id": "16cff30b-4532-4275-834d-a0d52b6c25d6",
    "type": "syntax",
    "attributes": {
      "account_id": "253933e2-a148-49d4-b54e-d956448c0075",
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
    "self": "http://example.org/syntaxes/16cff30b-4532-4275-834d-a0d52b6c25d6"
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
DELETE /syntaxes/1b0af291-4654-4f3a-8652-66033d46c884
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 855fa405-d4fa-4885-bf88-f0c6ca936f8a
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
POST /syntaxes/805f477a-bf94-4b5d-bd97-9c83272d9654/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 39d5cb25-dc5e-4e40-9623-6f8d79e0d8bd
200 OK
```


```json
{
  "data": {
    "id": "805f477a-bf94-4b5d-bd97-9c83272d9654",
    "type": "syntax",
    "attributes": {
      "account_id": "a3f772af-020e-4a47-8851-b7af22c5c8aa",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 30c7e7517c5f",
      "published": true,
      "published_at": "2019-12-13T07:14:00.748Z"
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
    "self": "http://example.org/syntaxes/805f477a-bf94-4b5d-bd97-9c83272d9654/publish"
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
POST /syntaxes/2242278b-80a0-4476-8ce4-28cd8f5ac1b1/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 272574cb-4db0-4cf9-ab3d-164f5cf8ffa8
200 OK
```


```json
{
  "data": {
    "id": "2242278b-80a0-4476-8ce4-28cd8f5ac1b1",
    "type": "syntax",
    "attributes": {
      "account_id": "238bbd7f-fc98-4e3e-a24f-11fd1a335ce3",
      "archived": true,
      "archived_at": "2019-12-13T07:14:00.999Z",
      "description": "Description",
      "name": "Syntax 476a4be93851",
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
    "self": "http://example.org/syntaxes/2242278b-80a0-4476-8ce4-28cd8f5ac1b1/archive"
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
X-Request-Id: 6997942c-79e0-4afb-8cee-990cb6931ba9
200 OK
```


```json
{
  "data": [
    {
      "id": "09d7e8a5-67fc-4b5f-b9bd-8032e6eeb33f",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "b927fd62-5513-4e0b-a5b0-9b0661b1436b",
        "hex_color": "0018c8",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 85d96286e99b",
        "syntax_id": "3d2595f4-9760-43b6-bcfc-8d788aefe2b1"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/3d2595f4-9760-43b6-bcfc-8d788aefe2b1"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/b927fd62-5513-4e0b-a5b0-9b0661b1436b"
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
GET /syntax_elements/17930a46-b411-437b-81a3-11d584fbb2b4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 181bace5-5ba3-4bf1-90fe-3dc63a4de192
200 OK
```


```json
{
  "data": {
    "id": "17930a46-b411-437b-81a3-11d584fbb2b4",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "19508a90-fb5e-4533-a32f-1eb4b3a1d9bf",
      "hex_color": "fb759e",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element add85308b13e",
      "syntax_id": "bb472e5b-6ecd-441d-870d-5e3f12a70dae"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/bb472e5b-6ecd-441d-870d-5e3f12a70dae"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/19508a90-fb5e-4533-a32f-1eb4b3a1d9bf"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/17930a46-b411-437b-81a3-11d584fbb2b4"
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
      "syntax_id": "3aafa3d4-2165-4cb3-824e-3e755a98bd43",
      "classification_table_id": "b6671367-a082-46ff-8a32-c658e85a9c38"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 0eadb5f7-1daa-4ad3-a622-82c210977ce6
201 Created
```


```json
{
  "data": {
    "id": "cfef9d59-49b9-4a0e-97cc-86200901a81b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "b6671367-a082-46ff-8a32-c658e85a9c38",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "syntax_id": "3aafa3d4-2165-4cb3-824e-3e755a98bd43"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/3aafa3d4-2165-4cb3-824e-3e755a98bd43"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/b6671367-a082-46ff-8a32-c658e85a9c38"
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
PATCH /syntax_elements/ae1ebc48-cd0f-4d4f-8c2a-cc6808930360
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "ae1ebc48-cd0f-4d4f-8c2a-cc6808930360",
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
X-Request-Id: b41f6be7-8e69-458e-ace8-83c636e81c0a
200 OK
```


```json
{
  "data": {
    "id": "ae1ebc48-cd0f-4d4f-8c2a-cc6808930360",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "2c76c3ad-9f7e-40ee-84bf-c0298181770c",
      "hex_color": "996e72",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "syntax_id": "af634c5d-3c45-43ec-9ce3-4da23f8348b5"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/af634c5d-3c45-43ec-9ce3-4da23f8348b5"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/2c76c3ad-9f7e-40ee-84bf-c0298181770c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/ae1ebc48-cd0f-4d4f-8c2a-cc6808930360"
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
DELETE /syntax_elements/78eaf129-b332-4eff-b264-25990f056437
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e6d4832b-6445-4a8f-a9e2-7eee885177db
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
GET /syntax_nodes/fa23e0b0-70c9-4687-8bd1-c59c06f30e20
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
X-Request-Id: 45d0e8a5-d8aa-49c1-9cc1-aa839bd3562e
200 OK
```


```json
{
  "data": {
    "id": "fa23e0b0-70c9-4687-8bd1-c59c06f30e20",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1,
      "syntax_element_id": "56089803-97b2-4f79-8516-b362bad5caba"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/56089803-97b2-4f79-8516-b362bad5caba"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/fa23e0b0-70c9-4687-8bd1-c59c06f30e20"
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
      "syntax_element_id": "085c7a46-81a7-4c78-8a91-7c236de37615"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 4e24eb63-eb52-4bbe-9e7a-06e541d63733
201 Created
```


```json
{
  "data": {
    "id": "7b59543a-6e28-428a-82e9-ef021d4dff49",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9,
      "syntax_element_id": "085c7a46-81a7-4c78-8a91-7c236de37615"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/085c7a46-81a7-4c78-8a91-7c236de37615"
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
PATCH /syntax_nodes/28dd598d-87d9-4dcb-98f2-cfe081d6a4e9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "28dd598d-87d9-4dcb-98f2-cfe081d6a4e9",
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
X-Request-Id: 2cbcb586-dbe9-465f-977c-21ef0df510b2
200 OK
```


```json
{
  "data": {
    "id": "28dd598d-87d9-4dcb-98f2-cfe081d6a4e9",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5,
      "syntax_element_id": "ff417cf9-1798-477f-b944-002177d6d4d1"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/ff417cf9-1798-477f-b944-002177d6d4d1"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/28dd598d-87d9-4dcb-98f2-cfe081d6a4e9"
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
DELETE /syntax_nodes/2c1f30ea-7f36-4fee-97b4-208e05b648ec
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9650c71e-cf75-4c45-b010-92d6716f622c
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


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


None known.


### Response

```plaintext
X-Request-Id: adfd4e0b-7840-4260-b149-f741464081e0
200 OK
```


```json
{
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
| data[attributes][event] | Permission name |
| data[attributes][event] | Permission description |


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
X-Request-Id: 68f91eb4-6a68-4d1f-a0b9-ef7db9beb7eb
200 OK
```


```json
{
  "data": [
    {
      "id": "31bff722-8ac5-4789-b602-eaf07956b79d",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/71ba6df0-1a86-4ab9-85dd-717ae7ffeeed"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/ec1557a2-d24e-42e6-8735-56bfdcc5a247"
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
X-Request-Id: 9a76b5d9-18e4-4d37-8c39-5bb5456d0f00
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



