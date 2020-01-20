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

When negotiating authentication with Auth0 the client should use the `https://<subdomain>.eu.auth0.com/api/v2` audience.

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
X-Request-Id: 59b68af9-a8ca-4cdf-9a43-07b7011cebef
200 OK
```


```json
{
  "data": {
    "id": "f7b8b9f0-46f6-473c-b30a-8bc207e107ae",
    "type": "account",
    "attributes": {
      "name": "Account 5443f9dcad4c"
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
    "id": "45b6d62d-4819-44d5-9f00-fce3dabe2c63",
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
X-Request-Id: 1f2f0db7-a28f-46d9-b00b-f8abe3e9a121
200 OK
```


```json
{
  "data": {
    "id": "45b6d62d-4819-44d5-9f00-fce3dabe2c63",
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
| data[attributes][name] | Account name |


# Projects

Projects are grouping of Contexts. The specific grouping is left up to the company consuming
the API.

A Project has a progerss which is decoupled from the derived progress of the nested contexts.
This allows the project's manager to indepedenly indicate the progress of the project.


## Add new tag


### Request

#### Endpoint

```plaintext
POST /projects/a29c75f6-3b81-4fb2-ac72-32070927eff1/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/relationships/tags`

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

None known.


### Response

```plaintext
X-Request-Id: 98e468ce-d5f8-41ff-9b71-8125b60965f7
201 Created
```


```json
{
  "data": {
    "id": "2e63d278-985f-4e58-89cf-d670590ab86d",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/a29c75f6-3b81-4fb2-ac72-32070927eff1/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Add existing tag


### Request

#### Endpoint

```plaintext
POST /projects/d671e39b-b3ae-4746-9da5-2a43c04ae56c/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "20a6765a-1e15-43ec-addc-3d9e203e92e6"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: c27c3f43-efe8-4739-af38-c84bc5207f36
201 Created
```


```json
{
  "data": {
    "id": "20a6765a-1e15-43ec-addc-3d9e203e92e6",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7f256b21c45a"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/d671e39b-b3ae-4746-9da5-2a43c04ae56c/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /projects/601dc2a4-f2c4-4039-bfe1-11852c1d8785/relationships/tags/1e3a0232-c687-4ad8-9c9b-9759059e95b4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a0f6d123-4697-4a2a-8e4d-77d548aa5d0e
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


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
X-Request-Id: b26ed469-466f-4aa2-a9f5-e7482f670a64
200 OK
```


```json
{
  "data": [
    {
      "id": "ec5efe4d-b346-4fed-ae8c-994ba2c4aa3d",
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
            "related": "/contexts?filter[project_id_eq]=ec5efe4d-b346-4fed-ae8c-994ba2c4aa3d",
            "self": "/projects/ec5efe4d-b346-4fed-ae8c-994ba2c4aa3d/relationships/contexts"
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
GET /projects/4e9ca917-0c0c-4212-8c25-7e2aad70058d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8aa47791-cbdf-473e-8ac5-0aa81738c4e4
200 OK
```


```json
{
  "data": {
    "id": "4e9ca917-0c0c-4212-8c25-7e2aad70058d",
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
          "related": "/contexts?filter[project_id_eq]=4e9ca917-0c0c-4212-8c25-7e2aad70058d",
          "self": "/projects/4e9ca917-0c0c-4212-8c25-7e2aad70058d/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/4e9ca917-0c0c-4212-8c25-7e2aad70058d"
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
PATCH /projects/756fafc1-9049-472c-b184-929c874ab609
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "756fafc1-9049-472c-b184-929c874ab609",
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
X-Request-Id: c252b03d-a834-4412-a69a-d99f35318db9
200 OK
```


```json
{
  "data": {
    "id": "756fafc1-9049-472c-b184-929c874ab609",
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
          "related": "/contexts?filter[project_id_eq]=756fafc1-9049-472c-b184-929c874ab609",
          "self": "/projects/756fafc1-9049-472c-b184-929c874ab609/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/756fafc1-9049-472c-b184-929c874ab609"
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
POST /projects/159d65f6-5b25-4d7c-aa4c-47a8b9e8cc80/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2e3ffbb4-3c97-421d-bef6-80fece1526cb
200 OK
```


```json
{
  "data": {
    "id": "159d65f6-5b25-4d7c-aa4c-47a8b9e8cc80",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-01-20T11:44:49.851Z",
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
          "related": "/contexts?filter[project_id_eq]=159d65f6-5b25-4d7c-aa4c-47a8b9e8cc80",
          "self": "/projects/159d65f6-5b25-4d7c-aa4c-47a8b9e8cc80/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/159d65f6-5b25-4d7c-aa4c-47a8b9e8cc80/archive"
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
DELETE /projects/d5cc5c6d-8a31-49e3-b0cc-b320ccf18468
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ed8be872-3a59-4042-a2dd-adf333b3ce05
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


## Add new tag


### Request

#### Endpoint

```plaintext
POST /contexts/0f3f9fcc-b68a-498c-98b9-89ca3b1a4ce9/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/relationships/tags`

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

None known.


### Response

```plaintext
X-Request-Id: e96500d3-45e6-41f7-b36e-401ba7138de0
201 Created
```


```json
{
  "data": {
    "id": "d61367ff-a1a7-4c5a-bedc-d3e33bbf19e3",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/0f3f9fcc-b68a-498c-98b9-89ca3b1a4ce9/relationships/tags"
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


## Add existing tag


### Request

#### Endpoint

```plaintext
POST /contexts/47154b17-ca22-4109-9e14-bbc51ef2e635/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "986680d5-ee2c-4045-aaa8-c609cba95bcd"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 495e33ea-7c29-452d-9615-f20a7aa501d4
201 Created
```


```json
{
  "data": {
    "id": "986680d5-ee2c-4045-aaa8-c609cba95bcd",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3cdd7bdced85"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/47154b17-ca22-4109-9e14-bbc51ef2e635/relationships/tags"
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


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /contexts/fd8dcc00-f87d-43f0-bbb0-63342fb32501/relationships/tags/554c61c2-18d9-4084-8988-3bf58977045e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fb021e27-83d3-4565-b3c1-26e460f4d54a
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
X-Request-Id: a6d7e504-c747-43f4-91aa-03d20ff1d1b5
200 OK
```


```json
{
  "data": [
    {
      "id": "19480eac-bb9f-409e-93ee-58900116bfa7",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "published_at": null,
        "revision": 0
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/01e02ee1-7703-47f4-94d5-b025bd32844d"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/1640c8a3-239a-4e99-bf7e-194df5a10f0b"
          }
        }
      }
    },
    {
      "id": "21fa0162-7280-43e1-a1b1-2e5615e02c63",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "published_at": null,
        "revision": 0
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/01e02ee1-7703-47f4-94d5-b025bd32844d"
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
GET /contexts/f865e11b-6927-4156-9ea2-3533d476efca
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 57429844-3d50-45f5-85cb-f2c98d271e64
200 OK
```


```json
{
  "data": {
    "id": "f865e11b-6927-4156-9ea2-3533d476efca",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "published_at": null,
      "revision": 0
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/ae25b227-96f6-4607-925f-7e93f4854757"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/3edf0a0d-eb76-4fcb-a892-0cc5c6710616"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/f865e11b-6927-4156-9ea2-3533d476efca"
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
PATCH /contexts/aaf03490-c1fa-43fa-af8b-915865f4ccac
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "aaf03490-c1fa-43fa-af8b-915865f4ccac",
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
X-Request-Id: 6a1ec9fe-f167-41c0-86b9-c8c2f53e5e60
200 OK
```


```json
{
  "data": {
    "id": "aaf03490-c1fa-43fa-af8b-915865f4ccac",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "New context name",
      "published_at": null,
      "revision": 0
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/e3db84d9-07dd-48ce-8d12-505a559f9d36"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/38c94e45-d960-476e-9606-de0aee21bc5e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/aaf03490-c1fa-43fa-af8b-915865f4ccac"
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
POST /projects/31e5ccf0-0769-496e-bb57-ac785d204bb0/relationships/contexts
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
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: b722de3a-8986-4251-b938-fe56993183bf
201 Created
```


```json
{
  "data": {
    "id": "d0fcdc3a-8963-446d-a4cc-de8034164d64",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context",
      "published_at": null,
      "revision": 0
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/31e5ccf0-0769-496e-bb57-ac785d204bb0"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/ddfffef1-a147-44eb-a7f7-9374238efba2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/31e5ccf0-0769-496e-bb57-ac785d204bb0/relationships/contexts"
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
POST /contexts/1a5432c4-0642-48a3-a9bb-ad9dddcc1c38/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 613e00f0-4e34-4d0b-bb78-98bcd864738a
201 Created
```


```json
{
  "data": {
    "id": "a465dc89-bf99-461f-980e-f5e8b7e9a04f",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "published_at": null,
      "revision": 1
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/70254185-bf99-46d1-80d0-7793a256b143"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/e2d4f023-91e8-4019-b7e3-8be626e33d30"
        }
      },
      "prev_revision": {
        "data": {
          "id": "1a5432c4-0642-48a3-a9bb-ad9dddcc1c38",
          "type": "context"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/1a5432c4-0642-48a3-a9bb-ad9dddcc1c38/revision"
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
DELETE /contexts/df80adb3-8596-4419-a69e-9490c4c10b67
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3bbc508b-cca1-4ccf-9dff-245e32f40ae5
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


## Add new tag


### Request

#### Endpoint

```plaintext
POST /object_occurrences/eacefe99-4cbe-44d7-a799-10189517b210/relationships/tags
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

None known.


### Response

```plaintext
X-Request-Id: c170c9bd-6273-4eb8-9247-14abf8bbfc70
201 Created
```


```json
{
  "data": {
    "id": "eda98726-40fd-4ffa-88f5-252557868c2c",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/eacefe99-4cbe-44d7-a799-10189517b210/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Add existing tag


### Request

#### Endpoint

```plaintext
POST /object_occurrences/4fb35cca-ec15-472f-9230-0175e6ac5389/relationships/tags
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
    "id": "b66ebdc1-17e0-44ac-ba89-b3b47e6f0bd7"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 317f675d-c98f-4ef8-bbb5-28435bab119f
201 Created
```


```json
{
  "data": {
    "id": "b66ebdc1-17e0-44ac-ba89-b3b47e6f0bd7",
    "type": "tag",
    "attributes": {
      "value": "Tag value 68108e9d15b7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/4fb35cca-ec15-472f-9230-0175e6ac5389/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/9f6d0a6d-5eca-48c9-86ba-0811497b856e/relationships/tags/bcdd94d3-1559-44f5-bedd-b93f25c6d9d0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e69e9eaa-4991-4132-b2b8-2755cc473804
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/301199e8-ff70-415d-8cfe-6388a4504526
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
X-Request-Id: a3be7427-e186-44ab-b861-d3e3dc36060f
200 OK
```


```json
{
  "data": {
    "id": "301199e8-ff70-415d-8cfe-6388a4504526",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
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
          "related": "/contexts/99ea321a-f1c1-4bf9-aa1e-18177924fd1c"
        }
      },
      "components": {
        "data": [
          {
            "id": "9e1946d3-9cdd-4068-9dc6-8fa6ebc4b791",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/301199e8-ff70-415d-8cfe-6388a4504526/relationships/components"
        }
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
    "self": "http://example.org/object_occurrences/301199e8-ff70-415d-8cfe-6388a4504526"
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
POST /object_occurrences/5adeb4d2-6844-4fbb-a961-50023ace616a/relationships/components
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
      "name": "ooc"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 77e899f7-e3b8-4ffb-a36f-de73f3f2039d
201 Created
```


```json
{
  "data": {
    "id": "1f39a82a-ccaa-42c5-a556-990c6e8f5bfd",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "hex_color": null,
      "name": "ooc",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": "0"
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/eb7b8959-1669-46d6-9e28-25593313ce88"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/5adeb4d2-6844-4fbb-a961-50023ace616a",
          "self": "/object_occurrences/1f39a82a-ccaa-42c5-a556-990c6e8f5bfd/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/1f39a82a-ccaa-42c5-a556-990c6e8f5bfd/relationships/components"
        }
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
    "self": "http://example.org/object_occurrences/5adeb4d2-6844-4fbb-a961-50023ace616a/relationships/components"
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
PATCH /object_occurrences/d4edf9d4-57c1-4ac8-8646-d7c762c4c9aa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "d4edf9d4-57c1-4ac8-8646-d7c762c4c9aa",
    "type": "object_occurrence",
    "attributes": {
      "name": "New name"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "39a02dd0-2635-409d-9068-60cb73829882"
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
X-Request-Id: a6d2991d-2b94-4238-9483-2339b4af7dc8
200 OK
```


```json
{
  "data": {
    "id": "d4edf9d4-57c1-4ac8-8646-d7c762c4c9aa",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
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
          "related": "/contexts/3459e9d5-b49f-4f75-997c-0a80cc098c14"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/39a02dd0-2635-409d-9068-60cb73829882",
          "self": "/object_occurrences/d4edf9d4-57c1-4ac8-8646-d7c762c4c9aa/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/d4edf9d4-57c1-4ac8-8646-d7c762c4c9aa/relationships/components"
        }
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
    "self": "http://example.org/object_occurrences/d4edf9d4-57c1-4ac8-8646-d7c762c4c9aa"
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
DELETE /object_occurrences/bd9385dd-e5e8-4dd8-a611-67cb4b07ce90
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: becfae2a-43a6-428a-a4a5-f6a8846e2d55
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/5b9fe869-52a5-4784-9603-7739648dcc02/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "dcea223e-5178-46bd-a771-057a0f8248f9",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 5df6dabe-8812-4d88-a35c-d2b716692b65
200 OK
```


```json
{
  "data": {
    "id": "5b9fe869-52a5-4784-9603-7739648dcc02",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "hex_color": null,
      "name": "OOC 2",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": "0"
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/9f78f30c-0883-451b-9d40-74712246a66d"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/dcea223e-5178-46bd-a771-057a0f8248f9",
          "self": "/object_occurrences/5b9fe869-52a5-4784-9603-7739648dcc02/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/5b9fe869-52a5-4784-9603-7739648dcc02/relationships/components"
        }
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
    "self": "http://example.org/object_occurrences/5b9fe869-52a5-4784-9603-7739648dcc02/relationships/part_of"
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
X-Request-Id: 2db9ef56-b719-456e-8207-53f72ae9f227
200 OK
```


```json
{
  "data": [
    {
      "id": "9c35a88c-afa2-4e91-80f4-9bab24a7e846",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=9c35a88c-afa2-4e91-80f4-9bab24a7e846",
            "self": "/classification_tables/9c35a88c-afa2-4e91-80f4-9bab24a7e846/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "151a3ccc-8183-49b1-bda3-402410f7bd10",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=151a3ccc-8183-49b1-bda3-402410f7bd10",
            "self": "/classification_tables/151a3ccc-8183-49b1-bda3-402410f7bd10/relationships/classification_entries"
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
GET /classification_tables/a9b482c8-ab9a-4d91-97d4-c712c153f058
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 61eb1bf4-7aea-47ed-9570-001b443f7f14
200 OK
```


```json
{
  "data": {
    "id": "a9b482c8-ab9a-4d91-97d4-c712c153f058",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=a9b482c8-ab9a-4d91-97d4-c712c153f058",
          "self": "/classification_tables/a9b482c8-ab9a-4d91-97d4-c712c153f058/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a9b482c8-ab9a-4d91-97d4-c712c153f058"
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
PATCH /classification_tables/6fe4475f-8015-449e-a5f6-0ad31c76f221
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "6fe4475f-8015-449e-a5f6-0ad31c76f221",
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
X-Request-Id: 699d008c-78fd-46e6-84c1-cc963db9fd9b
200 OK
```


```json
{
  "data": {
    "id": "6fe4475f-8015-449e-a5f6-0ad31c76f221",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=6fe4475f-8015-449e-a5f6-0ad31c76f221",
          "self": "/classification_tables/6fe4475f-8015-449e-a5f6-0ad31c76f221/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/6fe4475f-8015-449e-a5f6-0ad31c76f221"
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
DELETE /classification_tables/fbf0710e-5ab7-4959-90c9-4a478d003d5d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9b9cc352-1d2f-4b75-9e5d-b2beb76d05dc
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
POST /classification_tables/4a360bf8-ba03-4342-a7ad-cef3aa6ebdf2/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: dcce8d11-e02e-4a5f-a986-078d2e0b8cc9
200 OK
```


```json
{
  "data": {
    "id": "4a360bf8-ba03-4342-a7ad-cef3aa6ebdf2",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-01-20T11:45:02.552Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=4a360bf8-ba03-4342-a7ad-cef3aa6ebdf2",
          "self": "/classification_tables/4a360bf8-ba03-4342-a7ad-cef3aa6ebdf2/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/4a360bf8-ba03-4342-a7ad-cef3aa6ebdf2/publish"
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
POST /classification_tables/5dac6f02-aaa4-4265-9412-c29b1ffdba03/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8aa9ac84-46f1-4627-b143-af9b503df0da
200 OK
```


```json
{
  "data": {
    "id": "5dac6f02-aaa4-4265-9412-c29b1ffdba03",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-01-20T11:45:02.857Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=5dac6f02-aaa4-4265-9412-c29b1ffdba03",
          "self": "/classification_tables/5dac6f02-aaa4-4265-9412-c29b1ffdba03/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/5dac6f02-aaa4-4265-9412-c29b1ffdba03/archive"
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
X-Request-Id: d3e0c842-d261-441d-aaa5-77507d7b58d9
201 Created
```


```json
{
  "data": {
    "id": "57d26ad6-907c-421b-b8f2-863879a55ff3",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=57d26ad6-907c-421b-b8f2-863879a55ff3",
          "self": "/classification_tables/57d26ad6-907c-421b-b8f2-863879a55ff3/relationships/classification_entries"
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


# Classification Entries

Classification entries represent a single classification entry in a Classification Table.


## List


### Request

#### Endpoint

```plaintext
GET /classification_entries
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```
```plaintext
GET /classification_entries
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_entries`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 72af0640-61ae-46b5-8030-9104cffa6112
200 OK
```


```json
{
  "data": [
    {
      "id": "05f6f64a-203e-4af5-8e9b-23c6330860ed",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal",
        "name": "CE 1",
        "reciprocal_name": null
      },
      "relationships": {
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=05f6f64a-203e-4af5-8e9b-23c6330860ed",
            "self": "/classification_entries/05f6f64a-203e-4af5-8e9b-23c6330860ed/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "b3b8e37d-e619-459c-8dcf-b36b8eac94d5",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal",
        "name": "CE 11",
        "reciprocal_name": null
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "05f6f64a-203e-4af5-8e9b-23c6330860ed",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/b3b8e37d-e619-459c-8dcf-b36b8eac94d5"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=b3b8e37d-e619-459c-8dcf-b36b8eac94d5",
            "self": "/classification_entries/b3b8e37d-e619-459c-8dcf-b36b8eac94d5/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "5d81931f-a5d5-4821-92b0-3c8e72d60075",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal",
        "name": "CE 2",
        "reciprocal_name": null
      },
      "relationships": {
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=5d81931f-a5d5-4821-92b0-3c8e72d60075",
            "self": "/classification_entries/5d81931f-a5d5-4821-92b0-3c8e72d60075/relationships/classification_entries"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/classification_entries",
    "current": "http://example.org/classification_entries?page[number]=1"
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



None known.


### Response

```plaintext
X-Request-Id: 3064a979-5742-40d9-bb06-485237f4301a
200 OK
```


```json
{
  "data": [
    {
      "id": "9a1dfd89-4532-4536-8cdd-876af9c344e0",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal",
        "name": "CE 1",
        "reciprocal_name": null
      },
      "relationships": {
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=9a1dfd89-4532-4536-8cdd-876af9c344e0",
            "self": "/classification_entries/9a1dfd89-4532-4536-8cdd-876af9c344e0/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "3eb5067a-de0f-46ba-baf7-b3ca5d71b76c",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal",
        "name": "CE 11",
        "reciprocal_name": null
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "9a1dfd89-4532-4536-8cdd-876af9c344e0",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/3eb5067a-de0f-46ba-baf7-b3ca5d71b76c"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=3eb5067a-de0f-46ba-baf7-b3ca5d71b76c",
            "self": "/classification_entries/3eb5067a-de0f-46ba-baf7-b3ca5d71b76c/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "4470a674-4399-4849-9f27-99b1178b7454",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal",
        "name": "CE 2",
        "reciprocal_name": null
      },
      "relationships": {
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=4470a674-4399-4849-9f27-99b1178b7454",
            "self": "/classification_entries/4470a674-4399-4849-9f27-99b1178b7454/relationships/classification_entries"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/classification_entries",
    "current": "http://example.org/classification_entries?page[number]=1"
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
GET /classification_entries/a58f4b76-2890-4121-ab0e-ca8ce8521942
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fbbe3aee-f136-4a3b-886d-0263e0505934
200 OK
```


```json
{
  "data": {
    "id": "a58f4b76-2890-4121-ab0e-ca8ce8521942",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "Alarm signal",
      "name": "CE 1",
      "reciprocal_name": null
    },
    "relationships": {
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=a58f4b76-2890-4121-ab0e-ca8ce8521942",
          "self": "/classification_entries/a58f4b76-2890-4121-ab0e-ca8ce8521942/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/a58f4b76-2890-4121-ab0e-ca8ce8521942"
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


## Update


### Request

#### Endpoint

```plaintext
PATCH /classification_entries/8dcac1e9-b395-4a91-bbe1-57c386cfe160
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "8dcac1e9-b395-4a91-bbe1-57c386cfe160",
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
X-Request-Id: 95bc47f7-b163-4160-89e1-311e1a0e28e1
200 OK
```


```json
{
  "data": {
    "id": "8dcac1e9-b395-4a91-bbe1-57c386cfe160",
    "type": "classification_entry",
    "attributes": {
      "code": "AA",
      "definition": "Alarm signal",
      "name": "New classification entry name",
      "reciprocal_name": null
    },
    "relationships": {
      "classification_entry": {
        "data": {
          "id": "5c68c4f6-8f65-4597-a761-8e56e5911c21",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/8dcac1e9-b395-4a91-bbe1-57c386cfe160"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=8dcac1e9-b395-4a91-bbe1-57c386cfe160",
          "self": "/classification_entries/8dcac1e9-b395-4a91-bbe1-57c386cfe160/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/8dcac1e9-b395-4a91-bbe1-57c386cfe160"
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


## Delete


### Request

#### Endpoint

```plaintext
DELETE /classification_entries/431c463c-66d1-4d33-8e25-59b8077beb04
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f4d80f47-1817-4473-895b-59f03dc60e42
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
POST /classification_tables/3d2e529c-555b-456a-8d8d-c20cd0307a04/relationships/classification_entries
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
X-Request-Id: 9de0f26b-ee94-433b-9c65-ba9c358c5a02
201 Created
```


```json
{
  "data": {
    "id": "73c6fb42-1b9e-47a6-8a37-4fdf1a5f19bd",
    "type": "classification_entry",
    "attributes": {
      "code": "C",
      "definition": "New definition",
      "name": "New name",
      "reciprocal_name": null
    },
    "relationships": {
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=73c6fb42-1b9e-47a6-8a37-4fdf1a5f19bd",
          "self": "/classification_entries/73c6fb42-1b9e-47a6-8a37-4fdf1a5f19bd/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/3d2e529c-555b-456a-8d8d-c20cd0307a04/relationships/classification_entries"
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
X-Request-Id: daf62251-7661-4121-a324-f0605e5887a5
200 OK
```


```json
{
  "data": [
    {
      "id": "bf1368fe-43ee-4e0c-b5bb-a9af91be4149",
      "type": "syntax",
      "attributes": {
        "account_id": "551ffec1-7363-43fa-8684-c3a5479e1b1d",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax e1b7f0651552",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=bf1368fe-43ee-4e0c-b5bb-a9af91be4149",
            "self": "/syntaxes/bf1368fe-43ee-4e0c-b5bb-a9af91be4149/relationships/syntax_elements"
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
GET /syntaxes/b995a876-2167-4dc6-8453-b11ed2238fbf
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b52c322e-e951-4432-be98-a6d1bd8e8585
200 OK
```


```json
{
  "data": {
    "id": "b995a876-2167-4dc6-8453-b11ed2238fbf",
    "type": "syntax",
    "attributes": {
      "account_id": "59e89cd5-38bf-43f4-91c7-acc6c557aff2",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 304dce140074",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=b995a876-2167-4dc6-8453-b11ed2238fbf",
          "self": "/syntaxes/b995a876-2167-4dc6-8453-b11ed2238fbf/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/b995a876-2167-4dc6-8453-b11ed2238fbf"
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
X-Request-Id: de646f15-f84c-4333-857a-526a1d6b23fa
201 Created
```


```json
{
  "data": {
    "id": "5390d365-e9ee-4163-a70f-33bc085f5ccb",
    "type": "syntax",
    "attributes": {
      "account_id": "47460fd8-0b01-4d86-b053-57e6cd751494",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=5390d365-e9ee-4163-a70f-33bc085f5ccb",
          "self": "/syntaxes/5390d365-e9ee-4163-a70f-33bc085f5ccb/relationships/syntax_elements"
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
PATCH /syntaxes/94f24031-abf7-4e3e-b4a3-3be8cca7a622
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "94f24031-abf7-4e3e-b4a3-3be8cca7a622",
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
X-Request-Id: bcb7c875-f16a-4e79-94cc-31ab2a460d22
200 OK
```


```json
{
  "data": {
    "id": "94f24031-abf7-4e3e-b4a3-3be8cca7a622",
    "type": "syntax",
    "attributes": {
      "account_id": "41a89f21-8e91-4bf8-9584-c85036a498b9",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=94f24031-abf7-4e3e-b4a3-3be8cca7a622",
          "self": "/syntaxes/94f24031-abf7-4e3e-b4a3-3be8cca7a622/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/94f24031-abf7-4e3e-b4a3-3be8cca7a622"
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
DELETE /syntaxes/6bbf05d1-daa3-477c-960a-0dddc7ca73ef
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1caa35d5-7c41-479f-a0ba-0bde5ab9736d
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
POST /syntaxes/222a8f18-e0dd-4619-9f5a-9cd75ac3a1e9/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c0e244c9-886a-41ef-a8c7-d4f2ddad1bd2
200 OK
```


```json
{
  "data": {
    "id": "222a8f18-e0dd-4619-9f5a-9cd75ac3a1e9",
    "type": "syntax",
    "attributes": {
      "account_id": "d4db8577-22bc-415e-be0c-07d1f361e05b",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax a2d2cb1cdaa9",
      "published": true,
      "published_at": "2020-01-20T11:45:07.900Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=222a8f18-e0dd-4619-9f5a-9cd75ac3a1e9",
          "self": "/syntaxes/222a8f18-e0dd-4619-9f5a-9cd75ac3a1e9/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/222a8f18-e0dd-4619-9f5a-9cd75ac3a1e9/publish"
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
POST /syntaxes/0e7cc0a5-fc85-4cd9-b0e1-a558a6045467/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6ccf0727-3a03-4bb3-8a2b-cd437f00bd3c
200 OK
```


```json
{
  "data": {
    "id": "0e7cc0a5-fc85-4cd9-b0e1-a558a6045467",
    "type": "syntax",
    "attributes": {
      "account_id": "02875df3-3e8c-4f0c-b703-866ef574c426",
      "archived": true,
      "archived_at": "2020-01-20T11:45:08.274Z",
      "description": "Description",
      "name": "Syntax 9d4e3c371d65",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=0e7cc0a5-fc85-4cd9-b0e1-a558a6045467",
          "self": "/syntaxes/0e7cc0a5-fc85-4cd9-b0e1-a558a6045467/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/0e7cc0a5-fc85-4cd9-b0e1-a558a6045467/archive"
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
X-Request-Id: fb9a0add-bddd-4cc0-a8eb-09179c14b9f0
200 OK
```


```json
{
  "data": [
    {
      "id": "9498b303-f3c6-42bc-ad45-9de6aaab29b7",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "a372f2b9-01e1-4ea5-b0b1-87df220e4bd5",
        "hex_color": "7053f0",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 4236c12cebc0"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/b4408752-272c-409a-a6d0-e525f7d596b5"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/a372f2b9-01e1-4ea5-b0b1-87df220e4bd5",
            "self": "/syntax_elements/9498b303-f3c6-42bc-ad45-9de6aaab29b7/relationships/classification_table"
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
GET /syntax_elements/962c4f96-f950-42f1-8926-be5de5831b8b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 17c784a3-1ff2-4182-ae0c-a70fe3c880f9
200 OK
```


```json
{
  "data": {
    "id": "962c4f96-f950-42f1-8926-be5de5831b8b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "086f40b6-fd40-4d4c-aad9-b3172b99aa98",
      "hex_color": "1899b6",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 92b3175306e5"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/977e105c-e424-4956-8d87-2d9dba50957f"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/086f40b6-fd40-4d4c-aad9-b3172b99aa98",
          "self": "/syntax_elements/962c4f96-f950-42f1-8926-be5de5831b8b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/962c4f96-f950-42f1-8926-be5de5831b8b"
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
POST /syntaxes/3deddc8e-4e60-49d7-bc25-32d6c26d08f4/relationships/syntax_elements
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
          "id": "3abb6fc1-a73d-4326-8f70-4021642c7348"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: f11324e8-4e6d-4551-8acc-f1af67b2fa6a
201 Created
```


```json
{
  "data": {
    "id": "6e497c0b-94ac-4207-874d-64e17881aa49",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "3abb6fc1-a73d-4326-8f70-4021642c7348",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/3deddc8e-4e60-49d7-bc25-32d6c26d08f4"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/3abb6fc1-a73d-4326-8f70-4021642c7348",
          "self": "/syntax_elements/6e497c0b-94ac-4207-874d-64e17881aa49/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/3deddc8e-4e60-49d7-bc25-32d6c26d08f4/relationships/syntax_elements"
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
PATCH /syntax_elements/a4b408bd-119a-421f-b9d2-f43344b68f65
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "a4b408bd-119a-421f-b9d2-f43344b68f65",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "0983a3c7-227a-4fac-ade9-8519a42f5955"
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
X-Request-Id: 9c017005-1914-4878-870c-c853972395be
200 OK
```


```json
{
  "data": {
    "id": "a4b408bd-119a-421f-b9d2-f43344b68f65",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "0983a3c7-227a-4fac-ade9-8519a42f5955",
      "hex_color": "a41924",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/96aecb39-482b-45a2-a154-baf2dcc96061"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/0983a3c7-227a-4fac-ade9-8519a42f5955",
          "self": "/syntax_elements/a4b408bd-119a-421f-b9d2-f43344b68f65/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/a4b408bd-119a-421f-b9d2-f43344b68f65"
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
DELETE /syntax_elements/6d751a24-24b0-4d3d-b7cf-d56c4467f4d2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: dc836e3d-d6f3-4e93-b07c-a3ccf496dfa7
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
PATCH /syntax_elements/72cd0f0b-0d06-470c-a0c6-9e0048a33d31/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "4a51c3b5-ee02-4972-bb38-15329afe3908",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: e4aabfaf-9390-4d6f-ab00-cad5b0184704
200 OK
```


```json
{
  "data": {
    "id": "72cd0f0b-0d06-470c-a0c6-9e0048a33d31",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "4a51c3b5-ee02-4972-bb38-15329afe3908",
      "hex_color": "4e5d01",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element d1c727bf1733"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e07e058b-0f5a-4e88-8a7c-110fe211f0b3"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/4a51c3b5-ee02-4972-bb38-15329afe3908",
          "self": "/syntax_elements/72cd0f0b-0d06-470c-a0c6-9e0048a33d31/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/72cd0f0b-0d06-470c-a0c6-9e0048a33d31/relationships/classification_table"
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
DELETE /syntax_elements/6b2c4c88-afd4-4e98-ad3d-9eb8c0172fb3/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9dbfa83a-2ae2-45d6-bce7-84667dd6cc80
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
GET /syntax_nodes/bd48a010-6dda-4dac-9966-92f247413aed
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
X-Request-Id: 1de33b66-5035-4503-807c-deb2603e4660
200 OK
```


```json
{
  "data": {
    "id": "bd48a010-6dda-4dac-9966-92f247413aed",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/767d98de-3903-498a-acee-cf2f0b4ee690"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/bd48a010-6dda-4dac-9966-92f247413aed/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/bd48a010-6dda-4dac-9966-92f247413aed"
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
POST /syntax_nodes/9abe7399-b33a-4d5b-be28-9d9e5011776d/relationships/components
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
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 71bd3aff-1755-4480-b5f7-075ebe494237
201 Created
```


```json
{
  "data": {
    "id": "0f8810e1-0983-4159-b5bd-9e56773215ea",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/e3058b49-505c-41cd-9dfa-9432c16acd69"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/0f8810e1-0983-4159-b5bd-9e56773215ea/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/9abe7399-b33a-4d5b-be28-9d9e5011776d/relationships/components"
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
PATCH /syntax_nodes/1b02ad6e-478c-45fe-a193-e50abae7f44b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "1b02ad6e-478c-45fe-a193-e50abae7f44b",
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
X-Request-Id: e896dc55-8b9a-415e-a658-4a07280bab0b
200 OK
```


```json
{
  "data": {
    "id": "1b02ad6e-478c-45fe-a193-e50abae7f44b",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/65829c57-19c2-4d37-9d21-c4f98844c164"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/1b02ad6e-478c-45fe-a193-e50abae7f44b/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/1b02ad6e-478c-45fe-a193-e50abae7f44b"
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
DELETE /syntax_nodes/d964789c-90e0-46c1-9988-d4411c0cb5c2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4894ed90-1b0e-4ac1-bf35-fbdcbeaa0cae
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
X-Request-Id: 19cbbf50-e650-4859-94a4-9ab0fac27719
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


None known.


### Response

```plaintext
X-Request-Id: 688b2d1a-0f15-4a7e-a0c5-f6f66f4ea777
200 OK
```


```json
{
  "data": [
    {
      "id": "3d5c3905-a00d-4c21-bbb7-d60cefc4e20e",
      "type": "progress_model",
      "attributes": {
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-01-20T11:45:13.303Z"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=3d5c3905-a00d-4c21-bbb7-d60cefc4e20e",
            "self": "/progress_models/3d5c3905-a00d-4c21-bbb7-d60cefc4e20e/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "a87cbe33-d1b0-4a42-a5f7-c8320ff70d1b",
      "type": "progress_model",
      "attributes": {
        "name": "pm 2",
        "order": 2,
        "published": false,
        "published_at": null
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a87cbe33-d1b0-4a42-a5f7-c8320ff70d1b",
            "self": "/progress_models/a87cbe33-d1b0-4a42-a5f7-c8320ff70d1b/relationships/progress_steps"
          }
        }
      }
    }
  ],
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
GET /progress_models/03a406a7-f4c5-44ec-9f8d-0f332e610780
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6ea46f74-fa7c-468d-8cac-3072e098a57c
200 OK
```


```json
{
  "data": {
    "id": "03a406a7-f4c5-44ec-9f8d-0f332e610780",
    "type": "progress_model",
    "attributes": {
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-01-20T11:45:13.717Z"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=03a406a7-f4c5-44ec-9f8d-0f332e610780",
          "self": "/progress_models/03a406a7-f4c5-44ec-9f8d-0f332e610780/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/03a406a7-f4c5-44ec-9f8d-0f332e610780"
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
PATCH /progress_models/ee003cd1-1ce6-482f-aacb-224b9dde9d3b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "ee003cd1-1ce6-482f-aacb-224b9dde9d3b",
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
X-Request-Id: c7454211-d4f4-4c1d-b891-c80c72569bca
200 OK
```


```json
{
  "data": {
    "id": "ee003cd1-1ce6-482f-aacb-224b9dde9d3b",
    "type": "progress_model",
    "attributes": {
      "name": "New progress model name",
      "order": 6,
      "published": false,
      "published_at": null
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=ee003cd1-1ce6-482f-aacb-224b9dde9d3b",
          "self": "/progress_models/ee003cd1-1ce6-482f-aacb-224b9dde9d3b/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/ee003cd1-1ce6-482f-aacb-224b9dde9d3b"
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
DELETE /progress_models/434cd301-68e9-4564-810f-789ccd0ab82f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1b301332-6d1c-4c99-af44-7cc66a986326
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
POST /progress_models/02cdea2c-6f72-48da-a466-7e78501da06f/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fec0b286-0f52-4c3c-8deb-55834f25f476
200 OK
```


```json
{
  "data": {
    "id": "02cdea2c-6f72-48da-a466-7e78501da06f",
    "type": "progress_model",
    "attributes": {
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-01-20T11:45:15.177Z"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=02cdea2c-6f72-48da-a466-7e78501da06f",
          "self": "/progress_models/02cdea2c-6f72-48da-a466-7e78501da06f/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/02cdea2c-6f72-48da-a466-7e78501da06f/publish"
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
      "order": 1
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: c40acbce-730b-4ec7-ac2f-56c5bda588f8
201 Created
```


```json
{
  "data": {
    "id": "cf9abbcd-14b8-477a-8c81-43eb20ce6b8c",
    "type": "progress_model",
    "attributes": {
      "name": "New progress model name",
      "order": 1,
      "published": false,
      "published_at": null
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=cf9abbcd-14b8-477a-8c81-43eb20ce6b8c",
          "self": "/progress_models/cf9abbcd-14b8-477a-8c81-43eb20ce6b8c/relationships/progress_steps"
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


None known.


### Response

```plaintext
X-Request-Id: cedb49cd-ce38-4d37-bcf1-bb4ed1e9c87d
200 OK
```


```json
{
  "data": [
    {
      "id": "d1adca58-a10f-475e-b2f2-77d127de18f3",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/c2bdf269-728c-4356-8c63-5f611c6733a2"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/progress_steps",
    "current": "http://example.org/progress_steps?page[number]=1"
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
GET /progress_steps/d1efe426-522e-4713-a96e-cdb1397f280b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 13c4e565-9879-4d03-8049-5da8701c40d7
200 OK
```


```json
{
  "data": {
    "id": "d1efe426-522e-4713-a96e-cdb1397f280b",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/89dc37ba-02c0-40f4-9755-5448b006ab5a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/d1efe426-522e-4713-a96e-cdb1397f280b"
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
PATCH /progress_steps/9211323b-9ed8-4712-b9c1-1972a5e8f773
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "9211323b-9ed8-4712-b9c1-1972a5e8f773",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New progress step name |



### Response

```plaintext
X-Request-Id: b9a818a9-1661-44ac-a30d-8272fbf4a21a
200 OK
```


```json
{
  "data": {
    "id": "9211323b-9ed8-4712-b9c1-1972a5e8f773",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/ce3149e6-15c0-4a70-937c-ca9761a88db2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/9211323b-9ed8-4712-b9c1-1972a5e8f773"
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
DELETE /progress_steps/cec12d28-2af3-40bc-8fe4-334169ce8862
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f80aa63d-e136-4b8f-81ec-136d22865451
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
POST /progress_models/7b990d6d-8998-4333-9697-3d650df72d68/relationships/progress_steps
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
X-Request-Id: 6aab9a0d-e994-45d7-8ef0-562c8ceeb32f
201 Created
```


```json
{
  "data": {
    "id": "63115f44-e682-421d-a483-1383e06b83a5",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/7b990d6d-8998-4333-9697-3d650df72d68"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/7b990d6d-8998-4333-9697-3d650df72d68/relationships/progress_steps"
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


None known.


### Response

```plaintext
X-Request-Id: 9ca73c58-f55f-41c4-b63f-57ce4a6b3023
200 OK
```


```json
{
  "data": [
    {
      "id": "2aa12a0f-3033-447b-a468-50a352635a0c",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/b80acc20-8df2-4c35-9e9e-d32863a31b48"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/33d46f25-ee32-4f87-a359-ffee1b37c847"
          }
        }
      }
    }
  ],
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
GET /progress/91a6ff68-094e-4da9-ad94-3f7d6fd59ff9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3f92531f-5b48-4f06-9018-b01fe538804a
200 OK
```


```json
{
  "data": {
    "id": "91a6ff68-094e-4da9-ad94-3f7d6fd59ff9",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/79d6d1c5-f6f7-400b-9130-a22a63d1c95a"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/77147fea-412a-44d1-943e-0364c8eee9b4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/91a6ff68-094e-4da9-ad94-3f7d6fd59ff9"
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
DELETE /progress/9c353e44-23d2-4f21-98a1-f945ab45d9eb
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 93babbe3-03d3-45d4-8168-ac4a2f2a9810
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
          "id": "29176c77-ac56-483e-a82f-90ca2c437085"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "61a53057-69a1-400c-966c-ec76b93dcefa"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 77822472-103a-4e1b-a0ae-9d3ef6ea1b82
201 Created
```


```json
{
  "data": {
    "id": "19f49a14-1706-4f5c-940d-96ab9864b07e",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/29176c77-ac56-483e-a82f-90ca2c437085"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/61a53057-69a1-400c-966c-ec76b93dcefa"
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
X-Request-Id: 44084741-4949-42cb-b893-c7483e536f96
200 OK
```


```json
{
  "data": [
    {
      "id": "592becef-2095-4635-87ff-be97636bd471",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/047876ca-4182-4f0f-95ae-dca508419fbd"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/21449f7a-aca4-46fa-b0e1-46e7394fa2c2"
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
X-Request-Id: 78e58aa0-91af-4abe-ba1d-d3233dab8452
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



