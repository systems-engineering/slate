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
X-Request-Id: 69dd7ab4-d09c-49c2-90fe-c3bd42d2bced
200 OK
```


```json
{
  "data": {
    "id": "f6ad355d-bde5-46b7-aa0f-ef770e265b58",
    "type": "account",
    "attributes": {
      "name": "Account 570d20a58174"
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
X-Request-Id: 12c33c65-dfbe-4c04-931b-85506f923911
200 OK
```


```json
{
  "data": {
    "id": "a21deead-c30a-49f1-969e-e244ccd811ce",
    "type": "account",
    "attributes": {
      "name": "Account 94e75749a645"
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
    "id": "a6121d30-8af3-41ad-9939-1a9a5635f58f",
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
X-Request-Id: 171e1850-e3eb-4f39-a2ed-f50b8b5813e0
200 OK
```


```json
{
  "data": {
    "id": "a6121d30-8af3-41ad-9939-1a9a5635f58f",
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
POST /projects/96e138f3-7214-4ce8-b8da-1972b1ae58c6/relationships/tags
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
X-Request-Id: 055f54c6-2e0d-43d8-ac29-2211f54e9035
201 Created
```


```json
{
  "data": {
    "id": "6f19e2c4-8acb-4938-80c0-af1e82d31d90",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/96e138f3-7214-4ce8-b8da-1972b1ae58c6/relationships/tags"
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
POST /projects/a8146628-26f9-4b5a-8d21-c1b15aaceed5/relationships/tags
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
    "id": "a28adaf5-5a04-46e4-84f2-02961d3fd788"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3fdcff0f-7b73-486a-9e75-3f6c8ebfbebd
201 Created
```


```json
{
  "data": {
    "id": "a28adaf5-5a04-46e4-84f2-02961d3fd788",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/a8146628-26f9-4b5a-8d21-c1b15aaceed5/relationships/tags"
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
DELETE /projects/63cd835c-bf10-4501-9507-3890e9057674/relationships/tags/5fff2e3b-80c4-4995-8e6a-645694dae1d1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f0f928a5-fb68-451f-b9c8-90b2b86b490d
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
X-Request-Id: 7283c9c5-404f-466b-b7a5-862aa646ee4f
200 OK
```


```json
{
  "data": [
    {
      "id": "098e8465-79c8-4814-8a1d-f1b11855efe2",
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
            "related": "/tags?filter[target_id_eq]=098e8465-79c8-4814-8a1d-f1b11855efe2&filter[target_type_eq]=project",
            "self": "/projects/098e8465-79c8-4814-8a1d-f1b11855efe2/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=098e8465-79c8-4814-8a1d-f1b11855efe2",
            "self": "/projects/098e8465-79c8-4814-8a1d-f1b11855efe2/relationships/contexts"
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
GET /projects/a751dcbe-7fa7-479a-ab38-6689081b6b21
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
X-Request-Id: d6ace287-f0b9-4b6d-8bc3-5054f084f48c
200 OK
```


```json
{
  "data": {
    "id": "a751dcbe-7fa7-479a-ab38-6689081b6b21",
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
          "related": "/tags?filter[target_id_eq]=a751dcbe-7fa7-479a-ab38-6689081b6b21&filter[target_type_eq]=project",
          "self": "/projects/a751dcbe-7fa7-479a-ab38-6689081b6b21/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=a751dcbe-7fa7-479a-ab38-6689081b6b21",
          "self": "/projects/a751dcbe-7fa7-479a-ab38-6689081b6b21/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a751dcbe-7fa7-479a-ab38-6689081b6b21"
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
PATCH /projects/71069d68-afc4-4976-977a-f1f2989902c2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "71069d68-afc4-4976-977a-f1f2989902c2",
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
X-Request-Id: f90d4f24-a090-437d-9b3f-35b6b207ff6c
200 OK
```


```json
{
  "data": {
    "id": "71069d68-afc4-4976-977a-f1f2989902c2",
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
          "related": "/tags?filter[target_id_eq]=71069d68-afc4-4976-977a-f1f2989902c2&filter[target_type_eq]=project",
          "self": "/projects/71069d68-afc4-4976-977a-f1f2989902c2/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=71069d68-afc4-4976-977a-f1f2989902c2",
          "self": "/projects/71069d68-afc4-4976-977a-f1f2989902c2/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/71069d68-afc4-4976-977a-f1f2989902c2"
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
POST /projects/01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd/archive
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
X-Request-Id: db38a15a-7166-485d-b4c0-64fcbbef8fd2
200 OK
```


```json
{
  "data": {
    "id": "01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-28T16:59:35.514Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd&filter[target_type_eq]=project",
          "self": "/projects/01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd",
          "self": "/projects/01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/01baba9f-36a8-4d42-9d0d-d0c3e0f1b7cd/archive"
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
DELETE /projects/12f09502-a7ca-434e-bf81-93ea4cbed630
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 14741891-0fa2-400b-ab80-623dac5eadaf
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
POST /contexts/3ac67e3d-68a9-45b2-bce7-58e3e96eae44/relationships/tags
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
X-Request-Id: 008e04cb-aaf7-4c4b-9c8a-4ba73ca58a4a
201 Created
```


```json
{
  "data": {
    "id": "25fe01bb-aea1-4bf0-b78d-d2fb398bbca3",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/3ac67e3d-68a9-45b2-bce7-58e3e96eae44/relationships/tags"
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
POST /contexts/96801389-65e2-43bb-a18e-081d08a05451/relationships/tags
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
    "id": "9f186c2a-112f-4cb9-a148-0ce5458a8f5c"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e23624e8-3945-4ff8-8ab1-58f7711dba9c
201 Created
```


```json
{
  "data": {
    "id": "9f186c2a-112f-4cb9-a148-0ce5458a8f5c",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/96801389-65e2-43bb-a18e-081d08a05451/relationships/tags"
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
DELETE /contexts/75e43fa4-6392-453c-8363-ba2b994ac6b9/relationships/tags/3fa75fad-dc55-4d35-9ce1-045178a290d2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c09b4c9a-f185-47bc-9474-88e0e1328fe7
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
X-Request-Id: 515604f7-f352-42cd-a009-46e38bdad315
200 OK
```


```json
{
  "data": [
    {
      "id": "a7b73fa0-97c2-4eb2-b3be-bc7ea8d768e5",
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
            "related": "/tags?filter[target_id_eq]=a7b73fa0-97c2-4eb2-b3be-bc7ea8d768e5&filter[target_type_eq]=context",
            "self": "/contexts/a7b73fa0-97c2-4eb2-b3be-bc7ea8d768e5/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/31ae582d-4aaf-4828-bf9f-0910a6a06d74"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/ae2ff769-cba3-46eb-911f-ce5c61d4bd12"
          }
        }
      }
    },
    {
      "id": "531c0a97-c1b0-4b0e-a49a-34f294e1f8aa",
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
            "related": "/tags?filter[target_id_eq]=531c0a97-c1b0-4b0e-a49a-34f294e1f8aa&filter[target_type_eq]=context",
            "self": "/contexts/531c0a97-c1b0-4b0e-a49a-34f294e1f8aa/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/31ae582d-4aaf-4828-bf9f-0910a6a06d74"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/e7b15d29-9573-4e33-abaa-8f99471b1ea8"
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
GET /contexts/279d5454-c630-45fe-84f2-2f5ffe66a5f3
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
X-Request-Id: 3a357927-d85f-4061-b51f-a0d2db2857ed
200 OK
```


```json
{
  "data": {
    "id": "279d5454-c630-45fe-84f2-2f5ffe66a5f3",
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
          "related": "/tags?filter[target_id_eq]=279d5454-c630-45fe-84f2-2f5ffe66a5f3&filter[target_type_eq]=context",
          "self": "/contexts/279d5454-c630-45fe-84f2-2f5ffe66a5f3/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/f96abcd5-8ac9-4764-b607-bc1610824ef9"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/2cd1e465-8432-4cc0-9dc0-e1f51716e975"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/279d5454-c630-45fe-84f2-2f5ffe66a5f3"
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
PATCH /contexts/476055fb-22a5-4a22-87bc-72415408bb98
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "476055fb-22a5-4a22-87bc-72415408bb98",
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
X-Request-Id: e180f216-51a9-4b01-87cc-c4e1806abd47
200 OK
```


```json
{
  "data": {
    "id": "476055fb-22a5-4a22-87bc-72415408bb98",
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
          "related": "/tags?filter[target_id_eq]=476055fb-22a5-4a22-87bc-72415408bb98&filter[target_type_eq]=context",
          "self": "/contexts/476055fb-22a5-4a22-87bc-72415408bb98/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/dd0db1e2-6016-4105-9f35-305e5b06665b"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/2283eb0b-7b7a-42ed-9b3a-c9536a099015"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/476055fb-22a5-4a22-87bc-72415408bb98"
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
POST /projects/0eb595bd-1b69-4719-9c42-ce3a36ce68d1/relationships/contexts
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
X-Request-Id: a990b4a3-1eb4-4634-8e3e-db1e14ddd660
201 Created
```


```json
{
  "data": {
    "id": "c32b84ae-2eda-4d70-90b0-e4ad31fbc2c0",
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
          "related": "/tags?filter[target_id_eq]=c32b84ae-2eda-4d70-90b0-e4ad31fbc2c0&filter[target_type_eq]=context",
          "self": "/contexts/c32b84ae-2eda-4d70-90b0-e4ad31fbc2c0/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/0eb595bd-1b69-4719-9c42-ce3a36ce68d1"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/cfd0811a-fbe9-42b5-ba9c-a156fe0e419a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/0eb595bd-1b69-4719-9c42-ce3a36ce68d1/relationships/contexts"
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
POST /contexts/633ccc3a-161c-40bc-85dd-77e18d726929/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/737cc3076949574f2bb8e0b9
Content-Type: text/html; charset=utf-8
X-Request-Id: 49e0f6b0-772d-4a48-952d-c69b4a7acb18
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/737cc3076949574f2bb8e0b9">redirected</a>.</body></html>
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
DELETE /contexts/bf8dcff8-e12c-4808-9e0f-20d7ee1c8692
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d5a8880e-f3d7-423b-abce-87aa7d15338c
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
POST /object_occurrences/a99f8b8e-a87f-4c7a-a2f0-09b83510b123/relationships/tags
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
X-Request-Id: 527908da-eb85-489e-8a05-299dd7307e96
201 Created
```


```json
{
  "data": {
    "id": "70c4feef-e0dd-494a-a083-101ea48e8da7",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a99f8b8e-a87f-4c7a-a2f0-09b83510b123/relationships/tags"
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
POST /object_occurrences/aed3182d-2bef-4a75-9e6f-ed546fd73369/relationships/tags
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
    "id": "fb923f56-edfb-4264-a271-b59ea7064c2b"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 40093f67-cf1b-40b2-8c6b-cbb2c8a635f8
201 Created
```


```json
{
  "data": {
    "id": "fb923f56-edfb-4264-a271-b59ea7064c2b",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/aed3182d-2bef-4a75-9e6f-ed546fd73369/relationships/tags"
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
DELETE /object_occurrences/fde22b87-5510-48d5-a22e-ed2167ac2e1c/relationships/tags/181f3aa0-d620-4088-bad9-1a7234a113c5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 67bec246-4b0b-4da9-aaff-6321bbd6401b
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
GET /object_occurrences/7847f603-ee4c-471a-b499-37b33b090703
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
X-Request-Id: ff06c1e5-a6df-4e8a-9229-55a2996f20af
200 OK
```


```json
{
  "data": {
    "id": "7847f603-ee4c-471a-b499-37b33b090703",
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
          "related": "/tags?filter[target_id_eq]=7847f603-ee4c-471a-b499-37b33b090703&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/7847f603-ee4c-471a-b499-37b33b090703/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/d778b31f-5f46-4a5f-9db3-743b5591d2d2"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/84504176-823a-4805-a34e-e11c11f60f4a",
          "self": "/object_occurrences/7847f603-ee4c-471a-b499-37b33b090703/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "782b6495-b717-4e45-842c-3d29ae94773d",
            "type": "object_occurrence"
          },
          {
            "id": "b837bd49-adff-4252-860c-332ed14847ab",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/7847f603-ee4c-471a-b499-37b33b090703/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/7847f603-ee4c-471a-b499-37b33b090703"
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
POST /object_occurrences/d5f22234-8972-44df-8eef-42d1d9c700dc/relationships/components
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

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0e9456d9-dbc9-43d9-84d6-34c4c68fbf52
201 Created
```


```json
{
  "data": {
    "id": "9c41b477-50e4-4e4a-aebb-2f696d8ed4c0",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
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
          "related": "/tags?filter[target_id_eq]=9c41b477-50e4-4e4a-aebb-2f696d8ed4c0&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/9c41b477-50e4-4e4a-aebb-2f696d8ed4c0/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/d45e03f9-0c71-4d41-a31c-95eb4ab3d0ef"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/d5f22234-8972-44df-8eef-42d1d9c700dc",
          "self": "/object_occurrences/9c41b477-50e4-4e4a-aebb-2f696d8ed4c0/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/9c41b477-50e4-4e4a-aebb-2f696d8ed4c0/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d5f22234-8972-44df-8eef-42d1d9c700dc/relationships/components"
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
PATCH /object_occurrences/0f562eac-cb74-4874-b970-ce10d5bc126c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "0f562eac-cb74-4874-b970-ce10d5bc126c",
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
          "id": "4c0fcbe4-3055-40f4-a783-e64f1b5ea7bb"
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
X-Request-Id: 74d3174b-0afe-43a5-b1e7-cf3583688091
200 OK
```


```json
{
  "data": {
    "id": "0f562eac-cb74-4874-b970-ce10d5bc126c",
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
          "related": "/tags?filter[target_id_eq]=0f562eac-cb74-4874-b970-ce10d5bc126c&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/0f562eac-cb74-4874-b970-ce10d5bc126c/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/fc5d9b74-c761-4392-95b1-4f5838a135eb"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/4c0fcbe4-3055-40f4-a783-e64f1b5ea7bb",
          "self": "/object_occurrences/0f562eac-cb74-4874-b970-ce10d5bc126c/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/0f562eac-cb74-4874-b970-ce10d5bc126c/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/0f562eac-cb74-4874-b970-ce10d5bc126c"
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
POST /object_occurrences/a3121494-d321-49b6-9533-15a68e382d84/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "c3a147a0-b00f-4eb2-aafd-9f9a8171756b",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/77c1b4fb74e4c27eb0ccfa32
Content-Type: text/html; charset=utf-8
X-Request-Id: a238f57f-b01a-49a5-b478-c922201aa3ea
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/77c1b4fb74e4c27eb0ccfa32">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/5f9a92fb-9dbe-48c3-8e7b-e61a939b5d92
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: be59572e-ee6d-4f0c-9911-62489c63c6a1
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
PATCH /object_occurrences/81a61535-7e8d-4873-b0da-929cca684127/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "551e86e3-e961-4118-b5ce-6f739eb10a75",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fa02e579-3df8-49aa-bcd6-f6708f576621
200 OK
```


```json
{
  "data": {
    "id": "81a61535-7e8d-4873-b0da-929cca684127",
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
          "related": "/tags?filter[target_id_eq]=81a61535-7e8d-4873-b0da-929cca684127&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/81a61535-7e8d-4873-b0da-929cca684127/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/481a6ef5-5c6e-427b-95df-34655ebe9695"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/551e86e3-e961-4118-b5ce-6f739eb10a75",
          "self": "/object_occurrences/81a61535-7e8d-4873-b0da-929cca684127/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/81a61535-7e8d-4873-b0da-929cca684127/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/81a61535-7e8d-4873-b0da-929cca684127/relationships/part_of"
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
POST /classification_tables/63585d9f-12fc-4cea-9884-ea19cc98649d/relationships/tags
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
X-Request-Id: c1bfcb68-9cef-4a4a-84c0-f03f635b586d
201 Created
```


```json
{
  "data": {
    "id": "b75230b6-c979-41c3-a5da-469f34a72c50",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/63585d9f-12fc-4cea-9884-ea19cc98649d/relationships/tags"
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
POST /classification_tables/a0ff18ab-a15d-44d3-88c7-f56d172105cc/relationships/tags
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
    "id": "cd1edaf5-0e42-4e2d-abf6-eb8fbcd84dcd"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6577fabb-f41d-4ead-9c95-e7fb3925f863
201 Created
```


```json
{
  "data": {
    "id": "cd1edaf5-0e42-4e2d-abf6-eb8fbcd84dcd",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a0ff18ab-a15d-44d3-88c7-f56d172105cc/relationships/tags"
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
DELETE /classification_tables/dee65d10-6b44-42fe-a986-69a2f60deb9f/relationships/tags/9500c69c-c19a-48f7-a51b-52d4afa01418
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4c572513-f87e-40bb-903a-eac5c331bd6b
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
X-Request-Id: c7c85ec9-f7c9-4f5f-8585-b1f1b5726fc1
200 OK
```


```json
{
  "data": [
    {
      "id": "85699dfb-6ad6-4d8b-839e-09c3db6898e1",
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
            "related": "/tags?filter[target_id_eq]=85699dfb-6ad6-4d8b-839e-09c3db6898e1&filter[target_type_eq]=classification_table",
            "self": "/classification_tables/85699dfb-6ad6-4d8b-839e-09c3db6898e1/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=85699dfb-6ad6-4d8b-839e-09c3db6898e1",
            "self": "/classification_tables/85699dfb-6ad6-4d8b-839e-09c3db6898e1/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "38f89dfa-977c-4b37-9216-d899a26fde35",
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
            "related": "/tags?filter[target_id_eq]=38f89dfa-977c-4b37-9216-d899a26fde35&filter[target_type_eq]=classification_table",
            "self": "/classification_tables/38f89dfa-977c-4b37-9216-d899a26fde35/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=38f89dfa-977c-4b37-9216-d899a26fde35",
            "self": "/classification_tables/38f89dfa-977c-4b37-9216-d899a26fde35/relationships/classification_entries",
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
GET /classification_tables/70cdcf70-8905-431f-b0a4-c0de00cd39d8
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
X-Request-Id: 6a83c763-b36e-4ea9-a618-ab8c6a0eb0f8
200 OK
```


```json
{
  "data": {
    "id": "70cdcf70-8905-431f-b0a4-c0de00cd39d8",
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
          "related": "/tags?filter[target_id_eq]=70cdcf70-8905-431f-b0a4-c0de00cd39d8&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/70cdcf70-8905-431f-b0a4-c0de00cd39d8/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=70cdcf70-8905-431f-b0a4-c0de00cd39d8",
          "self": "/classification_tables/70cdcf70-8905-431f-b0a4-c0de00cd39d8/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/70cdcf70-8905-431f-b0a4-c0de00cd39d8"
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
PATCH /classification_tables/3d2ac9de-4f98-4edb-b0c2-10c61158ce03
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "3d2ac9de-4f98-4edb-b0c2-10c61158ce03",
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
X-Request-Id: 2737417e-43c5-4b59-9965-da4bd4bd5b71
200 OK
```


```json
{
  "data": {
    "id": "3d2ac9de-4f98-4edb-b0c2-10c61158ce03",
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
          "related": "/tags?filter[target_id_eq]=3d2ac9de-4f98-4edb-b0c2-10c61158ce03&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/3d2ac9de-4f98-4edb-b0c2-10c61158ce03/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=3d2ac9de-4f98-4edb-b0c2-10c61158ce03",
          "self": "/classification_tables/3d2ac9de-4f98-4edb-b0c2-10c61158ce03/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/3d2ac9de-4f98-4edb-b0c2-10c61158ce03"
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
DELETE /classification_tables/b7f329d6-c16f-4078-b33d-7a2c64830e2a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2575b4da-c7f0-4a94-82fc-8fc4e8a5459a
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
POST /classification_tables/7f4c6e24-795f-4f54-9330-ccefc5425aec/publish
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
X-Request-Id: 071d9b3b-b429-45fd-a91a-608df73096c1
200 OK
```


```json
{
  "data": {
    "id": "7f4c6e24-795f-4f54-9330-ccefc5425aec",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-28T16:59:56.944Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=7f4c6e24-795f-4f54-9330-ccefc5425aec&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/7f4c6e24-795f-4f54-9330-ccefc5425aec/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=7f4c6e24-795f-4f54-9330-ccefc5425aec",
          "self": "/classification_tables/7f4c6e24-795f-4f54-9330-ccefc5425aec/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/7f4c6e24-795f-4f54-9330-ccefc5425aec/publish"
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
POST /classification_tables/09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0/archive
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
X-Request-Id: 0928a9e2-4497-4bc1-b260-e0848b0279fd
200 OK
```


```json
{
  "data": {
    "id": "09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-28T16:59:57.581Z",
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
          "related": "/tags?filter[target_id_eq]=09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0",
          "self": "/classification_tables/09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/09ba9a9e-c9a2-40e9-b2cb-29d7d415feb0/archive"
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
X-Request-Id: 3e344b3d-1f1f-40ee-a08b-c4fdfe808938
201 Created
```


```json
{
  "data": {
    "id": "4dfaeabc-6ab1-46a5-b99a-103442f14918",
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
          "related": "/tags?filter[target_id_eq]=4dfaeabc-6ab1-46a5-b99a-103442f14918&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/4dfaeabc-6ab1-46a5-b99a-103442f14918/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=4dfaeabc-6ab1-46a5-b99a-103442f14918",
          "self": "/classification_tables/4dfaeabc-6ab1-46a5-b99a-103442f14918/relationships/classification_entries",
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
POST /classification_entries/6b9411e3-23c9-4f18-b94d-1cd77f131db3/relationships/tags
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
X-Request-Id: f23126a5-3e02-4e07-b07d-6e3d66945435
201 Created
```


```json
{
  "data": {
    "id": "c49aa321-0e3d-4977-9798-a9022f8f076f",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/6b9411e3-23c9-4f18-b94d-1cd77f131db3/relationships/tags"
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
POST /classification_entries/f853a4fe-5516-4bc4-a535-cafcae7ba217/relationships/tags
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
    "id": "08f1900d-b202-44a1-b56b-cec36242ed64"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f66578ee-2453-42db-9100-bce703c4e3dc
201 Created
```


```json
{
  "data": {
    "id": "08f1900d-b202-44a1-b56b-cec36242ed64",
    "type": "tag",
    "attributes": {
      "value": "Tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/f853a4fe-5516-4bc4-a535-cafcae7ba217/relationships/tags"
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
DELETE /classification_entries/d727728d-3252-401e-92eb-cabe60c6525b/relationships/tags/23b2f02e-ba83-43df-a84a-da158ab9555f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0d3ef10f-904d-4daa-bec0-1a9ec3596fd6
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
X-Request-Id: 84aad4e2-c499-4eb3-9727-161a2eda1eaa
200 OK
```


```json
{
  "data": [
    {
      "id": "588ed68f-9d28-42d5-8b1a-aa2e68d235b7",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal",
        "name": "CE 1",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=588ed68f-9d28-42d5-8b1a-aa2e68d235b7&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/588ed68f-9d28-42d5-8b1a-aa2e68d235b7/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=588ed68f-9d28-42d5-8b1a-aa2e68d235b7",
            "self": "/classification_entries/588ed68f-9d28-42d5-8b1a-aa2e68d235b7/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "5fac5b56-059e-4cce-b1ed-51049b2f70ab",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal",
        "name": "CE 11",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=5fac5b56-059e-4cce-b1ed-51049b2f70ab&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/5fac5b56-059e-4cce-b1ed-51049b2f70ab/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "588ed68f-9d28-42d5-8b1a-aa2e68d235b7",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/5fac5b56-059e-4cce-b1ed-51049b2f70ab"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=5fac5b56-059e-4cce-b1ed-51049b2f70ab",
            "self": "/classification_entries/5fac5b56-059e-4cce-b1ed-51049b2f70ab/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "236ef50f-6717-47e2-8b2b-f6d58bd03c31",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal",
        "name": "CE 2",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=236ef50f-6717-47e2-8b2b-f6d58bd03c31&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/236ef50f-6717-47e2-8b2b-f6d58bd03c31/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=236ef50f-6717-47e2-8b2b-f6d58bd03c31",
            "self": "/classification_entries/236ef50f-6717-47e2-8b2b-f6d58bd03c31/relationships/classification_entries",
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
    "current": "http://example.org/classification_entries?page[number]=1&sort=code"
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
GET /classification_entries/462b887e-e302-4535-810f-fa9837d4b1f4
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
X-Request-Id: ba886280-e746-4a76-97c4-6712f878d5cf
200 OK
```


```json
{
  "data": {
    "id": "462b887e-e302-4535-810f-fa9837d4b1f4",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "Alarm signal",
      "name": "CE 1",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=462b887e-e302-4535-810f-fa9837d4b1f4&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/462b887e-e302-4535-810f-fa9837d4b1f4/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=462b887e-e302-4535-810f-fa9837d4b1f4",
          "self": "/classification_entries/462b887e-e302-4535-810f-fa9837d4b1f4/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/462b887e-e302-4535-810f-fa9837d4b1f4"
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
PATCH /classification_entries/2d1f7573-a941-42ef-9a7c-2185630c169b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "2d1f7573-a941-42ef-9a7c-2185630c169b",
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
X-Request-Id: d632a416-2c1d-4b3c-98a5-d4bec6dac848
200 OK
```


```json
{
  "data": {
    "id": "2d1f7573-a941-42ef-9a7c-2185630c169b",
    "type": "classification_entry",
    "attributes": {
      "code": "AA",
      "definition": "Alarm signal",
      "name": "New classification entry name",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=2d1f7573-a941-42ef-9a7c-2185630c169b&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/2d1f7573-a941-42ef-9a7c-2185630c169b/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "33e77c3d-3b1e-48be-9a01-b5bb9b515e06",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/2d1f7573-a941-42ef-9a7c-2185630c169b"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=2d1f7573-a941-42ef-9a7c-2185630c169b",
          "self": "/classification_entries/2d1f7573-a941-42ef-9a7c-2185630c169b/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/2d1f7573-a941-42ef-9a7c-2185630c169b"
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
DELETE /classification_entries/d783d333-666b-4181-a799-76c30d339736
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b8eecd08-709c-4a56-8d62-56a7bb0693c1
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
POST /classification_tables/158e20a9-9a8f-4139-9a9f-95c9125079d3/relationships/classification_entries
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
X-Request-Id: 0a1b1a50-7a05-4b24-9308-655b69722b31
201 Created
```


```json
{
  "data": {
    "id": "5f859ba8-35a4-45c4-9e21-94ed5e59d0c1",
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
          "related": "/tags?filter[target_id_eq]=5f859ba8-35a4-45c4-9e21-94ed5e59d0c1&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/5f859ba8-35a4-45c4-9e21-94ed5e59d0c1/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=5f859ba8-35a4-45c4-9e21-94ed5e59d0c1",
          "self": "/classification_entries/5f859ba8-35a4-45c4-9e21-94ed5e59d0c1/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/158e20a9-9a8f-4139-9a9f-95c9125079d3/relationships/classification_entries"
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
X-Request-Id: f8ae4891-1390-44c1-93b3-6d0686e6280d
200 OK
```


```json
{
  "data": [
    {
      "id": "4dc25553-1241-4aad-9659-28a5647768fd",
      "type": "syntax",
      "attributes": {
        "account_id": "6c402f51-fcb0-4c02-a296-2f060376d915",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 7d5be04f8900",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=4dc25553-1241-4aad-9659-28a5647768fd",
            "self": "/syntaxes/4dc25553-1241-4aad-9659-28a5647768fd/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/8b247a0e-2be0-4696-9c53-b8ed7e234fba",
            "self": "/syntax_nodes/8b247a0e-2be0-4696-9c53-b8ed7e234fba/relationships/components"
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
GET /syntaxes/84b01acd-4dd2-41ab-b585-9c15fa5d4c73
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
X-Request-Id: 4b221819-205c-4cfe-afdc-b5b5e99e31d3
200 OK
```


```json
{
  "data": {
    "id": "84b01acd-4dd2-41ab-b585-9c15fa5d4c73",
    "type": "syntax",
    "attributes": {
      "account_id": "b9147adc-81df-4fce-affd-d8c7e41dec02",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 9e677fd28ce1",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=84b01acd-4dd2-41ab-b585-9c15fa5d4c73",
          "self": "/syntaxes/84b01acd-4dd2-41ab-b585-9c15fa5d4c73/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/594d2703-875f-4449-b98b-d0605d956793",
          "self": "/syntax_nodes/594d2703-875f-4449-b98b-d0605d956793/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/84b01acd-4dd2-41ab-b585-9c15fa5d4c73"
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
X-Request-Id: 3b89a6be-3ed4-4322-9fde-511ae3284464
201 Created
```


```json
{
  "data": {
    "id": "6178beaa-26e3-4f23-a81e-38e82aa61322",
    "type": "syntax",
    "attributes": {
      "account_id": "969608cf-2d3b-4db5-bc27-645d4e25012e",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=6178beaa-26e3-4f23-a81e-38e82aa61322",
          "self": "/syntaxes/6178beaa-26e3-4f23-a81e-38e82aa61322/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/c4e45bfb-f6b3-4ad8-818c-71fef1ca0503",
          "self": "/syntax_nodes/c4e45bfb-f6b3-4ad8-818c-71fef1ca0503/relationships/components"
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
PATCH /syntaxes/7814eec1-8c98-4e1d-bbb6-fd310bfc2303
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "7814eec1-8c98-4e1d-bbb6-fd310bfc2303",
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
X-Request-Id: d05d4491-7bb3-4309-9ffe-2ebe60994d50
200 OK
```


```json
{
  "data": {
    "id": "7814eec1-8c98-4e1d-bbb6-fd310bfc2303",
    "type": "syntax",
    "attributes": {
      "account_id": "ccaae265-0600-46e2-bf2e-962ece21f758",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=7814eec1-8c98-4e1d-bbb6-fd310bfc2303",
          "self": "/syntaxes/7814eec1-8c98-4e1d-bbb6-fd310bfc2303/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/85650266-b3da-4bb4-a908-e11b15fe90b5",
          "self": "/syntax_nodes/85650266-b3da-4bb4-a908-e11b15fe90b5/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/7814eec1-8c98-4e1d-bbb6-fd310bfc2303"
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
DELETE /syntaxes/60c808a3-7e62-41f7-b271-68a57582fb1d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 737f286d-442c-494b-8b12-6ea215b88e30
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
POST /syntaxes/1bf66e4b-03f9-41a3-8097-3e3d812c4d05/publish
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
X-Request-Id: f4a58928-25b8-4bb5-91e9-6ded82c013d1
200 OK
```


```json
{
  "data": {
    "id": "1bf66e4b-03f9-41a3-8097-3e3d812c4d05",
    "type": "syntax",
    "attributes": {
      "account_id": "c678f7fb-ede2-4e96-8deb-73e777044ff5",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 188bd220b933",
      "published": true,
      "published_at": "2020-02-28T17:00:06.861Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=1bf66e4b-03f9-41a3-8097-3e3d812c4d05",
          "self": "/syntaxes/1bf66e4b-03f9-41a3-8097-3e3d812c4d05/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/2c8ca7c0-ccea-491a-81d1-8e31a7c1cd16",
          "self": "/syntax_nodes/2c8ca7c0-ccea-491a-81d1-8e31a7c1cd16/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/1bf66e4b-03f9-41a3-8097-3e3d812c4d05/publish"
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
POST /syntaxes/2f1fa826-aa3b-4c94-9ea1-ebed123701f8/archive
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
X-Request-Id: f5797245-40d2-4f3a-a942-4f50075b393a
200 OK
```


```json
{
  "data": {
    "id": "2f1fa826-aa3b-4c94-9ea1-ebed123701f8",
    "type": "syntax",
    "attributes": {
      "account_id": "3263ddf6-dced-4a96-a90b-e98688ac45c8",
      "archived": true,
      "archived_at": "2020-02-28T17:00:07.473Z",
      "description": "Description",
      "name": "Syntax e9845e685063",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=2f1fa826-aa3b-4c94-9ea1-ebed123701f8",
          "self": "/syntaxes/2f1fa826-aa3b-4c94-9ea1-ebed123701f8/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/69eaaaf2-27e8-4090-ac1c-bc6c9ef03fc6",
          "self": "/syntax_nodes/69eaaaf2-27e8-4090-ac1c-bc6c9ef03fc6/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/2f1fa826-aa3b-4c94-9ea1-ebed123701f8/archive"
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
X-Request-Id: 2fb4269a-4673-4645-95b3-d26a18ac538c
200 OK
```


```json
{
  "data": [
    {
      "id": "d876a10e-426c-4cd4-8edd-6542f4add598",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "cb1fa27b-c6cc-4a85-a67c-88cc00c8c160",
        "hex_color": "d83679",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 5c4013ebf53e"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/9b152144-c894-44fd-aa7f-a866e54bfd6f"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/cb1fa27b-c6cc-4a85-a67c-88cc00c8c160",
            "self": "/syntax_elements/d876a10e-426c-4cd4-8edd-6542f4add598/relationships/classification_table"
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
GET /syntax_elements/4a763e10-dcaa-4419-8010-446b3bed6e0b
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
X-Request-Id: 0667eff7-47d4-431d-9468-a31a950830fd
200 OK
```


```json
{
  "data": {
    "id": "4a763e10-dcaa-4419-8010-446b3bed6e0b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "c50e00a8-9a83-4b44-99aa-e19f4d233f44",
      "hex_color": "b04265",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 3a9f29c5599e"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/5b603184-5c26-4f06-8ee0-5c8955b9b9cc"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/c50e00a8-9a83-4b44-99aa-e19f4d233f44",
          "self": "/syntax_elements/4a763e10-dcaa-4419-8010-446b3bed6e0b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/4a763e10-dcaa-4419-8010-446b3bed6e0b"
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
POST /syntaxes/5623bde8-7e54-47c9-bc78-a3bab1bd7198/relationships/syntax_elements
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
          "id": "913d917e-d5b0-45fd-985c-03678407cb36"
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
X-Request-Id: b06f82e6-0cb9-467b-bd56-751060e5626f
201 Created
```


```json
{
  "data": {
    "id": "11bb9a65-fd28-47fc-bd9f-d6661356f42b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "913d917e-d5b0-45fd-985c-03678407cb36",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/5623bde8-7e54-47c9-bc78-a3bab1bd7198"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/913d917e-d5b0-45fd-985c-03678407cb36",
          "self": "/syntax_elements/11bb9a65-fd28-47fc-bd9f-d6661356f42b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/5623bde8-7e54-47c9-bc78-a3bab1bd7198/relationships/syntax_elements"
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
PATCH /syntax_elements/e06bf77f-6363-40a3-a90e-3ea32d933216
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "e06bf77f-6363-40a3-a90e-3ea32d933216",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "bbda6428-480a-47aa-a2b9-e670088920b2"
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
X-Request-Id: 6a52b3f1-238f-406f-912d-fd489b3172aa
200 OK
```


```json
{
  "data": {
    "id": "e06bf77f-6363-40a3-a90e-3ea32d933216",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "bbda6428-480a-47aa-a2b9-e670088920b2",
      "hex_color": "d83376",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/c25d83a2-f4a8-4af5-bf43-8a06ae47f8be"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/bbda6428-480a-47aa-a2b9-e670088920b2",
          "self": "/syntax_elements/e06bf77f-6363-40a3-a90e-3ea32d933216/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/e06bf77f-6363-40a3-a90e-3ea32d933216"
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
DELETE /syntax_elements/92c968c6-e822-4cc0-ba04-94837802b815
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f78ce3ad-02b8-4680-ab91-47cd9f395744
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
PATCH /syntax_elements/0ced18ef-5329-40e3-86ed-35563e53f0b2/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "38357273-fc96-4366-a0f2-68775a8513b3",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1d6b6346-2f3c-450f-99d7-6673ae411d4c
200 OK
```


```json
{
  "data": {
    "id": "0ced18ef-5329-40e3-86ed-35563e53f0b2",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "38357273-fc96-4366-a0f2-68775a8513b3",
      "hex_color": "00f82a",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element a0e10d8ca133"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/9a78c985-0482-4c76-a82c-d0983a844759"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/38357273-fc96-4366-a0f2-68775a8513b3",
          "self": "/syntax_elements/0ced18ef-5329-40e3-86ed-35563e53f0b2/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/0ced18ef-5329-40e3-86ed-35563e53f0b2/relationships/classification_table"
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
DELETE /syntax_elements/ad146f24-dd90-49aa-bbfd-eb8cf00760af/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1215e48e-1e49-4703-9ffd-62791c4325bb
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
GET /syntax_nodes/035b590a-1587-47f2-bba5-18ff4d1f3258?depth=2
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
X-Request-Id: e0916080-3a52-4d40-9903-ba8cc502ad95
200 OK
```


```json
{
  "data": {
    "id": "035b590a-1587-47f2-bba5-18ff4d1f3258",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/968f3d98-c8e5-4d62-a377-7bf1836f08ea"
        }
      },
      "components": {
        "data": [
          {
            "id": "d3cd64eb-015a-4fdd-aa6a-585bc3b04d83",
            "type": "syntax_node"
          },
          {
            "id": "64b2b322-f19b-4bd7-a54e-fdcc528d7560",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/035b590a-1587-47f2-bba5-18ff4d1f3258/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/035b590a-1587-47f2-bba5-18ff4d1f3258/relationships/parent",
          "related": "/syntax_nodes/035b590a-1587-47f2-bba5-18ff4d1f3258"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/035b590a-1587-47f2-bba5-18ff4d1f3258?depth=2"
  },
  "included": [
    {
      "id": "64b2b322-f19b-4bd7-a54e-fdcc528d7560",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/968f3d98-c8e5-4d62-a377-7bf1836f08ea"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/64b2b322-f19b-4bd7-a54e-fdcc528d7560/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/64b2b322-f19b-4bd7-a54e-fdcc528d7560/relationships/parent",
            "related": "/syntax_nodes/64b2b322-f19b-4bd7-a54e-fdcc528d7560"
          }
        }
      }
    },
    {
      "id": "d3cd64eb-015a-4fdd-aa6a-585bc3b04d83",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/968f3d98-c8e5-4d62-a377-7bf1836f08ea"
          }
        },
        "components": {
          "data": [
            {
              "id": "862b945e-2e0d-44b9-9a2a-373c99764e17",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/d3cd64eb-015a-4fdd-aa6a-585bc3b04d83/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/d3cd64eb-015a-4fdd-aa6a-585bc3b04d83/relationships/parent",
            "related": "/syntax_nodes/d3cd64eb-015a-4fdd-aa6a-585bc3b04d83"
          }
        }
      }
    },
    {
      "id": "862b945e-2e0d-44b9-9a2a-373c99764e17",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/968f3d98-c8e5-4d62-a377-7bf1836f08ea"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/862b945e-2e0d-44b9-9a2a-373c99764e17/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/862b945e-2e0d-44b9-9a2a-373c99764e17/relationships/parent",
            "related": "/syntax_nodes/862b945e-2e0d-44b9-9a2a-373c99764e17"
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
POST /syntax_nodes/e68a979f-4e5a-455e-b462-bd6fb5923f64/relationships/components
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
X-Request-Id: 194b9605-7e04-47a5-9c83-83a00c92813d
201 Created
```


```json
{
  "data": {
    "id": "36a27d07-14c5-45ac-8a99-cfb76b115536",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/295428d3-51fb-4212-93df-25d41f7a6d94"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/36a27d07-14c5-45ac-8a99-cfb76b115536/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/36a27d07-14c5-45ac-8a99-cfb76b115536/relationships/parent",
          "related": "/syntax_nodes/36a27d07-14c5-45ac-8a99-cfb76b115536"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/e68a979f-4e5a-455e-b462-bd6fb5923f64/relationships/components"
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
PATCH /syntax_nodes/b4bee163-8fdd-4a48-b221-ebff2c8fd933/relationships/parent
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
    "id": "51713b0f-46b9-457e-958d-0fea0981a41b"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7ecb031c-fda3-49f5-bdd1-94cdac945733
200 OK
```


```json
{
  "data": {
    "id": "b4bee163-8fdd-4a48-b221-ebff2c8fd933",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/92644781-ca34-4dbb-9b55-f9ba1629ae5d"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/b4bee163-8fdd-4a48-b221-ebff2c8fd933/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/b4bee163-8fdd-4a48-b221-ebff2c8fd933/relationships/parent",
          "related": "/syntax_nodes/b4bee163-8fdd-4a48-b221-ebff2c8fd933"
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
PATCH /syntax_nodes/b2415b6f-09de-46eb-b68d-efc48c5e0d98
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "b2415b6f-09de-46eb-b68d-efc48c5e0d98",
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
X-Request-Id: f63bc3f0-3f03-4abd-9041-82b6a29c16e9
200 OK
```


```json
{
  "data": {
    "id": "b2415b6f-09de-46eb-b68d-efc48c5e0d98",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/7582ba1c-30f6-4dd7-a591-f036d4bfe1e8"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/b2415b6f-09de-46eb-b68d-efc48c5e0d98/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/b2415b6f-09de-46eb-b68d-efc48c5e0d98/relationships/parent",
          "related": "/syntax_nodes/b2415b6f-09de-46eb-b68d-efc48c5e0d98"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/b2415b6f-09de-46eb-b68d-efc48c5e0d98"
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
DELETE /syntax_nodes/6809382f-8f5d-48c7-be1e-975daedf96e7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b3bd1627-5de5-43d9-8834-3c57fc57c2e2
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
X-Request-Id: 97e93ba8-25c4-4789-a6b5-b266cfe46698
200 OK
```


```json
{
  "data": [
    {
      "id": "17ec7e59-fdc9-448f-87e5-80c86e936e3b",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-28T17:00:15.542Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=17ec7e59-fdc9-448f-87e5-80c86e936e3b",
            "self": "/progress_models/17ec7e59-fdc9-448f-87e5-80c86e936e3b/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "ee7f32f4-e324-4093-9f58-13497efff7f4",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=ee7f32f4-e324-4093-9f58-13497efff7f4",
            "self": "/progress_models/ee7f32f4-e324-4093-9f58-13497efff7f4/relationships/progress_steps"
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
GET /progress_models/0fe00318-2cff-4694-a04a-013553097db3
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
X-Request-Id: 11068422-97da-4164-846b-78e711cbacbf
200 OK
```


```json
{
  "data": {
    "id": "0fe00318-2cff-4694-a04a-013553097db3",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-28T17:00:16.115Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=0fe00318-2cff-4694-a04a-013553097db3",
          "self": "/progress_models/0fe00318-2cff-4694-a04a-013553097db3/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0fe00318-2cff-4694-a04a-013553097db3"
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
PATCH /progress_models/d600414d-db72-4990-925b-da1fa148c9af
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "d600414d-db72-4990-925b-da1fa148c9af",
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
X-Request-Id: 0b18471e-838d-4538-ae0f-681bfb11c8af
200 OK
```


```json
{
  "data": {
    "id": "d600414d-db72-4990-925b-da1fa148c9af",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=d600414d-db72-4990-925b-da1fa148c9af",
          "self": "/progress_models/d600414d-db72-4990-925b-da1fa148c9af/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/d600414d-db72-4990-925b-da1fa148c9af"
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
DELETE /progress_models/44bcb9ed-9e13-4209-a869-c8f12a1f426f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e1085c61-875d-4dc7-8fb6-8df4b827c702
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
POST /progress_models/d63425cb-9a66-405f-b5b7-07db2d99abaf/publish
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
X-Request-Id: d68714ff-13d2-4024-a1b7-7fe6ceff3603
200 OK
```


```json
{
  "data": {
    "id": "d63425cb-9a66-405f-b5b7-07db2d99abaf",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-28T17:00:18.306Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=d63425cb-9a66-405f-b5b7-07db2d99abaf",
          "self": "/progress_models/d63425cb-9a66-405f-b5b7-07db2d99abaf/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/d63425cb-9a66-405f-b5b7-07db2d99abaf/publish"
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
POST /progress_models/45220d39-2c85-4d69-921c-c4f2dbe3e3e5/archive
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
X-Request-Id: 969f3940-9849-48a4-957a-a708428b2e54
200 OK
```


```json
{
  "data": {
    "id": "45220d39-2c85-4d69-921c-c4f2dbe3e3e5",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-28T17:00:18.782Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=45220d39-2c85-4d69-921c-c4f2dbe3e3e5",
          "self": "/progress_models/45220d39-2c85-4d69-921c-c4f2dbe3e3e5/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/45220d39-2c85-4d69-921c-c4f2dbe3e3e5/archive"
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
X-Request-Id: 58b49a87-d68a-4aeb-bc67-5b2c223645a5
201 Created
```


```json
{
  "data": {
    "id": "01fb2a8b-e2ce-4027-9a48-a2859f8f3134",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=01fb2a8b-e2ce-4027-9a48-a2859f8f3134",
          "self": "/progress_models/01fb2a8b-e2ce-4027-9a48-a2859f8f3134/relationships/progress_steps"
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
X-Request-Id: 0af7552c-7370-4647-a2e0-54ce299f7cde
200 OK
```


```json
{
  "data": [
    {
      "id": "59ec2740-62b5-4850-a3d9-6e0f71cd9bee",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/b86b8b34-50a6-4611-813e-8196abfc0400"
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
GET /progress_steps/aca894bd-2ca2-40ee-8719-8aa2d9eb242c
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
X-Request-Id: 77391c62-3b6e-44a0-b4e1-7fa61e8612ad
200 OK
```


```json
{
  "data": {
    "id": "aca894bd-2ca2-40ee-8719-8aa2d9eb242c",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/4b5b65cb-2ee0-4cb7-8b33-f97bf5beacb6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/aca894bd-2ca2-40ee-8719-8aa2d9eb242c"
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
PATCH /progress_steps/401d2786-bb25-4e28-9bd5-0aef2b593eda
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "401d2786-bb25-4e28-9bd5-0aef2b593eda",
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
X-Request-Id: f53f792e-abb9-4ddb-b0bc-93362ef7a88e
200 OK
```


```json
{
  "data": {
    "id": "401d2786-bb25-4e28-9bd5-0aef2b593eda",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/b1e5b1f4-8fbf-4f9f-8eed-32b48e5e10b3"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/401d2786-bb25-4e28-9bd5-0aef2b593eda"
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
DELETE /progress_steps/5f03d95a-6cc9-4c36-8903-51b512afe1b3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4888d733-e4e0-4fe8-876a-2b121bd9d103
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
POST /progress_models/0adb9672-9428-42bd-9a81-38b4ba0a5a0b/relationships/progress_steps
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
X-Request-Id: a487e87e-2c48-495c-9d06-076a236d8efb
201 Created
```


```json
{
  "data": {
    "id": "7fccce65-96f8-44e5-b441-799596a43298",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/0adb9672-9428-42bd-9a81-38b4ba0a5a0b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0adb9672-9428-42bd-9a81-38b4ba0a5a0b/relationships/progress_steps"
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
X-Request-Id: b7b62324-4ed0-403b-9eb3-568e588ccc76
200 OK
```


```json
{
  "data": [
    {
      "id": "59fea5dc-7f0d-4614-8f06-1af06be87f22",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/bb083fef-19de-413b-9b08-ddb300be609f"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/ef5e1c63-2635-4cb3-90ac-8e2534f92333"
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
GET /progress/79b93591-3ff1-4a1d-b1a9-a5b2b21adbc9
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
X-Request-Id: b9d8cc6b-0182-4357-9810-dab25097e258
200 OK
```


```json
{
  "data": {
    "id": "79b93591-3ff1-4a1d-b1a9-a5b2b21adbc9",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/8c696e6f-804c-474a-826f-d5a0f7589d47"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/e19e133e-e8d6-4359-b3e0-443004f3bb3f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/79b93591-3ff1-4a1d-b1a9-a5b2b21adbc9"
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
DELETE /progress/c3e8fc8f-3237-47a4-9612-13e1baeaf192
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ac7d22de-32ca-48ec-b304-b74271f357eb
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
          "id": "c0a54641-381a-4879-a454-e1a91ed9eeba"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "279ba375-bc88-4f45-934d-8844eb843d21"
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
X-Request-Id: 6f467271-a701-4921-8b04-2dcda9eb74d3
201 Created
```


```json
{
  "data": {
    "id": "5381b6a5-bed7-4791-83fa-91bd8a41d44c",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/c0a54641-381a-4879-a454-e1a91ed9eeba"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/279ba375-bc88-4f45-934d-8844eb843d21"
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
X-Request-Id: 058363ce-6ab1-4052-9d68-84381045a50a
200 OK
```


```json
{
  "data": [
    {
      "id": "6166e20c-d808-433d-b9c0-7b323cce7e56",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "fd82d194-6c30-4d36-9e7e-c5e2df6e9fb1"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/fd82d194-6c30-4d36-9e7e-c5e2df6e9fb1"
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
GET /projects/505a5476-edaf-4b0c-8342-a785b1658e58/relationships/project_setting
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
X-Request-Id: 0c87b37a-893e-42fb-b530-eed78e18393f
200 OK
```


```json
{
  "data": {
    "id": "1bacd05f-de10-4787-a56d-3f964269248a",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "505a5476-edaf-4b0c-8342-a785b1658e58"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/505a5476-edaf-4b0c-8342-a785b1658e58"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/505a5476-edaf-4b0c-8342-a785b1658e58/relationships/project_setting"
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
PATCH /projects/604b8281-9492-4167-8b06-e3d2ace78cca/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "604b8281-9492-4167-8b06-e3d2ace78cca",
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
X-Request-Id: 7d7fea32-64cc-471a-a88f-d2772f67a602
200 OK
```


```json
{
  "data": {
    "id": "93d00938-a794-48b2-97bc-89536e46050d",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "604b8281-9492-4167-8b06-e3d2ace78cca"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/604b8281-9492-4167-8b06-e3d2ace78cca"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/604b8281-9492-4167-8b06-e3d2ace78cca/relationships/project_setting"
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
X-Request-Id: 9585b849-d790-4de5-83fa-b1d4e85be4ea
200 OK
```


```json
{
  "data": {
    "id": "4a5e6501-3ade-4411-be93-ae199c3ca502",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "d5cad8b2-8c6e-41d3-a872-154960b62d0c"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/d5cad8b2-8c6e-41d3-a872-154960b62d0c"
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
X-Request-Id: 14ac66bd-483a-4301-988f-a5a5bd61ff1b
200 OK
```


```json
{
  "data": {
    "id": "7e6115a0-39e8-43d8-80bd-45df637efb88",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "625b78c1-e52b-46fa-bf44-e1c1b37bed2a"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/625b78c1-e52b-46fa-bf44-e1c1b37bed2a"
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
| filter  | available filters: target_id_eq, target_type_eq |
| query  | search query |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: af6e7210-d8a9-4e62-99ef-1f1d3a95dd41
200 OK
```


```json
{
  "data": [
    {
      "id": "79211964-4361-4ced-90e9-0bfe67690cda",
      "type": "tag",
      "attributes": {
        "value": "Tag value 11"
      },
      "relationships": {
      }
    },
    {
      "id": "bd4c6cdc-7db8-4212-a1f7-080ba759a5fa",
      "type": "tag",
      "attributes": {
        "value": "Tag value 12"
      },
      "relationships": {
      }
    }
  ],
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
X-Request-Id: fc98f174-ff9e-4365-9d3f-6bd94aae0f72
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
GET /utils/path/from/object_occurrence/f0031bc6-49de-4420-ac5d-7dec06cdc18e/to/object_occurrence/79e4f6b1-eab0-4527-91f7-0bd604721dde
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
X-Request-Id: 93a4b25b-85fc-44b7-83b3-5a50c07492d2
200 OK
```


```json
[
  {
    "id": "f0031bc6-49de-4420-ac5d-7dec06cdc18e",
    "type": "object_occurrence"
  },
  {
    "id": "6aef0aa1-388d-41e4-ab04-a8c21732d0f0",
    "type": "object_occurrence"
  },
  {
    "id": "9001bc0a-4a96-43f0-b1ea-3cc071261b6b",
    "type": "object_occurrence"
  },
  {
    "id": "d151d0a3-5e74-4b94-8345-112b4c37f961",
    "type": "object_occurrence"
  },
  {
    "id": "08c35da3-b8b1-4438-88c8-ebdf95d696ed",
    "type": "object_occurrence"
  },
  {
    "id": "93b0aa1b-bb5f-4de8-bb4e-1b26ebc24a28",
    "type": "object_occurrence"
  },
  {
    "id": "79e4f6b1-eab0-4527-91f7-0bd604721dde",
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
X-Request-Id: 186c594d-5590-4146-8f05-64f188377b3e
200 OK
```


```json
{
  "data": [
    {
      "id": "edc878a1-6ce7-451a-b8d9-9858ddc32064",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/31fea0bc-54e4-457c-ad47-633eb3f0be10"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/0c743285-f937-4daf-8f02-7fd998759b42"
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
X-Request-Id: cdc9aea5-33f6-4321-8af6-52742c7893d1
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



