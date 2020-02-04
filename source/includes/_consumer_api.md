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
X-Request-Id: a8286f38-3dc7-499a-a68f-0c9db47a30cf
200 OK
```


```json
{
  "data": {
    "id": "2f903dfe-1388-49ff-9349-02a84d086698",
    "type": "account",
    "attributes": {
      "name": "Account 1a7b82da0e28"
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
    "id": "479c6bb5-e346-4ab5-8dc5-7c3c130e996a",
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
X-Request-Id: 5574999e-0c20-45d7-b59f-69d66c816794
200 OK
```


```json
{
  "data": {
    "id": "479c6bb5-e346-4ab5-8dc5-7c3c130e996a",
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
POST /projects/a490c6a9-aea1-411a-820b-71b6b7efce91/relationships/tags
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
X-Request-Id: abe47d3d-34ff-49e4-8970-81030473f8a8
201 Created
```


```json
{
  "data": {
    "id": "cdbf3ca9-f974-4883-92d4-aa6704d8d121",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/a490c6a9-aea1-411a-820b-71b6b7efce91/relationships/tags"
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
POST /projects/f0184a59-96fb-4e75-be03-94379b76db3d/relationships/tags
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
    "id": "e10616d2-7259-4898-b6ea-991057e33b85"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b38e89bc-f7f6-460a-938d-c12d15592251
201 Created
```


```json
{
  "data": {
    "id": "e10616d2-7259-4898-b6ea-991057e33b85",
    "type": "tag",
    "attributes": {
      "value": "Tag value 215e697ac493"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/f0184a59-96fb-4e75-be03-94379b76db3d/relationships/tags"
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
DELETE /projects/b9ccf99f-8117-42bb-be7f-f1403f94ad0b/relationships/tags/1254d719-17e3-4bdc-8fd5-d7e1c8afa9fa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c7e715cf-1500-429e-ae9b-61205b0e1aa2
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
X-Request-Id: 93a9e05e-d0b9-43ad-bfb2-086bc39d9255
200 OK
```


```json
{
  "data": [
    {
      "id": "f58b581a-6f84-4e45-be44-7a536c3f2266",
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
            "related": "/contexts?filter[project_id_eq]=f58b581a-6f84-4e45-be44-7a536c3f2266",
            "self": "/projects/f58b581a-6f84-4e45-be44-7a536c3f2266/relationships/contexts"
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
GET /projects/e98e7526-4126-48b8-9faf-cd1f0ce1c605
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
X-Request-Id: 397c63e9-7452-4855-a09f-1486b18383f5
200 OK
```


```json
{
  "data": {
    "id": "e98e7526-4126-48b8-9faf-cd1f0ce1c605",
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
          "related": "/contexts?filter[project_id_eq]=e98e7526-4126-48b8-9faf-cd1f0ce1c605",
          "self": "/projects/e98e7526-4126-48b8-9faf-cd1f0ce1c605/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/e98e7526-4126-48b8-9faf-cd1f0ce1c605"
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
PATCH /projects/17f20c5c-9e36-4d22-8137-132c86f4b4db
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "17f20c5c-9e36-4d22-8137-132c86f4b4db",
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
X-Request-Id: bbbc3536-e69d-4cec-bc5b-413ad696beba
200 OK
```


```json
{
  "data": {
    "id": "17f20c5c-9e36-4d22-8137-132c86f4b4db",
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
          "related": "/contexts?filter[project_id_eq]=17f20c5c-9e36-4d22-8137-132c86f4b4db",
          "self": "/projects/17f20c5c-9e36-4d22-8137-132c86f4b4db/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/17f20c5c-9e36-4d22-8137-132c86f4b4db"
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
POST /projects/338a5ef8-708e-4d40-b2db-4e60ca13acca/archive
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
X-Request-Id: 53768498-3c07-4873-9023-ecc99e34267b
200 OK
```


```json
{
  "data": {
    "id": "338a5ef8-708e-4d40-b2db-4e60ca13acca",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-04T20:53:00.157Z",
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
          "related": "/contexts?filter[project_id_eq]=338a5ef8-708e-4d40-b2db-4e60ca13acca",
          "self": "/projects/338a5ef8-708e-4d40-b2db-4e60ca13acca/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/338a5ef8-708e-4d40-b2db-4e60ca13acca/archive"
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
DELETE /projects/ea0d12cf-5e2b-466b-b2ba-353c5acc8ce4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8e82f046-f392-462b-822f-a271ceeb6079
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
POST /contexts/dc718e32-3e69-44cf-b25d-1e980dcc6e78/relationships/tags
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
X-Request-Id: 8d59a8a5-4871-4425-842d-938fc8f8f11a
201 Created
```


```json
{
  "data": {
    "id": "2b5d8d66-3aa6-4219-9495-1d513a9ea7b6",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/dc718e32-3e69-44cf-b25d-1e980dcc6e78/relationships/tags"
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
POST /contexts/3e835949-5e7e-4f19-97fd-1067ccd69f4a/relationships/tags
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
    "id": "55efdad8-8d61-4240-950e-f2c3892a75a1"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7b2c12b0-2a11-4d36-a3ce-ba717531bc6a
201 Created
```


```json
{
  "data": {
    "id": "55efdad8-8d61-4240-950e-f2c3892a75a1",
    "type": "tag",
    "attributes": {
      "value": "Tag value 0229e90c671a"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/3e835949-5e7e-4f19-97fd-1067ccd69f4a/relationships/tags"
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
DELETE /contexts/6dab637a-9005-4f72-b3f4-6a2663a2a3d1/relationships/tags/bf4eb9ac-b953-40ba-a603-1f6dbc7f8f4e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 301828d5-8d98-48a0-9e40-bebf1b540169
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
X-Request-Id: 9c1b5fc6-ecc5-48a2-ad71-c513c27dad19
200 OK
```


```json
{
  "data": [
    {
      "id": "af44488d-08bd-4933-b0a2-1891f23ea67e",
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
            "related": "/projects/68eeb697-64b8-419b-9a82-65dd4501bcbf"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/a1f4ea02-7914-44b4-8080-b7f52a9c5187"
          }
        }
      }
    },
    {
      "id": "1c5c5eb8-e8ff-42cb-991e-075f1227779a",
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
            "related": "/projects/68eeb697-64b8-419b-9a82-65dd4501bcbf"
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
GET /contexts/78034d82-4146-4bbc-b636-98da234afbd1
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
X-Request-Id: 43a2ead4-7ea4-4065-9206-ee246e0b0366
200 OK
```


```json
{
  "data": {
    "id": "78034d82-4146-4bbc-b636-98da234afbd1",
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
          "related": "/projects/41c33dc4-4e24-4d4a-aba2-39e1f1592c00"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/572e02e7-0fce-437a-8e3a-16a4ca48bddd"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/78034d82-4146-4bbc-b636-98da234afbd1"
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
PATCH /contexts/6338bc33-5c92-45b6-b6c1-f1d254db236f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "6338bc33-5c92-45b6-b6c1-f1d254db236f",
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
X-Request-Id: e6bd6891-d6e6-49d8-812b-dd448b0873ce
200 OK
```


```json
{
  "data": {
    "id": "6338bc33-5c92-45b6-b6c1-f1d254db236f",
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
          "related": "/projects/4ce2470a-18ad-4231-8e33-1f335724b8b6"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/4a39fd1e-84e6-4f79-8056-fe48e55eb72e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/6338bc33-5c92-45b6-b6c1-f1d254db236f"
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
POST /projects/07f8cc10-eb7c-4e1b-ba45-1ed10814bb4d/relationships/contexts
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
X-Request-Id: 935ef6be-e61c-4282-a190-bfe54f5911c4
201 Created
```


```json
{
  "data": {
    "id": "ba04eeaa-6ddc-4e03-884b-b6ee79beb05f",
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
          "related": "/projects/07f8cc10-eb7c-4e1b-ba45-1ed10814bb4d"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/4a58ad43-a253-4ec6-ac09-c2aea4ffc180"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/07f8cc10-eb7c-4e1b-ba45-1ed10814bb4d/relationships/contexts"
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
POST /contexts/e97b0f83-331e-4da7-8c17-99f5b4b92825/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/2f6ca169e6606a3eb816c514
Content-Type: text/html; charset=utf-8
X-Request-Id: e8fc1fa3-1aa7-430a-87a7-135835d749d5
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/2f6ca169e6606a3eb816c514">redirected</a>.</body></html>
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
DELETE /contexts/c97c22e0-3657-4973-8028-e7cdc776bb7d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1dc1eab3-140b-4230-b25a-550f41c5bc20
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
POST /object_occurrences/695e50aa-1372-49c8-b749-cccf407dee9e/relationships/tags
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
X-Request-Id: 9d8e6f3b-a4db-4f6d-bcf7-b21b16389e8a
201 Created
```


```json
{
  "data": {
    "id": "7c6b8f68-16d1-42e7-8cac-fa0d8e5b6955",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/695e50aa-1372-49c8-b749-cccf407dee9e/relationships/tags"
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
POST /object_occurrences/dde12e80-1cc1-4fc2-8098-41888d3df5f6/relationships/tags
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
    "id": "1b41725b-d094-403b-9247-d351a9ba45f4"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1e32d3dc-a0b7-4b48-a887-6c64b76fb8bd
201 Created
```


```json
{
  "data": {
    "id": "1b41725b-d094-403b-9247-d351a9ba45f4",
    "type": "tag",
    "attributes": {
      "value": "Tag value a5b829d4e68f"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/dde12e80-1cc1-4fc2-8098-41888d3df5f6/relationships/tags"
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
DELETE /object_occurrences/6051cd87-e369-4017-9209-99e0db9f7d71/relationships/tags/3565c7c8-4629-49a1-b863-21126ebcb969
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f1a7178c-45ec-4ffa-9351-e378c699d179
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
GET /object_occurrences/68a3592c-f5c7-4325-b555-e33c981fe121
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
X-Request-Id: acbb92fa-7089-4657-89ba-d6d7e8f94c23
200 OK
```


```json
{
  "data": {
    "id": "68a3592c-f5c7-4325-b555-e33c981fe121",
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
          "related": "/contexts/a48b458d-3047-4833-90b4-62215a7d3763"
        }
      },
      "components": {
        "data": [
          {
            "id": "68a6662b-bae6-4ff4-9f59-0927979d7b01",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/68a3592c-f5c7-4325-b555-e33c981fe121/relationships/components"
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
    "self": "http://example.org/object_occurrences/68a3592c-f5c7-4325-b555-e33c981fe121"
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
POST /object_occurrences/1140f8f4-74b9-4141-baa1-a53aafc3f599/relationships/components
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
X-Request-Id: 5b542a64-7ed0-4875-a579-ac99c191c147
201 Created
```


```json
{
  "data": {
    "id": "12daaf5d-ab07-496d-b9f0-13ba9da1616a",
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
          "related": "/contexts/2103d731-3552-4dee-982e-2484715513b9"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/1140f8f4-74b9-4141-baa1-a53aafc3f599",
          "self": "/object_occurrences/12daaf5d-ab07-496d-b9f0-13ba9da1616a/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/12daaf5d-ab07-496d-b9f0-13ba9da1616a/relationships/components"
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
    "self": "http://example.org/object_occurrences/1140f8f4-74b9-4141-baa1-a53aafc3f599/relationships/components"
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
PATCH /object_occurrences/60a325bf-9e25-4f0d-9142-0e3fbefe0404
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "60a325bf-9e25-4f0d-9142-0e3fbefe0404",
    "type": "object_occurrence",
    "attributes": {
      "name": "New name"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "f0a51236-98d9-4558-aed2-f20d32cb9f34"
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
X-Request-Id: 280d52e3-faab-48ce-afd3-69460993b807
200 OK
```


```json
{
  "data": {
    "id": "60a325bf-9e25-4f0d-9142-0e3fbefe0404",
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
          "related": "/contexts/6ff0d804-6d75-4975-986f-7568bb7f0ba2"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/f0a51236-98d9-4558-aed2-f20d32cb9f34",
          "self": "/object_occurrences/60a325bf-9e25-4f0d-9142-0e3fbefe0404/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/60a325bf-9e25-4f0d-9142-0e3fbefe0404/relationships/components"
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
    "self": "http://example.org/object_occurrences/60a325bf-9e25-4f0d-9142-0e3fbefe0404"
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
POST /object_occurrences/68376e4f-9125-48bd-8599-8fcb8dbd7363/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "45dba045-4e85-49e6-afb8-858571c2d4b7",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/a7c47db66f6b7b94279c75a7
Content-Type: text/html; charset=utf-8
X-Request-Id: 427a82b8-22a6-4a34-9c97-854276696042
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/a7c47db66f6b7b94279c75a7">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/630280b3-5f5d-40b3-8c12-16ff0bab88da
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 80cfb51b-67bb-4fe2-abc7-5a5df573d1dd
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
PATCH /object_occurrences/2a447917-cfe2-49fe-b4c1-3fd1ce1ea393/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "8a59f5d6-5ecf-45ba-9a78-3b9d8f80a691",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 50cd715e-c37d-41d8-8c21-b1a4428c1363
200 OK
```


```json
{
  "data": {
    "id": "2a447917-cfe2-49fe-b4c1-3fd1ce1ea393",
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
          "related": "/contexts/a418a255-059f-4f20-ac5d-aeae6ae002dd"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/8a59f5d6-5ecf-45ba-9a78-3b9d8f80a691",
          "self": "/object_occurrences/2a447917-cfe2-49fe-b4c1-3fd1ce1ea393/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/2a447917-cfe2-49fe-b4c1-3fd1ce1ea393/relationships/components"
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
    "self": "http://example.org/object_occurrences/2a447917-cfe2-49fe-b4c1-3fd1ce1ea393/relationships/part_of"
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
POST /classification_tables/ad38301d-9116-4ea2-92b0-040e11469d6b/relationships/tags
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
X-Request-Id: be3b21a2-5777-4ece-a46b-476a82b5aac3
201 Created
```


```json
{
  "data": {
    "id": "c5863b00-dc6e-409d-9f41-c5720b51b659",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ad38301d-9116-4ea2-92b0-040e11469d6b/relationships/tags"
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
POST /classification_tables/979bc89f-f376-4581-9869-e94fc6a9c5a6/relationships/tags
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
    "id": "d84028ab-4b2b-43d8-8ca6-aa26094813ad"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a91aae46-b24a-4135-8935-f524becd4762
201 Created
```


```json
{
  "data": {
    "id": "d84028ab-4b2b-43d8-8ca6-aa26094813ad",
    "type": "tag",
    "attributes": {
      "value": "Tag value 12296bcbc73f"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/979bc89f-f376-4581-9869-e94fc6a9c5a6/relationships/tags"
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
DELETE /classification_tables/39c1f194-ccc9-4a2f-b299-efbe5678f333/relationships/tags/60ed57e9-5d08-4563-86d6-92b3b3b4acaa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9dd4595f-2894-4132-a64f-a65ce5f0c33e
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
| filter[archived]  | filter by archived flag |
| filter[published]  | filter by published flag |
| filter[name_eq]  | filter by name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fa5a33a4-57b0-4eeb-9e69-df15b7a23a11
200 OK
```


```json
{
  "data": [
    {
      "id": "bb60198e-aeb1-4b73-b89f-5a692cc2e0db",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=bb60198e-aeb1-4b73-b89f-5a692cc2e0db",
            "self": "/classification_tables/bb60198e-aeb1-4b73-b89f-5a692cc2e0db/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "eda4b2a5-f2dd-4134-943d-2b7d72f73d56",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=eda4b2a5-f2dd-4134-943d-2b7d72f73d56",
            "self": "/classification_tables/eda4b2a5-f2dd-4134-943d-2b7d72f73d56/relationships/classification_entries"
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
GET /classification_tables/303ced92-f602-4f58-a98e-f3e609e8878a
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
X-Request-Id: c9d54716-d60f-4b6c-b21e-93ea6f57dc45
200 OK
```


```json
{
  "data": {
    "id": "303ced92-f602-4f58-a98e-f3e609e8878a",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=303ced92-f602-4f58-a98e-f3e609e8878a",
          "self": "/classification_tables/303ced92-f602-4f58-a98e-f3e609e8878a/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/303ced92-f602-4f58-a98e-f3e609e8878a"
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
PATCH /classification_tables/da8049c8-9cb7-4d9c-87e1-1fa54c8a9f29
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "da8049c8-9cb7-4d9c-87e1-1fa54c8a9f29",
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
X-Request-Id: 5bf4178d-9a3b-4d54-bf78-af3351f4278c
200 OK
```


```json
{
  "data": {
    "id": "da8049c8-9cb7-4d9c-87e1-1fa54c8a9f29",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=da8049c8-9cb7-4d9c-87e1-1fa54c8a9f29",
          "self": "/classification_tables/da8049c8-9cb7-4d9c-87e1-1fa54c8a9f29/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/da8049c8-9cb7-4d9c-87e1-1fa54c8a9f29"
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
DELETE /classification_tables/36364a09-2094-47ab-8418-015581e24f85
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f73c2362-5e47-4c89-9464-fb3c5a8a4903
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
POST /classification_tables/404bb6a4-07df-45dd-b56e-5001a32031ff/publish
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
X-Request-Id: ae8775a6-1847-4a49-853d-9719e3e66ec1
200 OK
```


```json
{
  "data": {
    "id": "404bb6a4-07df-45dd-b56e-5001a32031ff",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-04T20:53:15.191Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=404bb6a4-07df-45dd-b56e-5001a32031ff",
          "self": "/classification_tables/404bb6a4-07df-45dd-b56e-5001a32031ff/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/404bb6a4-07df-45dd-b56e-5001a32031ff/publish"
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
POST /classification_tables/61734880-0211-4413-a000-b2a67610241f/archive
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
X-Request-Id: f5ce19d5-bca0-4284-aec8-88147ec0fd10
200 OK
```


```json
{
  "data": {
    "id": "61734880-0211-4413-a000-b2a67610241f",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-04T20:53:15.556Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=61734880-0211-4413-a000-b2a67610241f",
          "self": "/classification_tables/61734880-0211-4413-a000-b2a67610241f/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/61734880-0211-4413-a000-b2a67610241f/archive"
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
X-Request-Id: dffbf44e-a2fd-4b1a-9fe9-6a07c4e949d7
201 Created
```


```json
{
  "data": {
    "id": "a3d55eba-5b76-4d9f-be9b-abef5c613724",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=a3d55eba-5b76-4d9f-be9b-abef5c613724",
          "self": "/classification_tables/a3d55eba-5b76-4d9f-be9b-abef5c613724/relationships/classification_entries"
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
POST /classification_entries/fa04f89f-76d9-4ae6-89f1-628c8afcf8c6/relationships/tags
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
X-Request-Id: e6263bbd-b0e2-48b8-be1d-dded22ac22bc
201 Created
```


```json
{
  "data": {
    "id": "d1cb25d1-4dbe-492c-8b80-b8c367369df9",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/fa04f89f-76d9-4ae6-89f1-628c8afcf8c6/relationships/tags"
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
POST /classification_entries/c951fcfc-20f8-4feb-b191-dda9d54e19c4/relationships/tags
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
    "id": "786ba70f-f5d1-4f90-9127-97e075ff6d5b"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1d5fbeca-92a9-4fd2-b2ea-2073ae8e6dbb
201 Created
```


```json
{
  "data": {
    "id": "786ba70f-f5d1-4f90-9127-97e075ff6d5b",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1b39bc9d418b"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/c951fcfc-20f8-4feb-b191-dda9d54e19c4/relationships/tags"
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
DELETE /classification_entries/09a71419-bcca-4a68-a74e-3574a4de47d9/relationships/tags/27bd13e4-dece-4c8e-b8cd-63dd6f6fc3d7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5fb2b5dd-feea-4282-87db-48d444348995
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
X-Request-Id: dbe1e077-4e99-4096-b19d-f7104f48f4ea
200 OK
```


```json
{
  "data": [
    {
      "id": "0b5b077e-3a8e-4482-be56-8fa01625efdd",
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
            "related": "/classification_entries?filter[classification_entry_id_eq]=0b5b077e-3a8e-4482-be56-8fa01625efdd",
            "self": "/classification_entries/0b5b077e-3a8e-4482-be56-8fa01625efdd/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "3790ff5f-c4e5-4453-9de1-ea7924ad03b0",
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
            "id": "0b5b077e-3a8e-4482-be56-8fa01625efdd",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/3790ff5f-c4e5-4453-9de1-ea7924ad03b0"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=3790ff5f-c4e5-4453-9de1-ea7924ad03b0",
            "self": "/classification_entries/3790ff5f-c4e5-4453-9de1-ea7924ad03b0/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "98c24a76-1aee-4e03-ba51-4d485eb29764",
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
            "related": "/classification_entries?filter[classification_entry_id_eq]=98c24a76-1aee-4e03-ba51-4d485eb29764",
            "self": "/classification_entries/98c24a76-1aee-4e03-ba51-4d485eb29764/relationships/classification_entries"
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
GET /classification_entries/bfa69e59-3ec3-40c8-a638-0f5bf97c4d3a
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
X-Request-Id: 143d47d3-b83f-4b72-9572-6572db24f563
200 OK
```


```json
{
  "data": {
    "id": "bfa69e59-3ec3-40c8-a638-0f5bf97c4d3a",
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
          "related": "/classification_entries?filter[classification_entry_id_eq]=bfa69e59-3ec3-40c8-a638-0f5bf97c4d3a",
          "self": "/classification_entries/bfa69e59-3ec3-40c8-a638-0f5bf97c4d3a/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/bfa69e59-3ec3-40c8-a638-0f5bf97c4d3a"
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
PATCH /classification_entries/80ea845a-ed43-4515-b91b-e0bdc7cc8e8b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "80ea845a-ed43-4515-b91b-e0bdc7cc8e8b",
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
X-Request-Id: 0d178e13-f0ae-46b6-9422-8a4de977ceba
200 OK
```


```json
{
  "data": {
    "id": "80ea845a-ed43-4515-b91b-e0bdc7cc8e8b",
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
          "id": "47eac173-e363-4479-bbee-c4d974dd3f23",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/80ea845a-ed43-4515-b91b-e0bdc7cc8e8b"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=80ea845a-ed43-4515-b91b-e0bdc7cc8e8b",
          "self": "/classification_entries/80ea845a-ed43-4515-b91b-e0bdc7cc8e8b/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/80ea845a-ed43-4515-b91b-e0bdc7cc8e8b"
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
DELETE /classification_entries/e9dc4174-47fa-4e80-9063-0d6e4ca2f683
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4ab47418-d251-4508-8ac4-6cd2180597a5
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
POST /classification_tables/a90291c5-a3d4-4b6c-a798-47753254ea5a/relationships/classification_entries
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
X-Request-Id: 5d0df4c1-3fde-4fea-a564-0381ce80a34d
201 Created
```


```json
{
  "data": {
    "id": "8fbca7d0-0c51-4af7-be96-8a6f920a6efc",
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
          "related": "/classification_entries?filter[classification_entry_id_eq]=8fbca7d0-0c51-4af7-be96-8a6f920a6efc",
          "self": "/classification_entries/8fbca7d0-0c51-4af7-be96-8a6f920a6efc/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a90291c5-a3d4-4b6c-a798-47753254ea5a/relationships/classification_entries"
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
X-Request-Id: b9a0ce7c-6a5f-4f52-a554-75a41d9e105c
200 OK
```


```json
{
  "data": [
    {
      "id": "3779fc41-2fe8-40fd-8988-93743f48824e",
      "type": "syntax",
      "attributes": {
        "account_id": "4a859104-87f1-4f53-a3cf-82792a4e4295",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 4daa159fedfc",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=3779fc41-2fe8-40fd-8988-93743f48824e",
            "self": "/syntaxes/3779fc41-2fe8-40fd-8988-93743f48824e/relationships/syntax_elements"
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
GET /syntaxes/37024945-941d-44ae-9806-19a0743e88b3
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
X-Request-Id: 09c198ef-b1e4-47fb-a9b1-c5b19e86ea3a
200 OK
```


```json
{
  "data": {
    "id": "37024945-941d-44ae-9806-19a0743e88b3",
    "type": "syntax",
    "attributes": {
      "account_id": "bf7f5b35-1fa5-48a7-b7a7-fa455c84cc33",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax b914c2fd0e5c",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=37024945-941d-44ae-9806-19a0743e88b3",
          "self": "/syntaxes/37024945-941d-44ae-9806-19a0743e88b3/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/37024945-941d-44ae-9806-19a0743e88b3"
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
X-Request-Id: 0a38dfb0-8019-4254-a528-b19bac53fdfa
201 Created
```


```json
{
  "data": {
    "id": "55b34d7c-1d00-40fe-951e-ef4e48421257",
    "type": "syntax",
    "attributes": {
      "account_id": "f1a2428e-0fc7-41d7-90e6-215086786a72",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=55b34d7c-1d00-40fe-951e-ef4e48421257",
          "self": "/syntaxes/55b34d7c-1d00-40fe-951e-ef4e48421257/relationships/syntax_elements"
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
PATCH /syntaxes/30d752de-db0f-4479-bf42-5f96b2c9bcf2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "30d752de-db0f-4479-bf42-5f96b2c9bcf2",
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
X-Request-Id: abdaccb4-5060-4be9-8f97-7424d3b29b69
200 OK
```


```json
{
  "data": {
    "id": "30d752de-db0f-4479-bf42-5f96b2c9bcf2",
    "type": "syntax",
    "attributes": {
      "account_id": "08bfeec0-db6c-46a8-b2f2-d07f38aa08d0",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=30d752de-db0f-4479-bf42-5f96b2c9bcf2",
          "self": "/syntaxes/30d752de-db0f-4479-bf42-5f96b2c9bcf2/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/30d752de-db0f-4479-bf42-5f96b2c9bcf2"
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
DELETE /syntaxes/9c76f686-5e6a-447a-817b-4b12fc99a5aa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 65ff68f4-eec8-4c26-8476-9780dfe64639
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
POST /syntaxes/a858a045-e7fe-4f3e-9dc8-c50ea826c519/publish
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
X-Request-Id: 69d4376f-30a2-425c-aa97-f50a6520a2b5
200 OK
```


```json
{
  "data": {
    "id": "a858a045-e7fe-4f3e-9dc8-c50ea826c519",
    "type": "syntax",
    "attributes": {
      "account_id": "47cde143-73a5-47f6-a592-ce707fa527e6",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 4b32830d1701",
      "published": true,
      "published_at": "2020-02-04T20:53:23.425Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=a858a045-e7fe-4f3e-9dc8-c50ea826c519",
          "self": "/syntaxes/a858a045-e7fe-4f3e-9dc8-c50ea826c519/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/a858a045-e7fe-4f3e-9dc8-c50ea826c519/publish"
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
POST /syntaxes/86baf046-85a4-492d-8dc3-c956494a50e1/archive
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
X-Request-Id: 708416bf-17e1-4406-882e-deb5b316fa21
200 OK
```


```json
{
  "data": {
    "id": "86baf046-85a4-492d-8dc3-c956494a50e1",
    "type": "syntax",
    "attributes": {
      "account_id": "0854cb66-795d-4a79-8108-7ac96fc5c057",
      "archived": true,
      "archived_at": "2020-02-04T20:53:23.757Z",
      "description": "Description",
      "name": "Syntax 0aa335ae8362",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=86baf046-85a4-492d-8dc3-c956494a50e1",
          "self": "/syntaxes/86baf046-85a4-492d-8dc3-c956494a50e1/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/86baf046-85a4-492d-8dc3-c956494a50e1/archive"
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
X-Request-Id: cee25772-0401-4027-9d19-7b540e2a5e07
200 OK
```


```json
{
  "data": [
    {
      "id": "6820ce8a-d38b-4ae3-ae7b-069314943a12",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "22ec277f-0dec-4d63-82e9-4abc2b82d535",
        "hex_color": "f53895",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 92030ccf75c8"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/6e173c7f-bc71-4086-becd-d374bfce39bb"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/22ec277f-0dec-4d63-82e9-4abc2b82d535",
            "self": "/syntax_elements/6820ce8a-d38b-4ae3-ae7b-069314943a12/relationships/classification_table"
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
GET /syntax_elements/abb54062-d3ad-4b7d-a3db-f4bc17e9afff
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
X-Request-Id: 8765277d-2fdd-41c8-ac84-ea927adfd92d
200 OK
```


```json
{
  "data": {
    "id": "abb54062-d3ad-4b7d-a3db-f4bc17e9afff",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "45e522d5-bead-40c8-977b-9c6359e3006d",
      "hex_color": "bff5bc",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 02187c88bc9a"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/336c1d97-6b5f-49b9-ab9d-81bc752d66d0"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/45e522d5-bead-40c8-977b-9c6359e3006d",
          "self": "/syntax_elements/abb54062-d3ad-4b7d-a3db-f4bc17e9afff/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/abb54062-d3ad-4b7d-a3db-f4bc17e9afff"
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
POST /syntaxes/25104b11-08d3-41d5-86a9-708a3aba85c8/relationships/syntax_elements
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
          "id": "a431fb85-9579-49fc-a760-1376dd41bc9f"
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
X-Request-Id: a1b01a69-b129-4aeb-b6fd-0ec5338c7dda
201 Created
```


```json
{
  "data": {
    "id": "538028e5-758b-4893-a6cc-a525ae587d74",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "a431fb85-9579-49fc-a760-1376dd41bc9f",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/25104b11-08d3-41d5-86a9-708a3aba85c8"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/a431fb85-9579-49fc-a760-1376dd41bc9f",
          "self": "/syntax_elements/538028e5-758b-4893-a6cc-a525ae587d74/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/25104b11-08d3-41d5-86a9-708a3aba85c8/relationships/syntax_elements"
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
PATCH /syntax_elements/c7bc40bb-91e5-4e9d-b4d7-178221872a85
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "c7bc40bb-91e5-4e9d-b4d7-178221872a85",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "4e15772d-d3d5-4c84-b8ec-f8697a2bcf5d"
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
X-Request-Id: 3a640f24-18f4-4aef-b4ba-55be1572ffef
200 OK
```


```json
{
  "data": {
    "id": "c7bc40bb-91e5-4e9d-b4d7-178221872a85",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "4e15772d-d3d5-4c84-b8ec-f8697a2bcf5d",
      "hex_color": "438a13",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e4636050-bc27-4814-94df-c86e6493cc1b"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/4e15772d-d3d5-4c84-b8ec-f8697a2bcf5d",
          "self": "/syntax_elements/c7bc40bb-91e5-4e9d-b4d7-178221872a85/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/c7bc40bb-91e5-4e9d-b4d7-178221872a85"
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
DELETE /syntax_elements/43db9d35-8ddd-47f4-b842-45ead4d07986
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 958e9d51-41a9-48e8-a479-31159652947a
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
PATCH /syntax_elements/c707343d-715c-49cf-ad80-8564cb7f05e5/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "7d39cbff-ec43-4818-aa6a-ca0d17d32a8d",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 963ee31b-ff10-4fbe-b4f6-10b6682b24c8
200 OK
```


```json
{
  "data": {
    "id": "c707343d-715c-49cf-ad80-8564cb7f05e5",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "7d39cbff-ec43-4818-aa6a-ca0d17d32a8d",
      "hex_color": "fbd687",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element c8cce3f1b178"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/5e4552b0-4f45-4b14-bf74-cee6a6a0591a"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/7d39cbff-ec43-4818-aa6a-ca0d17d32a8d",
          "self": "/syntax_elements/c707343d-715c-49cf-ad80-8564cb7f05e5/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/c707343d-715c-49cf-ad80-8564cb7f05e5/relationships/classification_table"
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
DELETE /syntax_elements/dede833f-0594-48a5-8f8d-aa0e777cdcaa/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2af1aa98-9d0e-432f-90d7-6354248c0789
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
GET /syntax_nodes/20c9fb9d-d27a-4055-8a7e-3b400a309187
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
X-Request-Id: 12ed1e4e-e0d0-478b-80cc-8f9deea81588
200 OK
```


```json
{
  "data": {
    "id": "20c9fb9d-d27a-4055-8a7e-3b400a309187",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/baa8b1bd-35c0-47b0-bff6-4279dbeb2cc7"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/20c9fb9d-d27a-4055-8a7e-3b400a309187/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/20c9fb9d-d27a-4055-8a7e-3b400a309187"
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
POST /syntax_nodes/fb1bd6c4-3d9c-4c62-81a1-dc195239ecba/relationships/components
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
X-Request-Id: 31be6a43-dfed-4f58-b347-d22a4a495977
201 Created
```


```json
{
  "data": {
    "id": "59fc05bc-4220-4e4a-8d7c-86e6c6cb4ccc",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/7bb7af18-d292-4773-aa81-c74c0dd524bd"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/59fc05bc-4220-4e4a-8d7c-86e6c6cb4ccc/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/fb1bd6c4-3d9c-4c62-81a1-dc195239ecba/relationships/components"
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
PATCH /syntax_nodes/351c18e8-6a8d-4b3d-9541-081672b7905d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "351c18e8-6a8d-4b3d-9541-081672b7905d",
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
X-Request-Id: 706761ea-886b-4063-a85b-970c50a4a2c1
200 OK
```


```json
{
  "data": {
    "id": "351c18e8-6a8d-4b3d-9541-081672b7905d",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/3d475129-ecfe-4194-85fc-81ee815db9e9"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/351c18e8-6a8d-4b3d-9541-081672b7905d/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/351c18e8-6a8d-4b3d-9541-081672b7905d"
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
DELETE /syntax_nodes/327cacd3-2cc6-4091-af9d-3a764166f4ce
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f2270303-9f0e-4198-83f4-82184443a41a
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
X-Request-Id: 31d82160-8c34-4d92-b0e6-aefca76e45b6
200 OK
```


```json
{
  "data": [
    {
      "id": "394b7512-f7fd-4b45-b01d-df82947d5ca6",
      "type": "progress_model",
      "attributes": {
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-04T20:53:28.989Z"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=394b7512-f7fd-4b45-b01d-df82947d5ca6",
            "self": "/progress_models/394b7512-f7fd-4b45-b01d-df82947d5ca6/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "fc2bd67f-619f-415f-acb9-46623831f5c7",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=fc2bd67f-619f-415f-acb9-46623831f5c7",
            "self": "/progress_models/fc2bd67f-619f-415f-acb9-46623831f5c7/relationships/progress_steps"
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
GET /progress_models/6004fa22-4284-45d2-95d4-60015cf2727a
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
X-Request-Id: cd798cd8-3be8-41d0-aec3-d910ddad0125
200 OK
```


```json
{
  "data": {
    "id": "6004fa22-4284-45d2-95d4-60015cf2727a",
    "type": "progress_model",
    "attributes": {
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-04T20:53:29.403Z"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=6004fa22-4284-45d2-95d4-60015cf2727a",
          "self": "/progress_models/6004fa22-4284-45d2-95d4-60015cf2727a/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/6004fa22-4284-45d2-95d4-60015cf2727a"
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
PATCH /progress_models/edb92b95-337c-4659-8a5e-cce1b32ce521
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "edb92b95-337c-4659-8a5e-cce1b32ce521",
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
X-Request-Id: b82504a4-a4ea-4582-919d-f536780cfe70
200 OK
```


```json
{
  "data": {
    "id": "edb92b95-337c-4659-8a5e-cce1b32ce521",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=edb92b95-337c-4659-8a5e-cce1b32ce521",
          "self": "/progress_models/edb92b95-337c-4659-8a5e-cce1b32ce521/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/edb92b95-337c-4659-8a5e-cce1b32ce521"
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
DELETE /progress_models/f7006b56-6282-4302-9240-5d4f6ab42af7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 05755f1e-54eb-4f55-845f-c3af407c2dc0
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
POST /progress_models/bfd72d2f-bbfa-4553-a84a-547511d0296d/publish
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
X-Request-Id: 81b52ccb-1215-459d-8473-c4da669bc8c1
200 OK
```


```json
{
  "data": {
    "id": "bfd72d2f-bbfa-4553-a84a-547511d0296d",
    "type": "progress_model",
    "attributes": {
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-04T20:53:30.698Z"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=bfd72d2f-bbfa-4553-a84a-547511d0296d",
          "self": "/progress_models/bfd72d2f-bbfa-4553-a84a-547511d0296d/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/bfd72d2f-bbfa-4553-a84a-547511d0296d/publish"
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a2254436-4652-4451-b228-33f1fade3a33
201 Created
```


```json
{
  "data": {
    "id": "4ac201c7-d035-4aba-874a-9da95eaf6258",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=4ac201c7-d035-4aba-874a-9da95eaf6258",
          "self": "/progress_models/4ac201c7-d035-4aba-874a-9da95eaf6258/relationships/progress_steps"
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
X-Request-Id: 92a18d09-02f7-4dc8-951a-88a084793d82
200 OK
```


```json
{
  "data": [
    {
      "id": "bf5b6c05-247a-4424-8b3c-d5e25ab64302",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/c89bf7c4-b0ce-44cb-9ff9-bc4477010077"
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
GET /progress_steps/8dccdcb6-7b8e-4f01-98db-58e658f0730e
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
X-Request-Id: 58cdb3d7-0d21-41f1-b06b-58a384f701ff
200 OK
```


```json
{
  "data": {
    "id": "8dccdcb6-7b8e-4f01-98db-58e658f0730e",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/954634ea-2361-463d-96e4-9bdec5203c41"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/8dccdcb6-7b8e-4f01-98db-58e658f0730e"
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
PATCH /progress_steps/20033818-e1f4-4012-ae53-07cfeb599814
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "20033818-e1f4-4012-ae53-07cfeb599814",
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
X-Request-Id: 256dcbdd-2b97-483c-86eb-cbf67b4290b7
200 OK
```


```json
{
  "data": {
    "id": "20033818-e1f4-4012-ae53-07cfeb599814",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/364199a6-32cb-4566-80cc-302a2f7e37b6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/20033818-e1f4-4012-ae53-07cfeb599814"
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
DELETE /progress_steps/3851614a-ef46-4bcc-b5aa-ea6feb2962ea
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: eca0789a-a6c6-44f8-a66e-e672612c1d5e
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
POST /progress_models/c000ab85-b0cd-498e-9582-62d5dd7022e1/relationships/progress_steps
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
X-Request-Id: 5704d171-3d31-498e-aa65-ef5aee88d552
201 Created
```


```json
{
  "data": {
    "id": "e4120201-5087-4420-9a41-b8f3a4e500d6",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/c000ab85-b0cd-498e-9582-62d5dd7022e1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/c000ab85-b0cd-498e-9582-62d5dd7022e1/relationships/progress_steps"
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
X-Request-Id: d3d1e01a-09cc-4cd4-98ed-07a1b63d44b1
200 OK
```


```json
{
  "data": [
    {
      "id": "020ffaf8-cacf-46cc-b5a6-e5b376a94bcc",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/3401bab3-f698-4c72-99f2-94eac54169ee"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/3c44c710-17e1-46f8-995a-3b0d2efd41d0"
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
GET /progress/5ccded3a-1985-4c63-b8f8-fe5f97f92f11
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
X-Request-Id: fefd3aea-3877-49b2-b043-d7a6ab45f45f
200 OK
```


```json
{
  "data": {
    "id": "5ccded3a-1985-4c63-b8f8-fe5f97f92f11",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/6edd46fc-0907-4bab-a4b9-557bfd16aeb7"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/1e99e6e0-eed8-4ae1-b382-aa3ed4b7a3e2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/5ccded3a-1985-4c63-b8f8-fe5f97f92f11"
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
DELETE /progress/794a83a7-fe9e-4e71-af89-d933839c1808
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: abd1431c-fd62-4bd8-a42d-5de75ab0a9da
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
          "id": "22c4458b-d1a0-462d-a80e-f1a14570f473"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "8b4633cd-5c2e-44dd-9c1d-41c604fd7f40"
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
X-Request-Id: 56705535-ae91-4ec5-afc5-f4d8a269d802
201 Created
```


```json
{
  "data": {
    "id": "db73b901-5753-4c94-81a1-a2ec0b4c9085",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/22c4458b-d1a0-462d-a80e-f1a14570f473"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/8b4633cd-5c2e-44dd-9c1d-41c604fd7f40"
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
X-Request-Id: b0c2ce22-4c69-417a-ba78-8448d5c19a45
200 OK
```


```json
{
  "data": [
    {
      "id": "79ccf5c1-8eba-4e9d-befb-e749e9f23409",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "fac33c40-2b3a-464a-937f-e07aa9239ac1"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/fac33c40-2b3a-464a-937f-e07aa9239ac1"
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
GET /projects/285ed11a-3de3-4682-91f8-8ee978552138/relationships/project_setting
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
X-Request-Id: 9e8dcc3f-af36-4d1e-be9a-89f009c01a9b
200 OK
```


```json
{
  "data": {
    "id": "d79b9149-a76f-4253-af47-ce0590a78754",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "285ed11a-3de3-4682-91f8-8ee978552138"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/285ed11a-3de3-4682-91f8-8ee978552138"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/285ed11a-3de3-4682-91f8-8ee978552138/relationships/project_setting"
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
PATCH /projects/0c7fe198-8fde-45f8-b53f-12ef1b6ac8b2/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "0c7fe198-8fde-45f8-b53f-12ef1b6ac8b2",
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
X-Request-Id: 69a35842-d27b-455a-bd0a-b833a733bc6f
200 OK
```


```json
{
  "data": {
    "id": "5ba7b5dc-8465-4784-8e0e-b42cdaeca078",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "0c7fe198-8fde-45f8-b53f-12ef1b6ac8b2"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/0c7fe198-8fde-45f8-b53f-12ef1b6ac8b2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/0c7fe198-8fde-45f8-b53f-12ef1b6ac8b2/relationships/project_setting"
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
X-Request-Id: d72466bd-6fe2-4e5d-82e5-2f4e0a9c7dcb
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
X-Request-Id: fe196e14-08d8-4d12-ad4c-2f4d40dcbf05
200 OK
```


```json
{
  "data": {
    "id": "ddc94242-89ad-409f-837b-aba07c0bb3c5",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "bfbb76f5-4338-4cad-8093-cb874f531616"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/bfbb76f5-4338-4cad-8093-cb874f531616"
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
X-Request-Id: a8d4c3d5-293c-45b3-bfc9-d17d01a8d95c
200 OK
```


```json
{
  "data": {
    "id": "26e02e0b-fe37-43b0-aabf-a3c48edf6032",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "eea167d4-1853-4857-b154-abb255dee30a"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/eea167d4-1853-4857-b154-abb255dee30a"
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
X-Request-Id: 91388959-ae34-4458-a7c9-a8903150b910
200 OK
```


```json
{
  "data": [
    {
      "id": "677c2aff-70c3-44c1-89a5-31786c44ad02",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/75dee500-d1f1-4fe6-a7ce-7779fc879a42"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/35d08fc7-8978-4b4e-8372-9bfa8c67287d"
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
X-Request-Id: 577db057-c176-4198-a2c1-351fc66ba3f0
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



