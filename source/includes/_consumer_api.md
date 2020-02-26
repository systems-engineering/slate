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
X-Request-Id: 9c8809dd-6e2f-4932-a010-eb247130f751
200 OK
```


```json
{
  "data": {
    "id": "482cb133-fa2d-4c61-b30f-3c821fa0a1e9",
    "type": "account",
    "attributes": {
      "name": "Account bb03cca59643"
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
X-Request-Id: f60d7299-5cc1-4069-b727-c49294a77352
200 OK
```


```json
{
  "data": {
    "id": "c239fa30-691f-443a-abed-c050d2a7814e",
    "type": "account",
    "attributes": {
      "name": "Account 812a2e7a41fe"
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
    "id": "0c5d3af6-0eb9-474d-8bd8-59eb7e061b71",
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
X-Request-Id: f62fafbd-62e0-4e62-8017-95c1b722d1a1
200 OK
```


```json
{
  "data": {
    "id": "0c5d3af6-0eb9-474d-8bd8-59eb7e061b71",
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
POST /projects/99af8ba0-dc48-4e54-94c3-9e70791bb754/relationships/tags
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
X-Request-Id: d51e3962-ff6d-4870-97bd-4b2395a3617e
201 Created
```


```json
{
  "data": {
    "id": "e504e354-9f65-497c-85ee-18fa161d8706",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/99af8ba0-dc48-4e54-94c3-9e70791bb754/relationships/tags"
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
POST /projects/d4e50fed-a04a-40c9-a272-a0d17a6817c9/relationships/tags
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
    "id": "6e57df31-d24a-49a2-83e5-5cc5dcaa7cf4"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 55cae0d7-99de-481c-a76c-e6432dde8208
201 Created
```


```json
{
  "data": {
    "id": "6e57df31-d24a-49a2-83e5-5cc5dcaa7cf4",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/d4e50fed-a04a-40c9-a272-a0d17a6817c9/relationships/tags"
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
DELETE /projects/8ce3913b-ca8e-4558-ae28-4cc15d0f8747/relationships/tags/c2018f1b-8885-4c3e-baee-be6d87f61b4f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 19fdf0e0-8571-48f8-a692-ddbc34a9c482
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
X-Request-Id: c575c3d5-6adf-4be0-a058-00f6e05862ba
200 OK
```


```json
{
  "data": [
    {
      "id": "51981881-024c-4727-a570-98a29930f749",
      "type": "project",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": "Project description",
        "name": "project 1"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=51981881-024c-4727-a570-98a29930f749&filter[target_type_eq]=Project",
            "self": "/projects/51981881-024c-4727-a570-98a29930f749/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=51981881-024c-4727-a570-98a29930f749",
            "self": "/projects/51981881-024c-4727-a570-98a29930f749/relationships/contexts"
          }
        }
      }
    }
  ],
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
GET /projects/896eda23-8c23-492f-beb9-d058a705046b
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
X-Request-Id: dc9a8298-db4b-47bd-b918-6c05aebaee34
200 OK
```


```json
{
  "data": {
    "id": "896eda23-8c23-492f-beb9-d058a705046b",
    "type": "project",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=896eda23-8c23-492f-beb9-d058a705046b&filter[target_type_eq]=Project",
          "self": "/projects/896eda23-8c23-492f-beb9-d058a705046b/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=896eda23-8c23-492f-beb9-d058a705046b",
          "self": "/projects/896eda23-8c23-492f-beb9-d058a705046b/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/896eda23-8c23-492f-beb9-d058a705046b"
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
PATCH /projects/b3a31be8-e53f-4042-9160-7a7504540197
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "b3a31be8-e53f-4042-9160-7a7504540197",
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
X-Request-Id: d5c437d7-3e52-4530-b8ad-cd1b0f99e962
200 OK
```


```json
{
  "data": {
    "id": "b3a31be8-e53f-4042-9160-7a7504540197",
    "type": "project",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "Project description",
      "name": "New project name"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=b3a31be8-e53f-4042-9160-7a7504540197&filter[target_type_eq]=Project",
          "self": "/projects/b3a31be8-e53f-4042-9160-7a7504540197/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=b3a31be8-e53f-4042-9160-7a7504540197",
          "self": "/projects/b3a31be8-e53f-4042-9160-7a7504540197/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b3a31be8-e53f-4042-9160-7a7504540197"
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
POST /projects/c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd/archive
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
X-Request-Id: 5ec75423-151b-447f-9afe-33afd216d121
200 OK
```


```json
{
  "data": {
    "id": "c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-26T11:40:39.563Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd&filter[target_type_eq]=Project",
          "self": "/projects/c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd",
          "self": "/projects/c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/c00780f6-e4b9-46a4-b4a7-e1ffe44df5cd/archive"
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
DELETE /projects/0148c1bd-ceb1-4f1e-a585-5e037b839c2f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8c2383ac-c800-442f-88e6-27f49c069168
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
POST /contexts/699f697a-7642-4976-9c74-d3682309e968/relationships/tags
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
X-Request-Id: 1561b8da-822a-4fb8-a426-f3fb756525ea
201 Created
```


```json
{
  "data": {
    "id": "2578d50f-a114-4944-a941-15b25ce8ee6b",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/699f697a-7642-4976-9c74-d3682309e968/relationships/tags"
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
POST /contexts/01e916be-cc0a-4862-8b6b-edc2d3c3ccdc/relationships/tags
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
    "id": "98609a4f-5b76-402f-8a8c-aa625eba10dd"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f8806510-0e0a-4b2e-9094-f1fa7a311f55
201 Created
```


```json
{
  "data": {
    "id": "98609a4f-5b76-402f-8a8c-aa625eba10dd",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/01e916be-cc0a-4862-8b6b-edc2d3c3ccdc/relationships/tags"
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
DELETE /contexts/2d61f0d0-830b-404a-aff8-528558bce16f/relationships/tags/2168a499-07ee-4333-899c-db82caf37fff
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a61e923d-5ba4-4b9f-b28e-0ab907b921db
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
X-Request-Id: 4f0c5a0b-87dd-4b1c-ba90-c0034bacd784
200 OK
```


```json
{
  "data": [
    {
      "id": "97d9e43c-b3d9-4992-8fc4-1e5032cf800e",
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
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=97d9e43c-b3d9-4992-8fc4-1e5032cf800e&filter[target_type_eq]=Context",
            "self": "/contexts/97d9e43c-b3d9-4992-8fc4-1e5032cf800e/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/7145f5b5-c39c-4ca5-bdb8-53ffec4bd0e2"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/9748e7df-bc77-40cb-a937-9879406ad80b"
          }
        }
      }
    },
    {
      "id": "ebe9aa1e-c9a8-4bc8-9331-2c7280a9ac48",
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
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=ebe9aa1e-c9a8-4bc8-9331-2c7280a9ac48&filter[target_type_eq]=Context",
            "self": "/contexts/ebe9aa1e-c9a8-4bc8-9331-2c7280a9ac48/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/7145f5b5-c39c-4ca5-bdb8-53ffec4bd0e2"
          }
        }
      }
    }
  ],
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


## Show


### Request

#### Endpoint

```plaintext
GET /contexts/0c9f8b07-4871-4b6d-9cd2-99c6d293b176
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
X-Request-Id: d6e53c83-b9e5-42dd-a857-8c4c20df0e47
200 OK
```


```json
{
  "data": {
    "id": "0c9f8b07-4871-4b6d-9cd2-99c6d293b176",
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
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=0c9f8b07-4871-4b6d-9cd2-99c6d293b176&filter[target_type_eq]=Context",
          "self": "/contexts/0c9f8b07-4871-4b6d-9cd2-99c6d293b176/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/7b801ad0-a9a9-402c-b08d-ee132f3864cc"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/a8a5d02a-2ec6-4509-8ed0-ec8f8a31e8f4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/0c9f8b07-4871-4b6d-9cd2-99c6d293b176"
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
PATCH /contexts/5466e986-6c7b-405e-acb4-021b5407cc40
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "5466e986-6c7b-405e-acb4-021b5407cc40",
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
X-Request-Id: d64d8a42-38a9-4aae-9108-7fd275942e95
200 OK
```


```json
{
  "data": {
    "id": "5466e986-6c7b-405e-acb4-021b5407cc40",
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
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=5466e986-6c7b-405e-acb4-021b5407cc40&filter[target_type_eq]=Context",
          "self": "/contexts/5466e986-6c7b-405e-acb4-021b5407cc40/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/eee6650e-13bc-4b63-872a-154b03ba7ce6"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/e4fc2ed9-a708-459e-a0b1-a1c2977644e0"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/5466e986-6c7b-405e-acb4-021b5407cc40"
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
POST /projects/791b6d06-9722-43aa-8d72-fd7b6ee511f3/relationships/contexts
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
X-Request-Id: 105b150c-c6b8-460b-8172-065a81e3d761
201 Created
```


```json
{
  "data": {
    "id": "feaa6002-f34f-4b76-9339-71175633850d",
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
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=feaa6002-f34f-4b76-9339-71175633850d&filter[target_type_eq]=Context",
          "self": "/contexts/feaa6002-f34f-4b76-9339-71175633850d/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/791b6d06-9722-43aa-8d72-fd7b6ee511f3"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/2c58a6d4-24ff-46b2-8000-57ab6e9eddfc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/791b6d06-9722-43aa-8d72-fd7b6ee511f3/relationships/contexts"
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
POST /contexts/9d07b45e-850a-49a5-85c0-94111052d8c3/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/dee8c7e3405ba03df36839f0
Content-Type: text/html; charset=utf-8
X-Request-Id: 9ba1abb9-8435-4336-8dcc-25e2e400c80a
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/dee8c7e3405ba03df36839f0">redirected</a>.</body></html>
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
DELETE /contexts/f18a2884-ef58-4d5e-a0f2-e9d7fbae7d1e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 754fe782-2cce-47dd-aa1b-ac751373e309
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
POST /object_occurrences/83491a2c-6f43-4306-a1b8-b423b8ec8983/relationships/tags
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
X-Request-Id: e7857d58-e6c1-4c1b-a73f-9d9572fb7fec
201 Created
```


```json
{
  "data": {
    "id": "2cd57ad9-4808-4bf1-a2e9-ca7500c00396",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/83491a2c-6f43-4306-a1b8-b423b8ec8983/relationships/tags"
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
POST /object_occurrences/c67d8f10-405b-4e82-a128-01b92dd6fef8/relationships/tags
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
    "id": "1a026507-0d5d-4fb5-95a5-c0ca946c9b02"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b7a806f5-0715-451f-964d-8a846e975c7f
201 Created
```


```json
{
  "data": {
    "id": "1a026507-0d5d-4fb5-95a5-c0ca946c9b02",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c67d8f10-405b-4e82-a128-01b92dd6fef8/relationships/tags"
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
DELETE /object_occurrences/dde18641-800a-4394-bf40-f8796cbbfe95/relationships/tags/7db90550-0f9c-4897-be3b-f5b5dc91d574
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5f61c655-9c5b-493a-a936-3d237f0fbd4d
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
GET /object_occurrences/349ab419-b8e4-47f3-97c7-3b17f54807a7
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
X-Request-Id: 358ace4a-fc41-44dd-9451-11e516167a84
200 OK
```


```json
{
  "data": {
    "id": "349ab419-b8e4-47f3-97c7-3b17f54807a7",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 1",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=349ab419-b8e4-47f3-97c7-3b17f54807a7&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/349ab419-b8e4-47f3-97c7-3b17f54807a7/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/3cdb03ad-ce11-42e8-9016-d821458e21b2"
        }
      },
      "components": {
        "data": [
          {
            "id": "085704d3-2466-4f93-800f-5e47e92b475b",
            "type": "object_occurrence"
          },
          {
            "id": "05cc60ef-d8a0-4f2e-9c14-96b3cc0e95d9",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/349ab419-b8e4-47f3-97c7-3b17f54807a7/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/349ab419-b8e4-47f3-97c7-3b17f54807a7"
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
POST /object_occurrences/b0794e89-29b1-4bca-bdcf-c701f584e64c/relationships/components
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
X-Request-Id: 81265723-f1b7-423f-bff8-abfa99367a45
201 Created
```


```json
{
  "data": {
    "id": "cd57eedd-42d5-4057-b967-3ed45aaff1e4",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "name": "ooc",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=cd57eedd-42d5-4057-b967-3ed45aaff1e4&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/cd57eedd-42d5-4057-b967-3ed45aaff1e4/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/e346e556-8a3e-4ca1-8500-e0ebe696f769"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/b0794e89-29b1-4bca-bdcf-c701f584e64c",
          "self": "/object_occurrences/cd57eedd-42d5-4057-b967-3ed45aaff1e4/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/cd57eedd-42d5-4057-b967-3ed45aaff1e4/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b0794e89-29b1-4bca-bdcf-c701f584e64c/relationships/components"
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
PATCH /object_occurrences/d466fb56-eebe-45d6-93fa-e6079052db02
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "d466fb56-eebe-45d6-93fa-e6079052db02",
    "type": "object_occurrence",
    "attributes": {
      "description": "New description",
      "name": "New name",
      "number": 8,
      "position": 2,
      "prefix": "%",
      "type": "external",
      "hex_color": "#FFA500"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "45190549-933b-4d59-bd5b-fc4e627dea37"
        }
      }
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New name |
| data[attributes][description]  | New description |
| data[attributes][hex_color]  | Specify a OOC color |
| data[attributes][position]  | Update sorting position |
| data[attributes][prefix]  | Update prefix |
| data[attributes][prefix]  | Update prefix |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 649280fb-080c-4b7a-a8df-1643a29c591a
200 OK
```


```json
{
  "data": {
    "id": "d466fb56-eebe-45d6-93fa-e6079052db02",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "system_element_relation_id": null,
      "type": "external",
      "hex_color": "#ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=d466fb56-eebe-45d6-93fa-e6079052db02&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/d466fb56-eebe-45d6-93fa-e6079052db02/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/d603871b-1ca8-4bc8-837f-ca26d2d583d8"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/45190549-933b-4d59-bd5b-fc4e627dea37",
          "self": "/object_occurrences/d466fb56-eebe-45d6-93fa-e6079052db02/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/d466fb56-eebe-45d6-93fa-e6079052db02/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d466fb56-eebe-45d6-93fa-e6079052db02"
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
POST /object_occurrences/b465132a-484c-421d-aba8-3a90c7321e22/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "a6c3348f-a972-4b1b-859c-bad3a0e91306",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/774872fb8d668b52a4e13854
Content-Type: text/html; charset=utf-8
X-Request-Id: fcef30dc-3451-47eb-956e-688cb86e4e95
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/774872fb8d668b52a4e13854">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/dba7df28-5511-4b7f-89ea-1712ec52005d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f97460eb-a649-4641-9bb1-e9717da1aa3a
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
PATCH /object_occurrences/c11ea7e2-f6d4-4fbf-8489-7563d2824c00/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "c1411ef0-7242-40f5-bb2d-dc78757aa9a9",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3a3e85b1-530e-4021-be85-caeaac29907d
200 OK
```


```json
{
  "data": {
    "id": "c11ea7e2-f6d4-4fbf-8489-7563d2824c00",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 2",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=c11ea7e2-f6d4-4fbf-8489-7563d2824c00&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/c11ea7e2-f6d4-4fbf-8489-7563d2824c00/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/b724c701-e3e9-4562-a5b1-124faba19871"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/c1411ef0-7242-40f5-bb2d-dc78757aa9a9",
          "self": "/object_occurrences/c11ea7e2-f6d4-4fbf-8489-7563d2824c00/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/c11ea7e2-f6d4-4fbf-8489-7563d2824c00/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c11ea7e2-f6d4-4fbf-8489-7563d2824c00/relationships/part_of"
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
POST /classification_tables/003ba6b5-7c0e-4e8c-bd39-5006fe5c38c6/relationships/tags
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
X-Request-Id: 145fc805-db28-4a2e-b347-f123b0f5601a
201 Created
```


```json
{
  "data": {
    "id": "728d8ed9-1cf6-4fae-a736-59f404ced80b",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/003ba6b5-7c0e-4e8c-bd39-5006fe5c38c6/relationships/tags"
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
POST /classification_tables/465b70de-0f38-48a2-b3ea-b7fd4f4171ae/relationships/tags
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
    "id": "2d02a742-3b58-41d1-ada3-4d90a9edcb01"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 04fd8848-c08e-4c81-9657-ba8a9dc9542d
201 Created
```


```json
{
  "data": {
    "id": "2d02a742-3b58-41d1-ada3-4d90a9edcb01",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/465b70de-0f38-48a2-b3ea-b7fd4f4171ae/relationships/tags"
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
DELETE /classification_tables/5dfd092d-f4cd-4b52-9b2a-f2a195579c85/relationships/tags/e8c941d1-cfa7-46fe-a97b-40a36da4927d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8c411951-76c9-4b92-bd2e-70f40e3b3981
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
X-Request-Id: ad9e1c4a-3ae6-4ff4-85e5-5724b087377d
200 OK
```


```json
{
  "data": [
    {
      "id": "87da806e-9f99-41ba-9071-78b5532e32b4",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=87da806e-9f99-41ba-9071-78b5532e32b4&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/87da806e-9f99-41ba-9071-78b5532e32b4/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=87da806e-9f99-41ba-9071-78b5532e32b4",
            "self": "/classification_tables/87da806e-9f99-41ba-9071-78b5532e32b4/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "b6a8134c-ac01-4ed0-b2e4-29139f67b018",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=b6a8134c-ac01-4ed0-b2e4-29139f67b018&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/b6a8134c-ac01-4ed0-b2e4-29139f67b018/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=b6a8134c-ac01-4ed0-b2e4-29139f67b018",
            "self": "/classification_tables/b6a8134c-ac01-4ed0-b2e4-29139f67b018/relationships/classification_entries",
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
GET /classification_tables/036738c6-30b0-48ba-9c4e-2bd5883db05c
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
X-Request-Id: 4dc73afd-ee7c-477f-a687-663183956b17
200 OK
```


```json
{
  "data": {
    "id": "036738c6-30b0-48ba-9c4e-2bd5883db05c",
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
        "links": {
          "related": "/tags?filter[target_id_eq]=036738c6-30b0-48ba-9c4e-2bd5883db05c&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/036738c6-30b0-48ba-9c4e-2bd5883db05c/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=036738c6-30b0-48ba-9c4e-2bd5883db05c",
          "self": "/classification_tables/036738c6-30b0-48ba-9c4e-2bd5883db05c/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/036738c6-30b0-48ba-9c4e-2bd5883db05c"
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
PATCH /classification_tables/49691b9d-3106-4607-9040-6404c69ea237
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "49691b9d-3106-4607-9040-6404c69ea237",
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
X-Request-Id: 288eafb5-595b-4865-9ed3-dd94aacf733d
200 OK
```


```json
{
  "data": {
    "id": "49691b9d-3106-4607-9040-6404c69ea237",
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
        "links": {
          "related": "/tags?filter[target_id_eq]=49691b9d-3106-4607-9040-6404c69ea237&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/49691b9d-3106-4607-9040-6404c69ea237/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=49691b9d-3106-4607-9040-6404c69ea237",
          "self": "/classification_tables/49691b9d-3106-4607-9040-6404c69ea237/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/49691b9d-3106-4607-9040-6404c69ea237"
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
DELETE /classification_tables/9c2fb81d-a77b-45bf-af53-5982dfddf4b4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6a7ff03e-4578-4142-ab5e-7626abddc68a
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
POST /classification_tables/9533ea60-dc39-41ea-bbf0-b1220e1b4a81/publish
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
X-Request-Id: 9c30666f-bb26-4cd0-9470-8b017441219b
200 OK
```


```json
{
  "data": {
    "id": "9533ea60-dc39-41ea-bbf0-b1220e1b4a81",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-26T11:40:59.033Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=9533ea60-dc39-41ea-bbf0-b1220e1b4a81&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/9533ea60-dc39-41ea-bbf0-b1220e1b4a81/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=9533ea60-dc39-41ea-bbf0-b1220e1b4a81",
          "self": "/classification_tables/9533ea60-dc39-41ea-bbf0-b1220e1b4a81/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/9533ea60-dc39-41ea-bbf0-b1220e1b4a81/publish"
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
POST /classification_tables/c445688c-03ef-4cba-9267-e06000e5b472/archive
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
X-Request-Id: 6f9bf030-bb23-47b0-9cc5-03794befef79
200 OK
```


```json
{
  "data": {
    "id": "c445688c-03ef-4cba-9267-e06000e5b472",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-26T11:40:59.881Z",
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=c445688c-03ef-4cba-9267-e06000e5b472&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/c445688c-03ef-4cba-9267-e06000e5b472/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=c445688c-03ef-4cba-9267-e06000e5b472",
          "self": "/classification_tables/c445688c-03ef-4cba-9267-e06000e5b472/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/c445688c-03ef-4cba-9267-e06000e5b472/archive"
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
X-Request-Id: 89e69e77-2118-4234-95ed-4ff819a0f374
201 Created
```


```json
{
  "data": {
    "id": "a3eae051-6cc6-4949-b60b-02d19896f0bd",
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
        "links": {
          "related": "/tags?filter[target_id_eq]=a3eae051-6cc6-4949-b60b-02d19896f0bd&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/a3eae051-6cc6-4949-b60b-02d19896f0bd/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=a3eae051-6cc6-4949-b60b-02d19896f0bd",
          "self": "/classification_tables/a3eae051-6cc6-4949-b60b-02d19896f0bd/relationships/classification_entries",
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
POST /classification_entries/e86671d6-82aa-4164-959a-19232db6910a/relationships/tags
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
X-Request-Id: dc2a37bf-7ec6-41a9-b91b-d4e2cbf4574a
201 Created
```


```json
{
  "data": {
    "id": "532910e7-70b1-4e2e-b7c3-781f8bcbbe30",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/e86671d6-82aa-4164-959a-19232db6910a/relationships/tags"
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
POST /classification_entries/d06f0b9a-de75-40f3-a871-fc82adebedb9/relationships/tags
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
    "id": "87804a5b-fb65-489f-8a30-1dd5c1c355c9"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 28f1c4e7-07e5-418a-a701-8cef6721ebce
201 Created
```


```json
{
  "data": {
    "id": "87804a5b-fb65-489f-8a30-1dd5c1c355c9",
    "type": "tag",
    "attributes": {
      "value": "Tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/d06f0b9a-de75-40f3-a871-fc82adebedb9/relationships/tags"
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
DELETE /classification_entries/b7c23a32-72fe-416d-a478-0fd2196ca1eb/relationships/tags/ed4ae4f2-9a8d-46f4-b7be-d4cab6474584
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8638517b-24f2-4442-a586-f835f4a81c09
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
X-Request-Id: bbed69f3-66e9-4ca0-988e-90f8f6f85e3a
200 OK
```


```json
{
  "data": [
    {
      "id": "347a36a6-1524-47df-bc97-b19e949550ad",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal",
        "name": "CE 1",
        "reciprocal_name": null
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=347a36a6-1524-47df-bc97-b19e949550ad&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/347a36a6-1524-47df-bc97-b19e949550ad/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=347a36a6-1524-47df-bc97-b19e949550ad",
            "self": "/classification_entries/347a36a6-1524-47df-bc97-b19e949550ad/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "e714e2b7-a6af-4d1d-b9f7-85efaac0e689",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal",
        "name": "CE 11",
        "reciprocal_name": null
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=e714e2b7-a6af-4d1d-b9f7-85efaac0e689&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/e714e2b7-a6af-4d1d-b9f7-85efaac0e689/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "347a36a6-1524-47df-bc97-b19e949550ad",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/e714e2b7-a6af-4d1d-b9f7-85efaac0e689"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=e714e2b7-a6af-4d1d-b9f7-85efaac0e689",
            "self": "/classification_entries/e714e2b7-a6af-4d1d-b9f7-85efaac0e689/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "48fd2ae6-2d7c-4919-8056-f2981fd86880",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal",
        "name": "CE 2",
        "reciprocal_name": null
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=48fd2ae6-2d7c-4919-8056-f2981fd86880&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/48fd2ae6-2d7c-4919-8056-f2981fd86880/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=48fd2ae6-2d7c-4919-8056-f2981fd86880",
            "self": "/classification_entries/48fd2ae6-2d7c-4919-8056-f2981fd86880/relationships/classification_entries",
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
GET /classification_entries/fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a
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
X-Request-Id: dd688620-a9ae-4ae1-a9a7-788b125c2d5c
200 OK
```


```json
{
  "data": {
    "id": "fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "Alarm signal",
      "name": "CE 1",
      "reciprocal_name": null
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a",
          "self": "/classification_entries/fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/fd2b835c-09a9-4cda-b9a0-01c84fe4dc0a"
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
PATCH /classification_entries/4cc1bc0e-17b7-4621-b2dd-6434e9276f41
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "4cc1bc0e-17b7-4621-b2dd-6434e9276f41",
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
X-Request-Id: 3aa28fe9-fffc-4430-9477-a933d3e65f72
200 OK
```


```json
{
  "data": {
    "id": "4cc1bc0e-17b7-4621-b2dd-6434e9276f41",
    "type": "classification_entry",
    "attributes": {
      "code": "AA",
      "definition": "Alarm signal",
      "name": "New classification entry name",
      "reciprocal_name": null
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=4cc1bc0e-17b7-4621-b2dd-6434e9276f41&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/4cc1bc0e-17b7-4621-b2dd-6434e9276f41/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "db1860c3-2ea6-4c00-977a-70076da7b3ce",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/4cc1bc0e-17b7-4621-b2dd-6434e9276f41"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=4cc1bc0e-17b7-4621-b2dd-6434e9276f41",
          "self": "/classification_entries/4cc1bc0e-17b7-4621-b2dd-6434e9276f41/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/4cc1bc0e-17b7-4621-b2dd-6434e9276f41"
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
DELETE /classification_entries/89337135-efba-45a7-9029-c6c5b801b12c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2fda0174-9f78-4f82-ba44-71f9b00829f9
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
POST /classification_tables/e852c934-f4a4-46bc-ba3f-830617bcbef3/relationships/classification_entries
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
X-Request-Id: 315b7aa6-9b0a-4e27-bce8-21a3b262d19d
201 Created
```


```json
{
  "data": {
    "id": "e9d7628e-4242-4018-9291-0eb21e4f77e9",
    "type": "classification_entry",
    "attributes": {
      "code": "C",
      "definition": "New definition",
      "name": "New name",
      "reciprocal_name": null
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=e9d7628e-4242-4018-9291-0eb21e4f77e9&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/e9d7628e-4242-4018-9291-0eb21e4f77e9/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=e9d7628e-4242-4018-9291-0eb21e4f77e9",
          "self": "/classification_entries/e9d7628e-4242-4018-9291-0eb21e4f77e9/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/e852c934-f4a4-46bc-ba3f-830617bcbef3/relationships/classification_entries"
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
X-Request-Id: 411abc8a-a548-4831-8699-31843549ba7c
200 OK
```


```json
{
  "data": [
    {
      "id": "d42b39a0-8c7b-4d37-9fbc-0bc1a9757920",
      "type": "syntax",
      "attributes": {
        "account_id": "4d094a0e-c089-4b47-90de-4deac765c6b2",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 0d0dbeb31d35",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=d42b39a0-8c7b-4d37-9fbc-0bc1a9757920",
            "self": "/syntaxes/d42b39a0-8c7b-4d37-9fbc-0bc1a9757920/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/5848d12e-0a42-4dc3-996b-a841914b813e",
            "self": "/syntax_nodes/5848d12e-0a42-4dc3-996b-a841914b813e/relationships/components"
          }
        }
      }
    }
  ],
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
GET /syntaxes/ee9d59f7-511d-482e-909a-527970a3566c
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
X-Request-Id: 2479af30-da8b-4aed-a351-d04dd632dac8
200 OK
```


```json
{
  "data": {
    "id": "ee9d59f7-511d-482e-909a-527970a3566c",
    "type": "syntax",
    "attributes": {
      "account_id": "084ee331-6316-464c-8652-0c6b0574b79e",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax ac6e6ff27c15",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ee9d59f7-511d-482e-909a-527970a3566c",
          "self": "/syntaxes/ee9d59f7-511d-482e-909a-527970a3566c/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/e015ba16-2a0e-4b2a-8a9d-1e7691bae372",
          "self": "/syntax_nodes/e015ba16-2a0e-4b2a-8a9d-1e7691bae372/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ee9d59f7-511d-482e-909a-527970a3566c"
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
X-Request-Id: 334323f9-391d-4535-8d24-d6b8dd22ceee
201 Created
```


```json
{
  "data": {
    "id": "f74a9ddc-a1c3-48b3-9121-d04fbce3ecb5",
    "type": "syntax",
    "attributes": {
      "account_id": "d8e13ad9-aa30-490e-bade-9de80ea45286",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=f74a9ddc-a1c3-48b3-9121-d04fbce3ecb5",
          "self": "/syntaxes/f74a9ddc-a1c3-48b3-9121-d04fbce3ecb5/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/c72cbd20-19ad-49e8-ac39-89af56bf66e9",
          "self": "/syntax_nodes/c72cbd20-19ad-49e8-ac39-89af56bf66e9/relationships/components"
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
PATCH /syntaxes/36773acd-87a6-423c-a3fa-d536457ecd5a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "36773acd-87a6-423c-a3fa-d536457ecd5a",
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
X-Request-Id: d0ba5445-e0c6-4847-8e69-b4494efec2ce
200 OK
```


```json
{
  "data": {
    "id": "36773acd-87a6-423c-a3fa-d536457ecd5a",
    "type": "syntax",
    "attributes": {
      "account_id": "4090c257-90be-4493-af3e-b74e90f291c4",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=36773acd-87a6-423c-a3fa-d536457ecd5a",
          "self": "/syntaxes/36773acd-87a6-423c-a3fa-d536457ecd5a/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/ce9084da-8a5e-4e2b-a9e6-b1f587423e23",
          "self": "/syntax_nodes/ce9084da-8a5e-4e2b-a9e6-b1f587423e23/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/36773acd-87a6-423c-a3fa-d536457ecd5a"
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
DELETE /syntaxes/3b646078-bdaf-4d44-a320-5dda5a24c462
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 570aa91a-0f0c-4d01-b16f-33177f4e3eec
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
POST /syntaxes/032d5791-7557-4684-9e26-4d3194e366bb/publish
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
X-Request-Id: 82320eef-15aa-494b-a2d0-a89533670c60
200 OK
```


```json
{
  "data": {
    "id": "032d5791-7557-4684-9e26-4d3194e366bb",
    "type": "syntax",
    "attributes": {
      "account_id": "f66d87a8-da31-4845-9269-af3056a4edcd",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 6a7db4f1e3b5",
      "published": true,
      "published_at": "2020-02-26T11:41:09.915Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=032d5791-7557-4684-9e26-4d3194e366bb",
          "self": "/syntaxes/032d5791-7557-4684-9e26-4d3194e366bb/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/a4447871-22b9-431c-a9eb-4c71207748db",
          "self": "/syntax_nodes/a4447871-22b9-431c-a9eb-4c71207748db/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/032d5791-7557-4684-9e26-4d3194e366bb/publish"
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
POST /syntaxes/ee557a6d-d73f-4354-8e22-66db63ec101a/archive
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
X-Request-Id: ea00f93f-58ca-4a62-b393-571322b7e1c3
200 OK
```


```json
{
  "data": {
    "id": "ee557a6d-d73f-4354-8e22-66db63ec101a",
    "type": "syntax",
    "attributes": {
      "account_id": "34671175-155c-4d25-ae6a-47900bdf029d",
      "archived": true,
      "archived_at": "2020-02-26T11:41:10.365Z",
      "description": "Description",
      "name": "Syntax 78fab7dda5b7",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ee557a6d-d73f-4354-8e22-66db63ec101a",
          "self": "/syntaxes/ee557a6d-d73f-4354-8e22-66db63ec101a/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/5fb3af3c-a409-4b57-8024-249e9842dc86",
          "self": "/syntax_nodes/5fb3af3c-a409-4b57-8024-249e9842dc86/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ee557a6d-d73f-4354-8e22-66db63ec101a/archive"
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
X-Request-Id: e03e4926-5707-475f-9b9d-3d4461b39c65
200 OK
```


```json
{
  "data": [
    {
      "id": "9a8ca417-d64d-4bd9-8e31-e2f405214425",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "b80d8ef2-73d5-40d1-893d-5a2ed1e44a9d",
        "hex_color": "59fdf7",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 77649f75e1f7"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/aa8054ad-45ad-4d21-9848-a740468aa05e"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/b80d8ef2-73d5-40d1-893d-5a2ed1e44a9d",
            "self": "/syntax_elements/9a8ca417-d64d-4bd9-8e31-e2f405214425/relationships/classification_table"
          }
        }
      }
    }
  ],
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
GET /syntax_elements/3ef5de5e-47d1-4862-b664-666652acecb4
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
X-Request-Id: c1fc0c4a-cff7-49d3-8b98-4b109d1048cf
200 OK
```


```json
{
  "data": {
    "id": "3ef5de5e-47d1-4862-b664-666652acecb4",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "e6f90540-ba46-4f83-ba95-a35b47c69fb9",
      "hex_color": "91efc1",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element ef3a09781b00"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/6806575b-1e1b-4a85-add8-e6782130063c"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/e6f90540-ba46-4f83-ba95-a35b47c69fb9",
          "self": "/syntax_elements/3ef5de5e-47d1-4862-b664-666652acecb4/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/3ef5de5e-47d1-4862-b664-666652acecb4"
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
POST /syntaxes/8776790e-27c3-4532-8da2-a28273c22a60/relationships/syntax_elements
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
          "id": "cc3307ed-2205-4b47-8aa6-945afb223376"
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
X-Request-Id: 9f2fd0f6-6735-4be9-88fa-607efec72d28
201 Created
```


```json
{
  "data": {
    "id": "7f551b58-fe21-4410-9917-125ec0b778a0",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "cc3307ed-2205-4b47-8aa6-945afb223376",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/8776790e-27c3-4532-8da2-a28273c22a60"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/cc3307ed-2205-4b47-8aa6-945afb223376",
          "self": "/syntax_elements/7f551b58-fe21-4410-9917-125ec0b778a0/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/8776790e-27c3-4532-8da2-a28273c22a60/relationships/syntax_elements"
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
PATCH /syntax_elements/32fe4d5e-6f97-4162-8054-71320527c3ea
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "32fe4d5e-6f97-4162-8054-71320527c3ea",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "0ddf2a61-68aa-4aa6-b068-bf8437eabb65"
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
X-Request-Id: bb7ba8de-171b-451d-8e3f-bd04783afe5b
200 OK
```


```json
{
  "data": {
    "id": "32fe4d5e-6f97-4162-8054-71320527c3ea",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "0ddf2a61-68aa-4aa6-b068-bf8437eabb65",
      "hex_color": "e52af7",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/61e6a2ff-49ae-434e-b6d1-991c1a22ba5c"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/0ddf2a61-68aa-4aa6-b068-bf8437eabb65",
          "self": "/syntax_elements/32fe4d5e-6f97-4162-8054-71320527c3ea/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/32fe4d5e-6f97-4162-8054-71320527c3ea"
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
DELETE /syntax_elements/d8d40ca0-7f93-4d37-9081-0559341438b6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c56f1f01-2a27-4587-a64b-468a4d227131
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
PATCH /syntax_elements/20f3e5d3-a44e-475a-8da9-8a13dc3b9129/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "f6921639-78e0-4e62-845f-0086bf91bcf0",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 830ae773-ac52-47b0-b610-54c7c0ce5c10
200 OK
```


```json
{
  "data": {
    "id": "20f3e5d3-a44e-475a-8da9-8a13dc3b9129",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "f6921639-78e0-4e62-845f-0086bf91bcf0",
      "hex_color": "d01d48",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element b698850ba378"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/d571871b-dfa4-4445-8d87-4c0cd210cfdd"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/f6921639-78e0-4e62-845f-0086bf91bcf0",
          "self": "/syntax_elements/20f3e5d3-a44e-475a-8da9-8a13dc3b9129/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/20f3e5d3-a44e-475a-8da9-8a13dc3b9129/relationships/classification_table"
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
DELETE /syntax_elements/37b59e01-6f4c-41c0-80d8-81cbaf26b23b/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 900af1af-275d-4f35-a75a-b6c8961e6823
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
GET /syntax_nodes/69ef1ab5-e671-4d3c-b521-22d010b0ebf9?depth=2
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
X-Request-Id: 50d0cee9-4838-4f08-aea8-ce765bfbed69
200 OK
```


```json
{
  "data": {
    "id": "69ef1ab5-e671-4d3c-b521-22d010b0ebf9",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/4b960169-3e4b-42f8-b703-9561a0525341"
        }
      },
      "components": {
        "data": [
          {
            "id": "41220f51-0a97-446b-b260-fa5481b05817",
            "type": "syntax_node"
          },
          {
            "id": "b8435e08-3bd0-4584-8f32-12d99b9fbbd0",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/69ef1ab5-e671-4d3c-b521-22d010b0ebf9/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/69ef1ab5-e671-4d3c-b521-22d010b0ebf9/relationships/parent",
          "related": "/syntax_nodes/69ef1ab5-e671-4d3c-b521-22d010b0ebf9"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/69ef1ab5-e671-4d3c-b521-22d010b0ebf9?depth=2"
  },
  "included": [
    {
      "id": "b8435e08-3bd0-4584-8f32-12d99b9fbbd0",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/4b960169-3e4b-42f8-b703-9561a0525341"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/b8435e08-3bd0-4584-8f32-12d99b9fbbd0/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/b8435e08-3bd0-4584-8f32-12d99b9fbbd0/relationships/parent",
            "related": "/syntax_nodes/b8435e08-3bd0-4584-8f32-12d99b9fbbd0"
          }
        }
      }
    },
    {
      "id": "41220f51-0a97-446b-b260-fa5481b05817",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/4b960169-3e4b-42f8-b703-9561a0525341"
          }
        },
        "components": {
          "data": [
            {
              "id": "94e59b6c-91d2-4a75-ae8a-7a067dc54554",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/41220f51-0a97-446b-b260-fa5481b05817/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/41220f51-0a97-446b-b260-fa5481b05817/relationships/parent",
            "related": "/syntax_nodes/41220f51-0a97-446b-b260-fa5481b05817"
          }
        }
      }
    },
    {
      "id": "94e59b6c-91d2-4a75-ae8a-7a067dc54554",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/4b960169-3e4b-42f8-b703-9561a0525341"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/94e59b6c-91d2-4a75-ae8a-7a067dc54554/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/94e59b6c-91d2-4a75-ae8a-7a067dc54554/relationships/parent",
            "related": "/syntax_nodes/94e59b6c-91d2-4a75-ae8a-7a067dc54554"
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
POST /syntax_nodes/3838079b-37eb-40b1-866b-f85f050a3bb3/relationships/components
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
X-Request-Id: 9c965ba7-1c22-44ce-b1a7-2b26e73e3846
201 Created
```


```json
{
  "data": {
    "id": "dc1e845e-f432-4cf5-9553-29f6b19de542",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/ea6616e2-3abe-4471-ab90-38efc399258c"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/dc1e845e-f432-4cf5-9553-29f6b19de542/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/dc1e845e-f432-4cf5-9553-29f6b19de542/relationships/parent",
          "related": "/syntax_nodes/dc1e845e-f432-4cf5-9553-29f6b19de542"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/3838079b-37eb-40b1-866b-f85f050a3bb3/relationships/components"
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
PATCH /syntax_nodes/59760faa-16be-4035-9c02-409260c8c622/relationships/parent
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
    "id": "9a108678-2608-4d88-80f9-01ada67196f6"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c2b4b5b7-0a03-4d98-a4d4-10a31995967f
200 OK
```


```json
{
  "data": {
    "id": "59760faa-16be-4035-9c02-409260c8c622",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/7418b86d-65c9-47ce-99fd-12915e61d978"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/59760faa-16be-4035-9c02-409260c8c622/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/59760faa-16be-4035-9c02-409260c8c622/relationships/parent",
          "related": "/syntax_nodes/59760faa-16be-4035-9c02-409260c8c622"
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
PATCH /syntax_nodes/bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1",
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
X-Request-Id: 19b821de-19a8-46e9-861b-d27bc2183280
200 OK
```


```json
{
  "data": {
    "id": "bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/106b8600-6c2c-4753-9284-aac62858146a"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1/relationships/parent",
          "related": "/syntax_nodes/bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/bdd4d22c-e7d9-44f3-a333-54cf2cd85ff1"
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
DELETE /syntax_nodes/7d566c87-37f1-4a32-b47f-1cfb8fa0883d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f81c3ae4-e91b-477f-a706-7bad28e72253
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
X-Request-Id: 3978a251-857d-4285-873a-8cc95575babb
200 OK
```


```json
{
  "data": [
    {
      "id": "0fc3fc80-76bd-40d4-b0bc-392f7d14801e",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-26T11:41:19.057Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=0fc3fc80-76bd-40d4-b0bc-392f7d14801e",
            "self": "/progress_models/0fc3fc80-76bd-40d4-b0bc-392f7d14801e/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "57ae0a82-223e-4ff9-85e6-013200173799",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=57ae0a82-223e-4ff9-85e6-013200173799",
            "self": "/progress_models/57ae0a82-223e-4ff9-85e6-013200173799/relationships/progress_steps"
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
GET /progress_models/74235e2c-af83-424b-9837-1245955660d6
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
X-Request-Id: efc9889d-788a-42f2-a596-6a44b64d356c
200 OK
```


```json
{
  "data": {
    "id": "74235e2c-af83-424b-9837-1245955660d6",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-26T11:41:19.801Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=74235e2c-af83-424b-9837-1245955660d6",
          "self": "/progress_models/74235e2c-af83-424b-9837-1245955660d6/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/74235e2c-af83-424b-9837-1245955660d6"
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
PATCH /progress_models/19a87c26-df31-461f-8b97-ddf8198bf98f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "19a87c26-df31-461f-8b97-ddf8198bf98f",
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
X-Request-Id: 780b69bd-3d93-4b04-b4a5-6ff6993d5edd
200 OK
```


```json
{
  "data": {
    "id": "19a87c26-df31-461f-8b97-ddf8198bf98f",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=19a87c26-df31-461f-8b97-ddf8198bf98f",
          "self": "/progress_models/19a87c26-df31-461f-8b97-ddf8198bf98f/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/19a87c26-df31-461f-8b97-ddf8198bf98f"
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
DELETE /progress_models/a78c9e17-7111-4a70-8724-ae9425e3ade9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fd9853c0-2c37-4218-b070-b912b2c4dfa5
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
POST /progress_models/a0367469-5028-441b-9614-3b991dcb1571/publish
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
X-Request-Id: 143b1d0c-313f-4854-91e1-c8ce40c2e663
200 OK
```


```json
{
  "data": {
    "id": "a0367469-5028-441b-9614-3b991dcb1571",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-26T11:41:22.431Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a0367469-5028-441b-9614-3b991dcb1571",
          "self": "/progress_models/a0367469-5028-441b-9614-3b991dcb1571/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/a0367469-5028-441b-9614-3b991dcb1571/publish"
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
POST /progress_models/e96797e6-0aa1-4a1d-946f-64b7319d497a/archive
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
X-Request-Id: 381c9d75-8c90-43e5-8793-717736cde37d
200 OK
```


```json
{
  "data": {
    "id": "e96797e6-0aa1-4a1d-946f-64b7319d497a",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-26T11:41:23.039Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=e96797e6-0aa1-4a1d-946f-64b7319d497a",
          "self": "/progress_models/e96797e6-0aa1-4a1d-946f-64b7319d497a/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/e96797e6-0aa1-4a1d-946f-64b7319d497a/archive"
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
X-Request-Id: 9c2e0bd7-082b-419e-942d-9086d310a7e7
201 Created
```


```json
{
  "data": {
    "id": "e86ac311-c974-453f-a38d-25e9a1c7cba3",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=e86ac311-c974-453f-a38d-25e9a1c7cba3",
          "self": "/progress_models/e86ac311-c974-453f-a38d-25e9a1c7cba3/relationships/progress_steps"
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
X-Request-Id: 70527cdd-78a3-44cf-a0e8-0c17be7a5888
200 OK
```


```json
{
  "data": [
    {
      "id": "072b41e2-1a5f-4537-a0dd-b0689305c93b",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/eb30251e-9f41-45f4-b6b3-6708910e7258"
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
GET /progress_steps/b78c582c-c547-4497-953a-37a672408e42
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
X-Request-Id: 408e6a2c-10c1-4eb3-b7b6-65c6c9e6fa94
200 OK
```


```json
{
  "data": {
    "id": "b78c582c-c547-4497-953a-37a672408e42",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/dbf4d626-9117-4121-8b93-25ca4c1728dc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/b78c582c-c547-4497-953a-37a672408e42"
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
PATCH /progress_steps/8130c2a0-558b-4794-9d43-aa546c8fe1be
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "8130c2a0-558b-4794-9d43-aa546c8fe1be",
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
X-Request-Id: 7dfd38ed-a1c9-49c5-89d7-b22232bbbd7c
200 OK
```


```json
{
  "data": {
    "id": "8130c2a0-558b-4794-9d43-aa546c8fe1be",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/5cb8dc42-3a59-4118-9cc1-5da859085dfd"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/8130c2a0-558b-4794-9d43-aa546c8fe1be"
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
DELETE /progress_steps/20970004-1095-4687-ae80-7b19faf05069
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e0d8f790-0bf7-436d-b823-85e2a3597cf4
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
POST /progress_models/85725d11-e61e-499f-a9a6-756d83078388/relationships/progress_steps
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
X-Request-Id: 5d179eb3-f717-4c84-907c-8c323c7f7d53
201 Created
```


```json
{
  "data": {
    "id": "f6ec322f-f99d-42b5-961c-2c69dc1b4ea7",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/85725d11-e61e-499f-a9a6-756d83078388"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/85725d11-e61e-499f-a9a6-756d83078388/relationships/progress_steps"
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
X-Request-Id: ff8921b4-f4a8-4efb-892f-ab8364d33e2a
200 OK
```


```json
{
  "data": [
    {
      "id": "9e720967-2ec2-40fe-92e1-0df250aec33e",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/8f0351f4-c3c4-4f00-a6cb-b3e80a7b9df9"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/bedca666-0dd5-4202-88c8-3383b171ec1a"
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
GET /progress/36f19426-ce5b-44ca-b585-0ae0c54d4f24
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
X-Request-Id: 2ebe9e4b-f0a0-49e1-8b7b-9d30f3a352f3
200 OK
```


```json
{
  "data": {
    "id": "36f19426-ce5b-44ca-b585-0ae0c54d4f24",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/46a97700-159a-4d8c-aa89-fea31376d699"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/ae274965-6411-4259-bb2c-140ac91fe5fe"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/36f19426-ce5b-44ca-b585-0ae0c54d4f24"
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
DELETE /progress/dffdec7c-4efc-47c4-bf0d-ee24aa720f08
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b18ab97b-0985-4486-b38f-601f7177d884
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
          "id": "384c2392-227d-4f88-a0ca-5349ebb71018"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "a1f82750-06f4-4831-ab96-c4eba7d3cfa1"
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
X-Request-Id: de23450f-c1c6-4904-8564-4f946dd318b0
201 Created
```


```json
{
  "data": {
    "id": "c42cea1e-d14f-4aca-ba8c-6b1ceabc3358",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/384c2392-227d-4f88-a0ca-5349ebb71018"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/a1f82750-06f4-4831-ab96-c4eba7d3cfa1"
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
X-Request-Id: 0212be07-e1c7-43ac-b414-f85748e58212
200 OK
```


```json
{
  "data": [
    {
      "id": "5d19b428-9dbf-47d3-94c6-df6ab8830084",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "e0574d62-e82f-467b-a349-47463ec69eeb"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/e0574d62-e82f-467b-a349-47463ec69eeb"
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
GET /projects/9867d45e-d7d2-4823-9656-e892ebdab860/relationships/project_setting
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
X-Request-Id: 8b36fdef-72a9-4445-a227-e38a7a59b772
200 OK
```


```json
{
  "data": {
    "id": "8e887bf3-a02d-4ed5-945a-27ee8d8823ef",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "9867d45e-d7d2-4823-9656-e892ebdab860"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/9867d45e-d7d2-4823-9656-e892ebdab860"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/9867d45e-d7d2-4823-9656-e892ebdab860/relationships/project_setting"
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
PATCH /projects/5d414844-d383-4c85-bd54-e71e07a09b79/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "5d414844-d383-4c85-bd54-e71e07a09b79",
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
X-Request-Id: da71ea61-4b55-473a-9338-f86b204c288b
200 OK
```


```json
{
  "data": {
    "id": "674b77ff-2fde-4ef8-8330-40c349d3c7d2",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "5d414844-d383-4c85-bd54-e71e07a09b79"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/5d414844-d383-4c85-bd54-e71e07a09b79"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/5d414844-d383-4c85-bd54-e71e07a09b79/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


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
X-Request-Id: fa567681-0e04-4d05-9e69-ace599c5def1
200 OK
```


```json
{
  "data": {
    "id": "ad6f8bbb-a59a-432f-a7ec-732214c13226",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "d2987b9c-e586-4627-9cd5-e09f3a9178c9"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/d2987b9c-e586-4627-9cd5-e09f3a9178c9"
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
X-Request-Id: 4dbf8a1e-e360-4e75-9767-c2603cedeb4d
200 OK
```


```json
{
  "data": {
    "id": "413f95d0-cb6c-4b64-bb3d-6fc0caaa3da4",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "9bc5d4e0-ba19-4b54-a237-6fc25e42f32d"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/9bc5d4e0-ba19-4b54-a237-6fc25e42f32d"
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
X-Request-Id: eef2555f-8a6a-4a35-8cba-a64828848ef1
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
GET /utils/path/from/object_occurrence/5377d2ac-c790-4675-b997-b15b3a78079a/to/object_occurrence/6cfb60e0-185b-43dd-9302-4543b9844aef
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
X-Request-Id: 1d7b7000-afb7-4904-9a8f-786285b04962
200 OK
```


```json
[
  {
    "id": "5377d2ac-c790-4675-b997-b15b3a78079a",
    "type": "object_occurrence"
  },
  {
    "id": "e9eeccbb-4e58-450b-bfef-89450b125bdd",
    "type": "object_occurrence"
  },
  {
    "id": "24766f91-a572-4eb9-b807-3fbf7e486167",
    "type": "object_occurrence"
  },
  {
    "id": "b61dddad-d82e-4ed4-8213-d72ae39c5a5f",
    "type": "object_occurrence"
  },
  {
    "id": "c2f988ca-bfd7-4bcc-a886-bb0cd7787d1b",
    "type": "object_occurrence"
  },
  {
    "id": "8fb6fa9e-fcb0-4248-962c-a0daecf6b40c",
    "type": "object_occurrence"
  },
  {
    "id": "6cfb60e0-185b-43dd-9302-4543b9844aef",
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
X-Request-Id: 2c025d8a-6987-4198-9ee2-90ebc387d6c5
200 OK
```


```json
{
  "data": [
    {
      "id": "d33757ff-0877-4ca7-8cd7-643c0e8b43f1",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/08fbd14c-e7e8-48f8-b47f-c3a1575125e0"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/bec15fd3-2f95-4863-971b-5de783a4451b"
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
X-Request-Id: 0d1169fd-2739-417b-8087-cb667629bb51
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



