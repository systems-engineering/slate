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
X-Request-Id: 1e20d2e6-492d-4f9d-a7b9-49d6367bbcd4
200 OK
```


```json
{
  "data": {
    "id": "b57516fd-7a7b-4f33-880d-1cd26cef522a",
    "type": "account",
    "attributes": {
      "name": "Account c80366728552"
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
    "id": "afa6b5b3-8662-4f94-9076-d64628403518",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f7df7e6b-49e0-4430-ad36-e3b2f9488e64
200 OK
```


```json
{
  "data": {
    "id": "afa6b5b3-8662-4f94-9076-d64628403518",
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
POST /projects/88398f72-25ce-485e-9113-0b9da1e1a3df/relationships/tags
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 64184d79-1d51-485a-b643-a9db936f6f54
201 Created
```


```json
{
  "data": {
    "id": "39fab593-ada6-42e8-b3bf-5e3531462257",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/88398f72-25ce-485e-9113-0b9da1e1a3df/relationships/tags"
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
POST /projects/befb7af5-961c-493d-8ad9-e19f7c0da4b1/relationships/tags
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
    "id": "37309ef6-b94a-440e-bafe-cce20d930d9e"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 954ce25f-e1a0-4da1-ad0a-da459407ba50
201 Created
```


```json
{
  "data": {
    "id": "37309ef6-b94a-440e-bafe-cce20d930d9e",
    "type": "tag",
    "attributes": {
      "value": "Tag value 606632e900f6"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/befb7af5-961c-493d-8ad9-e19f7c0da4b1/relationships/tags"
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
DELETE /projects/31dd9199-fb21-4623-99d1-7ad2f760c3c1/relationships/tags/2ba79814-be40-4a70-83f0-8b40bce765c3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e46d34af-d6b0-4f96-a9f8-ccf07f2df950
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[archived]  | filter by archived flag |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e3327273-7f07-4bd4-b1b6-87057a91fdc2
200 OK
```


```json
{
  "data": [
    {
      "id": "0e0cf19d-f0d6-4aa9-a971-760c153fedce",
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
            "related": "/contexts?filter[project_id_eq]=0e0cf19d-f0d6-4aa9-a971-760c153fedce",
            "self": "/projects/0e0cf19d-f0d6-4aa9-a971-760c153fedce/relationships/contexts"
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
GET /projects/12f53c44-43cd-46b0-843b-687ebb321a02
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
X-Request-Id: a9f28607-4f97-4066-ab6f-fb666a4a463f
200 OK
```


```json
{
  "data": {
    "id": "12f53c44-43cd-46b0-843b-687ebb321a02",
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
          "related": "/contexts?filter[project_id_eq]=12f53c44-43cd-46b0-843b-687ebb321a02",
          "self": "/projects/12f53c44-43cd-46b0-843b-687ebb321a02/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/12f53c44-43cd-46b0-843b-687ebb321a02"
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
PATCH /projects/9e4348b7-1684-4986-a1d6-107f2b60adf3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "9e4348b7-1684-4986-a1d6-107f2b60adf3",
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
X-Request-Id: 54109dfe-0213-4670-92d2-6059c5357f52
200 OK
```


```json
{
  "data": {
    "id": "9e4348b7-1684-4986-a1d6-107f2b60adf3",
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
          "related": "/contexts?filter[project_id_eq]=9e4348b7-1684-4986-a1d6-107f2b60adf3",
          "self": "/projects/9e4348b7-1684-4986-a1d6-107f2b60adf3/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/9e4348b7-1684-4986-a1d6-107f2b60adf3"
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
POST /projects/96f84344-c9ff-4f35-a03d-037589f01e7e/archive
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
X-Request-Id: 8c60fd47-0446-4614-8810-5b72d5657a0c
200 OK
```


```json
{
  "data": {
    "id": "96f84344-c9ff-4f35-a03d-037589f01e7e",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:43:43.699Z",
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
          "related": "/contexts?filter[project_id_eq]=96f84344-c9ff-4f35-a03d-037589f01e7e",
          "self": "/projects/96f84344-c9ff-4f35-a03d-037589f01e7e/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/96f84344-c9ff-4f35-a03d-037589f01e7e/archive"
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
DELETE /projects/c113e9d4-d4cf-47ae-aa6b-7f02335b68db
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6727c27b-50a5-401c-9bcf-122627cdf7a2
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
POST /contexts/d6f71a26-a31f-4841-913d-1b3e7fe50ce8/relationships/tags
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0e3ece90-9697-4167-9e00-8beade949b39
201 Created
```


```json
{
  "data": {
    "id": "a4d3ef2f-5435-497f-8633-fb3ded8f4b0c",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/d6f71a26-a31f-4841-913d-1b3e7fe50ce8/relationships/tags"
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
POST /contexts/538bce9a-40d9-4868-a745-f091487ebbbe/relationships/tags
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
    "id": "c34e8df6-e54b-4ab9-8863-6b61f0de159e"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 9eea644f-789c-4946-a632-a57e9da4882e
201 Created
```


```json
{
  "data": {
    "id": "c34e8df6-e54b-4ab9-8863-6b61f0de159e",
    "type": "tag",
    "attributes": {
      "value": "Tag value ab64c0c2cc49"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/538bce9a-40d9-4868-a745-f091487ebbbe/relationships/tags"
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
DELETE /contexts/a1f32ceb-e896-4147-a3f1-88477bb42aa9/relationships/tags/e76eb366-65b9-49e8-9ccf-d42576a4510c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4f60be63-3a1f-4b9a-9250-720ab523dcd8
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name, object_occurrences_count |
| query  | search query |
| filter[archived]  | filter by archived flag |
| filter[project_id_eq]  | filter by project_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: dea24a9e-21d5-4996-ab8f-0b2ad7f8f1b4
200 OK
```


```json
{
  "data": [
    {
      "id": "00765e26-abd2-4723-8a12-173bfaf4ad6e",
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
            "related": "/projects/d1bf7f02-4677-4853-bd41-6f41880d8a34"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/cfa161eb-8278-46c8-a3dc-ca72ad08ce01"
          }
        }
      }
    },
    {
      "id": "4985b709-8406-4d2c-a309-e6c49a35e24e",
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
            "related": "/projects/d1bf7f02-4677-4853-bd41-6f41880d8a34"
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
GET /contexts/27ec02d4-931b-41c5-9170-d4b6045cb4e7
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
X-Request-Id: 205cf555-6906-4a1a-8da0-ae9f724f1555
200 OK
```


```json
{
  "data": {
    "id": "27ec02d4-931b-41c5-9170-d4b6045cb4e7",
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
          "related": "/projects/76dbcdd9-86a5-4152-9269-c8e28eebc5bf"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/bdb383b4-231a-4a98-b8fb-922e1883977a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/27ec02d4-931b-41c5-9170-d4b6045cb4e7"
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
PATCH /contexts/166b9cd3-a0ee-4ad9-a813-07aae76faf29
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "166b9cd3-a0ee-4ad9-a813-07aae76faf29",
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
X-Request-Id: 984678d0-595a-4fb8-b749-71b77faa7a79
200 OK
```


```json
{
  "data": {
    "id": "166b9cd3-a0ee-4ad9-a813-07aae76faf29",
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
          "related": "/projects/9f1b7f23-4af8-4402-8a02-39e0bb860ef3"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/454cb7d2-2cf1-4536-a92a-c89d44a2d88c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/166b9cd3-a0ee-4ad9-a813-07aae76faf29"
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
POST /projects/f1e78c3a-aa08-454e-a87d-bb834df00451/relationships/contexts
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c57c3d34-71fd-491c-ac0e-934d0cc56e8a
201 Created
```


```json
{
  "data": {
    "id": "335ba596-5fe5-4b31-843e-9577d4f61f6a",
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
          "related": "/projects/f1e78c3a-aa08-454e-a87d-bb834df00451"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/e3f6edc7-32c5-4bd7-b570-50fc400769b7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/f1e78c3a-aa08-454e-a87d-bb834df00451/relationships/contexts"
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
POST /contexts/296a62a8-30da-41ae-8029-19afed21e5eb/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/6710615040bf6dfd7de27ccb
Content-Type: text/html; charset=utf-8
X-Request-Id: bd694c3c-4290-4a57-a446-b2405958b5f8
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/6710615040bf6dfd7de27ccb">redirected</a>.</body></html>
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
DELETE /contexts/ddbd6279-cce3-45ec-b2ec-d924e73fbf9f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f9ccefb2-dc4a-4b93-9d7c-cc30b9580b20
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
POST /object_occurrences/a86b56e7-3581-4fc1-b015-3265cf54539e/relationships/tags
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 47fd6fc0-bc22-46d4-9d3e-b7bb32348cd7
201 Created
```


```json
{
  "data": {
    "id": "daab6313-2412-4ed2-986f-3d7b3f214f99",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a86b56e7-3581-4fc1-b015-3265cf54539e/relationships/tags"
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
POST /object_occurrences/fa3fa0c9-906e-4dcc-aaf4-a3619b21c083/relationships/tags
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
    "id": "32ba9bbe-ccbd-4049-b837-1619f2291ff5"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 32286710-7e8e-475b-a032-a66fd1e91fdb
201 Created
```


```json
{
  "data": {
    "id": "32ba9bbe-ccbd-4049-b837-1619f2291ff5",
    "type": "tag",
    "attributes": {
      "value": "Tag value 96fdd79a50da"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/fa3fa0c9-906e-4dcc-aaf4-a3619b21c083/relationships/tags"
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
DELETE /object_occurrences/7ef0b426-e2da-4d98-ac05-1cd0efe91646/relationships/tags/c319e286-47f5-4927-b096-1f8b675ba0f9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e311e8c6-4870-4550-9372-2795c424c592
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
GET /object_occurrences/6fa28a57-e119-4b55-8d1c-2175e2c31c2e
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 40f16bfd-353a-4641-90b6-e2d110a7c777
200 OK
```


```json
{
  "data": {
    "id": "6fa28a57-e119-4b55-8d1c-2175e2c31c2e",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "hex_color": null,
      "name": "OOC 1",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/69defa52-d449-4851-b15f-736187d3cba5"
        }
      },
      "components": {
        "data": [
          {
            "id": "e23a769a-d36f-4f0c-814e-cb34c0eb1a06",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/6fa28a57-e119-4b55-8d1c-2175e2c31c2e/relationships/components"
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
    "self": "http://example.org/object_occurrences/6fa28a57-e119-4b55-8d1c-2175e2c31c2e"
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
POST /object_occurrences/9593808f-909c-47bd-b02e-6901f0496e17/relationships/components
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
      "number": 1,
      "prefix": "="
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 52976898-f398-49b4-ba9b-bae11b7bf9a3
201 Created
```


```json
{
  "data": {
    "id": "e77627a7-7791-4488-adac-d2bca516aa0a",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "hex_color": null,
      "name": "ooc",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/de71dded-18a9-4680-aeee-f3e965bc9720"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/9593808f-909c-47bd-b02e-6901f0496e17",
          "self": "/object_occurrences/e77627a7-7791-4488-adac-d2bca516aa0a/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/e77627a7-7791-4488-adac-d2bca516aa0a/relationships/components"
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
    "self": "http://example.org/object_occurrences/9593808f-909c-47bd-b02e-6901f0496e17/relationships/components"
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
PATCH /object_occurrences/fb576be0-1e89-4220-8cef-73e7289b134e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "fb576be0-1e89-4220-8cef-73e7289b134e",
    "type": "object_occurrence",
    "attributes": {
      "name": "New name"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "ba8deade-c884-4e84-a2ac-5d5703ffcbc4"
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
X-Request-Id: ae63ee8f-6dd1-4ece-b984-c33ad3b3d0ae
200 OK
```


```json
{
  "data": {
    "id": "fb576be0-1e89-4220-8cef-73e7289b134e",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "hex_color": null,
      "name": "New name",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/315b59ef-0258-4b84-a008-c5ac1087ea00"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/ba8deade-c884-4e84-a2ac-5d5703ffcbc4",
          "self": "/object_occurrences/fb576be0-1e89-4220-8cef-73e7289b134e/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/fb576be0-1e89-4220-8cef-73e7289b134e/relationships/components"
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
    "self": "http://example.org/object_occurrences/fb576be0-1e89-4220-8cef-73e7289b134e"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


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
POST /object_occurrences/db001363-b6f8-44c9-b83c-39ba343669f9/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "a8c0da45-155d-4239-82d1-f36164b3c373",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/6166ff0b88cf103367c9e525
Content-Type: text/html; charset=utf-8
X-Request-Id: be850c9a-a8a1-4aa1-a0f7-4e065cc9b6db
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/6166ff0b88cf103367c9e525">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/6bd04aae-9b04-4865-89af-0becd308ed0b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7be89ed1-a458-4503-832a-d47b5d128c51
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
PATCH /object_occurrences/88696244-3a5d-48d7-994b-c475ba8a1f0e/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "2b386c4f-9f9a-43df-ac2e-9dbea70bcf9a",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 34d86f69-be66-47bb-b226-0ef100d09cea
200 OK
```


```json
{
  "data": {
    "id": "88696244-3a5d-48d7-994b-c475ba8a1f0e",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "hex_color": null,
      "name": "OOC 2",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/81df8270-ff3b-4a0a-9843-234030c1f489"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/2b386c4f-9f9a-43df-ac2e-9dbea70bcf9a",
          "self": "/object_occurrences/88696244-3a5d-48d7-994b-c475ba8a1f0e/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/88696244-3a5d-48d7-994b-c475ba8a1f0e/relationships/components"
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
    "self": "http://example.org/object_occurrences/88696244-3a5d-48d7-994b-c475ba8a1f0e/relationships/part_of"
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


## Add new tag


### Request

#### Endpoint

```plaintext
POST /classification_tables/9926ecad-52ca-4054-be1f-4a5e44a11c84/relationships/tags
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

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f801e8f5-a040-4b2a-863f-16ecb7ada558
201 Created
```


```json
{
  "data": {
    "id": "db6006f2-2106-44b0-b52d-918a9bac6d58",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/9926ecad-52ca-4054-be1f-4a5e44a11c84/relationships/tags"
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


## Add existing tag


### Request

#### Endpoint

```plaintext
POST /classification_tables/0e9f9721-16a7-467a-939b-286ab97d5a75/relationships/tags
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
    "id": "f0f9fd95-876b-4877-a492-ca3bfc7c98a6"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7284bdd0-9fd0-4914-976b-7cc96c3d8ec9
201 Created
```


```json
{
  "data": {
    "id": "f0f9fd95-876b-4877-a492-ca3bfc7c98a6",
    "type": "tag",
    "attributes": {
      "value": "Tag value 4667e34e650d"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0e9f9721-16a7-467a-939b-286ab97d5a75/relationships/tags"
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


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /classification_tables/040c3175-38d1-4ee8-92da-d0f6b024a9a5/relationships/tags/df82f61b-3e12-46db-b7ff-0d185ec512cc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b4f056ee-f7db-4081-ae88-8a8fd3276b6e
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
| filter[archived]  | filter by archived flag |
| filter[published]  | filter by published flag |
| filter[name_eq]  | filter by name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a6bd8f3c-aabd-4f72-9205-7a181c7424cf
200 OK
```


```json
{
  "data": [
    {
      "id": "ac36b954-6a68-4fcd-8d18-0e6f1d278731",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=ac36b954-6a68-4fcd-8d18-0e6f1d278731",
            "self": "/classification_tables/ac36b954-6a68-4fcd-8d18-0e6f1d278731/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "72c67d23-d819-4a11-a821-e3b88aab4015",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=72c67d23-d819-4a11-a821-e3b88aab4015",
            "self": "/classification_tables/72c67d23-d819-4a11-a821-e3b88aab4015/relationships/classification_entries",
            "meta": {
              "count": 1
            }
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




| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[archived]  | filter by archived flag |
| filter[published]  | filter by published flag |
| filter[name_eq]  | filter by name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f99c91a8-ba20-4b33-b939-4d9e659f7963
200 OK
```


```json
{
  "data": [
    {
      "id": "8af8c6b1-0cfd-4331-b02d-c538cd48f6af",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=8af8c6b1-0cfd-4331-b02d-c538cd48f6af",
            "self": "/classification_tables/8af8c6b1-0cfd-4331-b02d-c538cd48f6af/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "5b1b7c2d-ac03-4bb4-bc3d-94bc51e74969",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=5b1b7c2d-ac03-4bb4-bc3d-94bc51e74969",
            "self": "/classification_tables/5b1b7c2d-ac03-4bb4-bc3d-94bc51e74969/relationships/classification_entries",
            "meta": {
              "count": 1
            }
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
GET /classification_tables/44c7c753-6f88-4597-8693-a333bedbb908
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
X-Request-Id: 852323dc-bc11-42f8-8dc3-3999889c90a5
200 OK
```


```json
{
  "data": {
    "id": "44c7c753-6f88-4597-8693-a333bedbb908",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=44c7c753-6f88-4597-8693-a333bedbb908",
          "self": "/classification_tables/44c7c753-6f88-4597-8693-a333bedbb908/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/44c7c753-6f88-4597-8693-a333bedbb908"
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
PATCH /classification_tables/4243c00e-1e92-4c03-81b4-a0f977998054
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "4243c00e-1e92-4c03-81b4-a0f977998054",
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
X-Request-Id: 44c91b71-76da-46dd-9971-2ad0931589d5
200 OK
```


```json
{
  "data": {
    "id": "4243c00e-1e92-4c03-81b4-a0f977998054",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=4243c00e-1e92-4c03-81b4-a0f977998054",
          "self": "/classification_tables/4243c00e-1e92-4c03-81b4-a0f977998054/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/4243c00e-1e92-4c03-81b4-a0f977998054"
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
DELETE /classification_tables/5b09c1cc-97bd-461c-a3b7-8fb12237d404
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b7c5f3be-ee28-4e05-934c-5da658d5b535
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
POST /classification_tables/3e31132e-46dc-4c4d-bfcf-b3cc7f966fb2/publish
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
X-Request-Id: dc031a17-e085-4d38-bdd2-54ce4f96eaa3
200 OK
```


```json
{
  "data": {
    "id": "3e31132e-46dc-4c4d-bfcf-b3cc7f966fb2",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-09T22:44:02.544Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=3e31132e-46dc-4c4d-bfcf-b3cc7f966fb2",
          "self": "/classification_tables/3e31132e-46dc-4c4d-bfcf-b3cc7f966fb2/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/3e31132e-46dc-4c4d-bfcf-b3cc7f966fb2/publish"
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
POST /classification_tables/fce05233-3332-49c9-82d9-4431be162654/archive
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
X-Request-Id: 7657c694-c2cf-49c7-905c-b316fda544a9
200 OK
```


```json
{
  "data": {
    "id": "fce05233-3332-49c9-82d9-4431be162654",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:44:03.184Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=fce05233-3332-49c9-82d9-4431be162654",
          "self": "/classification_tables/fce05233-3332-49c9-82d9-4431be162654/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/fce05233-3332-49c9-82d9-4431be162654/archive"
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 088e6cf9-dc11-458b-9dab-3eb07cf4f832
201 Created
```


```json
{
  "data": {
    "id": "592b754f-dbb5-46d6-9f74-2621bd61be21",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=592b754f-dbb5-46d6-9f74-2621bd61be21",
          "self": "/classification_tables/592b754f-dbb5-46d6-9f74-2621bd61be21/relationships/classification_entries",
          "meta": {
            "count": 0
          }
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


## Add new tag


### Request

#### Endpoint

```plaintext
POST /classification_entries/e19c0615-3253-455d-8140-4214b2b5dd0f/relationships/tags
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

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2d957483-f6d7-4bd2-99d5-09921cf2a745
201 Created
```


```json
{
  "data": {
    "id": "e8af915c-eddb-4134-abab-ba5513c58d16",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/e19c0615-3253-455d-8140-4214b2b5dd0f/relationships/tags"
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


## Add existing tag


### Request

#### Endpoint

```plaintext
POST /classification_entries/1858d5a1-e19c-42bc-ae4c-70e47e30fddd/relationships/tags
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
    "id": "12f91e59-0d27-4f80-9d15-7a78a145406e"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f910f379-2f49-4316-a784-caf1c4192489
201 Created
```


```json
{
  "data": {
    "id": "12f91e59-0d27-4f80-9d15-7a78a145406e",
    "type": "tag",
    "attributes": {
      "value": "Tag value 4a96ca08d814"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/1858d5a1-e19c-42bc-ae4c-70e47e30fddd/relationships/tags"
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


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /classification_entries/d71ed8a1-6007-4d62-b408-20a6ccb42ee1/relationships/tags/fabe81f8-b9df-4d4c-9aa2-90276ad4f7e4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 79007070-c6ee-49b8-a290-a9d33c02ecb6
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
| filter[classification_entry_id_blank]  | filter by blank classification_entry_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ef25153e-3dcb-4ec6-9f58-2124ce939c85
200 OK
```


```json
{
  "data": [
    {
      "id": "0cc1f25b-fe79-4bc9-b038-ada44d65ae3a",
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
            "related": "/classification_entries?filter[classification_entry_id_eq]=0cc1f25b-fe79-4bc9-b038-ada44d65ae3a",
            "self": "/classification_entries/0cc1f25b-fe79-4bc9-b038-ada44d65ae3a/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "2075601d-5cf1-4cf0-9338-15bcd0b356eb",
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
            "id": "0cc1f25b-fe79-4bc9-b038-ada44d65ae3a",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/2075601d-5cf1-4cf0-9338-15bcd0b356eb"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=2075601d-5cf1-4cf0-9338-15bcd0b356eb",
            "self": "/classification_entries/2075601d-5cf1-4cf0-9338-15bcd0b356eb/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "32febc25-aa89-483d-9028-ee3b6e1c5043",
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
            "related": "/classification_entries?filter[classification_entry_id_eq]=32febc25-aa89-483d-9028-ee3b6e1c5043",
            "self": "/classification_entries/32febc25-aa89-483d-9028-ee3b6e1c5043/relationships/classification_entries",
            "meta": {
              "count": 0
            }
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
GET /classification_entries/a6e13a4d-8779-4b63-a531-811ef6618b26
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
X-Request-Id: c3f5e350-4fca-468c-b29b-6cbc7a1c9853
200 OK
```


```json
{
  "data": {
    "id": "a6e13a4d-8779-4b63-a531-811ef6618b26",
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
          "related": "/classification_entries?filter[classification_entry_id_eq]=a6e13a4d-8779-4b63-a531-811ef6618b26",
          "self": "/classification_entries/a6e13a4d-8779-4b63-a531-811ef6618b26/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/a6e13a4d-8779-4b63-a531-811ef6618b26"
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
PATCH /classification_entries/57f12f2c-c8a0-4c16-ac04-e8f713ef5b53
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "57f12f2c-c8a0-4c16-ac04-e8f713ef5b53",
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
X-Request-Id: 9a7dbf18-f81d-4e49-953d-7b35060b7fd0
200 OK
```


```json
{
  "data": {
    "id": "57f12f2c-c8a0-4c16-ac04-e8f713ef5b53",
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
          "id": "53c9f3bb-0970-4688-aeca-696f0b02920f",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/57f12f2c-c8a0-4c16-ac04-e8f713ef5b53"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=57f12f2c-c8a0-4c16-ac04-e8f713ef5b53",
          "self": "/classification_entries/57f12f2c-c8a0-4c16-ac04-e8f713ef5b53/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/57f12f2c-c8a0-4c16-ac04-e8f713ef5b53"
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
DELETE /classification_entries/41a3c4ac-e6e2-4456-876e-ddb3069e6f3c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4b60d8e7-5d4a-49f7-be6e-7ff588672a72
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
POST /classification_tables/a4499bc0-1361-471c-81b0-e37165ed559e/relationships/classification_entries
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
X-Request-Id: 2eaa9b32-4000-4196-9036-f0aa909b35ef
201 Created
```


```json
{
  "data": {
    "id": "b4651a95-a393-4ed0-b9be-2ec05f5c8e8c",
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
          "related": "/classification_entries?filter[classification_entry_id_eq]=b4651a95-a393-4ed0-b9be-2ec05f5c8e8c",
          "self": "/classification_entries/b4651a95-a393-4ed0-b9be-2ec05f5c8e8c/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a4499bc0-1361-471c-81b0-e37165ed559e/relationships/classification_entries"
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



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[archived]  | filter by archived flag |
| filter[published]  | filter by published flag |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c71b0cb1-75db-4875-a08e-25fe16f0ab61
200 OK
```


```json
{
  "data": [
    {
      "id": "0523b398-4674-45aa-8e2b-329579d3d2db",
      "type": "syntax",
      "attributes": {
        "account_id": "759c9a64-1d8f-4d14-a50d-89968d7d94ba",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 15f84892e217",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=0523b398-4674-45aa-8e2b-329579d3d2db",
            "self": "/syntaxes/0523b398-4674-45aa-8e2b-329579d3d2db/relationships/syntax_elements"
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
GET /syntaxes/dcd3aca3-0ecb-4233-ab8f-0b8b7efc4ff6
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
X-Request-Id: 2792708b-fbf6-40e0-a2cd-d003efc30631
200 OK
```


```json
{
  "data": {
    "id": "dcd3aca3-0ecb-4233-ab8f-0b8b7efc4ff6",
    "type": "syntax",
    "attributes": {
      "account_id": "5da92f96-dee0-43fe-b4aa-456ae6d5604c",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 784ff6f18c2d",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=dcd3aca3-0ecb-4233-ab8f-0b8b7efc4ff6",
          "self": "/syntaxes/dcd3aca3-0ecb-4233-ab8f-0b8b7efc4ff6/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/dcd3aca3-0ecb-4233-ab8f-0b8b7efc4ff6"
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
X-Request-Id: da0e67a4-f199-464c-8a2b-ec9f495779a0
201 Created
```


```json
{
  "data": {
    "id": "37ba2d2b-3685-43d0-9569-c1c064e4b46a",
    "type": "syntax",
    "attributes": {
      "account_id": "8088fe4e-196b-4865-877d-5c66c3213cc1",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=37ba2d2b-3685-43d0-9569-c1c064e4b46a",
          "self": "/syntaxes/37ba2d2b-3685-43d0-9569-c1c064e4b46a/relationships/syntax_elements"
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
PATCH /syntaxes/79cf7c37-66ee-4c83-92b6-f8b40f33510e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "79cf7c37-66ee-4c83-92b6-f8b40f33510e",
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
X-Request-Id: 5df172a3-8e3d-4cf0-86bb-19d75f740f5d
200 OK
```


```json
{
  "data": {
    "id": "79cf7c37-66ee-4c83-92b6-f8b40f33510e",
    "type": "syntax",
    "attributes": {
      "account_id": "5a7d09f9-4ad8-4b38-acb4-7df31a8bf7ba",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=79cf7c37-66ee-4c83-92b6-f8b40f33510e",
          "self": "/syntaxes/79cf7c37-66ee-4c83-92b6-f8b40f33510e/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/79cf7c37-66ee-4c83-92b6-f8b40f33510e"
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
DELETE /syntaxes/641125af-b68d-4891-b22a-abc5d404ac05
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 94a493da-e8bb-461f-8ab1-bc6dc8626efe
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
POST /syntaxes/de509992-adb9-48f0-af75-0f4025b0d2cd/publish
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
X-Request-Id: 3e06f3ee-de16-4fed-947e-6b4d87b32f65
200 OK
```


```json
{
  "data": {
    "id": "de509992-adb9-48f0-af75-0f4025b0d2cd",
    "type": "syntax",
    "attributes": {
      "account_id": "0d6fe676-0dbc-4748-bdd1-fccd38a9db27",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 0253517a0c3d",
      "published": true,
      "published_at": "2020-02-09T22:44:11.289Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=de509992-adb9-48f0-af75-0f4025b0d2cd",
          "self": "/syntaxes/de509992-adb9-48f0-af75-0f4025b0d2cd/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/de509992-adb9-48f0-af75-0f4025b0d2cd/publish"
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
POST /syntaxes/6a0bdfe1-17be-4f84-83ed-06946006da7b/archive
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
X-Request-Id: 1ebf7325-4ca2-4573-aacb-b870541faa57
200 OK
```


```json
{
  "data": {
    "id": "6a0bdfe1-17be-4f84-83ed-06946006da7b",
    "type": "syntax",
    "attributes": {
      "account_id": "a4221650-e3ea-47ff-9dbd-29ce1851bc9e",
      "archived": true,
      "archived_at": "2020-02-09T22:44:11.675Z",
      "description": "Description",
      "name": "Syntax 32d4044db60b",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=6a0bdfe1-17be-4f84-83ed-06946006da7b",
          "self": "/syntaxes/6a0bdfe1-17be-4f84-83ed-06946006da7b/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/6a0bdfe1-17be-4f84-83ed-06946006da7b/archive"
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



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 9c735f89-3129-4c45-b8ca-6e41653ccf77
200 OK
```


```json
{
  "data": [
    {
      "id": "868ef143-d14f-4ccd-96aa-22a13926023e",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "a64aa1bb-96b6-493d-9939-3488ea03ad0e",
        "hex_color": "7d01c7",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element c45d49cdab82"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/9b7ff0b7-572e-4ea2-937f-c6a2af64c765"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/a64aa1bb-96b6-493d-9939-3488ea03ad0e",
            "self": "/syntax_elements/868ef143-d14f-4ccd-96aa-22a13926023e/relationships/classification_table"
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
GET /syntax_elements/b6890830-db98-4f64-b152-bf81a613380a
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
X-Request-Id: f9fa8ece-e0be-4201-a9a2-b344de70e667
200 OK
```


```json
{
  "data": {
    "id": "b6890830-db98-4f64-b152-bf81a613380a",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "d0819060-0fb7-43ef-a2aa-5b747d6c2c58",
      "hex_color": "139f37",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element a6252189c120"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/98256604-2ac1-47c9-934d-efbea577fa99"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/d0819060-0fb7-43ef-a2aa-5b747d6c2c58",
          "self": "/syntax_elements/b6890830-db98-4f64-b152-bf81a613380a/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/b6890830-db98-4f64-b152-bf81a613380a"
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
POST /syntaxes/e43989fb-1afd-4bd0-bb3e-fdbebc047792/relationships/syntax_elements
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
          "id": "6c62a704-2d2a-4df5-bedb-e5adf550cf5e"
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
X-Request-Id: 82d2729b-21f4-4deb-b36b-759c7a3c943f
201 Created
```


```json
{
  "data": {
    "id": "432b3fc1-e99b-471a-b603-4e682f0b3b8d",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "6c62a704-2d2a-4df5-bedb-e5adf550cf5e",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e43989fb-1afd-4bd0-bb3e-fdbebc047792"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/6c62a704-2d2a-4df5-bedb-e5adf550cf5e",
          "self": "/syntax_elements/432b3fc1-e99b-471a-b603-4e682f0b3b8d/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/e43989fb-1afd-4bd0-bb3e-fdbebc047792/relationships/syntax_elements"
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
PATCH /syntax_elements/4b235ae6-14fa-4894-9f38-9eaa3e3d7e50
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "4b235ae6-14fa-4894-9f38-9eaa3e3d7e50",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "c61d5936-7b52-4599-9f40-1e25a38fa19d"
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
X-Request-Id: dea567da-54c1-4646-9cfd-2479dbbaef8a
200 OK
```


```json
{
  "data": {
    "id": "4b235ae6-14fa-4894-9f38-9eaa3e3d7e50",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "c61d5936-7b52-4599-9f40-1e25a38fa19d",
      "hex_color": "e3f0fa",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/88641f03-15fe-4f0f-9d15-65ef646b90c1"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/c61d5936-7b52-4599-9f40-1e25a38fa19d",
          "self": "/syntax_elements/4b235ae6-14fa-4894-9f38-9eaa3e3d7e50/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/4b235ae6-14fa-4894-9f38-9eaa3e3d7e50"
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
DELETE /syntax_elements/3cd026ce-6e24-4394-b4b0-1ba61487ab0a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 017c37ef-72a9-42a8-b126-1b64e1d07df8
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
PATCH /syntax_elements/c1969661-861a-4387-8f99-0ee656f3391d/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "5ff24afa-ea35-4120-b5aa-af63f2cdd754",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e2e341f0-52a3-4855-98c6-55a4d6bb9bda
200 OK
```


```json
{
  "data": {
    "id": "c1969661-861a-4387-8f99-0ee656f3391d",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "5ff24afa-ea35-4120-b5aa-af63f2cdd754",
      "hex_color": "3920c9",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 49395ff20af5"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/0be30656-cbf7-4053-baea-d349666e8075"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/5ff24afa-ea35-4120-b5aa-af63f2cdd754",
          "self": "/syntax_elements/c1969661-861a-4387-8f99-0ee656f3391d/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/c1969661-861a-4387-8f99-0ee656f3391d/relationships/classification_table"
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
DELETE /syntax_elements/555b6bb3-5b2b-4bde-bb5c-13cd67315db3/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 45735076-acf0-4de6-b83b-fa759340f9dd
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
GET /syntax_nodes/17e2c498-ba1c-4f41-b79e-2d10edb8b848
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: af76a481-f7c9-400f-a833-7cd8996825d4
200 OK
```


```json
{
  "data": {
    "id": "17e2c498-ba1c-4f41-b79e-2d10edb8b848",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/23a39a78-f58d-4050-a6e1-8ec699dee4d7"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/17e2c498-ba1c-4f41-b79e-2d10edb8b848/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/17e2c498-ba1c-4f41-b79e-2d10edb8b848"
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
POST /syntax_nodes/5a42bec1-ef1d-4344-b7ec-f0ab027b558d/relationships/components
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6a46d12e-0588-482f-bfca-c451da113126
201 Created
```


```json
{
  "data": {
    "id": "fa6ea394-87bb-4a7a-b734-84d915722ef7",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/d307f11b-2f63-4752-8bdb-ee5c7f67245a"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/fa6ea394-87bb-4a7a-b734-84d915722ef7/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/5a42bec1-ef1d-4344-b7ec-f0ab027b558d/relationships/components"
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
PATCH /syntax_nodes/695d3663-3432-4827-9bfd-490a460a6caa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "695d3663-3432-4827-9bfd-490a460a6caa",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7cfe508c-260b-4cdd-a5fc-367b9820edd7
200 OK
```


```json
{
  "data": {
    "id": "695d3663-3432-4827-9bfd-490a460a6caa",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/69c6a13c-45a1-4b90-b292-89f49589a2ea"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/695d3663-3432-4827-9bfd-490a460a6caa/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/695d3663-3432-4827-9bfd-490a460a6caa"
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
DELETE /syntax_nodes/979fae7c-f644-4a14-960a-e120f4c8db3f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3ab7ee59-c75c-49bb-8cc8-bb7d8a155e4d
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
X-Request-Id: f3c15f8d-ece2-466b-b736-3d8c8e0bd457
200 OK
```


```json
{
  "data": [
    {
      "id": "4e7e9681-bc5d-4851-a0c1-0e4afe38554a",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-09T22:44:17.918Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=4e7e9681-bc5d-4851-a0c1-0e4afe38554a",
            "self": "/progress_models/4e7e9681-bc5d-4851-a0c1-0e4afe38554a/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "bde1fa4e-7b45-456e-a783-6245d513876a",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 2",
        "order": 2,
        "published": false,
        "published_at": null,
        "type": "ObjectOccurrenceRelation"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=bde1fa4e-7b45-456e-a783-6245d513876a",
            "self": "/progress_models/bde1fa4e-7b45-456e-a783-6245d513876a/relationships/progress_steps"
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
GET /progress_models/71688131-4216-4161-9327-e2e8a615368a
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
X-Request-Id: 84983bc6-9452-4912-9f86-a14657a8b5b2
200 OK
```


```json
{
  "data": {
    "id": "71688131-4216-4161-9327-e2e8a615368a",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-09T22:44:18.551Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=71688131-4216-4161-9327-e2e8a615368a",
          "self": "/progress_models/71688131-4216-4161-9327-e2e8a615368a/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/71688131-4216-4161-9327-e2e8a615368a"
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
PATCH /progress_models/0f5681b6-c2d2-42f4-91e0-af17183e6ad3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "0f5681b6-c2d2-42f4-91e0-af17183e6ad3",
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
X-Request-Id: 743dae27-e4a9-412b-95c9-5c53267b69d7
200 OK
```


```json
{
  "data": {
    "id": "0f5681b6-c2d2-42f4-91e0-af17183e6ad3",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 6,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=0f5681b6-c2d2-42f4-91e0-af17183e6ad3",
          "self": "/progress_models/0f5681b6-c2d2-42f4-91e0-af17183e6ad3/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0f5681b6-c2d2-42f4-91e0-af17183e6ad3"
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
DELETE /progress_models/0357f073-f3a0-47de-affd-86a941c75e7d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1c186281-7a99-4f1c-b6de-1a613c73869b
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
POST /progress_models/aebafcc3-f8e3-4050-b94d-d7e7641fdad2/publish
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
X-Request-Id: bddc4851-97e4-4911-a619-bb9a6ed5cd42
200 OK
```


```json
{
  "data": {
    "id": "aebafcc3-f8e3-4050-b94d-d7e7641fdad2",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-09T22:44:20.411Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=aebafcc3-f8e3-4050-b94d-d7e7641fdad2",
          "self": "/progress_models/aebafcc3-f8e3-4050-b94d-d7e7641fdad2/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/aebafcc3-f8e3-4050-b94d-d7e7641fdad2/publish"
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
POST /progress_models/208a6f09-8aae-49f3-abf8-973ec027c904/archive
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
X-Request-Id: b3d0d53b-7f59-4bee-9481-1c05347d7dcb
200 OK
```


```json
{
  "data": {
    "id": "208a6f09-8aae-49f3-abf8-973ec027c904",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:44:20.992Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=208a6f09-8aae-49f3-abf8-973ec027c904",
          "self": "/progress_models/208a6f09-8aae-49f3-abf8-973ec027c904/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/208a6f09-8aae-49f3-abf8-973ec027c904/archive"
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
X-Request-Id: 7a217269-1e09-42be-93c0-e6d43ae6388a
201 Created
```


```json
{
  "data": {
    "id": "0d0ece7d-b8d0-4036-9692-959018ad2724",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 1,
      "published": false,
      "published_at": null,
      "type": "Project"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=0d0ece7d-b8d0-4036-9692-959018ad2724",
          "self": "/progress_models/0d0ece7d-b8d0-4036-9692-959018ad2724/relationships/progress_steps"
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
X-Request-Id: 68200c52-90a9-4f20-b392-a4194ef7f911
200 OK
```


```json
{
  "data": [
    {
      "id": "d7141160-1231-49f5-930b-f2edf69b6e25",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/de108169-6ca3-41eb-b3c6-b4934f3a3f50"
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
GET /progress_steps/e78babee-14a0-49ab-8162-7256559504d8
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
X-Request-Id: ccefb884-6581-40a1-a294-74cc9630a804
200 OK
```


```json
{
  "data": {
    "id": "e78babee-14a0-49ab-8162-7256559504d8",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/b484a7a0-c45c-4df1-9f5a-d0ade48b0dcf"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/e78babee-14a0-49ab-8162-7256559504d8"
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
PATCH /progress_steps/5b83bf02-8485-421e-8cd3-f6313eee7989
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "5b83bf02-8485-421e-8cd3-f6313eee7989",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 052de57f-b43f-4159-9252-7d1fc225eb4c
200 OK
```


```json
{
  "data": {
    "id": "5b83bf02-8485-421e-8cd3-f6313eee7989",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/2a269739-3908-4b68-8fcf-19f7306a9e95"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/5b83bf02-8485-421e-8cd3-f6313eee7989"
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
DELETE /progress_steps/67db1e11-be72-4572-9d8c-566bcbcc977f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f3b39a92-c116-4506-9517-159b5f305dc9
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
POST /progress_models/16723968-0213-4ffd-bbaf-5dc2f54ee71c/relationships/progress_steps
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
X-Request-Id: 0bff37e1-d95e-46d6-b8ac-3d17a8615b05
201 Created
```


```json
{
  "data": {
    "id": "23c95600-3a8f-41bb-ae69-76d40aa50344",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/16723968-0213-4ffd-bbaf-5dc2f54ee71c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/16723968-0213-4ffd-bbaf-5dc2f54ee71c/relationships/progress_steps"
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
X-Request-Id: c666d4f2-8085-4b05-b17c-17391986d3b3
200 OK
```


```json
{
  "data": [
    {
      "id": "7913ddc4-cc62-45f3-9443-0d3a66e01477",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/a55f7058-86c3-4e59-9b21-e574bb1f5085"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/ebce002d-ae86-4e45-9662-f8dde1fd42c7"
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
GET /progress/ed7d8d74-0ce1-46ad-8667-92f52b317b1d
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
X-Request-Id: 60d5078b-1a2e-4030-a573-4b57a8f591b1
200 OK
```


```json
{
  "data": {
    "id": "ed7d8d74-0ce1-46ad-8667-92f52b317b1d",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/edabd675-4b59-4e81-861d-8c9777214291"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/d2da60d0-d70d-4c3b-8616-1f33820519ce"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/ed7d8d74-0ce1-46ad-8667-92f52b317b1d"
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
DELETE /progress/d1152008-e232-4332-8ac5-9a52a3f2783a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 74feae69-f6f4-40d3-a645-9d8624841db7
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
          "id": "beed2d5d-b641-403a-a7c8-b8be93cf75f5"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "8043d906-abd5-4b07-a83e-b575ad9c233c"
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
X-Request-Id: 8d48556c-7628-4b7b-80f7-805277ff0c98
201 Created
```


```json
{
  "data": {
    "id": "431f5ce0-9144-4d3e-999e-7d8cebfd2213",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/beed2d5d-b641-403a-a7c8-b8be93cf75f5"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/8043d906-abd5-4b07-a83e-b575ad9c233c"
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
X-Request-Id: ba2c89b8-cbcd-4c32-9c83-9219d58f50ef
200 OK
```


```json
{
  "data": [
    {
      "id": "de5569cd-e194-4443-9d13-ccd97c5dcc04",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "0224fd8e-4a07-461c-b88b-043ae14e843f"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/0224fd8e-4a07-461c-b88b-043ae14e843f"
          }
        }
      }
    }
  ],
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
GET /projects/18e952a9-4118-4ac7-80b3-06933cbb2bd4/relationships/project_setting
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
X-Request-Id: 5fb89f43-4492-471f-aad4-a23392b0c57a
200 OK
```


```json
{
  "data": {
    "id": "fa490e12-d067-48fd-bc08-d42603ece592",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "18e952a9-4118-4ac7-80b3-06933cbb2bd4"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/18e952a9-4118-4ac7-80b3-06933cbb2bd4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/18e952a9-4118-4ac7-80b3-06933cbb2bd4/relationships/project_setting"
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
PATCH /projects/cd45d5d0-75a7-4f78-a307-d6ff2afe3f5f/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "cd45d5d0-75a7-4f78-a307-d6ff2afe3f5f",
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
X-Request-Id: e4f94c06-85c5-44bf-b206-de395f2a5f78
200 OK
```


```json
{
  "data": {
    "id": "bca00fe4-7852-4ce7-a989-cbe283880eae",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "cd45d5d0-75a7-4f78-a307-d6ff2afe3f5f"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/cd45d5d0-75a7-4f78-a307-d6ff2afe3f5f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/cd45d5d0-75a7-4f78-a307-d6ff2afe3f5f/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


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
X-Request-Id: acfff5bf-91a8-485c-9b3d-f261a356feed
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
X-Request-Id: 71233b01-cd95-479f-ac90-f4bed1bf6dcd
200 OK
```


```json
{
  "data": {
    "id": "391075cb-e950-4881-934f-5d2313454016",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "35598a0b-982b-4b83-88ef-460ed47ead9c"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/35598a0b-982b-4b83-88ef-460ed47ead9c"
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
X-Request-Id: 963c6691-a35b-467a-ba03-08cf73df11f4
200 OK
```


```json
{
  "data": {
    "id": "61999cf9-72d6-4346-b194-3caf18900fec",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "88d7d92c-9d77-4e38-be97-af5e0888dabf"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/88d7d92c-9d77-4e38-be97-af5e0888dabf"
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


# Utils

Events is a way to track which changes and events has happened to resources.


## Look up path


### Request

#### Endpoint

```plaintext
GET /utils/path/from/object_occurrence/2e36b8ac-4e1b-48ab-a9ad-cdf270cfe5f6/to/object_occurrence/de9c0059-a788-41cc-9858-97805b4c1580
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
X-Request-Id: cd336d4e-ea2d-419b-ab34-4bb84a64919e
200 OK
```


```json
[
  {
    "id": "2e36b8ac-4e1b-48ab-a9ad-cdf270cfe5f6",
    "type": "object_occurrence"
  },
  {
    "id": "3e0ee786-d7e6-499e-b4ad-1abfbbb2b055",
    "type": "object_occurrence"
  },
  {
    "id": "e5185809-f0f3-4455-b482-83b5b18dd6b2",
    "type": "object_occurrence"
  },
  {
    "id": "345ab0e1-0cd8-46e3-bb11-2abe885ea59b",
    "type": "object_occurrence"
  },
  {
    "id": "087e30e1-48c5-4bf3-aba4-950b4f4c0c6a",
    "type": "object_occurrence"
  },
  {
    "id": "e6d0d85a-473e-44e3-b6a9-64dda3905cfb",
    "type": "object_occurrence"
  },
  {
    "id": "de9c0059-a788-41cc-9858-97805b4c1580",
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
X-Request-Id: 7eafc30b-8db1-4e7a-9007-e5e09b0d4e84
200 OK
```


```json
{
  "data": [
    {
      "id": "2d2b61b6-83bc-4c33-a738-054c5bae4bbf",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/1aee9d7e-f450-4219-8bb6-e0d6c599c2d5"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/cb84bee1-98b7-4a46-bfb8-fa8c2da1f9b7"
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
Content-Type: text/plain; charset=utf-8
X-Request-Id: 28ad3b97-e6b1-495e-b68b-d84d7cc816c5
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



