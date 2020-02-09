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
X-Request-Id: e0cc5c9a-7139-45f3-a68d-b3708e36bd17
200 OK
```


```json
{
  "data": {
    "id": "3ce9326c-e022-4f57-ba0a-fe6570baf16f",
    "type": "account",
    "attributes": {
      "name": "Account 988447ef50e2"
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
    "id": "78313175-cacc-4b16-a240-a37b4a9c90f7",
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
X-Request-Id: 07a5dc27-f050-49f7-b76f-81f0ffb9d198
200 OK
```


```json
{
  "data": {
    "id": "78313175-cacc-4b16-a240-a37b4a9c90f7",
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
POST /projects/cdf09851-0c7c-4dcc-9aab-05736be45dbf/relationships/tags
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
X-Request-Id: 540faabd-ff6f-43d9-b3eb-f79aac3d2524
201 Created
```


```json
{
  "data": {
    "id": "5f680f94-62f8-4d5e-a560-73fab82b36bc",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/cdf09851-0c7c-4dcc-9aab-05736be45dbf/relationships/tags"
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
POST /projects/e845d1ee-84de-4d83-b0ef-6058be041c3a/relationships/tags
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
    "id": "0a19c9a5-8cdc-4ba3-b45f-5fccca10ca63"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2d58efdf-56b3-48d7-a649-4734b6085e0e
201 Created
```


```json
{
  "data": {
    "id": "0a19c9a5-8cdc-4ba3-b45f-5fccca10ca63",
    "type": "tag",
    "attributes": {
      "value": "Tag value 10f912acd153"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/e845d1ee-84de-4d83-b0ef-6058be041c3a/relationships/tags"
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
DELETE /projects/7df7eccf-3faa-48c0-aff6-10d952867f86/relationships/tags/33fb92d7-0ffb-4e2c-b2f4-64fd27e69ac7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2d4b6c07-dd39-444d-ae48-9280144b1ed7
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
X-Request-Id: 37351cca-9bb5-42d8-be2b-a62358374382
200 OK
```


```json
{
  "data": [
    {
      "id": "64d1f927-82ea-4fd0-b4bc-01da21e46096",
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
            "related": "/contexts?filter[project_id_eq]=64d1f927-82ea-4fd0-b4bc-01da21e46096",
            "self": "/projects/64d1f927-82ea-4fd0-b4bc-01da21e46096/relationships/contexts"
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
GET /projects/8d7269b5-25d8-46ec-b01a-466242876f84
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
X-Request-Id: 8dd6e9de-d927-4ed9-9431-d83eab2d0eb9
200 OK
```


```json
{
  "data": {
    "id": "8d7269b5-25d8-46ec-b01a-466242876f84",
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
          "related": "/contexts?filter[project_id_eq]=8d7269b5-25d8-46ec-b01a-466242876f84",
          "self": "/projects/8d7269b5-25d8-46ec-b01a-466242876f84/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/8d7269b5-25d8-46ec-b01a-466242876f84"
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
PATCH /projects/b5d5dc4f-6ebb-471b-bc74-74bf556a9b90
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "b5d5dc4f-6ebb-471b-bc74-74bf556a9b90",
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
X-Request-Id: 515d5b4a-d7b8-45d0-a47d-bc8f649fc828
200 OK
```


```json
{
  "data": {
    "id": "b5d5dc4f-6ebb-471b-bc74-74bf556a9b90",
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
          "related": "/contexts?filter[project_id_eq]=b5d5dc4f-6ebb-471b-bc74-74bf556a9b90",
          "self": "/projects/b5d5dc4f-6ebb-471b-bc74-74bf556a9b90/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b5d5dc4f-6ebb-471b-bc74-74bf556a9b90"
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
POST /projects/bb1b111a-104f-47bb-b008-cc99b472c9c2/archive
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
X-Request-Id: 93beb7f9-ca9b-434b-b21d-9b7e7e821b0f
200 OK
```


```json
{
  "data": {
    "id": "bb1b111a-104f-47bb-b008-cc99b472c9c2",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:51:44.943Z",
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
          "related": "/contexts?filter[project_id_eq]=bb1b111a-104f-47bb-b008-cc99b472c9c2",
          "self": "/projects/bb1b111a-104f-47bb-b008-cc99b472c9c2/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/bb1b111a-104f-47bb-b008-cc99b472c9c2/archive"
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
DELETE /projects/3150a2f1-3bcf-4bc8-939a-04f6fe89175a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d17700e1-9b15-4c32-8f78-1849e9eae9ad
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
POST /contexts/eed1ca57-bb23-4ad3-94bf-7bf80b540bce/relationships/tags
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
X-Request-Id: 86135e6b-ef43-44c6-b4d9-ef0a9428cc00
201 Created
```


```json
{
  "data": {
    "id": "7be3a634-3eca-4cac-ad5e-2738b70b5360",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/eed1ca57-bb23-4ad3-94bf-7bf80b540bce/relationships/tags"
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
POST /contexts/f9e87bad-3143-4645-a05c-a73f562b34af/relationships/tags
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
    "id": "f46d5aab-fb08-4bfe-82c8-daff76846325"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8a2ead63-df3c-4bd6-a86c-51bb2a99007e
201 Created
```


```json
{
  "data": {
    "id": "f46d5aab-fb08-4bfe-82c8-daff76846325",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5cf21029f736"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/f9e87bad-3143-4645-a05c-a73f562b34af/relationships/tags"
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
DELETE /contexts/9fb354d5-730b-400f-96b9-077f538c6a8e/relationships/tags/97244b6b-e1a5-4bae-ae83-8b92f433c02d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 49f6f1e5-375d-497c-bde2-f85dbd0dede9
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
X-Request-Id: 54b39093-ffcc-4c84-a9b7-e0533fde1102
200 OK
```


```json
{
  "data": [
    {
      "id": "db412cc8-8a8a-4aaa-be19-0141c5bbdef4",
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
            "related": "/projects/896c1041-6690-4e18-b2f7-88f22c5d2fc1"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/21464077-c44d-4f39-ae99-f3db92d90bff"
          }
        }
      }
    },
    {
      "id": "b6db8c62-c364-40d3-9493-3f1380e9a18c",
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
            "related": "/projects/896c1041-6690-4e18-b2f7-88f22c5d2fc1"
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
GET /contexts/22b15b79-9777-4e22-a09d-da8298b757e3
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
X-Request-Id: 4ff41120-576f-4be0-9166-ea79cca1abfe
200 OK
```


```json
{
  "data": {
    "id": "22b15b79-9777-4e22-a09d-da8298b757e3",
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
          "related": "/projects/02a48287-43fc-47ea-9078-dfd95a156b20"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/5b83a41f-e15c-44bb-b045-819a98c7d418"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/22b15b79-9777-4e22-a09d-da8298b757e3"
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
PATCH /contexts/4a6c73da-da6b-4fa6-bf63-21f243563c6c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "4a6c73da-da6b-4fa6-bf63-21f243563c6c",
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
X-Request-Id: 09ceb2b4-c7d1-42a4-88ae-8cc4a1769d55
200 OK
```


```json
{
  "data": {
    "id": "4a6c73da-da6b-4fa6-bf63-21f243563c6c",
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
          "related": "/projects/572dfa4d-febf-450d-baa1-8f461f16cc77"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/95fec0e3-c41d-4324-9d52-3a2dd2f7945c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/4a6c73da-da6b-4fa6-bf63-21f243563c6c"
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
POST /projects/2a26a2ba-c031-469e-bed2-fecac0d9800b/relationships/contexts
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
X-Request-Id: d232109f-7fc0-495d-8286-fac93e939812
201 Created
```


```json
{
  "data": {
    "id": "e9ccaae6-551c-4eb0-8614-eb03330ad660",
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
          "related": "/projects/2a26a2ba-c031-469e-bed2-fecac0d9800b"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/27f780bb-6d8f-4ecf-afda-b731eba1b005"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/2a26a2ba-c031-469e-bed2-fecac0d9800b/relationships/contexts"
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
POST /contexts/8f7d69ee-5afb-43b8-946f-634bbd1ea6c6/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/52b44304e2479e79d2f60f07
Content-Type: text/html; charset=utf-8
X-Request-Id: df89a29a-9bc2-479b-80b7-fb9a7ec093a2
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/52b44304e2479e79d2f60f07">redirected</a>.</body></html>
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
DELETE /contexts/8f04fcac-5e83-4ec1-8da0-085f1f8a0c2f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4b6a7e0c-51d5-4772-be54-baa1f67554d5
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
POST /object_occurrences/f5559fd3-bb2e-4659-b8a2-6b08adf876f0/relationships/tags
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
X-Request-Id: 1e62497b-80b4-4c64-accb-e34a8141f974
201 Created
```


```json
{
  "data": {
    "id": "5ba7f19d-656d-442f-b170-e724b228593c",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f5559fd3-bb2e-4659-b8a2-6b08adf876f0/relationships/tags"
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
POST /object_occurrences/bed16764-db22-413f-af27-dd03c685cff7/relationships/tags
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
    "id": "d8291f36-7f27-4019-8b41-9076464042e0"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 675ad948-6065-4c53-9886-007b411106c2
201 Created
```


```json
{
  "data": {
    "id": "d8291f36-7f27-4019-8b41-9076464042e0",
    "type": "tag",
    "attributes": {
      "value": "Tag value fb6ee654e7f5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/bed16764-db22-413f-af27-dd03c685cff7/relationships/tags"
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
DELETE /object_occurrences/68d427f0-08eb-40dc-b4a0-8246fbbb9812/relationships/tags/43a43415-eb52-4e76-bc0c-4308ba291c62
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: bbd9516f-b5d0-4f15-805f-c83603769d86
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
GET /object_occurrences/108b75e0-af30-4d43-82f8-7dc84da61d21
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
X-Request-Id: 3486560d-36ec-4ed5-8d7c-6915a51c6e66
200 OK
```


```json
{
  "data": {
    "id": "108b75e0-af30-4d43-82f8-7dc84da61d21",
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
          "related": "/contexts/046a8c1d-5fbf-4f4d-a0c3-4161780d2178"
        }
      },
      "components": {
        "data": [
          {
            "id": "e2257abb-971f-43d2-a8e0-b37e76a91008",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/108b75e0-af30-4d43-82f8-7dc84da61d21/relationships/components"
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
    "self": "http://example.org/object_occurrences/108b75e0-af30-4d43-82f8-7dc84da61d21"
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
POST /object_occurrences/cf13a854-0b83-4f11-a603-3b593e7ab045/relationships/components
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
X-Request-Id: 65521ca4-2355-46ef-bed2-ee17229854da
201 Created
```


```json
{
  "data": {
    "id": "b7c0648c-c09e-471f-b020-f33217c51697",
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
          "related": "/contexts/c267385e-15b0-4103-90ed-d2872f47e362"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/cf13a854-0b83-4f11-a603-3b593e7ab045",
          "self": "/object_occurrences/b7c0648c-c09e-471f-b020-f33217c51697/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/b7c0648c-c09e-471f-b020-f33217c51697/relationships/components"
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
    "self": "http://example.org/object_occurrences/cf13a854-0b83-4f11-a603-3b593e7ab045/relationships/components"
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
PATCH /object_occurrences/c96b8f0d-0030-4862-afbc-b913a1d63963
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "c96b8f0d-0030-4862-afbc-b913a1d63963",
    "type": "object_occurrence",
    "attributes": {
      "name": "New name"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "bb3e8c59-7cbd-40ba-88c6-cf9ff15bd9ee"
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
X-Request-Id: b9474bb5-57a3-4e29-befd-eaab65e509aa
200 OK
```


```json
{
  "data": {
    "id": "c96b8f0d-0030-4862-afbc-b913a1d63963",
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
          "related": "/contexts/d9b7aae6-766b-48e9-b070-22a310823d99"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/bb3e8c59-7cbd-40ba-88c6-cf9ff15bd9ee",
          "self": "/object_occurrences/c96b8f0d-0030-4862-afbc-b913a1d63963/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/c96b8f0d-0030-4862-afbc-b913a1d63963/relationships/components"
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
    "self": "http://example.org/object_occurrences/c96b8f0d-0030-4862-afbc-b913a1d63963"
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
POST /object_occurrences/6a4bdfa2-d062-4462-9709-e7ee57e3ce83/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "6aad65b5-462b-418b-9e03-b49efbb924a6",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/cafeea42ac98ec25451357a3
Content-Type: text/html; charset=utf-8
X-Request-Id: a26d865c-cead-47e1-9ec2-cb09106b39b7
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/cafeea42ac98ec25451357a3">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/8b53e3f5-0297-439d-aaa1-9cf936824a28
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8df56648-d439-40b0-826d-bf1746aabbc3
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
PATCH /object_occurrences/bc2b48ca-d7d0-4d1b-ae1b-997a501a6ee6/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "a612c2ce-1576-49fe-b58c-23db3bf9c218",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a85e0c5f-c752-4de1-831c-d716e9e62790
200 OK
```


```json
{
  "data": {
    "id": "bc2b48ca-d7d0-4d1b-ae1b-997a501a6ee6",
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
          "related": "/contexts/7599b915-06c2-4449-9b84-9b94a3238e32"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/a612c2ce-1576-49fe-b58c-23db3bf9c218",
          "self": "/object_occurrences/bc2b48ca-d7d0-4d1b-ae1b-997a501a6ee6/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/bc2b48ca-d7d0-4d1b-ae1b-997a501a6ee6/relationships/components"
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
    "self": "http://example.org/object_occurrences/bc2b48ca-d7d0-4d1b-ae1b-997a501a6ee6/relationships/part_of"
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
POST /classification_tables/fded2ec5-1ab3-4d19-a8a8-f6c00517d6fb/relationships/tags
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
X-Request-Id: 5d888274-569f-4dd8-84c9-3dbdf9b215cf
201 Created
```


```json
{
  "data": {
    "id": "519ed6a1-7d9a-4b21-87e1-a694a8f0ff81",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/fded2ec5-1ab3-4d19-a8a8-f6c00517d6fb/relationships/tags"
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
POST /classification_tables/aa6a0354-679e-4533-aae4-64bb927c3fa0/relationships/tags
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
    "id": "7f8a4dc6-9795-4173-a9a8-0dedda508a82"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 5272f684-c025-409b-ba76-85984c84b67c
201 Created
```


```json
{
  "data": {
    "id": "7f8a4dc6-9795-4173-a9a8-0dedda508a82",
    "type": "tag",
    "attributes": {
      "value": "Tag value 96ae4cb264b6"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/aa6a0354-679e-4533-aae4-64bb927c3fa0/relationships/tags"
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
DELETE /classification_tables/a5bcf423-7db4-47ac-8c30-1fc156a17a37/relationships/tags/81657a90-a63c-4442-9e20-545bfe5b0e92
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 850fdc8a-3dd6-4490-b4fb-46c49633950e
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
X-Request-Id: 7839793e-e1ee-4fb0-a2ce-7e2709d96e78
200 OK
```


```json
{
  "data": [
    {
      "id": "4f4b467b-3236-40f7-b5b5-d8bc32f06a6c",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=4f4b467b-3236-40f7-b5b5-d8bc32f06a6c",
            "self": "/classification_tables/4f4b467b-3236-40f7-b5b5-d8bc32f06a6c/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "9cef4bed-9ed3-4809-9ada-89814882e04c",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=9cef4bed-9ed3-4809-9ada-89814882e04c",
            "self": "/classification_tables/9cef4bed-9ed3-4809-9ada-89814882e04c/relationships/classification_entries",
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
X-Request-Id: 5e902594-9852-4b1f-9906-024b90cdb469
200 OK
```


```json
{
  "data": [
    {
      "id": "e8d647c5-368f-4dc1-8d93-85e34c649865",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=e8d647c5-368f-4dc1-8d93-85e34c649865",
            "self": "/classification_tables/e8d647c5-368f-4dc1-8d93-85e34c649865/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "46fa3316-8084-42a3-8e46-483277d35954",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=46fa3316-8084-42a3-8e46-483277d35954",
            "self": "/classification_tables/46fa3316-8084-42a3-8e46-483277d35954/relationships/classification_entries",
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
GET /classification_tables/0bb641c1-0468-4f7d-ab34-ef9348c954be
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
X-Request-Id: 72b82fb0-6d68-4d2f-bc77-019d56083355
200 OK
```


```json
{
  "data": {
    "id": "0bb641c1-0468-4f7d-ab34-ef9348c954be",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=0bb641c1-0468-4f7d-ab34-ef9348c954be",
          "self": "/classification_tables/0bb641c1-0468-4f7d-ab34-ef9348c954be/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0bb641c1-0468-4f7d-ab34-ef9348c954be"
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
PATCH /classification_tables/ee4ad379-5e55-4b0f-8bbc-b851bf7e5d7f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "ee4ad379-5e55-4b0f-8bbc-b851bf7e5d7f",
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
X-Request-Id: 5e56ea9b-d6e0-4ea5-a2bd-0f037b658a0f
200 OK
```


```json
{
  "data": {
    "id": "ee4ad379-5e55-4b0f-8bbc-b851bf7e5d7f",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=ee4ad379-5e55-4b0f-8bbc-b851bf7e5d7f",
          "self": "/classification_tables/ee4ad379-5e55-4b0f-8bbc-b851bf7e5d7f/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ee4ad379-5e55-4b0f-8bbc-b851bf7e5d7f"
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
DELETE /classification_tables/236c5cc6-f8ca-4369-b3aa-871d57eb7cbb
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 661290f1-bc9d-4286-b148-ccce544b04d6
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
POST /classification_tables/32e62c03-fce8-4c6d-b342-6f47af484d23/publish
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
X-Request-Id: ef13cb65-1e3f-4272-a6a5-1453b2d19db9
200 OK
```


```json
{
  "data": {
    "id": "32e62c03-fce8-4c6d-b342-6f47af484d23",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-09T22:52:04.100Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=32e62c03-fce8-4c6d-b342-6f47af484d23",
          "self": "/classification_tables/32e62c03-fce8-4c6d-b342-6f47af484d23/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/32e62c03-fce8-4c6d-b342-6f47af484d23/publish"
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
POST /classification_tables/17785289-e8eb-404d-a420-4472647f61d9/archive
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
X-Request-Id: 78eefa49-018b-46ba-9e07-459f9ddffcfa
200 OK
```


```json
{
  "data": {
    "id": "17785289-e8eb-404d-a420-4472647f61d9",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:52:04.741Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=17785289-e8eb-404d-a420-4472647f61d9",
          "self": "/classification_tables/17785289-e8eb-404d-a420-4472647f61d9/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/17785289-e8eb-404d-a420-4472647f61d9/archive"
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
X-Request-Id: 619d18b6-032c-470f-b580-1d8dff1824ed
201 Created
```


```json
{
  "data": {
    "id": "6a966386-5e08-4eb9-9f26-45d76ab6a9be",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=6a966386-5e08-4eb9-9f26-45d76ab6a9be",
          "self": "/classification_tables/6a966386-5e08-4eb9-9f26-45d76ab6a9be/relationships/classification_entries",
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
POST /classification_entries/964818f3-49eb-4a87-92da-23ee6a0c9c27/relationships/tags
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
X-Request-Id: 0633b9a5-dfa2-443a-b795-ac2df8f5835f
201 Created
```


```json
{
  "data": {
    "id": "bf1cf66a-f969-4699-89e0-fc16b2c7ea91",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/964818f3-49eb-4a87-92da-23ee6a0c9c27/relationships/tags"
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
POST /classification_entries/3ab0bab1-99a2-468d-97f3-ed36299882c9/relationships/tags
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
    "id": "a48d1948-705f-4166-b25a-f0b0dc1e9adf"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f523d208-caa8-49ba-9c38-e93a2e25df16
201 Created
```


```json
{
  "data": {
    "id": "a48d1948-705f-4166-b25a-f0b0dc1e9adf",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5ea40b150651"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/3ab0bab1-99a2-468d-97f3-ed36299882c9/relationships/tags"
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
DELETE /classification_entries/1e27588b-23ca-41d5-b090-5f9feff0ee56/relationships/tags/99b3b62d-8fa3-4654-82bf-a7114f623a18
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f76b7ee7-7132-4e13-bd86-3fe61a571b3c
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
X-Request-Id: 29a0b5f5-68b2-45d0-803f-70e2a3a65666
200 OK
```


```json
{
  "data": [
    {
      "id": "d3bac4f6-883f-4786-963e-274fc4f966aa",
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
            "related": "/classification_entries?filter[classification_entry_id_eq]=d3bac4f6-883f-4786-963e-274fc4f966aa",
            "self": "/classification_entries/d3bac4f6-883f-4786-963e-274fc4f966aa/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "160a79ba-bbbb-4606-85df-c96aaaa87ef5",
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
            "id": "d3bac4f6-883f-4786-963e-274fc4f966aa",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/160a79ba-bbbb-4606-85df-c96aaaa87ef5"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=160a79ba-bbbb-4606-85df-c96aaaa87ef5",
            "self": "/classification_entries/160a79ba-bbbb-4606-85df-c96aaaa87ef5/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "95686860-04aa-4664-a12a-1226bcb38213",
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
            "related": "/classification_entries?filter[classification_entry_id_eq]=95686860-04aa-4664-a12a-1226bcb38213",
            "self": "/classification_entries/95686860-04aa-4664-a12a-1226bcb38213/relationships/classification_entries",
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
GET /classification_entries/917b48da-2838-4787-8d02-9ff444e5a2c6
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
X-Request-Id: 2f6d02ce-a0a7-4699-935e-b828d65328e3
200 OK
```


```json
{
  "data": {
    "id": "917b48da-2838-4787-8d02-9ff444e5a2c6",
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
          "related": "/classification_entries?filter[classification_entry_id_eq]=917b48da-2838-4787-8d02-9ff444e5a2c6",
          "self": "/classification_entries/917b48da-2838-4787-8d02-9ff444e5a2c6/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/917b48da-2838-4787-8d02-9ff444e5a2c6"
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
PATCH /classification_entries/1de0a4d3-579a-450c-a280-77e0e3612c39
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "1de0a4d3-579a-450c-a280-77e0e3612c39",
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
X-Request-Id: 2492b794-f64e-4118-ac09-f787962e49c1
200 OK
```


```json
{
  "data": {
    "id": "1de0a4d3-579a-450c-a280-77e0e3612c39",
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
          "id": "3ed92ca3-a836-40c3-9055-be112f03c87a",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/1de0a4d3-579a-450c-a280-77e0e3612c39"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=1de0a4d3-579a-450c-a280-77e0e3612c39",
          "self": "/classification_entries/1de0a4d3-579a-450c-a280-77e0e3612c39/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/1de0a4d3-579a-450c-a280-77e0e3612c39"
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
DELETE /classification_entries/e9760b86-9b78-49c1-b6ea-1f21dd384ee4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e84aa8c1-2665-40a3-91cf-a8b3740b00ed
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
POST /classification_tables/99227151-ec5d-42cd-bc60-e497aa4c7801/relationships/classification_entries
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
X-Request-Id: 6f75a8fa-c4ac-4d95-a146-a218cc0f5d76
201 Created
```


```json
{
  "data": {
    "id": "73ec17f7-d121-4fb2-801e-821900e41f6f",
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
          "related": "/classification_entries?filter[classification_entry_id_eq]=73ec17f7-d121-4fb2-801e-821900e41f6f",
          "self": "/classification_entries/73ec17f7-d121-4fb2-801e-821900e41f6f/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/99227151-ec5d-42cd-bc60-e497aa4c7801/relationships/classification_entries"
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
X-Request-Id: be03a183-2fcd-430f-acd7-ef38e2650d60
200 OK
```


```json
{
  "data": [
    {
      "id": "967d7255-339b-4614-a0a3-630b73173a4f",
      "type": "syntax",
      "attributes": {
        "account_id": "2c793c74-078b-4afd-8b0a-b4d008999b16",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 31389b6fff0e",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=967d7255-339b-4614-a0a3-630b73173a4f",
            "self": "/syntaxes/967d7255-339b-4614-a0a3-630b73173a4f/relationships/syntax_elements"
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
GET /syntaxes/6960eb91-5290-4343-be55-ebcc57441045
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
X-Request-Id: 7f981886-4963-4613-98f0-101096e7e27d
200 OK
```


```json
{
  "data": {
    "id": "6960eb91-5290-4343-be55-ebcc57441045",
    "type": "syntax",
    "attributes": {
      "account_id": "b37c1b43-724c-4f60-b224-bed3c790b6db",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 15b437140337",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=6960eb91-5290-4343-be55-ebcc57441045",
          "self": "/syntaxes/6960eb91-5290-4343-be55-ebcc57441045/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/6960eb91-5290-4343-be55-ebcc57441045"
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
X-Request-Id: 48a262cf-94e8-4463-ad1b-22130a37e7e0
201 Created
```


```json
{
  "data": {
    "id": "e6454ef8-f35a-4db9-a1be-3beb7d31641e",
    "type": "syntax",
    "attributes": {
      "account_id": "ad85fae5-de23-4dc7-9b0f-5c6ce4151395",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=e6454ef8-f35a-4db9-a1be-3beb7d31641e",
          "self": "/syntaxes/e6454ef8-f35a-4db9-a1be-3beb7d31641e/relationships/syntax_elements"
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
PATCH /syntaxes/fda7f26c-2c73-4afc-a684-c1afee412e8e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "fda7f26c-2c73-4afc-a684-c1afee412e8e",
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
X-Request-Id: 6fec1915-2a95-4846-9639-7aea7afeab8b
200 OK
```


```json
{
  "data": {
    "id": "fda7f26c-2c73-4afc-a684-c1afee412e8e",
    "type": "syntax",
    "attributes": {
      "account_id": "12aeaa39-0d75-4a11-8a39-937e159559c1",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=fda7f26c-2c73-4afc-a684-c1afee412e8e",
          "self": "/syntaxes/fda7f26c-2c73-4afc-a684-c1afee412e8e/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/fda7f26c-2c73-4afc-a684-c1afee412e8e"
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
DELETE /syntaxes/e4ed76d3-c4c8-4610-b39c-8d30a363a123
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 633fa8cb-c5f4-4745-9461-681be50103b0
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
POST /syntaxes/f6991004-7a6b-427c-9e42-5c864bc4ad7c/publish
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
X-Request-Id: 9ff8ad5e-d205-4994-8dc8-7a1d0e1a659b
200 OK
```


```json
{
  "data": {
    "id": "f6991004-7a6b-427c-9e42-5c864bc4ad7c",
    "type": "syntax",
    "attributes": {
      "account_id": "daab41a6-29f5-4859-8f6a-c3b6e5f8c9b8",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax e300bee88b6d",
      "published": true,
      "published_at": "2020-02-09T22:52:16.134Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=f6991004-7a6b-427c-9e42-5c864bc4ad7c",
          "self": "/syntaxes/f6991004-7a6b-427c-9e42-5c864bc4ad7c/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/f6991004-7a6b-427c-9e42-5c864bc4ad7c/publish"
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
POST /syntaxes/ef19adb3-e6ab-4376-8828-2de03441352c/archive
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
X-Request-Id: 68d39568-8ee4-46e4-a0d0-72c6ba096d95
200 OK
```


```json
{
  "data": {
    "id": "ef19adb3-e6ab-4376-8828-2de03441352c",
    "type": "syntax",
    "attributes": {
      "account_id": "7364b280-65bb-4709-af95-c705042ab88b",
      "archived": true,
      "archived_at": "2020-02-09T22:52:16.737Z",
      "description": "Description",
      "name": "Syntax 58639585ce2b",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ef19adb3-e6ab-4376-8828-2de03441352c",
          "self": "/syntaxes/ef19adb3-e6ab-4376-8828-2de03441352c/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ef19adb3-e6ab-4376-8828-2de03441352c/archive"
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
X-Request-Id: 4430c2e4-3bb8-474b-9aba-e005cd9ddda3
200 OK
```


```json
{
  "data": [
    {
      "id": "b893cd88-51f3-4fa9-8d1b-659e8c82bf0c",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "abc3ffcf-068f-4476-8d97-26b8a05d2e1e",
        "hex_color": "fef870",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 0d0122ae1fb4"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/6e17819f-03a7-4b43-b900-dea6b6889e3a"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/abc3ffcf-068f-4476-8d97-26b8a05d2e1e",
            "self": "/syntax_elements/b893cd88-51f3-4fa9-8d1b-659e8c82bf0c/relationships/classification_table"
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
GET /syntax_elements/cf60712d-bfe4-490f-b074-072e72f4df07
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
X-Request-Id: de5d67c4-9fe6-4e51-a8f9-4c7b60ff3498
200 OK
```


```json
{
  "data": {
    "id": "cf60712d-bfe4-490f-b074-072e72f4df07",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "b2656ff5-5974-411d-9274-9a1e2182c45f",
      "hex_color": "2212f9",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element fce70c1e26e5"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/b146d2cf-aa18-494e-b404-3bc8b875e826"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/b2656ff5-5974-411d-9274-9a1e2182c45f",
          "self": "/syntax_elements/cf60712d-bfe4-490f-b074-072e72f4df07/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/cf60712d-bfe4-490f-b074-072e72f4df07"
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
POST /syntaxes/c33bbf40-556c-497a-ba1d-f043f5a92648/relationships/syntax_elements
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
          "id": "d34b4f02-fcf4-4cdc-ad57-1139d8da2cab"
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
X-Request-Id: bc7ec4fd-1f7e-43ae-9881-1a26d76cfc07
201 Created
```


```json
{
  "data": {
    "id": "f95daf4d-1132-451c-af69-5f337a8e6192",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "d34b4f02-fcf4-4cdc-ad57-1139d8da2cab",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/c33bbf40-556c-497a-ba1d-f043f5a92648"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/d34b4f02-fcf4-4cdc-ad57-1139d8da2cab",
          "self": "/syntax_elements/f95daf4d-1132-451c-af69-5f337a8e6192/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/c33bbf40-556c-497a-ba1d-f043f5a92648/relationships/syntax_elements"
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
PATCH /syntax_elements/b18f2dbd-1751-42b9-8870-23ad18813668
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "b18f2dbd-1751-42b9-8870-23ad18813668",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "1b7ad43e-6936-4fd9-a9bb-0a49c975c0c7"
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
X-Request-Id: adc9c276-10a3-4860-9ed1-f7549c4bb1a7
200 OK
```


```json
{
  "data": {
    "id": "b18f2dbd-1751-42b9-8870-23ad18813668",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "1b7ad43e-6936-4fd9-a9bb-0a49c975c0c7",
      "hex_color": "dfb1bb",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/4464b627-6e25-45bb-b429-505433cf929b"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/1b7ad43e-6936-4fd9-a9bb-0a49c975c0c7",
          "self": "/syntax_elements/b18f2dbd-1751-42b9-8870-23ad18813668/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/b18f2dbd-1751-42b9-8870-23ad18813668"
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
DELETE /syntax_elements/354c14a7-fcaa-4a60-9e7c-067d82830744
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0dd3e050-c038-4b17-9ff9-2161a2af9c1e
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
PATCH /syntax_elements/1767a10c-9d06-47e8-b42e-22dd6e5227d9/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "b9e38dc2-df0b-4139-b034-6eecbb895c38",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 84fd6eea-b536-425f-acc0-734e1515469f
200 OK
```


```json
{
  "data": {
    "id": "1767a10c-9d06-47e8-b42e-22dd6e5227d9",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "b9e38dc2-df0b-4139-b034-6eecbb895c38",
      "hex_color": "079930",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element a49ccff8eb44"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e13a20bb-ae91-4e09-83d9-c84ecc9ec587"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/b9e38dc2-df0b-4139-b034-6eecbb895c38",
          "self": "/syntax_elements/1767a10c-9d06-47e8-b42e-22dd6e5227d9/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/1767a10c-9d06-47e8-b42e-22dd6e5227d9/relationships/classification_table"
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
DELETE /syntax_elements/ed08fdd7-9b6d-4299-baa3-a989be4ded21/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 15cdb75c-81db-4527-82d1-2dedc463e56d
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
GET /syntax_nodes/d1b23cc6-8b19-4683-b55c-81d93eb930fa
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
X-Request-Id: 6286771e-aef3-4e01-88c9-0436594200c5
200 OK
```


```json
{
  "data": {
    "id": "d1b23cc6-8b19-4683-b55c-81d93eb930fa",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/a0631e6c-36f6-4465-a4a7-e04bb16b2da2"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/d1b23cc6-8b19-4683-b55c-81d93eb930fa/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/d1b23cc6-8b19-4683-b55c-81d93eb930fa"
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
POST /syntax_nodes/b7482951-19cb-4510-b1e2-821a4be5e09c/relationships/components
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
X-Request-Id: e38588f0-cf1f-414c-925a-e17facd79128
201 Created
```


```json
{
  "data": {
    "id": "a4ebc293-1f33-4db5-af35-c0f57007a79b",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/0b93101c-3c2c-4413-9fa7-3ec6977c4972"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/a4ebc293-1f33-4db5-af35-c0f57007a79b/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/b7482951-19cb-4510-b1e2-821a4be5e09c/relationships/components"
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
PATCH /syntax_nodes/65f9cb27-7e34-4cdd-8edd-65dd8c5b8f8e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "65f9cb27-7e34-4cdd-8edd-65dd8c5b8f8e",
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
X-Request-Id: 05c65416-fa9d-4322-9789-9cc6556449d6
200 OK
```


```json
{
  "data": {
    "id": "65f9cb27-7e34-4cdd-8edd-65dd8c5b8f8e",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/d97a4055-c6c0-4bd2-83bb-3cd8e627d1aa"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/65f9cb27-7e34-4cdd-8edd-65dd8c5b8f8e/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/65f9cb27-7e34-4cdd-8edd-65dd8c5b8f8e"
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
DELETE /syntax_nodes/ef7f8d30-a051-4a59-a749-28e06455acbb
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8fe279e9-eb87-4a9c-b728-f8781e7b7a96
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
X-Request-Id: 03c06a48-68c9-4656-835a-22fa683740ce
200 OK
```


```json
{
  "data": [
    {
      "id": "8f0ae229-4b0c-441f-9957-b6e716768f64",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-09T22:52:23.715Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=8f0ae229-4b0c-441f-9957-b6e716768f64",
            "self": "/progress_models/8f0ae229-4b0c-441f-9957-b6e716768f64/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "abe7e715-b7de-4f37-b2a8-e448a076ee22",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=abe7e715-b7de-4f37-b2a8-e448a076ee22",
            "self": "/progress_models/abe7e715-b7de-4f37-b2a8-e448a076ee22/relationships/progress_steps"
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
GET /progress_models/738d7574-34ba-4080-b1ca-38dd485338f9
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
X-Request-Id: ea90bd1e-7e19-43d4-aa60-14dec70dbb1e
200 OK
```


```json
{
  "data": {
    "id": "738d7574-34ba-4080-b1ca-38dd485338f9",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-09T22:52:24.271Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=738d7574-34ba-4080-b1ca-38dd485338f9",
          "self": "/progress_models/738d7574-34ba-4080-b1ca-38dd485338f9/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/738d7574-34ba-4080-b1ca-38dd485338f9"
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
PATCH /progress_models/23a51190-9957-40e7-9da9-4f2795b9ea1e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "23a51190-9957-40e7-9da9-4f2795b9ea1e",
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
X-Request-Id: 6d1e5d92-d79f-4714-b8ec-dfa7b4f584ad
200 OK
```


```json
{
  "data": {
    "id": "23a51190-9957-40e7-9da9-4f2795b9ea1e",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=23a51190-9957-40e7-9da9-4f2795b9ea1e",
          "self": "/progress_models/23a51190-9957-40e7-9da9-4f2795b9ea1e/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/23a51190-9957-40e7-9da9-4f2795b9ea1e"
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
DELETE /progress_models/3cf508e0-9719-4d6b-86a9-1b5e501bea7e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c14c5290-659e-4292-b56a-290bd14697f6
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
POST /progress_models/2f0ab8b4-3fdc-4a12-82f0-027fb47a5b5b/publish
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
X-Request-Id: 5287e1bd-399f-4604-8105-5cf7a2ac9832
200 OK
```


```json
{
  "data": {
    "id": "2f0ab8b4-3fdc-4a12-82f0-027fb47a5b5b",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-09T22:52:26.494Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=2f0ab8b4-3fdc-4a12-82f0-027fb47a5b5b",
          "self": "/progress_models/2f0ab8b4-3fdc-4a12-82f0-027fb47a5b5b/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/2f0ab8b4-3fdc-4a12-82f0-027fb47a5b5b/publish"
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
POST /progress_models/b1abeeaa-d101-4b39-83d2-031a8f5f4c1d/archive
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
X-Request-Id: 7368aa77-d3fa-4b54-b67a-4694e7c3f20d
200 OK
```


```json
{
  "data": {
    "id": "b1abeeaa-d101-4b39-83d2-031a8f5f4c1d",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:52:27.005Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b1abeeaa-d101-4b39-83d2-031a8f5f4c1d",
          "self": "/progress_models/b1abeeaa-d101-4b39-83d2-031a8f5f4c1d/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/b1abeeaa-d101-4b39-83d2-031a8f5f4c1d/archive"
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
X-Request-Id: f6d057b4-36bc-4589-8434-e13ea7fa94a5
201 Created
```


```json
{
  "data": {
    "id": "f77d28a7-1021-4b02-b864-4293beda0d63",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=f77d28a7-1021-4b02-b864-4293beda0d63",
          "self": "/progress_models/f77d28a7-1021-4b02-b864-4293beda0d63/relationships/progress_steps"
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
X-Request-Id: 098d1136-6f1d-4b66-ae3d-d95b79c1c1d8
200 OK
```


```json
{
  "data": [
    {
      "id": "c1a1e387-e984-4f40-854a-d3a0ac96b21e",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/eb6d69ad-94d4-4daf-94b4-d6e662f6567d"
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
GET /progress_steps/5f654b6f-fc35-4350-bc49-32b2a65f74a5
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
X-Request-Id: aa755a09-7227-4f6e-9bf5-42c2442c2f0e
200 OK
```


```json
{
  "data": {
    "id": "5f654b6f-fc35-4350-bc49-32b2a65f74a5",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/3b7f8ffd-2751-485d-810c-6673d2a56166"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/5f654b6f-fc35-4350-bc49-32b2a65f74a5"
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
PATCH /progress_steps/c981b799-2ef1-4265-803d-1ddf67f93ec5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "c981b799-2ef1-4265-803d-1ddf67f93ec5",
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
X-Request-Id: ce6ab8e7-851e-4ff5-ad27-d7e4defd4fc0
200 OK
```


```json
{
  "data": {
    "id": "c981b799-2ef1-4265-803d-1ddf67f93ec5",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/bb194463-0e59-46e6-a66e-179884f6ffea"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/c981b799-2ef1-4265-803d-1ddf67f93ec5"
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
DELETE /progress_steps/85d0e217-edd7-4811-accd-60eb85433cb6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f0ce6ab8-afb7-486b-a89a-0a6ed39ac5ae
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
POST /progress_models/58914c15-326a-4d4b-993a-061036d05295/relationships/progress_steps
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
X-Request-Id: a5a29da5-af81-46bf-bb60-31f10abe97ec
201 Created
```


```json
{
  "data": {
    "id": "6149f3ed-aae0-41cb-a2b7-0a774ef60958",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/58914c15-326a-4d4b-993a-061036d05295"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/58914c15-326a-4d4b-993a-061036d05295/relationships/progress_steps"
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
X-Request-Id: 3869fb03-89c8-45f9-99a9-d24dcf3efe6b
200 OK
```


```json
{
  "data": [
    {
      "id": "e90c033a-e536-4b1b-9cf5-525a74de9d85",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/5727ab32-9654-45d0-b1eb-d7bd9bcb9270"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/51dc6e81-c3f1-4a9c-8f3a-9f6748d073e8"
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
GET /progress/1ae57e98-53de-4a65-b0ab-7289a549f9d5
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
X-Request-Id: d7d311ad-99db-402e-8746-88ec6bb79fae
200 OK
```


```json
{
  "data": {
    "id": "1ae57e98-53de-4a65-b0ab-7289a549f9d5",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/19e10a80-cbb7-495c-a7ce-34b4c418fe54"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/3df6619f-9ed2-4d6d-9ffb-24ea1dccf5d1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/1ae57e98-53de-4a65-b0ab-7289a549f9d5"
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
DELETE /progress/fe8602b3-9303-49f9-967b-b3f7972e6337
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f433fe48-40e5-4e9f-a143-7815dfa45e95
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
          "id": "73343876-11d4-4cf4-b77a-bc2cce8a859d"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "c1711398-7ab7-4e56-8199-327fa08e1b5f"
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
X-Request-Id: b8b89e55-ccca-404a-8a00-8cf5aa33a703
201 Created
```


```json
{
  "data": {
    "id": "87aa96e0-a91c-4260-aab3-f4d0ea55afe5",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/73343876-11d4-4cf4-b77a-bc2cce8a859d"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/c1711398-7ab7-4e56-8199-327fa08e1b5f"
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
X-Request-Id: 9b75a814-f21b-4b7c-bdba-4f9c1284cec1
200 OK
```


```json
{
  "data": [
    {
      "id": "1f65db3c-e70c-41e9-b233-c145c6216309",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "ee0f4e9b-420c-49be-be37-9075a0f636c4"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/ee0f4e9b-420c-49be-be37-9075a0f636c4"
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
GET /projects/9ffb2c64-93ed-4eac-a721-2eadb25f7a7d/relationships/project_setting
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
X-Request-Id: 69fea327-6924-4cb0-ae61-c6f2c0e9d994
200 OK
```


```json
{
  "data": {
    "id": "6de49b01-15d4-4f65-8a26-36dad9d97baa",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "9ffb2c64-93ed-4eac-a721-2eadb25f7a7d"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/9ffb2c64-93ed-4eac-a721-2eadb25f7a7d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/9ffb2c64-93ed-4eac-a721-2eadb25f7a7d/relationships/project_setting"
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
PATCH /projects/f6a0a692-e10f-4c03-8729-76ae2ce77ebd/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "f6a0a692-e10f-4c03-8729-76ae2ce77ebd",
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
X-Request-Id: 9aa5a770-17f6-4009-bc1c-307acbda63cf
200 OK
```


```json
{
  "data": {
    "id": "0db2b845-937e-49ca-b688-6bdc4a0ff0e8",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "f6a0a692-e10f-4c03-8729-76ae2ce77ebd"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/f6a0a692-e10f-4c03-8729-76ae2ce77ebd"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/f6a0a692-e10f-4c03-8729-76ae2ce77ebd/relationships/project_setting"
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
X-Request-Id: 59940f54-2bc0-48cd-9ac5-9148b3db15bd
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
X-Request-Id: 80f60626-7ddf-4def-9d81-443aa37835c4
200 OK
```


```json
{
  "data": {
    "id": "0e22f6bb-f334-41d1-a7c9-4e560f4a9a71",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "b943cbc1-98c6-46ff-bc75-ce26e695dad1"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/b943cbc1-98c6-46ff-bc75-ce26e695dad1"
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
X-Request-Id: ef372676-4028-4118-8c3b-b2c057423217
200 OK
```


```json
{
  "data": {
    "id": "bb5cfb20-f7c6-4fdd-a79c-1f3322493cd9",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "2587ac74-b323-428e-8353-073f634ed525"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/2587ac74-b323-428e-8353-073f634ed525"
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

<aside class="warning">
  We only support this endpoint for <code>from_type</code> and <code>to_type</code> which are
  stored in the Neo4j database. We're currently working on making this available for all data
  types.
</aside>


## Look up path


### Request

#### Endpoint

```plaintext
GET /utils/path/from/object_occurrence/3b0ae128-5187-4e34-bc76-94bd2e5ca748/to/object_occurrence/40192a04-35d3-42a7-b61d-9f8dbae94c8a
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
X-Request-Id: 4f1a7199-ecae-41df-ae78-eb037c8c1fd3
200 OK
```


```json
[
  {
    "id": "3b0ae128-5187-4e34-bc76-94bd2e5ca748",
    "type": "object_occurrence"
  },
  {
    "id": "8c75c9bf-d5d4-442f-8aba-5c519356ad96",
    "type": "object_occurrence"
  },
  {
    "id": "e0f06572-34a3-40ed-956e-7444869c6b8b",
    "type": "object_occurrence"
  },
  {
    "id": "6751cc19-2543-474c-b3f2-9cf90b14c8d6",
    "type": "object_occurrence"
  },
  {
    "id": "6b102aad-3789-417c-b6ec-fd6a64815bd1",
    "type": "object_occurrence"
  },
  {
    "id": "32aeb789-8dc2-4502-89bf-1c72dff2cd81",
    "type": "object_occurrence"
  },
  {
    "id": "40192a04-35d3-42a7-b61d-9f8dbae94c8a",
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
X-Request-Id: 0afa8e9b-d605-4a7c-9418-7e85d603794a
200 OK
```


```json
{
  "data": [
    {
      "id": "d149f256-41b5-40ce-8c7a-3699a24f9000",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/ce78e3a5-a185-4637-b3a6-215a9f9c8670"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/7299ceea-dd35-4451-8eef-51330b8add0a"
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
X-Request-Id: 26aad2ca-21af-4a93-b225-6511e1fc47b1
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



