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
X-Request-Id: 1d4fe9d3-eb09-46d6-bd80-7bdc8aa3a728
200 OK
```


```json
{
  "data": {
    "id": "615f97c5-b514-4295-82ec-65067774356d",
    "type": "account",
    "attributes": {
      "name": "Account 1d87402b80c2"
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
X-Request-Id: d990c34b-fbe0-49a2-9f67-ca6adff75bb7
200 OK
```


```json
{
  "data": {
    "id": "f0a650e9-6f43-4a04-b934-896e7ecdb523",
    "type": "account",
    "attributes": {
      "name": "Account 1dea5fbb28dd"
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
    "id": "3cc2f3de-872a-49ae-bf5e-2b907eea503b",
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
X-Request-Id: 4e590933-5549-43c8-a54a-67815a3168b2
200 OK
```


```json
{
  "data": {
    "id": "3cc2f3de-872a-49ae-bf5e-2b907eea503b",
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
POST /projects/1cf6a29f-21e5-4a54-893a-d97571dd84cf/relationships/tags
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
X-Request-Id: 25c5d11f-07f8-4f82-adb0-575f880284d4
201 Created
```


```json
{
  "data": {
    "id": "4b1e4dbe-4c12-49af-a4aa-d47f47fa9984",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/1cf6a29f-21e5-4a54-893a-d97571dd84cf/relationships/tags"
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
POST /projects/5e5902f1-094e-487e-8e0d-db093187ddaa/relationships/tags
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
    "id": "aeac869f-fdd3-4d32-9d6d-63c37ee86d22"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 581c079f-511f-4d06-9c0d-f0b6ee58e071
201 Created
```


```json
{
  "data": {
    "id": "aeac869f-fdd3-4d32-9d6d-63c37ee86d22",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/5e5902f1-094e-487e-8e0d-db093187ddaa/relationships/tags"
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
DELETE /projects/d5a67ebf-79db-4d85-9cbc-5fac5386e2a7/relationships/tags/4abab8df-ffcf-4558-b48e-8fc03b40342c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b1b2607c-e551-42b5-aaa4-9113bb859a33
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
X-Request-Id: 72f4c79f-94c1-42cf-93fe-36df5071beb6
200 OK
```


```json
{
  "data": [
    {
      "id": "9b8f9295-fc65-47a3-b049-fd21867fb989",
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
            "related": "/tags?filter[target_id_eq]=9b8f9295-fc65-47a3-b049-fd21867fb989&filter[target_type_eq]=Project",
            "self": "/projects/9b8f9295-fc65-47a3-b049-fd21867fb989/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=9b8f9295-fc65-47a3-b049-fd21867fb989",
            "self": "/projects/9b8f9295-fc65-47a3-b049-fd21867fb989/relationships/contexts"
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
GET /projects/fc3b8db8-5c8c-4ea0-9668-63e0869a2837
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
X-Request-Id: 8c725a5e-9cf9-47c7-a26f-e37bdfb674bb
200 OK
```


```json
{
  "data": {
    "id": "fc3b8db8-5c8c-4ea0-9668-63e0869a2837",
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
          "related": "/tags?filter[target_id_eq]=fc3b8db8-5c8c-4ea0-9668-63e0869a2837&filter[target_type_eq]=Project",
          "self": "/projects/fc3b8db8-5c8c-4ea0-9668-63e0869a2837/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=fc3b8db8-5c8c-4ea0-9668-63e0869a2837",
          "self": "/projects/fc3b8db8-5c8c-4ea0-9668-63e0869a2837/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/fc3b8db8-5c8c-4ea0-9668-63e0869a2837"
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
PATCH /projects/66344a4d-5964-4e75-90f9-69e9b61740d8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "66344a4d-5964-4e75-90f9-69e9b61740d8",
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
X-Request-Id: 5aaf7c2e-d634-42e5-a5c2-95e87df2666e
200 OK
```


```json
{
  "data": {
    "id": "66344a4d-5964-4e75-90f9-69e9b61740d8",
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
          "related": "/tags?filter[target_id_eq]=66344a4d-5964-4e75-90f9-69e9b61740d8&filter[target_type_eq]=Project",
          "self": "/projects/66344a4d-5964-4e75-90f9-69e9b61740d8/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=66344a4d-5964-4e75-90f9-69e9b61740d8",
          "self": "/projects/66344a4d-5964-4e75-90f9-69e9b61740d8/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/66344a4d-5964-4e75-90f9-69e9b61740d8"
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
POST /projects/925e1cf2-c934-45c5-a4cb-73832dbe9a54/archive
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
X-Request-Id: 34f09687-07df-489a-b01f-599dd0aee21e
200 OK
```


```json
{
  "data": {
    "id": "925e1cf2-c934-45c5-a4cb-73832dbe9a54",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T14:02:41.866Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=925e1cf2-c934-45c5-a4cb-73832dbe9a54&filter[target_type_eq]=Project",
          "self": "/projects/925e1cf2-c934-45c5-a4cb-73832dbe9a54/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=925e1cf2-c934-45c5-a4cb-73832dbe9a54",
          "self": "/projects/925e1cf2-c934-45c5-a4cb-73832dbe9a54/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/925e1cf2-c934-45c5-a4cb-73832dbe9a54/archive"
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
DELETE /projects/f5b90c42-4034-4d7a-b57d-bfbd8005722b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 70d02537-36d9-48a8-924f-dbc56800f095
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
POST /contexts/e4e61f75-7fe1-46bc-b669-d2dd136266c7/relationships/tags
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
X-Request-Id: 6a66f16b-7f07-4840-9e1e-e112f698031f
201 Created
```


```json
{
  "data": {
    "id": "ab04ff27-d998-44cc-92b9-896223c37125",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/e4e61f75-7fe1-46bc-b669-d2dd136266c7/relationships/tags"
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
POST /contexts/99445d06-0446-48a3-9e9d-8b0b9cf4fe95/relationships/tags
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
    "id": "8f70b5f8-990d-4ccc-92e7-4983d89c924c"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 10cb3212-e04f-42c0-8701-7bc87df9ccbc
201 Created
```


```json
{
  "data": {
    "id": "8f70b5f8-990d-4ccc-92e7-4983d89c924c",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/99445d06-0446-48a3-9e9d-8b0b9cf4fe95/relationships/tags"
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
DELETE /contexts/dae4c8e3-2af0-4e84-955f-cc6e57059b65/relationships/tags/68b6480c-cd57-4a49-a122-0227b39b4e54
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 317ffda1-65f6-4db5-869b-e9a5338fcb0f
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
X-Request-Id: d57dde47-4bd1-41e8-bd1b-6edea36f5d7d
200 OK
```


```json
{
  "data": [
    {
      "id": "14cbc915-9eb9-4be8-b859-cb9ecb10e71b",
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
            "related": "/tags?filter[target_id_eq]=14cbc915-9eb9-4be8-b859-cb9ecb10e71b&filter[target_type_eq]=Context",
            "self": "/contexts/14cbc915-9eb9-4be8-b859-cb9ecb10e71b/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/8fc5d522-366c-4d9d-a934-41e0793c7213"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/d0abc34d-4aea-49b0-b9c2-3e3494047a89"
          }
        }
      }
    },
    {
      "id": "a8eef4b1-8580-465d-aa70-378adb09a91f",
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
            "related": "/tags?filter[target_id_eq]=a8eef4b1-8580-465d-aa70-378adb09a91f&filter[target_type_eq]=Context",
            "self": "/contexts/a8eef4b1-8580-465d-aa70-378adb09a91f/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/8fc5d522-366c-4d9d-a934-41e0793c7213"
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
GET /contexts/9da2f484-02ca-4fab-9a5d-3b7e1a0794fc
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
X-Request-Id: 13095ed4-f459-4ef7-9909-4878985f490b
200 OK
```


```json
{
  "data": {
    "id": "9da2f484-02ca-4fab-9a5d-3b7e1a0794fc",
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
          "related": "/tags?filter[target_id_eq]=9da2f484-02ca-4fab-9a5d-3b7e1a0794fc&filter[target_type_eq]=Context",
          "self": "/contexts/9da2f484-02ca-4fab-9a5d-3b7e1a0794fc/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/bb86bfa3-651f-4158-a248-97ba53e7fcb3"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/33bb6689-3990-4851-8a78-ca81233df2b1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/9da2f484-02ca-4fab-9a5d-3b7e1a0794fc"
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
PATCH /contexts/fc2ac5f3-d73d-4f06-a839-d498f34a7259
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "fc2ac5f3-d73d-4f06-a839-d498f34a7259",
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
X-Request-Id: dee2225a-b9e9-46c2-b780-8d05af3c703e
200 OK
```


```json
{
  "data": {
    "id": "fc2ac5f3-d73d-4f06-a839-d498f34a7259",
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
          "related": "/tags?filter[target_id_eq]=fc2ac5f3-d73d-4f06-a839-d498f34a7259&filter[target_type_eq]=Context",
          "self": "/contexts/fc2ac5f3-d73d-4f06-a839-d498f34a7259/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/bf95b494-cdac-479a-ac52-d68b3ec3892d"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/cb105a60-bb77-4a3e-811a-99583c43b6bd"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/fc2ac5f3-d73d-4f06-a839-d498f34a7259"
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
POST /projects/b5880e5f-6638-4fdb-a5ac-09b27167eda0/relationships/contexts
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
X-Request-Id: 81e94673-6204-43fe-9815-92e4a6f1e401
201 Created
```


```json
{
  "data": {
    "id": "cdf8c173-22fa-47f4-9d3b-7a0ea11f6c2c",
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
          "related": "/tags?filter[target_id_eq]=cdf8c173-22fa-47f4-9d3b-7a0ea11f6c2c&filter[target_type_eq]=Context",
          "self": "/contexts/cdf8c173-22fa-47f4-9d3b-7a0ea11f6c2c/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/b5880e5f-6638-4fdb-a5ac-09b27167eda0"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/ee0cf8e0-29a3-42c7-ac48-c140fc7b8b9d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b5880e5f-6638-4fdb-a5ac-09b27167eda0/relationships/contexts"
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
POST /contexts/a6f45ce8-9bee-4c68-a927-e0921fb2e39f/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/56439a8978d838175e627cad
Content-Type: text/html; charset=utf-8
X-Request-Id: 808d3e09-0090-4a5d-80fe-d9fe28e8aaa9
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/56439a8978d838175e627cad">redirected</a>.</body></html>
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
DELETE /contexts/17153a47-609e-4ee5-adbc-e7f868ed122f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0747e394-5754-4a88-8084-c3b31af8a0c9
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
POST /object_occurrences/41055261-c356-4340-8a0a-38270b4daa5e/relationships/tags
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
X-Request-Id: d8c5ec8b-af68-4300-9a48-bb5edc82f97a
201 Created
```


```json
{
  "data": {
    "id": "79a8d0a1-0059-4aee-9632-91e3763083e0",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/41055261-c356-4340-8a0a-38270b4daa5e/relationships/tags"
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
POST /object_occurrences/9fe912fc-f96d-46c7-9626-21c08eb4825d/relationships/tags
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
    "id": "56399f31-2bc7-4b73-b261-6fb6582f772e"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 58529fa4-368d-4b44-99a7-e3e9bab62906
201 Created
```


```json
{
  "data": {
    "id": "56399f31-2bc7-4b73-b261-6fb6582f772e",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/9fe912fc-f96d-46c7-9626-21c08eb4825d/relationships/tags"
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
DELETE /object_occurrences/dd1a41cb-9807-4247-ac38-a565b3ee378f/relationships/tags/fd933c10-533e-40be-9248-a1d65cf661ec
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: adec153e-d18a-46e1-b6c5-ea8416eae4a5
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
GET /object_occurrences/2ff171a9-faaa-4193-98bf-30e00b541df3
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
X-Request-Id: e9e228e2-9421-442c-a5c2-9565efb46157
200 OK
```


```json
{
  "data": {
    "id": "2ff171a9-faaa-4193-98bf-30e00b541df3",
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
          "related": "/tags?filter[target_id_eq]=2ff171a9-faaa-4193-98bf-30e00b541df3&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/2ff171a9-faaa-4193-98bf-30e00b541df3/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/f3b0f0a2-b98d-4c22-b7d5-6b11ab920b31"
        }
      },
      "components": {
        "data": [
          {
            "id": "44822f6a-6382-4d6d-9dd3-9aecda7edd7d",
            "type": "object_occurrence"
          },
          {
            "id": "1d33350b-1eb0-483c-9b38-479611d73ae8",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/2ff171a9-faaa-4193-98bf-30e00b541df3/relationships/components"
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
    "self": "http://example.org/object_occurrences/2ff171a9-faaa-4193-98bf-30e00b541df3"
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
POST /object_occurrences/9f616634-bef3-46a4-aa81-8b977205ecdc/relationships/components
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
X-Request-Id: 3436a6e3-0785-4ea1-85b6-67dbeb08987c
201 Created
```


```json
{
  "data": {
    "id": "1dbbe703-3677-4144-8fad-cf19d76e2042",
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
          "related": "/tags?filter[target_id_eq]=1dbbe703-3677-4144-8fad-cf19d76e2042&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/1dbbe703-3677-4144-8fad-cf19d76e2042/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/86de1319-654a-4108-8381-d718d408cb2f"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/9f616634-bef3-46a4-aa81-8b977205ecdc",
          "self": "/object_occurrences/1dbbe703-3677-4144-8fad-cf19d76e2042/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/1dbbe703-3677-4144-8fad-cf19d76e2042/relationships/components"
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
    "self": "http://example.org/object_occurrences/9f616634-bef3-46a4-aa81-8b977205ecdc/relationships/components"
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
PATCH /object_occurrences/016a1457-6f5c-4931-ba47-f9006e711870
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "016a1457-6f5c-4931-ba47-f9006e711870",
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
          "id": "6a034899-0151-45ef-9f2f-b699e5dee30c"
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
X-Request-Id: 030a2a15-4c53-4655-8e8c-9389ada03f29
200 OK
```


```json
{
  "data": {
    "id": "016a1457-6f5c-4931-ba47-f9006e711870",
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
          "related": "/tags?filter[target_id_eq]=016a1457-6f5c-4931-ba47-f9006e711870&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/016a1457-6f5c-4931-ba47-f9006e711870/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/8cb21b9b-68f9-40ba-8b12-82bfaaa90f26"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6a034899-0151-45ef-9f2f-b699e5dee30c",
          "self": "/object_occurrences/016a1457-6f5c-4931-ba47-f9006e711870/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/016a1457-6f5c-4931-ba47-f9006e711870/relationships/components"
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
    "self": "http://example.org/object_occurrences/016a1457-6f5c-4931-ba47-f9006e711870"
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
POST /object_occurrences/f3f82343-0183-48e7-a36c-b65d4cfff53b/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "1391f7a0-a3c4-4960-8126-38534f934499",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/ce8946441ff6d97a86b63bb0
Content-Type: text/html; charset=utf-8
X-Request-Id: 4ea26557-cdd4-46a7-868b-a0606bb20ea6
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/ce8946441ff6d97a86b63bb0">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/04977f86-1567-441e-9dd0-9fa146c9af88
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 81088e45-4e9e-4231-b8bf-7443765c0330
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
PATCH /object_occurrences/aa470b6e-2e8a-4712-ac24-94fc572cc8ba/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "27cec7f0-0f00-4d73-a4d7-76a6103ca44d",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f4543868-3778-4eee-af58-8467c6297924
200 OK
```


```json
{
  "data": {
    "id": "aa470b6e-2e8a-4712-ac24-94fc572cc8ba",
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
          "related": "/tags?filter[target_id_eq]=aa470b6e-2e8a-4712-ac24-94fc572cc8ba&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/aa470b6e-2e8a-4712-ac24-94fc572cc8ba/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/a336e996-e4a4-4e84-a9b9-2ae8074ad7ab"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/27cec7f0-0f00-4d73-a4d7-76a6103ca44d",
          "self": "/object_occurrences/aa470b6e-2e8a-4712-ac24-94fc572cc8ba/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/aa470b6e-2e8a-4712-ac24-94fc572cc8ba/relationships/components"
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
    "self": "http://example.org/object_occurrences/aa470b6e-2e8a-4712-ac24-94fc572cc8ba/relationships/part_of"
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
POST /classification_tables/1586c62c-2df6-43a3-9b34-b753b0f39441/relationships/tags
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
X-Request-Id: 0d64e759-e589-4585-a7e7-961121a95ceb
201 Created
```


```json
{
  "data": {
    "id": "22b15818-c161-494c-81d6-3549df9271e9",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/1586c62c-2df6-43a3-9b34-b753b0f39441/relationships/tags"
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
POST /classification_tables/1684bbbb-fa3b-420b-ae36-46a20f2658cb/relationships/tags
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
    "id": "3783adad-867c-4d00-8a81-5bb4b095718a"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: bcbab992-60ad-4d60-9d55-41c947e8ea08
201 Created
```


```json
{
  "data": {
    "id": "3783adad-867c-4d00-8a81-5bb4b095718a",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/1684bbbb-fa3b-420b-ae36-46a20f2658cb/relationships/tags"
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
DELETE /classification_tables/0b1fe009-e61e-4178-8c55-d1005445330c/relationships/tags/d23b94c2-d4e8-4f0e-b608-cfea15d5b897
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c50ac39e-293a-40cc-a7ec-4ec04a78a8b4
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
X-Request-Id: 6b18fede-2ffb-46a0-bc80-fbae7838dede
200 OK
```


```json
{
  "data": [
    {
      "id": "c597edb1-31db-4de6-9967-163237711f71",
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
            "related": "/tags?filter[target_id_eq]=c597edb1-31db-4de6-9967-163237711f71&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/c597edb1-31db-4de6-9967-163237711f71/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=c597edb1-31db-4de6-9967-163237711f71",
            "self": "/classification_tables/c597edb1-31db-4de6-9967-163237711f71/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "cd1dc319-21f0-4bb4-a7c9-03c9c697bd01",
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
            "related": "/tags?filter[target_id_eq]=cd1dc319-21f0-4bb4-a7c9-03c9c697bd01&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/cd1dc319-21f0-4bb4-a7c9-03c9c697bd01/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=cd1dc319-21f0-4bb4-a7c9-03c9c697bd01",
            "self": "/classification_tables/cd1dc319-21f0-4bb4-a7c9-03c9c697bd01/relationships/classification_entries",
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
X-Request-Id: e0da28fb-24ed-46ea-b1d3-b4ea0206d16a
200 OK
```


```json
{
  "data": [
    {
      "id": "b1100798-9573-49c4-929d-fb93567b4584",
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
            "related": "/tags?filter[target_id_eq]=b1100798-9573-49c4-929d-fb93567b4584&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/b1100798-9573-49c4-929d-fb93567b4584/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=b1100798-9573-49c4-929d-fb93567b4584",
            "self": "/classification_tables/b1100798-9573-49c4-929d-fb93567b4584/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "365971e4-247b-4620-ac2a-8b39914a8cef",
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
            "related": "/tags?filter[target_id_eq]=365971e4-247b-4620-ac2a-8b39914a8cef&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/365971e4-247b-4620-ac2a-8b39914a8cef/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=365971e4-247b-4620-ac2a-8b39914a8cef",
            "self": "/classification_tables/365971e4-247b-4620-ac2a-8b39914a8cef/relationships/classification_entries",
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
GET /classification_tables/ffd99da4-f664-424f-8fa7-4e8efc5335f6
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
X-Request-Id: 281ca651-e898-48b1-b5d2-cd4fdb4a0778
200 OK
```


```json
{
  "data": {
    "id": "ffd99da4-f664-424f-8fa7-4e8efc5335f6",
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
          "related": "/tags?filter[target_id_eq]=ffd99da4-f664-424f-8fa7-4e8efc5335f6&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/ffd99da4-f664-424f-8fa7-4e8efc5335f6/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=ffd99da4-f664-424f-8fa7-4e8efc5335f6",
          "self": "/classification_tables/ffd99da4-f664-424f-8fa7-4e8efc5335f6/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ffd99da4-f664-424f-8fa7-4e8efc5335f6"
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
PATCH /classification_tables/231fe851-7592-4ae4-a5f5-b6decd8d0435
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "231fe851-7592-4ae4-a5f5-b6decd8d0435",
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
X-Request-Id: 7d76116b-e092-490a-b73d-f22855a01a0f
200 OK
```


```json
{
  "data": {
    "id": "231fe851-7592-4ae4-a5f5-b6decd8d0435",
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
          "related": "/tags?filter[target_id_eq]=231fe851-7592-4ae4-a5f5-b6decd8d0435&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/231fe851-7592-4ae4-a5f5-b6decd8d0435/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=231fe851-7592-4ae4-a5f5-b6decd8d0435",
          "self": "/classification_tables/231fe851-7592-4ae4-a5f5-b6decd8d0435/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/231fe851-7592-4ae4-a5f5-b6decd8d0435"
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
DELETE /classification_tables/34d86e13-618e-4933-9027-65b66908cdb3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 948766bd-6abf-473c-aee6-fc2e781acc00
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
POST /classification_tables/860aac8a-f1e5-415b-bce5-32c9285678af/publish
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
X-Request-Id: a4137f67-4420-4627-a6ae-c928ce244085
200 OK
```


```json
{
  "data": {
    "id": "860aac8a-f1e5-415b-bce5-32c9285678af",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-12T14:03:00.843Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=860aac8a-f1e5-415b-bce5-32c9285678af&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/860aac8a-f1e5-415b-bce5-32c9285678af/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=860aac8a-f1e5-415b-bce5-32c9285678af",
          "self": "/classification_tables/860aac8a-f1e5-415b-bce5-32c9285678af/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/860aac8a-f1e5-415b-bce5-32c9285678af/publish"
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
POST /classification_tables/a517e32e-2511-4feb-a7ff-2fa14ad98f18/archive
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
X-Request-Id: ae339601-409d-4877-8526-e3f0a844e886
200 OK
```


```json
{
  "data": {
    "id": "a517e32e-2511-4feb-a7ff-2fa14ad98f18",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T14:03:01.255Z",
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
          "related": "/tags?filter[target_id_eq]=a517e32e-2511-4feb-a7ff-2fa14ad98f18&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/a517e32e-2511-4feb-a7ff-2fa14ad98f18/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=a517e32e-2511-4feb-a7ff-2fa14ad98f18",
          "self": "/classification_tables/a517e32e-2511-4feb-a7ff-2fa14ad98f18/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a517e32e-2511-4feb-a7ff-2fa14ad98f18/archive"
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
X-Request-Id: 41692d7a-a9a1-4717-a957-499ab83dce4f
201 Created
```


```json
{
  "data": {
    "id": "4717607a-9581-4705-846b-ba6c85b7a31e",
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
          "related": "/tags?filter[target_id_eq]=4717607a-9581-4705-846b-ba6c85b7a31e&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/4717607a-9581-4705-846b-ba6c85b7a31e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=4717607a-9581-4705-846b-ba6c85b7a31e",
          "self": "/classification_tables/4717607a-9581-4705-846b-ba6c85b7a31e/relationships/classification_entries",
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
POST /classification_entries/c4b5da82-08e6-47ce-87c1-c5dbe72ae74a/relationships/tags
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
X-Request-Id: 25fb1a23-cea1-4108-9ccf-35d4d8774eaf
201 Created
```


```json
{
  "data": {
    "id": "52c1465f-06dc-4d9f-a7f1-18cb01be6d39",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/c4b5da82-08e6-47ce-87c1-c5dbe72ae74a/relationships/tags"
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
POST /classification_entries/7503eca7-56d5-44d8-b18a-854f9bf9512a/relationships/tags
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
    "id": "1532f2b6-138c-49a3-bfee-1b8b32b33989"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 92e68e1d-15f7-4b01-ba60-bd82906144e7
201 Created
```


```json
{
  "data": {
    "id": "1532f2b6-138c-49a3-bfee-1b8b32b33989",
    "type": "tag",
    "attributes": {
      "value": "Tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/7503eca7-56d5-44d8-b18a-854f9bf9512a/relationships/tags"
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
DELETE /classification_entries/fc209184-012a-47d3-ae8d-93e2a00cafc4/relationships/tags/d8f67765-7997-458a-9430-74421eb4d83a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4829c8cc-4230-40ce-9e7f-782e3a0af0dc
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
X-Request-Id: 6d8b57f9-7400-46bc-9a0f-be8f8418b28c
200 OK
```


```json
{
  "data": [
    {
      "id": "04657478-a242-45e8-9e87-58b4a4d92a08",
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
            "related": "/tags?filter[target_id_eq]=04657478-a242-45e8-9e87-58b4a4d92a08&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/04657478-a242-45e8-9e87-58b4a4d92a08/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=04657478-a242-45e8-9e87-58b4a4d92a08",
            "self": "/classification_entries/04657478-a242-45e8-9e87-58b4a4d92a08/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "6bd32baf-210c-4550-a917-34546589b036",
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
            "related": "/tags?filter[target_id_eq]=6bd32baf-210c-4550-a917-34546589b036&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/6bd32baf-210c-4550-a917-34546589b036/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "04657478-a242-45e8-9e87-58b4a4d92a08",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/6bd32baf-210c-4550-a917-34546589b036"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=6bd32baf-210c-4550-a917-34546589b036",
            "self": "/classification_entries/6bd32baf-210c-4550-a917-34546589b036/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "1a2c7a0f-aab5-41b2-9e0b-2383e3c4762d",
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
            "related": "/tags?filter[target_id_eq]=1a2c7a0f-aab5-41b2-9e0b-2383e3c4762d&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/1a2c7a0f-aab5-41b2-9e0b-2383e3c4762d/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=1a2c7a0f-aab5-41b2-9e0b-2383e3c4762d",
            "self": "/classification_entries/1a2c7a0f-aab5-41b2-9e0b-2383e3c4762d/relationships/classification_entries",
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
GET /classification_entries/db79d5e0-5f64-4c68-92eb-bbba1e41c28a
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
X-Request-Id: 97121450-868b-40a9-86d2-a7ce8ebece3b
200 OK
```


```json
{
  "data": {
    "id": "db79d5e0-5f64-4c68-92eb-bbba1e41c28a",
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
          "related": "/tags?filter[target_id_eq]=db79d5e0-5f64-4c68-92eb-bbba1e41c28a&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/db79d5e0-5f64-4c68-92eb-bbba1e41c28a/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=db79d5e0-5f64-4c68-92eb-bbba1e41c28a",
          "self": "/classification_entries/db79d5e0-5f64-4c68-92eb-bbba1e41c28a/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/db79d5e0-5f64-4c68-92eb-bbba1e41c28a"
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
PATCH /classification_entries/f3a66ddc-85a8-4c30-9da0-40a6f6d4248f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "f3a66ddc-85a8-4c30-9da0-40a6f6d4248f",
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
X-Request-Id: c2c4dc7f-7532-4949-97d4-3454ed139327
200 OK
```


```json
{
  "data": {
    "id": "f3a66ddc-85a8-4c30-9da0-40a6f6d4248f",
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
          "related": "/tags?filter[target_id_eq]=f3a66ddc-85a8-4c30-9da0-40a6f6d4248f&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/f3a66ddc-85a8-4c30-9da0-40a6f6d4248f/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "43cd0b11-2e60-49b9-ac41-ad1676a4934e",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/f3a66ddc-85a8-4c30-9da0-40a6f6d4248f"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=f3a66ddc-85a8-4c30-9da0-40a6f6d4248f",
          "self": "/classification_entries/f3a66ddc-85a8-4c30-9da0-40a6f6d4248f/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/f3a66ddc-85a8-4c30-9da0-40a6f6d4248f"
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
DELETE /classification_entries/edf72eff-e289-4ce3-a423-a18b2d02d1bb
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fbc56d60-fc06-4241-9edb-b73fd963d91b
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
POST /classification_tables/d287e299-cc4c-48aa-8331-03d1bb4c40df/relationships/classification_entries
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
X-Request-Id: 7d651d54-ff9e-4fc2-b864-bfbfc63c8b65
201 Created
```


```json
{
  "data": {
    "id": "109d13f6-ec31-4dc2-88a1-2e710eaedd92",
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
          "related": "/tags?filter[target_id_eq]=109d13f6-ec31-4dc2-88a1-2e710eaedd92&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/109d13f6-ec31-4dc2-88a1-2e710eaedd92/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=109d13f6-ec31-4dc2-88a1-2e710eaedd92",
          "self": "/classification_entries/109d13f6-ec31-4dc2-88a1-2e710eaedd92/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d287e299-cc4c-48aa-8331-03d1bb4c40df/relationships/classification_entries"
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
X-Request-Id: 3ae23699-68dd-437f-8d08-a44919e072c8
200 OK
```


```json
{
  "data": [
    {
      "id": "909bd13d-a294-43ef-81d9-45fba78352e6",
      "type": "syntax",
      "attributes": {
        "account_id": "c6646f2a-6c90-4c08-a7bf-6f3362b19eda",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 0f145fb866fd",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=909bd13d-a294-43ef-81d9-45fba78352e6",
            "self": "/syntaxes/909bd13d-a294-43ef-81d9-45fba78352e6/relationships/syntax_elements"
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
GET /syntaxes/ac6b0a3f-d085-499c-9670-b5b43772ea4f
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
X-Request-Id: 6e93877f-554c-4944-83a3-0087ba78d5f3
200 OK
```


```json
{
  "data": {
    "id": "ac6b0a3f-d085-499c-9670-b5b43772ea4f",
    "type": "syntax",
    "attributes": {
      "account_id": "26f03eda-f636-4327-bce9-76d0bc32e0f2",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 01d9f23be9eb",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ac6b0a3f-d085-499c-9670-b5b43772ea4f",
          "self": "/syntaxes/ac6b0a3f-d085-499c-9670-b5b43772ea4f/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ac6b0a3f-d085-499c-9670-b5b43772ea4f"
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
X-Request-Id: 3a46ae01-83bd-4d7c-ae32-65b138d38671
201 Created
```


```json
{
  "data": {
    "id": "f2c520a8-c455-4c1c-ad9f-37cd8c716407",
    "type": "syntax",
    "attributes": {
      "account_id": "d30082c2-cb7d-419c-8e4d-dad72893ce45",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=f2c520a8-c455-4c1c-ad9f-37cd8c716407",
          "self": "/syntaxes/f2c520a8-c455-4c1c-ad9f-37cd8c716407/relationships/syntax_elements"
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
PATCH /syntaxes/3357dd39-363b-4a3c-8da7-95caf5498df3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "3357dd39-363b-4a3c-8da7-95caf5498df3",
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
X-Request-Id: e1f64f89-efff-47ba-a6b7-cacc0833202b
200 OK
```


```json
{
  "data": {
    "id": "3357dd39-363b-4a3c-8da7-95caf5498df3",
    "type": "syntax",
    "attributes": {
      "account_id": "928d30db-f9b1-4217-a42c-1447f1eff057",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=3357dd39-363b-4a3c-8da7-95caf5498df3",
          "self": "/syntaxes/3357dd39-363b-4a3c-8da7-95caf5498df3/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/3357dd39-363b-4a3c-8da7-95caf5498df3"
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
DELETE /syntaxes/9fb79bca-b246-49a1-b347-6dc73c843e16
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9ee36068-bb92-4b51-97a3-5eea96d5d8ea
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
POST /syntaxes/8ab4785e-4adc-45b2-84b6-a0892959a209/publish
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
X-Request-Id: 88da919a-a020-4ace-8ad5-4d2c0e9c1366
200 OK
```


```json
{
  "data": {
    "id": "8ab4785e-4adc-45b2-84b6-a0892959a209",
    "type": "syntax",
    "attributes": {
      "account_id": "9face788-89ca-45ec-b6b2-4f8d394c0be3",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 7273bff908fc",
      "published": true,
      "published_at": "2020-02-12T14:03:08.545Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=8ab4785e-4adc-45b2-84b6-a0892959a209",
          "self": "/syntaxes/8ab4785e-4adc-45b2-84b6-a0892959a209/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/8ab4785e-4adc-45b2-84b6-a0892959a209/publish"
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
POST /syntaxes/0872e5a0-22c9-4ab2-9bb3-a2a932ba0dd6/archive
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
X-Request-Id: fa6d1e0f-4bc2-45c0-a96f-c975b1a2618e
200 OK
```


```json
{
  "data": {
    "id": "0872e5a0-22c9-4ab2-9bb3-a2a932ba0dd6",
    "type": "syntax",
    "attributes": {
      "account_id": "a7df658b-0389-4ee8-8a99-b28c5a43aacc",
      "archived": true,
      "archived_at": "2020-02-12T14:03:08.990Z",
      "description": "Description",
      "name": "Syntax 3468ec3ce231",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=0872e5a0-22c9-4ab2-9bb3-a2a932ba0dd6",
          "self": "/syntaxes/0872e5a0-22c9-4ab2-9bb3-a2a932ba0dd6/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/0872e5a0-22c9-4ab2-9bb3-a2a932ba0dd6/archive"
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
X-Request-Id: 5606ec82-0d6d-4923-a306-e4ab2ee9a40f
200 OK
```


```json
{
  "data": [
    {
      "id": "f1393be2-dde8-4c92-88e6-468626a15f50",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "4b1a73a5-e823-4a5c-8167-4d00b4601068",
        "hex_color": "d6af3d",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 423e302b9d46"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/3b44b589-dc03-4dd1-a55c-d033898ef5ad"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/4b1a73a5-e823-4a5c-8167-4d00b4601068",
            "self": "/syntax_elements/f1393be2-dde8-4c92-88e6-468626a15f50/relationships/classification_table"
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
GET /syntax_elements/cfcbb9e7-7b22-4ea3-b6fc-944a177d1f8b
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
X-Request-Id: 3c0a45ab-0274-4b5e-b2a2-0966638cf3dd
200 OK
```


```json
{
  "data": {
    "id": "cfcbb9e7-7b22-4ea3-b6fc-944a177d1f8b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "916a7f20-799d-426b-9526-280f87085ff2",
      "hex_color": "8a5c20",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element d401e21fa605"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/a584235c-c626-4856-851d-d00d2b583b69"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/916a7f20-799d-426b-9526-280f87085ff2",
          "self": "/syntax_elements/cfcbb9e7-7b22-4ea3-b6fc-944a177d1f8b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/cfcbb9e7-7b22-4ea3-b6fc-944a177d1f8b"
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
POST /syntaxes/4e86c8c7-6521-4e76-a021-32c2e1866d99/relationships/syntax_elements
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
          "id": "64ed9e00-7de1-4a9c-a1fa-e87e22c86521"
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
X-Request-Id: 1d12a069-d6f4-47b9-a9d6-b72c1300e55b
201 Created
```


```json
{
  "data": {
    "id": "03218ad2-682d-4e0e-a442-cf519312db93",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "64ed9e00-7de1-4a9c-a1fa-e87e22c86521",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/4e86c8c7-6521-4e76-a021-32c2e1866d99"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/64ed9e00-7de1-4a9c-a1fa-e87e22c86521",
          "self": "/syntax_elements/03218ad2-682d-4e0e-a442-cf519312db93/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/4e86c8c7-6521-4e76-a021-32c2e1866d99/relationships/syntax_elements"
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
PATCH /syntax_elements/bb877301-6d00-4516-961f-a76441dc5da3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "bb877301-6d00-4516-961f-a76441dc5da3",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "e1096192-03b1-4f07-a6ae-e7e8247a7386"
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
X-Request-Id: 034f34d6-4dfa-459f-9969-c2a7ab694763
200 OK
```


```json
{
  "data": {
    "id": "bb877301-6d00-4516-961f-a76441dc5da3",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "e1096192-03b1-4f07-a6ae-e7e8247a7386",
      "hex_color": "de44a7",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/cbd1bbb3-edea-45d8-bebc-486cfdebb918"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/e1096192-03b1-4f07-a6ae-e7e8247a7386",
          "self": "/syntax_elements/bb877301-6d00-4516-961f-a76441dc5da3/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/bb877301-6d00-4516-961f-a76441dc5da3"
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
DELETE /syntax_elements/a498e30e-6651-4739-bbe5-f9b5f5541228
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c1e45a4f-a8eb-4a91-a5da-f20c315d2732
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
PATCH /syntax_elements/6c6ee178-dc29-4ab8-acb4-66cf7e4ac379/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "efa69de9-8182-4bb9-a592-f8af2f381435",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: cbc95a11-a3c4-4a07-b32b-85b172e00d38
200 OK
```


```json
{
  "data": {
    "id": "6c6ee178-dc29-4ab8-acb4-66cf7e4ac379",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "efa69de9-8182-4bb9-a592-f8af2f381435",
      "hex_color": "3e2d38",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 5def03ea4f2a"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/a1a14f78-d0a3-4668-aaa5-a8e15456b027"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/efa69de9-8182-4bb9-a592-f8af2f381435",
          "self": "/syntax_elements/6c6ee178-dc29-4ab8-acb4-66cf7e4ac379/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/6c6ee178-dc29-4ab8-acb4-66cf7e4ac379/relationships/classification_table"
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
DELETE /syntax_elements/9e9a9de3-1eb3-431f-962f-4be244bc7086/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6840d3fb-2f9c-4cc4-86b4-38566451723e
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
X-Request-Id: dba9ff2c-0886-4270-b204-84f49a8bd1b2
200 OK
```


```json
{
  "data": [
    {
      "id": "df1d43ee-e108-4a41-a118-771565af81d4",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-12T14:03:12.580Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=df1d43ee-e108-4a41-a118-771565af81d4",
            "self": "/progress_models/df1d43ee-e108-4a41-a118-771565af81d4/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "d47ccf0b-10fd-4709-94c4-04cd39283043",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=d47ccf0b-10fd-4709-94c4-04cd39283043",
            "self": "/progress_models/d47ccf0b-10fd-4709-94c4-04cd39283043/relationships/progress_steps"
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
GET /progress_models/47c2d24f-8111-42a4-8716-7f31082fdbb3
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
X-Request-Id: ddef0438-fa5a-43a3-989b-e6eac736bc48
200 OK
```


```json
{
  "data": {
    "id": "47c2d24f-8111-42a4-8716-7f31082fdbb3",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-12T14:03:13.168Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=47c2d24f-8111-42a4-8716-7f31082fdbb3",
          "self": "/progress_models/47c2d24f-8111-42a4-8716-7f31082fdbb3/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/47c2d24f-8111-42a4-8716-7f31082fdbb3"
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
PATCH /progress_models/dcb0bba4-7976-44a8-8caa-be3288db2413
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "dcb0bba4-7976-44a8-8caa-be3288db2413",
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
X-Request-Id: ed18165d-ff81-42e9-8c05-37c2e9d1ceba
200 OK
```


```json
{
  "data": {
    "id": "dcb0bba4-7976-44a8-8caa-be3288db2413",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=dcb0bba4-7976-44a8-8caa-be3288db2413",
          "self": "/progress_models/dcb0bba4-7976-44a8-8caa-be3288db2413/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/dcb0bba4-7976-44a8-8caa-be3288db2413"
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
DELETE /progress_models/53fed411-04ea-4763-95e6-3961153c2b9d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ee5b39f0-53bd-46ab-8013-c010b346b517
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
POST /progress_models/6fc7e3c6-544a-41d7-b19b-059ed49a0141/publish
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
X-Request-Id: e44e2806-76a4-4768-9395-afa1d192b6f5
200 OK
```


```json
{
  "data": {
    "id": "6fc7e3c6-544a-41d7-b19b-059ed49a0141",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-12T14:03:15.343Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=6fc7e3c6-544a-41d7-b19b-059ed49a0141",
          "self": "/progress_models/6fc7e3c6-544a-41d7-b19b-059ed49a0141/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/6fc7e3c6-544a-41d7-b19b-059ed49a0141/publish"
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
POST /progress_models/91088408-ff22-482b-9c00-512c70d0a986/archive
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
X-Request-Id: d85f0427-3b02-4c97-8367-94ae3c90c9ee
200 OK
```


```json
{
  "data": {
    "id": "91088408-ff22-482b-9c00-512c70d0a986",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T14:03:15.915Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=91088408-ff22-482b-9c00-512c70d0a986",
          "self": "/progress_models/91088408-ff22-482b-9c00-512c70d0a986/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/91088408-ff22-482b-9c00-512c70d0a986/archive"
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
X-Request-Id: c64d1ff7-54c9-445d-84b5-eeb73bff0dff
201 Created
```


```json
{
  "data": {
    "id": "cf4763a0-7fa5-4b45-a186-0a73f65ce278",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=cf4763a0-7fa5-4b45-a186-0a73f65ce278",
          "self": "/progress_models/cf4763a0-7fa5-4b45-a186-0a73f65ce278/relationships/progress_steps"
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
X-Request-Id: fa19abc3-8566-4f30-b4f7-dd4870fb9d2d
200 OK
```


```json
{
  "data": [
    {
      "id": "a5b088ca-8a0a-4b08-8ce0-6797725f1e94",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 15,
        "published": true,
        "published_at": "2020-02-12T14:03:19.268Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a5b088ca-8a0a-4b08-8ce0-6797725f1e94",
            "self": "/progress_models/a5b088ca-8a0a-4b08-8ce0-6797725f1e94/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "106fd3e9-a41a-4bd3-a3b1-983554e39618",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 2",
        "order": 16,
        "published": false,
        "published_at": null,
        "type": "ObjectOccurrenceRelation"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=106fd3e9-a41a-4bd3-a3b1-983554e39618",
            "self": "/progress_models/106fd3e9-a41a-4bd3-a3b1-983554e39618/relationships/progress_steps"
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
GET /progress_models/89dd602a-7956-466b-adf2-e97c85966f69
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
X-Request-Id: 546f2807-f99d-4058-95d4-bcc6268bc125
200 OK
```


```json
{
  "data": {
    "id": "89dd602a-7956-466b-adf2-e97c85966f69",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 17,
      "published": true,
      "published_at": "2020-02-12T14:03:19.664Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=89dd602a-7956-466b-adf2-e97c85966f69",
          "self": "/progress_models/89dd602a-7956-466b-adf2-e97c85966f69/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/89dd602a-7956-466b-adf2-e97c85966f69"
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
PATCH /progress_models/7a314e0f-dfc6-4c12-908e-41fe1d0a786c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "7a314e0f-dfc6-4c12-908e-41fe1d0a786c",
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
X-Request-Id: 503bcd85-c19e-4a4c-9692-7bbbcb972833
200 OK
```


```json
{
  "data": {
    "id": "7a314e0f-dfc6-4c12-908e-41fe1d0a786c",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 20,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=7a314e0f-dfc6-4c12-908e-41fe1d0a786c",
          "self": "/progress_models/7a314e0f-dfc6-4c12-908e-41fe1d0a786c/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/7a314e0f-dfc6-4c12-908e-41fe1d0a786c"
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
DELETE /progress_models/592a0f84-3311-44a9-bb7e-44bac30b9d46
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f2a7d7ae-e3b3-4da9-801d-35e104092140
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
POST /progress_models/b94269cc-dc94-4878-9e69-d4155f5ee24f/publish
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
X-Request-Id: e00d0f62-f24f-4c3b-90d6-c623c3733ca5
200 OK
```


```json
{
  "data": {
    "id": "b94269cc-dc94-4878-9e69-d4155f5ee24f",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 24,
      "published": true,
      "published_at": "2020-02-12T14:03:21.718Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b94269cc-dc94-4878-9e69-d4155f5ee24f",
          "self": "/progress_models/b94269cc-dc94-4878-9e69-d4155f5ee24f/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/b94269cc-dc94-4878-9e69-d4155f5ee24f/publish"
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
POST /progress_models/8406e2a1-b5bc-4dd9-abd2-2b47ff5e3cda/archive
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
X-Request-Id: f1a71731-0834-495f-9b43-2c3bb83df0b5
200 OK
```


```json
{
  "data": {
    "id": "8406e2a1-b5bc-4dd9-abd2-2b47ff5e3cda",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T14:03:22.184Z",
      "name": "pm 2",
      "order": 26,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=8406e2a1-b5bc-4dd9-abd2-2b47ff5e3cda",
          "self": "/progress_models/8406e2a1-b5bc-4dd9-abd2-2b47ff5e3cda/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/8406e2a1-b5bc-4dd9-abd2-2b47ff5e3cda/archive"
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
X-Request-Id: 72dc458a-3225-4fa1-96ea-01d2e57315ba
201 Created
```


```json
{
  "data": {
    "id": "490f6d80-7812-43f2-9d52-6cef594e5e87",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=490f6d80-7812-43f2-9d52-6cef594e5e87",
          "self": "/progress_models/490f6d80-7812-43f2-9d52-6cef594e5e87/relationships/progress_steps"
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


# Syntax nodes

Syntax Nodes is the structure, in which Contexts are allowed to represent Syntax Elements. Syntax Nodes make up a graph tree.


## Show


### Request

#### Endpoint

```plaintext
GET /syntax_nodes/c0e50599-b314-4235-8722-be29cb7c1fe4?depth=2
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
X-Request-Id: de298ca2-6076-473a-ab3f-299fc2da5d11
200 OK
```


```json
{
  "data": {
    "id": "c0e50599-b314-4235-8722-be29cb7c1fe4",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/35098f56-95ef-46f5-bad9-5bb24ab794cf"
        }
      },
      "components": {
        "data": [
          {
            "id": "1ceacc99-556d-4c3a-a768-844bc56456f6",
            "type": "syntax_node"
          },
          {
            "id": "4d4039ea-c27a-473f-856c-80d010c8d834",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/c0e50599-b314-4235-8722-be29cb7c1fe4/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/c0e50599-b314-4235-8722-be29cb7c1fe4?depth=2"
  },
  "included": [
    {
      "id": "4d4039ea-c27a-473f-856c-80d010c8d834",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/35098f56-95ef-46f5-bad9-5bb24ab794cf"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/4d4039ea-c27a-473f-856c-80d010c8d834/relationships/components"
          }
        }
      }
    },
    {
      "id": "1ceacc99-556d-4c3a-a768-844bc56456f6",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/35098f56-95ef-46f5-bad9-5bb24ab794cf"
          }
        },
        "components": {
          "data": [
            {
              "id": "2f383687-9e1f-4fa1-90a5-ed860d3d6b81",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/1ceacc99-556d-4c3a-a768-844bc56456f6/relationships/components"
          }
        }
      }
    },
    {
      "id": "2f383687-9e1f-4fa1-90a5-ed860d3d6b81",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/35098f56-95ef-46f5-bad9-5bb24ab794cf"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/2f383687-9e1f-4fa1-90a5-ed860d3d6b81/relationships/components"
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
POST /syntax_nodes/870e8e8c-77b9-4c8a-9c85-8df37f4c9db1/relationships/components
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
X-Request-Id: c48ab58e-d72a-4599-a40c-c621b51b88cb
201 Created
```


```json
{
  "data": {
    "id": "e5c71ae7-f0e9-4a38-bf4f-5393fa672ade",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/24a0e384-3c57-4b28-973e-cfd93d3441a9"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/e5c71ae7-f0e9-4a38-bf4f-5393fa672ade/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/870e8e8c-77b9-4c8a-9c85-8df37f4c9db1/relationships/components"
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
PATCH /syntax_nodes/93e15a19-131d-4745-8963-7bc10a7c8706
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "93e15a19-131d-4745-8963-7bc10a7c8706",
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
X-Request-Id: 68df0f7e-7958-45b9-ba92-6701a8c89ec1
200 OK
```


```json
{
  "data": {
    "id": "93e15a19-131d-4745-8963-7bc10a7c8706",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/357a01b9-bcaa-43bd-9400-54bf5817e438"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/93e15a19-131d-4745-8963-7bc10a7c8706/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/93e15a19-131d-4745-8963-7bc10a7c8706"
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
DELETE /syntax_nodes/d6b46995-00dd-40f4-870d-bc645c5f34da
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e589263d-7a7a-4273-b378-20026c8c93f0
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


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
X-Request-Id: f6dd5c2b-c538-4806-8cc9-f1586f3d9925
200 OK
```


```json
{
  "data": [
    {
      "id": "ffb5d9ce-3331-44a4-bd92-d269992aba3b",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/cb8e0c64-6c83-4c90-8879-0624e356ede0"
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
GET /progress_steps/270af55c-c39c-4a65-baa2-3ce113546f72
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
X-Request-Id: b02f8c44-a71c-46ec-869a-1408b5ff62a1
200 OK
```


```json
{
  "data": {
    "id": "270af55c-c39c-4a65-baa2-3ce113546f72",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/c53ad465-44d6-49b9-9c09-88338bda4812"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/270af55c-c39c-4a65-baa2-3ce113546f72"
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
PATCH /progress_steps/dff1c520-10f2-4420-9c05-94c45fd74def
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "dff1c520-10f2-4420-9c05-94c45fd74def",
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
X-Request-Id: dc5fd474-1d56-4999-b8a4-e26709745367
200 OK
```


```json
{
  "data": {
    "id": "dff1c520-10f2-4420-9c05-94c45fd74def",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/29ce1a9b-67ed-40e0-a243-99be2c63d785"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/dff1c520-10f2-4420-9c05-94c45fd74def"
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
DELETE /progress_steps/03bbdd09-f87a-434e-a680-6bc2f319073b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 83431230-8720-44f2-95c3-160375decf06
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
POST /progress_models/0e195d9d-f4f8-4233-bae9-59b8fc00115f/relationships/progress_steps
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
X-Request-Id: 9c6cd702-8f76-42f2-bc19-0e982dece2e6
201 Created
```


```json
{
  "data": {
    "id": "c1b4a7a8-d186-4fb7-a3fc-ea095d51512c",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/0e195d9d-f4f8-4233-bae9-59b8fc00115f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0e195d9d-f4f8-4233-bae9-59b8fc00115f/relationships/progress_steps"
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
X-Request-Id: d25b2290-cab4-464c-8525-b405387a729b
200 OK
```


```json
{
  "data": [
    {
      "id": "0f50f26e-3273-4ff9-b309-7fa70c6e658d",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/e0fc9df1-6969-4dac-affe-524603ece400"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/991d62ac-f28b-4808-bfc4-002b9ad0b51f"
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
GET /progress/ed86d12f-1ba5-4295-bf41-ba416ade9f22
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
X-Request-Id: 5870572f-3590-4ad1-bdd8-d21feca5c61f
200 OK
```


```json
{
  "data": {
    "id": "ed86d12f-1ba5-4295-bf41-ba416ade9f22",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/2abbfa02-66f5-4b03-9e6d-db37800ee38b"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/c3195229-7c12-4c70-bd1a-f20c7b484ddf"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/ed86d12f-1ba5-4295-bf41-ba416ade9f22"
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
DELETE /progress/a8df05f9-0622-4007-a066-ddfdecea0d6e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c47a7ac3-6b60-4c71-8089-6a76d07a1e7d
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
          "id": "26a8d1ad-f6f1-4df3-8794-27b134767384"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "35d749a3-d34a-43b0-a176-66c02f22538d"
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
X-Request-Id: b0374edb-3301-46ca-bbc1-1496ba9bea9e
201 Created
```


```json
{
  "data": {
    "id": "e239185a-db58-4694-9b77-138b3b4130c4",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/26a8d1ad-f6f1-4df3-8794-27b134767384"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/35d749a3-d34a-43b0-a176-66c02f22538d"
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
X-Request-Id: 8317e261-9e7a-4e06-aefb-d57c3a2aaaba
200 OK
```


```json
{
  "data": [
    {
      "id": "29998342-6c6b-4872-a658-35bc42e31e7d",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "b77a51c4-c507-409b-b0a3-e3100d4bb2be"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/b77a51c4-c507-409b-b0a3-e3100d4bb2be"
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
GET /projects/b5f9348b-4b2a-4591-9dff-54c999dac446/relationships/project_setting
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
X-Request-Id: 48db2605-f107-4946-aeec-9fb9e1bea0ab
200 OK
```


```json
{
  "data": {
    "id": "fcd680d5-42f4-4a91-ba5e-a94e5e028048",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "b5f9348b-4b2a-4591-9dff-54c999dac446"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/b5f9348b-4b2a-4591-9dff-54c999dac446"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b5f9348b-4b2a-4591-9dff-54c999dac446/relationships/project_setting"
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
PATCH /projects/130b11b0-5663-4d1e-92fd-e66010d66219/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "130b11b0-5663-4d1e-92fd-e66010d66219",
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
X-Request-Id: 36c1868f-bc0d-4f97-b527-fa73765acb0f
200 OK
```


```json
{
  "data": {
    "id": "577f0c1c-070b-4b1d-8a4b-5dae94efbfee",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "130b11b0-5663-4d1e-92fd-e66010d66219"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/130b11b0-5663-4d1e-92fd-e66010d66219"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/130b11b0-5663-4d1e-92fd-e66010d66219/relationships/project_setting"
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
X-Request-Id: 5e97d322-1283-42ba-9da3-fb3a721aab82
200 OK
```


```json
{
  "data": {
    "id": "37b1b577-c9ea-408a-8ec3-84094322e51a",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "36892cf0-7fba-4dd8-bd75-2467a91fa87a"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/36892cf0-7fba-4dd8-bd75-2467a91fa87a"
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
X-Request-Id: 1f6b62f3-b528-460e-9d56-c40c4b79f961
200 OK
```


```json
{
  "data": {
    "id": "55024ba2-58d7-4990-af4a-26906b89fec6",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "555446a0-ee3f-4ee4-8eb9-5ac2907a61b4"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/555446a0-ee3f-4ee4-8eb9-5ac2907a61b4"
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
X-Request-Id: ce8bd713-38cb-4e4f-bbaa-8c3e674bbcfe
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
GET /utils/path/from/object_occurrence/c5be80bb-9e7a-4a75-bf12-39d374916784/to/object_occurrence/9d079dc6-93e4-496a-a952-291bfaa4dfae
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
X-Request-Id: 47242e84-2a72-4b5a-80eb-450e97c3717e
200 OK
```


```json
[
  {
    "id": "c5be80bb-9e7a-4a75-bf12-39d374916784",
    "type": "object_occurrence"
  },
  {
    "id": "4fffd4f6-009e-4cc9-91f7-3647a4a0d056",
    "type": "object_occurrence"
  },
  {
    "id": "92828da5-06a0-4ea8-bb59-5c2804a6d4d4",
    "type": "object_occurrence"
  },
  {
    "id": "76c386f9-ff3d-4682-94ee-3ea2386626c7",
    "type": "object_occurrence"
  },
  {
    "id": "db08a840-d6bd-4664-8316-c3824771e9e3",
    "type": "object_occurrence"
  },
  {
    "id": "4dc60800-8af8-44df-bf6d-a7dfa48a8a0b",
    "type": "object_occurrence"
  },
  {
    "id": "9d079dc6-93e4-496a-a952-291bfaa4dfae",
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
X-Request-Id: 8159fda7-9b24-4ae0-8356-466f50fd0a99
200 OK
```


```json
{
  "data": [
    {
      "id": "19cfc617-190b-4376-bd23-08b6cf65cd67",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/74665752-553c-41dc-866c-4b1762cb3935"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/39d4af8e-4b82-4ca6-ac76-f80fb57dd95b"
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
X-Request-Id: 747c56da-5ff3-403d-a22e-5e2cbf2ec488
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



