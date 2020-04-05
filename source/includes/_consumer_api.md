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
X-Request-Id: 8b8e99eb-ee10-4ff3-a32e-acab56f58681
200 OK
```


```json
{
  "data": {
    "id": "01b32c4b-c01e-4a7d-b703-401b2f8b976e",
    "type": "account",
    "attributes": {
      "name": "Account 9157b5d421ad"
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
X-Request-Id: 8e817a41-e8e6-4bf3-87b8-cb2953a4b10c
200 OK
```


```json
{
  "data": {
    "id": "5a9bc3d5-912f-4db0-86ee-2e79f1e63a3c",
    "type": "account",
    "attributes": {
      "name": "Account d89de6ce58eb"
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
    "id": "14c10a2b-da06-4b48-9c8b-6bd0ba1894ae",
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
X-Request-Id: 3616c2e7-1a6a-4c2c-a27a-2823d8f3395a
200 OK
```


```json
{
  "data": {
    "id": "14c10a2b-da06-4b48-9c8b-6bd0ba1894ae",
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
X-Request-Id: 7e6f7a21-7153-4ee3-a5ca-efcda9c612ec
200 OK
```


```json
{
  "data": [
    {
      "id": "7b8ebaad-f81c-43ca-83fb-7b1f980d7c63",
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
            "related": "/contexts?filter[project_id_eq]=7b8ebaad-f81c-43ca-83fb-7b1f980d7c63",
            "self": "/projects/7b8ebaad-f81c-43ca-83fb-7b1f980d7c63/relationships/contexts"
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
GET /projects/0aba85b4-adff-4109-b6fd-d160cba45713
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
X-Request-Id: 453ad647-9e10-4694-aae3-2355d632a48e
200 OK
```


```json
{
  "data": {
    "id": "0aba85b4-adff-4109-b6fd-d160cba45713",
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
          "related": "/contexts?filter[project_id_eq]=0aba85b4-adff-4109-b6fd-d160cba45713",
          "self": "/projects/0aba85b4-adff-4109-b6fd-d160cba45713/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/0aba85b4-adff-4109-b6fd-d160cba45713"
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
PATCH /projects/22042f8b-c691-4873-ab7d-8b5fd9399e6d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "22042f8b-c691-4873-ab7d-8b5fd9399e6d",
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
X-Request-Id: 43306372-39ff-4179-92fd-56684a88bbfb
200 OK
```


```json
{
  "data": {
    "id": "22042f8b-c691-4873-ab7d-8b5fd9399e6d",
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
          "related": "/contexts?filter[project_id_eq]=22042f8b-c691-4873-ab7d-8b5fd9399e6d",
          "self": "/projects/22042f8b-c691-4873-ab7d-8b5fd9399e6d/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/22042f8b-c691-4873-ab7d-8b5fd9399e6d"
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
POST /projects/5fe50268-3374-45d1-ab23-eae29df7bbe8/archive
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
X-Request-Id: 887babdd-8d83-4bf8-9545-1d0c1479c126
200 OK
```


```json
{
  "data": {
    "id": "5fe50268-3374-45d1-ab23-eae29df7bbe8",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-05T09:37:37.877Z",
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
          "related": "/contexts?filter[project_id_eq]=5fe50268-3374-45d1-ab23-eae29df7bbe8",
          "self": "/projects/5fe50268-3374-45d1-ab23-eae29df7bbe8/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/5fe50268-3374-45d1-ab23-eae29df7bbe8/archive"
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
DELETE /projects/a5a68d28-6db3-467d-8727-91b559ae5865
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2827991d-5d56-4d24-83a9-cd9a75e8aee1
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
X-Request-Id: 855065e7-c796-4c5d-b096-9d8433ee708e
200 OK
```


```json
{
  "data": [
    {
      "id": "4647bbd3-241c-4a68-a6ee-5d6f4ea972ea",
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
            "related": "/projects/1fd36c02-ed5e-4328-b071-1df09d5bbf7f"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/8f6ce926-6da5-4eae-b457-db0c6f4b71a5"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/7e7231b0-662b-4bb4-ad81-85b7dcb8d80c"
          }
        }
      }
    },
    {
      "id": "da89368e-ae6c-41cc-b0fb-e4d0ad4b6a15",
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
            "related": "/projects/1fd36c02-ed5e-4328-b071-1df09d5bbf7f"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/046a2403-8864-41fb-8ae2-b9be484f63db"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/7e7231b0-662b-4bb4-ad81-85b7dcb8d80c"
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
GET /contexts/3909594c-d4af-4af9-936f-659f7b2cbf1f
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
X-Request-Id: 7413a161-b9d2-4c07-8d27-860fcead9cd6
200 OK
```


```json
{
  "data": {
    "id": "3909594c-d4af-4af9-936f-659f7b2cbf1f",
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
          "related": "/projects/623e75a4-cc4e-4da6-a5e2-1cbbddce6cb2"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/52f89ed8-150b-4e89-a436-7f2c8e75a286"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/1a17ed1f-8901-4d1e-878b-25c283e9a2de"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/3909594c-d4af-4af9-936f-659f7b2cbf1f"
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
PATCH /contexts/f0035072-6feb-425d-a2fa-d4e2eeabed5a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "f0035072-6feb-425d-a2fa-d4e2eeabed5a",
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
X-Request-Id: ab5247c9-9fb5-4456-84ce-75b9502ad18f
200 OK
```


```json
{
  "data": {
    "id": "f0035072-6feb-425d-a2fa-d4e2eeabed5a",
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
          "related": "/projects/514ae7a1-5e69-491b-a8d0-d7373f22137b"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/aba120e0-d71c-433b-ab3f-857f0d8f6fe6"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/14e85703-a603-4fb7-8824-a9a29485ad11"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/f0035072-6feb-425d-a2fa-d4e2eeabed5a"
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
POST /projects/d1b6e29c-f10c-4a9c-aacf-bab168acb3ec/relationships/contexts
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
          "id": "8c0bc53d-7519-4980-bb92-718fb5806c61"
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
X-Request-Id: 763e3c32-6630-48fe-ab0a-03b1e69eb586
201 Created
```


```json
{
  "data": {
    "id": "77151fd4-d17a-4e56-b78e-952b6d57b971",
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
          "related": "/projects/d1b6e29c-f10c-4a9c-aacf-bab168acb3ec"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/c2fc70b5-e37c-452c-af87-e23bc895c568"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/8c0bc53d-7519-4980-bb92-718fb5806c61"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/d1b6e29c-f10c-4a9c-aacf-bab168acb3ec/relationships/contexts"
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
POST /contexts/7bebfd6d-c0d7-4e17-84b7-94416bc173bb/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/19047704f59edd9c31848a2f
Content-Type: text/html; charset=utf-8
X-Request-Id: 03140e22-0a82-46f7-9ef1-ef9d4557f411
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/19047704f59edd9c31848a2f">redirected</a>.</body></html>
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
DELETE /contexts/59ddfeac-b9eb-44b1-bc67-548cf8b95210
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: aaa1fa5c-cae4-4529-8c19-d88e4f5201c4
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
POST /object_occurrences/c9efc62a-fc38-4eb8-bc2e-01e21df24559/relationships/tags
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
X-Request-Id: dc0e0940-9444-4135-9b91-3b41c66fcee0
201 Created
```


```json
{
  "data": {
    "id": "bad2b97b-240a-4a0d-a9a6-2c62c0c2a789",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c9efc62a-fc38-4eb8-bc2e-01e21df24559/relationships/tags"
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
POST /object_occurrences/34852793-c5c5-40ee-a394-261126571d45/relationships/tags
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
    "id": "ba33b878-72de-4218-80ae-498c4b5ac068"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 07876fd4-3906-462b-954c-81fe0dceae5c
201 Created
```


```json
{
  "data": {
    "id": "ba33b878-72de-4218-80ae-498c4b5ac068",
    "type": "tag",
    "attributes": {
      "value": "tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/34852793-c5c5-40ee-a394-261126571d45/relationships/tags"
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
DELETE /object_occurrences/a820d5dc-9581-4fc1-a8eb-6d8e58a406f0/relationships/tags/0f655d81-006c-40dd-9895-ce465b84eb07
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 95dae39d-692d-4f36-b582-29dd71c7fc81
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/edc46da9-7298-4b8b-b526-0ba513851f34/relationships/owners
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
X-Request-Id: 7f81f0fa-7ec1-45e6-af09-cf6ec96250c4
201 Created
```


```json
{
  "data": {
    "id": "59d57616-9dc5-494f-a5f3-0f440c1dcf80",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/edc46da9-7298-4b8b-b526-0ba513851f34/relationships/owners"
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
POST /object_occurrences/52a039d0-6f8d-4901-9265-f88ab0cdc9bf/relationships/owners
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
X-Request-Id: 2ac76066-c65e-4418-b312-dbc00e00a74b
201 Created
```


```json
{
  "data": {
    "id": "f154413d-9bcc-478e-8c1b-70a7e1961b0d",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/52a039d0-6f8d-4901-9265-f88ab0cdc9bf/relationships/owners"
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
POST /object_occurrences/d2287216-4dc9-45cf-b145-818245532157/relationships/owners
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
    "id": "40ddc8af-062c-4171-8dbe-c7d92763669a"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 404761d9-3fea-4928-857b-ecf4dd414f5c
201 Created
```


```json
{
  "data": {
    "id": "40ddc8af-062c-4171-8dbe-c7d92763669a",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 1",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d2287216-4dc9-45cf-b145-818245532157/relationships/owners"
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
DELETE /object_occurrences/02bfa301-e110-41a6-81c4-2cf3b68d42a8/relationships/owners/59959740-bebf-4e9e-8b08-0e2ff4ee01a9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 78079919-4419-460c-8e6a-2572114f144c
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
| filter[syntax_element_id_in]  | filter by syntax elements ids |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 148991f2-9957-481e-87a5-88d235cf9d6f
200 OK
```


```json
{
  "data": [
    {
      "id": "e25f525e-39a7-4015-8faa-85c63ec2b88b",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 94ae679eb339",
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
            "related": "/tags?filter[target_id_eq]=e25f525e-39a7-4015-8faa-85c63ec2b88b",
            "self": "/object_occurrences/e25f525e-39a7-4015-8faa-85c63ec2b88b/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e25f525e-39a7-4015-8faa-85c63ec2b88b&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e25f525e-39a7-4015-8faa-85c63ec2b88b/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/dbc1f500-a46b-4bc9-b7ee-0d65eff4157f"
          }
        },
        "components": {
          "data": [
            {
              "id": "443800f0-29a3-4051-aa6f-b4455f3c3723",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/e25f525e-39a7-4015-8faa-85c63ec2b88b/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e25f525e-39a7-4015-8faa-85c63ec2b88b"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e25f525e-39a7-4015-8faa-85c63ec2b88b"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e25f525e-39a7-4015-8faa-85c63ec2b88b"
          }
        }
      }
    },
    {
      "id": "443800f0-29a3-4051-aa6f-b4455f3c3723",
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
            "related": "/tags?filter[target_id_eq]=443800f0-29a3-4051-aa6f-b4455f3c3723",
            "self": "/object_occurrences/443800f0-29a3-4051-aa6f-b4455f3c3723/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=443800f0-29a3-4051-aa6f-b4455f3c3723&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/443800f0-29a3-4051-aa6f-b4455f3c3723/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/dbc1f500-a46b-4bc9-b7ee-0d65eff4157f"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/e25f525e-39a7-4015-8faa-85c63ec2b88b",
            "self": "/object_occurrences/443800f0-29a3-4051-aa6f-b4455f3c3723/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "f5252603-501b-4b78-806e-0bf0b15877a5",
              "type": "object_occurrence"
            },
            {
              "id": "b179a00e-9e3d-44d6-aa16-5ac760534500",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/443800f0-29a3-4051-aa6f-b4455f3c3723/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=443800f0-29a3-4051-aa6f-b4455f3c3723"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=443800f0-29a3-4051-aa6f-b4455f3c3723"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=443800f0-29a3-4051-aa6f-b4455f3c3723"
          }
        }
      }
    },
    {
      "id": "3417659c-7544-4502-a7f7-a2757497f304",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC f8d4cea1ea92",
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
            "related": "/tags?filter[target_id_eq]=3417659c-7544-4502-a7f7-a2757497f304",
            "self": "/object_occurrences/3417659c-7544-4502-a7f7-a2757497f304/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=3417659c-7544-4502-a7f7-a2757497f304&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/3417659c-7544-4502-a7f7-a2757497f304/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/be94eeda-1637-4b35-90c1-71e001f562e7"
          }
        },
        "components": {
          "data": [
            {
              "id": "3c289754-c84a-438a-ba2f-c728eb466bbf",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/3417659c-7544-4502-a7f7-a2757497f304/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=3417659c-7544-4502-a7f7-a2757497f304"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=3417659c-7544-4502-a7f7-a2757497f304"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=3417659c-7544-4502-a7f7-a2757497f304"
          }
        }
      }
    },
    {
      "id": "f5252603-501b-4b78-806e-0bf0b15877a5",
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
            "related": "/tags?filter[target_id_eq]=f5252603-501b-4b78-806e-0bf0b15877a5",
            "self": "/object_occurrences/f5252603-501b-4b78-806e-0bf0b15877a5/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=f5252603-501b-4b78-806e-0bf0b15877a5&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/f5252603-501b-4b78-806e-0bf0b15877a5/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/dbc1f500-a46b-4bc9-b7ee-0d65eff4157f"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/443800f0-29a3-4051-aa6f-b4455f3c3723",
            "self": "/object_occurrences/f5252603-501b-4b78-806e-0bf0b15877a5/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/f5252603-501b-4b78-806e-0bf0b15877a5/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=f5252603-501b-4b78-806e-0bf0b15877a5"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=f5252603-501b-4b78-806e-0bf0b15877a5"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=f5252603-501b-4b78-806e-0bf0b15877a5"
          }
        }
      }
    },
    {
      "id": "b179a00e-9e3d-44d6-aa16-5ac760534500",
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
            "related": "/tags?filter[target_id_eq]=b179a00e-9e3d-44d6-aa16-5ac760534500",
            "self": "/object_occurrences/b179a00e-9e3d-44d6-aa16-5ac760534500/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=b179a00e-9e3d-44d6-aa16-5ac760534500&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/b179a00e-9e3d-44d6-aa16-5ac760534500/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/dbc1f500-a46b-4bc9-b7ee-0d65eff4157f"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/443800f0-29a3-4051-aa6f-b4455f3c3723",
            "self": "/object_occurrences/b179a00e-9e3d-44d6-aa16-5ac760534500/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/b179a00e-9e3d-44d6-aa16-5ac760534500/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b179a00e-9e3d-44d6-aa16-5ac760534500"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b179a00e-9e3d-44d6-aa16-5ac760534500"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b179a00e-9e3d-44d6-aa16-5ac760534500"
          }
        }
      }
    },
    {
      "id": "3c289754-c84a-438a-ba2f-c728eb466bbf",
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
            "related": "/tags?filter[target_id_eq]=3c289754-c84a-438a-ba2f-c728eb466bbf",
            "self": "/object_occurrences/3c289754-c84a-438a-ba2f-c728eb466bbf/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=3c289754-c84a-438a-ba2f-c728eb466bbf&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/3c289754-c84a-438a-ba2f-c728eb466bbf/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/be94eeda-1637-4b35-90c1-71e001f562e7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/3417659c-7544-4502-a7f7-a2757497f304",
            "self": "/object_occurrences/3c289754-c84a-438a-ba2f-c728eb466bbf/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/3c289754-c84a-438a-ba2f-c728eb466bbf/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=3c289754-c84a-438a-ba2f-c728eb466bbf"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=3c289754-c84a-438a-ba2f-c728eb466bbf"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=3c289754-c84a-438a-ba2f-c728eb466bbf"
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
GET /object_occurrences/ef8daa5c-229a-4513-b6ed-d55c021fd249
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
X-Request-Id: 2439bcf3-0154-4701-b7ed-40130adfa642
200 OK
```


```json
{
  "data": {
    "id": "ef8daa5c-229a-4513-b6ed-d55c021fd249",
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
          "related": "/tags?filter[target_id_eq]=ef8daa5c-229a-4513-b6ed-d55c021fd249",
          "self": "/object_occurrences/ef8daa5c-229a-4513-b6ed-d55c021fd249/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=ef8daa5c-229a-4513-b6ed-d55c021fd249&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/ef8daa5c-229a-4513-b6ed-d55c021fd249/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/0cd758c6-5716-487d-9243-f802669cb5f0"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/5887165c-fc6f-4c87-897a-1fbbacb5c57a",
          "self": "/object_occurrences/ef8daa5c-229a-4513-b6ed-d55c021fd249/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "d332cbd2-7e07-41b7-8f18-a18876f55a85",
            "type": "object_occurrence"
          },
          {
            "id": "a60432f5-92d1-4e5a-80c5-3fdedef88466",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/ef8daa5c-229a-4513-b6ed-d55c021fd249/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=ef8daa5c-229a-4513-b6ed-d55c021fd249"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=ef8daa5c-229a-4513-b6ed-d55c021fd249"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=ef8daa5c-229a-4513-b6ed-d55c021fd249"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/ef8daa5c-229a-4513-b6ed-d55c021fd249"
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
POST /object_occurrences/7d01fb9d-43e0-4d5e-935a-ebbfcbb50127/relationships/components
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
X-Request-Id: 3194fb5b-e830-4f2b-b50b-7cb62c8d8dad
201 Created
```


```json
{
  "data": {
    "id": "fea0716b-4362-44b1-af63-34955ea37083",
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
          "related": "/tags?filter[target_id_eq]=fea0716b-4362-44b1-af63-34955ea37083",
          "self": "/object_occurrences/fea0716b-4362-44b1-af63-34955ea37083/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=fea0716b-4362-44b1-af63-34955ea37083&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/fea0716b-4362-44b1-af63-34955ea37083/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/f84e6e6d-e7db-4702-adb9-a83a0ca6b019"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/7d01fb9d-43e0-4d5e-935a-ebbfcbb50127",
          "self": "/object_occurrences/fea0716b-4362-44b1-af63-34955ea37083/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/fea0716b-4362-44b1-af63-34955ea37083/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=fea0716b-4362-44b1-af63-34955ea37083"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=fea0716b-4362-44b1-af63-34955ea37083"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=fea0716b-4362-44b1-af63-34955ea37083"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/7d01fb9d-43e0-4d5e-935a-ebbfcbb50127/relationships/components"
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
POST /object_occurrences/b197d617-7eb9-4aeb-82f0-dca7af737fec/relationships/components
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
X-Request-Id: 419441d7-b33c-4a63-bb1c-56b23bd0e77e
201 Created
```


```json
{
  "data": {
    "id": "1e68c61f-d3b1-4784-b40e-d207ef70ab99",
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
          "related": "/tags?filter[target_id_eq]=1e68c61f-d3b1-4784-b40e-d207ef70ab99",
          "self": "/object_occurrences/1e68c61f-d3b1-4784-b40e-d207ef70ab99/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=1e68c61f-d3b1-4784-b40e-d207ef70ab99&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/1e68c61f-d3b1-4784-b40e-d207ef70ab99/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/656b44a1-dfee-420e-8a37-1aeecf1bf63f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b197d617-7eb9-4aeb-82f0-dca7af737fec/relationships/components"
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
PATCH /object_occurrences/b3c6448b-3285-42f9-95bd-fdf3968030ad
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "b3c6448b-3285-42f9-95bd-fdf3968030ad",
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
          "id": "6b67f7df-6395-4e6c-abfe-3e3be338c37e"
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
X-Request-Id: 3b405282-f59c-4427-a0b3-ad2de67851ca
200 OK
```


```json
{
  "data": {
    "id": "b3c6448b-3285-42f9-95bd-fdf3968030ad",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "#ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=b3c6448b-3285-42f9-95bd-fdf3968030ad",
          "self": "/object_occurrences/b3c6448b-3285-42f9-95bd-fdf3968030ad/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=b3c6448b-3285-42f9-95bd-fdf3968030ad&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/b3c6448b-3285-42f9-95bd-fdf3968030ad/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/de67e24d-0e6d-4302-a513-9da9db20e733"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6b67f7df-6395-4e6c-abfe-3e3be338c37e",
          "self": "/object_occurrences/b3c6448b-3285-42f9-95bd-fdf3968030ad/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/b3c6448b-3285-42f9-95bd-fdf3968030ad/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b3c6448b-3285-42f9-95bd-fdf3968030ad"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b3c6448b-3285-42f9-95bd-fdf3968030ad"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b3c6448b-3285-42f9-95bd-fdf3968030ad"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b3c6448b-3285-42f9-95bd-fdf3968030ad"
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
POST /object_occurrences/654ad851-51a0-4aed-8587-499e899e4829/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "5c21fa45-6710-4c3b-9c9d-32a576f731b9",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/566af1b861c5c25980c342d5
Content-Type: text/html; charset=utf-8
X-Request-Id: 69e75fce-dd78-4a28-8c08-5af3a8a47844
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/566af1b861c5c25980c342d5">redirected</a>.</body></html>
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
DELETE /object_occurrences/1c9207fb-a3c4-43de-b9bf-de63ac142f30
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3cbffde9-b350-4a91-b9fc-896b3fd661bc
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/983b91a2-09f6-4355-bdd3-ab784ccf2d79/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "bf7c1761-6ba1-4651-ba9a-210dd463c8dc",
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
X-Request-Id: cc4b5519-d2aa-436d-9349-cacbdad77f55
200 OK
```


```json
{
  "data": {
    "id": "983b91a2-09f6-4355-bdd3-ab784ccf2d79",
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
          "related": "/tags?filter[target_id_eq]=983b91a2-09f6-4355-bdd3-ab784ccf2d79",
          "self": "/object_occurrences/983b91a2-09f6-4355-bdd3-ab784ccf2d79/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=983b91a2-09f6-4355-bdd3-ab784ccf2d79&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/983b91a2-09f6-4355-bdd3-ab784ccf2d79/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/048ae9a0-8936-407e-94e1-caa921d8efc2"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/bf7c1761-6ba1-4651-ba9a-210dd463c8dc",
          "self": "/object_occurrences/983b91a2-09f6-4355-bdd3-ab784ccf2d79/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/983b91a2-09f6-4355-bdd3-ab784ccf2d79/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=983b91a2-09f6-4355-bdd3-ab784ccf2d79"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=983b91a2-09f6-4355-bdd3-ab784ccf2d79"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=983b91a2-09f6-4355-bdd3-ab784ccf2d79"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/983b91a2-09f6-4355-bdd3-ab784ccf2d79/relationships/part_of"
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
POST /classification_tables/923e9dc7-2c0d-4027-8e2c-bc722aa0b9b3/relationships/tags
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
X-Request-Id: bcbb6ba6-5703-49de-a9b2-8acd3b476067
201 Created
```


```json
{
  "data": {
    "id": "d875aa38-a2aa-4f94-81c7-1613aa5a89ed",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/923e9dc7-2c0d-4027-8e2c-bc722aa0b9b3/relationships/tags"
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
POST /classification_tables/adb7b1a7-d47a-4633-9abc-c07729cc37ac/relationships/tags
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
    "id": "b51789fa-f1d0-4e39-b809-41ed0e78690d"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c6370dd8-cba6-4057-887c-9090b9412809
201 Created
```


```json
{
  "data": {
    "id": "b51789fa-f1d0-4e39-b809-41ed0e78690d",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/adb7b1a7-d47a-4633-9abc-c07729cc37ac/relationships/tags"
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
DELETE /classification_tables/e46accb0-ad89-437a-a508-6e7b6c6ccf7b/relationships/tags/498c614f-b5ec-4494-944c-f3e2eea987f5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5bfe623d-afca-4d5b-a40a-aa25d34b86bd
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
X-Request-Id: c7a388cc-2314-42be-a731-86f33fca32be
200 OK
```


```json
{
  "data": [
    {
      "id": "ade81fd5-488c-41e9-b2e8-e10fa479019d",
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
            "related": "/tags?filter[target_id_eq]=ade81fd5-488c-41e9-b2e8-e10fa479019d",
            "self": "/classification_tables/ade81fd5-488c-41e9-b2e8-e10fa479019d/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=ade81fd5-488c-41e9-b2e8-e10fa479019d",
            "self": "/classification_tables/ade81fd5-488c-41e9-b2e8-e10fa479019d/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "8c7566ef-f2ef-4978-b13d-5b040aedf203",
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
            "related": "/tags?filter[target_id_eq]=8c7566ef-f2ef-4978-b13d-5b040aedf203",
            "self": "/classification_tables/8c7566ef-f2ef-4978-b13d-5b040aedf203/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=8c7566ef-f2ef-4978-b13d-5b040aedf203",
            "self": "/classification_tables/8c7566ef-f2ef-4978-b13d-5b040aedf203/relationships/classification_entries",
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
GET /classification_tables/99299f42-3c78-4f0c-90d0-8d4aac31aa20
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
X-Request-Id: c9f59e08-d56b-4b42-b0ee-17e70aeb8ac2
200 OK
```


```json
{
  "data": {
    "id": "99299f42-3c78-4f0c-90d0-8d4aac31aa20",
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
          "related": "/tags?filter[target_id_eq]=99299f42-3c78-4f0c-90d0-8d4aac31aa20",
          "self": "/classification_tables/99299f42-3c78-4f0c-90d0-8d4aac31aa20/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=99299f42-3c78-4f0c-90d0-8d4aac31aa20",
          "self": "/classification_tables/99299f42-3c78-4f0c-90d0-8d4aac31aa20/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/99299f42-3c78-4f0c-90d0-8d4aac31aa20"
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
PATCH /classification_tables/95c4cd20-3338-4fb3-bc31-510328435755
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "95c4cd20-3338-4fb3-bc31-510328435755",
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
X-Request-Id: 19fc6520-5599-4c7a-a888-e4a337dbe659
200 OK
```


```json
{
  "data": {
    "id": "95c4cd20-3338-4fb3-bc31-510328435755",
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
          "related": "/tags?filter[target_id_eq]=95c4cd20-3338-4fb3-bc31-510328435755",
          "self": "/classification_tables/95c4cd20-3338-4fb3-bc31-510328435755/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=95c4cd20-3338-4fb3-bc31-510328435755",
          "self": "/classification_tables/95c4cd20-3338-4fb3-bc31-510328435755/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/95c4cd20-3338-4fb3-bc31-510328435755"
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
DELETE /classification_tables/97ad8d08-b94a-483e-8d82-bd847dd60f4a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5c93faf1-613c-494a-bb0a-9203d75d6426
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
POST /classification_tables/8b1648cd-18ad-40e6-8946-f7c169d74cca/publish
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
X-Request-Id: b34fce95-63b6-4969-9adb-f9373a2cfd45
200 OK
```


```json
{
  "data": {
    "id": "8b1648cd-18ad-40e6-8946-f7c169d74cca",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-04-05T09:38:04.912Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=8b1648cd-18ad-40e6-8946-f7c169d74cca",
          "self": "/classification_tables/8b1648cd-18ad-40e6-8946-f7c169d74cca/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=8b1648cd-18ad-40e6-8946-f7c169d74cca",
          "self": "/classification_tables/8b1648cd-18ad-40e6-8946-f7c169d74cca/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/8b1648cd-18ad-40e6-8946-f7c169d74cca/publish"
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
POST /classification_tables/d3cc865a-0416-434d-95cf-7d6516407d5d/archive
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
X-Request-Id: e78881ec-5b67-4cf5-9018-547a543c6bc6
200 OK
```


```json
{
  "data": {
    "id": "d3cc865a-0416-434d-95cf-7d6516407d5d",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-05T09:38:05.616Z",
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
          "related": "/tags?filter[target_id_eq]=d3cc865a-0416-434d-95cf-7d6516407d5d",
          "self": "/classification_tables/d3cc865a-0416-434d-95cf-7d6516407d5d/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=d3cc865a-0416-434d-95cf-7d6516407d5d",
          "self": "/classification_tables/d3cc865a-0416-434d-95cf-7d6516407d5d/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d3cc865a-0416-434d-95cf-7d6516407d5d/archive"
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
X-Request-Id: ea7af9d3-ca38-46fc-ae1e-4046884c9b96
201 Created
```


```json
{
  "data": {
    "id": "bf556769-e91d-4f43-86da-338e81d6d144",
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
          "related": "/tags?filter[target_id_eq]=bf556769-e91d-4f43-86da-338e81d6d144",
          "self": "/classification_tables/bf556769-e91d-4f43-86da-338e81d6d144/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=bf556769-e91d-4f43-86da-338e81d6d144",
          "self": "/classification_tables/bf556769-e91d-4f43-86da-338e81d6d144/relationships/classification_entries",
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
POST /classification_entries/9ca43fbc-bf0b-4b7f-9c5e-088cfef0d179/relationships/tags
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
X-Request-Id: a604e06c-b07a-46a3-ad39-22b56442e4dc
201 Created
```


```json
{
  "data": {
    "id": "0404adb7-c12c-46eb-9fb7-82c3adb95f14",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/9ca43fbc-bf0b-4b7f-9c5e-088cfef0d179/relationships/tags"
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
POST /classification_entries/072b2bd4-ca49-45fc-b82d-ff31fb63f270/relationships/tags
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
    "id": "f27be3e9-7101-4683-a925-018ffb6328eb"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: eb98e095-1002-49f0-82fc-a663be40b653
201 Created
```


```json
{
  "data": {
    "id": "f27be3e9-7101-4683-a925-018ffb6328eb",
    "type": "tag",
    "attributes": {
      "value": "tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/072b2bd4-ca49-45fc-b82d-ff31fb63f270/relationships/tags"
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
DELETE /classification_entries/ec414c95-0269-494b-85dc-3ec1d1113593/relationships/tags/438b2b9b-0891-4e1a-bd39-7bdbd231e492
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1c32ef3d-201b-462c-bee5-619c529b9f32
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
X-Request-Id: c4c2e3b7-b592-4f5d-8203-da5e4ff9e1bf
200 OK
```


```json
{
  "data": [
    {
      "id": "a8f1b7a1-6d53-40f0-8f4a-eeb3908619e2",
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
            "related": "/tags?filter[target_id_eq]=a8f1b7a1-6d53-40f0-8f4a-eeb3908619e2",
            "self": "/classification_entries/a8f1b7a1-6d53-40f0-8f4a-eeb3908619e2/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=a8f1b7a1-6d53-40f0-8f4a-eeb3908619e2",
            "self": "/classification_entries/a8f1b7a1-6d53-40f0-8f4a-eeb3908619e2/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "0636da9f-53ac-4443-b6ee-450d375e6f70",
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
            "related": "/tags?filter[target_id_eq]=0636da9f-53ac-4443-b6ee-450d375e6f70",
            "self": "/classification_entries/0636da9f-53ac-4443-b6ee-450d375e6f70/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "a8f1b7a1-6d53-40f0-8f4a-eeb3908619e2",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/0636da9f-53ac-4443-b6ee-450d375e6f70"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=0636da9f-53ac-4443-b6ee-450d375e6f70",
            "self": "/classification_entries/0636da9f-53ac-4443-b6ee-450d375e6f70/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "3d16d31e-9768-43f8-94fb-44991b3f58f4",
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
            "related": "/tags?filter[target_id_eq]=3d16d31e-9768-43f8-94fb-44991b3f58f4",
            "self": "/classification_entries/3d16d31e-9768-43f8-94fb-44991b3f58f4/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=3d16d31e-9768-43f8-94fb-44991b3f58f4",
            "self": "/classification_entries/3d16d31e-9768-43f8-94fb-44991b3f58f4/relationships/classification_entries",
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
GET /classification_entries/7049a161-49d6-4087-8a38-66621906bf27
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
X-Request-Id: bd35eae5-4f3b-4c3b-8118-3b3070141622
200 OK
```


```json
{
  "data": {
    "id": "7049a161-49d6-4087-8a38-66621906bf27",
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
          "related": "/tags?filter[target_id_eq]=7049a161-49d6-4087-8a38-66621906bf27",
          "self": "/classification_entries/7049a161-49d6-4087-8a38-66621906bf27/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=7049a161-49d6-4087-8a38-66621906bf27",
          "self": "/classification_entries/7049a161-49d6-4087-8a38-66621906bf27/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/7049a161-49d6-4087-8a38-66621906bf27"
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
PATCH /classification_entries/01bfe8d9-8b8e-478a-833c-1d4ab269b2fc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "01bfe8d9-8b8e-478a-833c-1d4ab269b2fc",
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
X-Request-Id: 92bd9542-e140-4fc1-a02a-397d6fc573e8
200 OK
```


```json
{
  "data": {
    "id": "01bfe8d9-8b8e-478a-833c-1d4ab269b2fc",
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
          "related": "/tags?filter[target_id_eq]=01bfe8d9-8b8e-478a-833c-1d4ab269b2fc",
          "self": "/classification_entries/01bfe8d9-8b8e-478a-833c-1d4ab269b2fc/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "ef7947df-631e-4493-a6c5-23b5f6091495",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/01bfe8d9-8b8e-478a-833c-1d4ab269b2fc"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=01bfe8d9-8b8e-478a-833c-1d4ab269b2fc",
          "self": "/classification_entries/01bfe8d9-8b8e-478a-833c-1d4ab269b2fc/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/01bfe8d9-8b8e-478a-833c-1d4ab269b2fc"
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
DELETE /classification_entries/f4495cef-0323-47b1-865e-04a5135701b1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9e039cb0-06c9-4273-87fd-f30042e818aa
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
POST /classification_tables/4f1f285a-1a44-490d-b69f-cf8339a02ee3/relationships/classification_entries
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
X-Request-Id: 9ab97814-ac91-4820-86c0-714a9c51c14c
201 Created
```


```json
{
  "data": {
    "id": "29cb98d0-50e8-4fd3-b8f4-b2171a5c2325",
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
          "related": "/tags?filter[target_id_eq]=29cb98d0-50e8-4fd3-b8f4-b2171a5c2325",
          "self": "/classification_entries/29cb98d0-50e8-4fd3-b8f4-b2171a5c2325/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=29cb98d0-50e8-4fd3-b8f4-b2171a5c2325",
          "self": "/classification_entries/29cb98d0-50e8-4fd3-b8f4-b2171a5c2325/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/4f1f285a-1a44-490d-b69f-cf8339a02ee3/relationships/classification_entries"
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
X-Request-Id: f2685f92-654e-4627-8052-6eb84b210b64
200 OK
```


```json
{
  "data": [
    {
      "id": "3ecf9bad-f109-45ce-a5a8-7a38dba648a5",
      "type": "syntax",
      "attributes": {
        "account_id": "d5561af6-0a89-4acc-8ccb-a667e79f2c4f",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 255246f5093e",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=3ecf9bad-f109-45ce-a5a8-7a38dba648a5",
            "self": "/syntaxes/3ecf9bad-f109-45ce-a5a8-7a38dba648a5/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/022f3a8e-1c3c-471c-90ff-1108a784fb4b",
            "self": "/syntax_nodes/022f3a8e-1c3c-471c-90ff-1108a784fb4b/relationships/components"
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
GET /syntaxes/777909b3-953b-4efe-b9fd-76c695339f89
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
X-Request-Id: b25e3d72-ddf5-4236-aa05-033f5bfc4714
200 OK
```


```json
{
  "data": {
    "id": "777909b3-953b-4efe-b9fd-76c695339f89",
    "type": "syntax",
    "attributes": {
      "account_id": "e8a50868-8d94-4bbe-beb1-144126b80bcb",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 0775497177be",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=777909b3-953b-4efe-b9fd-76c695339f89",
          "self": "/syntaxes/777909b3-953b-4efe-b9fd-76c695339f89/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/31965930-9f1c-4f0c-bf10-5188a9fe2647",
          "self": "/syntax_nodes/31965930-9f1c-4f0c-bf10-5188a9fe2647/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/777909b3-953b-4efe-b9fd-76c695339f89"
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
X-Request-Id: ee89effb-c837-47c8-96ee-da73637daa30
201 Created
```


```json
{
  "data": {
    "id": "809cc7c2-67dd-4a24-aca9-3cb3a33987c6",
    "type": "syntax",
    "attributes": {
      "account_id": "7d954a4e-0ebe-4649-b971-ff9b7d8d3458",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=809cc7c2-67dd-4a24-aca9-3cb3a33987c6",
          "self": "/syntaxes/809cc7c2-67dd-4a24-aca9-3cb3a33987c6/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/33f4d996-bce8-4820-8dc7-a4fd1a41294c",
          "self": "/syntax_nodes/33f4d996-bce8-4820-8dc7-a4fd1a41294c/relationships/components"
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
PATCH /syntaxes/e0611fab-7cc5-4afb-8460-e1f3caa2f111
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "e0611fab-7cc5-4afb-8460-e1f3caa2f111",
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
X-Request-Id: 2f6eae67-53d5-425c-b528-25bfa7b79087
200 OK
```


```json
{
  "data": {
    "id": "e0611fab-7cc5-4afb-8460-e1f3caa2f111",
    "type": "syntax",
    "attributes": {
      "account_id": "814ee2ca-b2cb-4f22-ac12-597b29f074b0",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=e0611fab-7cc5-4afb-8460-e1f3caa2f111",
          "self": "/syntaxes/e0611fab-7cc5-4afb-8460-e1f3caa2f111/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/a7ab038a-e60d-4ba9-933f-355407c31cdf",
          "self": "/syntax_nodes/a7ab038a-e60d-4ba9-933f-355407c31cdf/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/e0611fab-7cc5-4afb-8460-e1f3caa2f111"
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
DELETE /syntaxes/fc7f7074-be24-4868-ba0d-4375419706ee
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 49a11a58-ea61-48a8-88df-9e16696cc4e1
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
POST /syntaxes/75ad2e70-8d83-4582-9a45-6c58dbda295d/publish
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
X-Request-Id: 142af2a3-7d03-45bc-a61a-6f94205d02a4
200 OK
```


```json
{
  "data": {
    "id": "75ad2e70-8d83-4582-9a45-6c58dbda295d",
    "type": "syntax",
    "attributes": {
      "account_id": "0bae36e8-63da-4491-b73c-7675b5dab5c2",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 1e587771a8cf",
      "published": true,
      "published_at": "2020-04-05T09:38:16.715Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=75ad2e70-8d83-4582-9a45-6c58dbda295d",
          "self": "/syntaxes/75ad2e70-8d83-4582-9a45-6c58dbda295d/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/47ed68ef-5cfe-4d3c-8c30-815e767cde70",
          "self": "/syntax_nodes/47ed68ef-5cfe-4d3c-8c30-815e767cde70/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/75ad2e70-8d83-4582-9a45-6c58dbda295d/publish"
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
POST /syntaxes/3a7371d0-549a-4072-be1d-80cd639f1a5d/archive
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
X-Request-Id: a75de375-b03e-4436-9d48-3de5c597f4bb
200 OK
```


```json
{
  "data": {
    "id": "3a7371d0-549a-4072-be1d-80cd639f1a5d",
    "type": "syntax",
    "attributes": {
      "account_id": "acfe90bb-6ef5-4513-a01b-60aa8c4c20cd",
      "archived": true,
      "archived_at": "2020-04-05T09:38:17.400Z",
      "description": "Description",
      "name": "Syntax 28fcbbe02f48",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=3a7371d0-549a-4072-be1d-80cd639f1a5d",
          "self": "/syntaxes/3a7371d0-549a-4072-be1d-80cd639f1a5d/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/252aa3ec-d7b1-4714-b201-dbbc14bc3e8b",
          "self": "/syntax_nodes/252aa3ec-d7b1-4714-b201-dbbc14bc3e8b/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/3a7371d0-549a-4072-be1d-80cd639f1a5d/archive"
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
X-Request-Id: f4ac85fc-a4c0-433b-90b1-ce99bb208c07
200 OK
```


```json
{
  "data": [
    {
      "id": "f53c4dd4-8aa9-404c-b2fa-d4047c93166b",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 6584bef8aa5b",
        "hex_color": "#988a7a"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/1895f330-6d1c-4bb1-89ab-a77d828f7a62"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/4d545842-2158-4491-a577-e2eafe0b51c4",
            "self": "/syntax_elements/f53c4dd4-8aa9-404c-b2fa-d4047c93166b/relationships/classification_table"
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
GET /syntax_elements/4cd6e0cb-9b54-4927-8f67-4428522ccef9
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
X-Request-Id: 78564178-0047-485c-bafc-f4d83e9bfd56
200 OK
```


```json
{
  "data": {
    "id": "4cd6e0cb-9b54-4927-8f67-4428522ccef9",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element d8a85c6bed12",
      "hex_color": "#b6445c"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/688de2a0-99be-4c71-9b4b-7d6e4cf41c30"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/817d4bf2-2852-420e-abcd-b7e230e4e7cf",
          "self": "/syntax_elements/4cd6e0cb-9b54-4927-8f67-4428522ccef9/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/4cd6e0cb-9b54-4927-8f67-4428522ccef9"
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
POST /syntaxes/ba65833e-aade-4fa4-ae74-95d3e7f243f0/relationships/syntax_elements
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
          "id": "00e091e6-e539-4ddc-ae59-e06c57e4c9b7"
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
X-Request-Id: 5ffe328c-8023-401e-ac58-756011e555a8
201 Created
```


```json
{
  "data": {
    "id": "dcdc0fe4-ef87-4f2d-8b5f-49693f951429",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "hex_color": "#001122"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/ba65833e-aade-4fa4-ae74-95d3e7f243f0"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/00e091e6-e539-4ddc-ae59-e06c57e4c9b7",
          "self": "/syntax_elements/dcdc0fe4-ef87-4f2d-8b5f-49693f951429/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ba65833e-aade-4fa4-ae74-95d3e7f243f0/relationships/syntax_elements"
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
PATCH /syntax_elements/7642ec9f-8eb7-4aab-bd37-3cd626a4a3f1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "7642ec9f-8eb7-4aab-bd37-3cd626a4a3f1",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "21e51ec6-e0fb-49c6-8ca7-9b9065b7ef1b"
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
X-Request-Id: e432fb9a-addd-4175-9f38-019a102e23a9
200 OK
```


```json
{
  "data": {
    "id": "7642ec9f-8eb7-4aab-bd37-3cd626a4a3f1",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "hex_color": "#43c8c5"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/556bac52-e1f8-4d66-9a42-2bedd7893bab"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/21e51ec6-e0fb-49c6-8ca7-9b9065b7ef1b",
          "self": "/syntax_elements/7642ec9f-8eb7-4aab-bd37-3cd626a4a3f1/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/7642ec9f-8eb7-4aab-bd37-3cd626a4a3f1"
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
DELETE /syntax_elements/e1cec0fe-e787-4f42-bb64-e1c2df841009
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 494d67f6-0c35-4454-a23e-ad1f88560129
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
PATCH /syntax_elements/6a7ef571-998c-4691-8329-8753544300f7/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "8c98b56e-6951-4ae0-bc9b-58e99659f0a8",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8544b473-17c9-4055-8fcc-5327acc5b0d2
200 OK
```


```json
{
  "data": {
    "id": "6a7ef571-998c-4691-8329-8753544300f7",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 33d962d93e3e",
      "hex_color": "#f52a56"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/d92f6eba-cb35-4298-b939-be788e7346b6"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/8c98b56e-6951-4ae0-bc9b-58e99659f0a8",
          "self": "/syntax_elements/6a7ef571-998c-4691-8329-8753544300f7/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/6a7ef571-998c-4691-8329-8753544300f7/relationships/classification_table"
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
DELETE /syntax_elements/e991bc00-f67c-4239-8bef-22959eb12841/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3657750f-3f0a-488e-8ef5-dfc636ce9a4d
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
X-Request-Id: d2d6a2ac-971a-428d-8ca5-61e251c920c7
200 OK
```


```json
{
  "data": [
    {
      "id": "73c48a94-409f-4009-a9b9-a0fc987cf22c",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/cdd9f4fc-bad9-497a-849d-113332c7248f"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/73c48a94-409f-4009-a9b9-a0fc987cf22c/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/73c48a94-409f-4009-a9b9-a0fc987cf22c/relationships/parent",
            "related": "/syntax_nodes/73c48a94-409f-4009-a9b9-a0fc987cf22c"
          }
        }
      }
    },
    {
      "id": "814f07a8-89a2-476d-bf57-740945bda3cc",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/cdd9f4fc-bad9-497a-849d-113332c7248f"
          }
        },
        "components": {
          "data": [
            {
              "id": "580aa911-e362-49ce-96e7-6fc155291225",
              "type": "syntax_node"
            },
            {
              "id": "6567a2de-f785-47b2-8478-d15cb64619ac",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/814f07a8-89a2-476d-bf57-740945bda3cc/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/814f07a8-89a2-476d-bf57-740945bda3cc/relationships/parent",
            "related": "/syntax_nodes/814f07a8-89a2-476d-bf57-740945bda3cc"
          }
        }
      }
    },
    {
      "id": "6567a2de-f785-47b2-8478-d15cb64619ac",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/cdd9f4fc-bad9-497a-849d-113332c7248f"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/6567a2de-f785-47b2-8478-d15cb64619ac/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/6567a2de-f785-47b2-8478-d15cb64619ac/relationships/parent",
            "related": "/syntax_nodes/6567a2de-f785-47b2-8478-d15cb64619ac"
          }
        }
      }
    },
    {
      "id": "580aa911-e362-49ce-96e7-6fc155291225",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/cdd9f4fc-bad9-497a-849d-113332c7248f"
          }
        },
        "components": {
          "data": [
            {
              "id": "73c48a94-409f-4009-a9b9-a0fc987cf22c",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/580aa911-e362-49ce-96e7-6fc155291225/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/580aa911-e362-49ce-96e7-6fc155291225/relationships/parent",
            "related": "/syntax_nodes/580aa911-e362-49ce-96e7-6fc155291225"
          }
        }
      }
    },
    {
      "id": "92f6d876-39a3-4712-9c99-6c515b111eaf",
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
              "id": "814f07a8-89a2-476d-bf57-740945bda3cc",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/92f6d876-39a3-4712-9c99-6c515b111eaf/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/92f6d876-39a3-4712-9c99-6c515b111eaf/relationships/parent",
            "related": "/syntax_nodes/92f6d876-39a3-4712-9c99-6c515b111eaf"
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
GET /syntax_nodes/606d6f2c-2c5c-439b-8e23-a52e5e234831?depth=2
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
X-Request-Id: 1d8282d2-206d-4cf0-b616-7b8d62c6f325
200 OK
```


```json
{
  "data": {
    "id": "606d6f2c-2c5c-439b-8e23-a52e5e234831",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/2aa4da21-0d0e-4daa-a7c0-f09533902907"
        }
      },
      "components": {
        "data": [
          {
            "id": "52c72896-0878-43d0-ab80-536cc9b09b15",
            "type": "syntax_node"
          },
          {
            "id": "41bb5235-4a9b-49c7-82d4-cdb882de5a6c",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/606d6f2c-2c5c-439b-8e23-a52e5e234831/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/606d6f2c-2c5c-439b-8e23-a52e5e234831/relationships/parent",
          "related": "/syntax_nodes/606d6f2c-2c5c-439b-8e23-a52e5e234831"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/606d6f2c-2c5c-439b-8e23-a52e5e234831?depth=2"
  },
  "included": [
    {
      "id": "41bb5235-4a9b-49c7-82d4-cdb882de5a6c",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/2aa4da21-0d0e-4daa-a7c0-f09533902907"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/41bb5235-4a9b-49c7-82d4-cdb882de5a6c/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/41bb5235-4a9b-49c7-82d4-cdb882de5a6c/relationships/parent",
            "related": "/syntax_nodes/41bb5235-4a9b-49c7-82d4-cdb882de5a6c"
          }
        }
      }
    },
    {
      "id": "52c72896-0878-43d0-ab80-536cc9b09b15",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/2aa4da21-0d0e-4daa-a7c0-f09533902907"
          }
        },
        "components": {
          "data": [
            {
              "id": "15047ed7-f2eb-4c53-b7ac-21b56dafa28c",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/52c72896-0878-43d0-ab80-536cc9b09b15/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/52c72896-0878-43d0-ab80-536cc9b09b15/relationships/parent",
            "related": "/syntax_nodes/52c72896-0878-43d0-ab80-536cc9b09b15"
          }
        }
      }
    },
    {
      "id": "15047ed7-f2eb-4c53-b7ac-21b56dafa28c",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/2aa4da21-0d0e-4daa-a7c0-f09533902907"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/15047ed7-f2eb-4c53-b7ac-21b56dafa28c/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/15047ed7-f2eb-4c53-b7ac-21b56dafa28c/relationships/parent",
            "related": "/syntax_nodes/15047ed7-f2eb-4c53-b7ac-21b56dafa28c"
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
POST /syntax_nodes/c3dd0444-8e02-4b59-807a-42741df81fd7/relationships/components
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
          "id": "3e9cd6ce-af44-4602-ac86-57a21ffea28e"
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
X-Request-Id: 0edd3eac-f86d-4f75-99f2-aa57498cc0b2
201 Created
```


```json
{
  "data": {
    "id": "1cd3476d-f9b6-4ca3-9ba6-ec77dda73783",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/3e9cd6ce-af44-4602-ac86-57a21ffea28e"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/1cd3476d-f9b6-4ca3-9ba6-ec77dda73783/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/1cd3476d-f9b6-4ca3-9ba6-ec77dda73783/relationships/parent",
          "related": "/syntax_nodes/1cd3476d-f9b6-4ca3-9ba6-ec77dda73783"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/c3dd0444-8e02-4b59-807a-42741df81fd7/relationships/components"
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
PATCH /syntax_nodes/94115b2b-1e20-4b93-8725-b1b7f4912980/relationships/parent
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
    "id": "9b16979f-4875-4e4f-9a4c-7dbc20984073"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 75c01fc1-5c08-4759-b967-5e9a0711e4db
200 OK
```


```json
{
  "data": {
    "id": "94115b2b-1e20-4b93-8725-b1b7f4912980",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/dedee5b2-7170-44cc-b1a8-485305a1d2cc"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/94115b2b-1e20-4b93-8725-b1b7f4912980/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/94115b2b-1e20-4b93-8725-b1b7f4912980/relationships/parent",
          "related": "/syntax_nodes/94115b2b-1e20-4b93-8725-b1b7f4912980"
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
PATCH /syntax_nodes/deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc",
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
X-Request-Id: b38c8774-bb0c-48fa-8145-dcefd77d2b30
200 OK
```


```json
{
  "data": {
    "id": "deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/c7b6c3e8-52da-4ce9-9c84-961babf332fb"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc/relationships/parent",
          "related": "/syntax_nodes/deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/deb6ce56-3fcc-4e8a-bffb-cadae1bc24cc"
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
DELETE /syntax_nodes/cc73d03f-717d-4efb-8e73-9a3d81f82305
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a58080a2-e3c6-436c-9e35-79b0c9ab3444
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
X-Request-Id: bdf8da63-41ec-4384-90e1-825c98cec287
200 OK
```


```json
{
  "data": [
    {
      "id": "60fee5a4-c605-4ea9-a979-2b37509eb0bf",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-04-05T09:38:29.219Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=60fee5a4-c605-4ea9-a979-2b37509eb0bf",
            "self": "/progress_models/60fee5a4-c605-4ea9-a979-2b37509eb0bf/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "4ba34cc6-1f2e-40c5-84b9-457ee1fe8cdc",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=4ba34cc6-1f2e-40c5-84b9-457ee1fe8cdc",
            "self": "/progress_models/4ba34cc6-1f2e-40c5-84b9-457ee1fe8cdc/relationships/progress_steps"
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
GET /progress_models/8a357d11-2304-46b2-8a77-f54f250be4ef
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
X-Request-Id: 4bc2a778-8383-47df-b6e8-e9a0cf9e0c36
200 OK
```


```json
{
  "data": {
    "id": "8a357d11-2304-46b2-8a77-f54f250be4ef",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-04-05T09:38:29.944Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=8a357d11-2304-46b2-8a77-f54f250be4ef",
          "self": "/progress_models/8a357d11-2304-46b2-8a77-f54f250be4ef/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/8a357d11-2304-46b2-8a77-f54f250be4ef"
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
PATCH /progress_models/bf471777-886a-4db9-87dc-53dcb39b7bc9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "bf471777-886a-4db9-87dc-53dcb39b7bc9",
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
X-Request-Id: ca428eca-538c-4d04-a5c5-91c4ae616d82
200 OK
```


```json
{
  "data": {
    "id": "bf471777-886a-4db9-87dc-53dcb39b7bc9",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=bf471777-886a-4db9-87dc-53dcb39b7bc9",
          "self": "/progress_models/bf471777-886a-4db9-87dc-53dcb39b7bc9/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/bf471777-886a-4db9-87dc-53dcb39b7bc9"
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
DELETE /progress_models/5d727f02-ff4f-4ffe-94a3-f492b8a55131
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 90251191-68ca-4eea-ac89-6a8454001da0
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
POST /progress_models/7afd03de-8a6b-4846-9b8e-12bd8e09b680/publish
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
X-Request-Id: 7e812f37-2562-4db5-b551-662687053e30
200 OK
```


```json
{
  "data": {
    "id": "7afd03de-8a6b-4846-9b8e-12bd8e09b680",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-04-05T09:38:32.641Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=7afd03de-8a6b-4846-9b8e-12bd8e09b680",
          "self": "/progress_models/7afd03de-8a6b-4846-9b8e-12bd8e09b680/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/7afd03de-8a6b-4846-9b8e-12bd8e09b680/publish"
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
POST /progress_models/fc1819c3-64e4-4000-adb2-09675585c59f/archive
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
X-Request-Id: d852628c-8767-4a62-a733-1e77c4aa1690
200 OK
```


```json
{
  "data": {
    "id": "fc1819c3-64e4-4000-adb2-09675585c59f",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-05T09:38:33.212Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=fc1819c3-64e4-4000-adb2-09675585c59f",
          "self": "/progress_models/fc1819c3-64e4-4000-adb2-09675585c59f/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/fc1819c3-64e4-4000-adb2-09675585c59f/archive"
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
X-Request-Id: c86e5876-4159-447e-9ff8-40bca37e9d75
201 Created
```


```json
{
  "data": {
    "id": "c36b3415-fe3d-4e21-9dbb-b691697ca7ad",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=c36b3415-fe3d-4e21-9dbb-b691697ca7ad",
          "self": "/progress_models/c36b3415-fe3d-4e21-9dbb-b691697ca7ad/relationships/progress_steps"
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
X-Request-Id: 4360fd82-acf9-4a38-84e6-ae518680a702
200 OK
```


```json
{
  "data": [
    {
      "id": "2a08eaca-10b7-4336-b1e5-df26d88fb48b",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1,
        "hex_color": "#26eead"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/da399ff3-41eb-4f79-bbb6-34c53595e579"
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
GET /progress_steps/49496539-f629-449a-a5fe-d43f1e72b378
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
X-Request-Id: ea6dcd90-5d81-4a3a-8f7e-5e83a390f6aa
200 OK
```


```json
{
  "data": {
    "id": "49496539-f629-449a-a5fe-d43f1e72b378",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2,
      "hex_color": "#d05b8f"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/acb4c754-0b14-479d-8786-a454e5f85f5a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/49496539-f629-449a-a5fe-d43f1e72b378"
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
PATCH /progress_steps/5102faae-06e0-47eb-a075-e9d7b93409cc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "5102faae-06e0-47eb-a075-e9d7b93409cc",
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
X-Request-Id: 27cbef63-07ac-463a-946d-8f8ca8e0df14
200 OK
```


```json
{
  "data": {
    "id": "5102faae-06e0-47eb-a075-e9d7b93409cc",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3,
      "hex_color": "#444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/f955cd52-f04c-4472-b7b9-ab240c188e88"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/5102faae-06e0-47eb-a075-e9d7b93409cc"
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
DELETE /progress_steps/f65e8d66-6f56-4000-ab8f-81bf3d61dc9f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d1459701-5c83-499c-96fe-1ef869e19230
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
POST /progress_models/bf10c58a-0f07-4134-adfd-af8ffc21d9aa/relationships/progress_steps
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
X-Request-Id: febf40e3-2bb0-44e6-8d77-4b3d330ce790
201 Created
```


```json
{
  "data": {
    "id": "7fceb2d4-9ba2-4ff5-84eb-0c8c1dc9ae32",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/bf10c58a-0f07-4134-adfd-af8ffc21d9aa"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/bf10c58a-0f07-4134-adfd-af8ffc21d9aa/relationships/progress_steps"
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
X-Request-Id: c8ff5529-60b0-48e8-b120-0dd6f804ce61
200 OK
```


```json
{
  "data": [
    {
      "id": "10fadd17-2e12-4d35-bfd5-bfbdc07fa369",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/528ba122-0b83-4569-9e6d-1191d20c5ed9"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/d213c3da-00c7-4c8a-942f-8e7f3bc2f8d9"
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
GET /progress/2456cfe2-f600-4d4a-9fcc-437bc27410c1
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
X-Request-Id: 21f4c427-586f-451a-b9d8-abee777a897d
200 OK
```


```json
{
  "data": {
    "id": "2456cfe2-f600-4d4a-9fcc-437bc27410c1",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/f274025e-dcc1-4402-a7bd-09f19e5966b6"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/190b006e-7fe8-427d-925a-2ed2da092839"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/2456cfe2-f600-4d4a-9fcc-437bc27410c1"
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
DELETE /progress/3825ccb8-e89d-4010-8156-c89398747848
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e995a950-b7e1-402d-9ba2-cdd82df5dcdc
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
          "id": "c968124a-c016-4e25-bd26-7217b4b5ff49"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "269e516e-c8f4-46cc-83b8-231adfd79edf"
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
X-Request-Id: 3a949536-f406-4de6-b94c-eeedfdb224e9
201 Created
```


```json
{
  "data": {
    "id": "dfe3029e-aa70-45de-8e03-612471cb5507",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/c968124a-c016-4e25-bd26-7217b4b5ff49"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/269e516e-c8f4-46cc-83b8-231adfd79edf"
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
X-Request-Id: a85bfc91-af48-4721-a6b1-f61ed80eb0ad
200 OK
```


```json
{
  "data": [
    {
      "id": "074b8e2f-b6ab-4fd5-b6e5-75b292a5fe15",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "5c1c4e05-387c-4932-b823-22d417a8a428"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/5c1c4e05-387c-4932-b823-22d417a8a428"
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
GET /projects/2267c3f6-a717-40b4-9518-489da2ced47a/relationships/project_setting
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
X-Request-Id: f0a2d5fb-4759-4af6-8c16-15c99d604f2d
200 OK
```


```json
{
  "data": {
    "id": "3da08fb9-c2c9-4d50-b337-9805787a5667",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "2267c3f6-a717-40b4-9518-489da2ced47a"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/2267c3f6-a717-40b4-9518-489da2ced47a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/2267c3f6-a717-40b4-9518-489da2ced47a/relationships/project_setting"
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
PATCH /projects/a2d3eb26-0702-4da5-babc-73a765023ee2/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "a2d3eb26-0702-4da5-babc-73a765023ee2",
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
X-Request-Id: cc74918d-9f9f-471e-81bf-8e8dfe07c5c6
200 OK
```


```json
{
  "data": {
    "id": "fa02ba32-e8ed-403b-9bbb-f30f4ceec00d",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "a2d3eb26-0702-4da5-babc-73a765023ee2"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/a2d3eb26-0702-4da5-babc-73a765023ee2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a2d3eb26-0702-4da5-babc-73a765023ee2/relationships/project_setting"
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
X-Request-Id: 31c07085-be74-48b6-ab81-fb322fe2d313
200 OK
```


```json
{
  "data": [
    {
      "id": "a6eb220c-1e96-4309-b6e4-d9ececfd0aca",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/a6eb220c-1e96-4309-b6e4-d9ececfd0aca"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/a6eb220c-1e96-4309-b6e4-d9ececfd0aca"
          }
        }
      }
    },
    {
      "id": "3bc90e24-cb3d-4a57-a9b4-0419106e60f3",
      "type": "system_element",
      "attributes": {
        "name": "OOC 979b5cd1364c-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/3bc90e24-cb3d-4a57-a9b4-0419106e60f3"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/3bc90e24-cb3d-4a57-a9b4-0419106e60f3"
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
GET /system_elements/f95ab017-5e25-435c-9d3e-a8487b1ac182
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
X-Request-Id: 8ec2f722-15e8-48cf-86e1-15cc7e98a8ce
200 OK
```


```json
{
  "data": {
    "id": "f95ab017-5e25-435c-9d3e-a8487b1ac182",
    "type": "system_element",
    "attributes": {
      "name": "OOC 3618bf4078b9-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/f95ab017-5e25-435c-9d3e-a8487b1ac182"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/f95ab017-5e25-435c-9d3e-a8487b1ac182"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/f95ab017-5e25-435c-9d3e-a8487b1ac182"
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
POST /object_occurrences/fd9d827c-8169-4f0d-a979-5546e84f1d2b/relationships/system_elements
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
      "target_id": "e466e10c-c0dd-4a8b-bd5d-e79af4222d3c"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b38d5354-8e53-4073-b1b8-fd75cee2a5ee
201 Created
```


```json
{
  "data": {
    "id": "2c7848e6-78dc-4f11-81ef-6bb44014cb8a",
    "type": "system_element",
    "attributes": {
      "name": "OOC 626cfea40ccb-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/2c7848e6-78dc-4f11-81ef-6bb44014cb8a"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/2c7848e6-78dc-4f11-81ef-6bb44014cb8a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/fd9d827c-8169-4f0d-a979-5546e84f1d2b/relationships/system_elements"
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
DELETE /object_occurrences/43a8ff7e-83d9-49e4-8b88-a3f8b229d6ee/relationships/system_elements/eb32b4fe-0037-4620-a46c-6d2e2a556e1e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e0914cb8-52ad-40e4-8e65-642c2748647a
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


# Object Occurrence Relations

Object Occurrence Relations between Object Occurrences.


## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrence_relations/e1313a63-4a99-4b31-b0b9-b5711ba93b06/relationships/owners
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
X-Request-Id: 8d1c0b78-3691-4969-96ba-60e726a41986
201 Created
```


```json
{
  "data": {
    "id": "87bee107-24a8-43d1-b334-1a764e57bade",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/e1313a63-4a99-4b31-b0b9-b5711ba93b06/relationships/owners"
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
POST /object_occurrence_relations/cd2e86dc-263e-48ea-a823-bc5a7b67f79d/relationships/owners
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
X-Request-Id: c73dc60a-f303-4d5b-8e2c-30e59bd13feb
201 Created
```


```json
{
  "data": {
    "id": "6d6ea299-c475-4e0b-816b-a07f60219f2c",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/cd2e86dc-263e-48ea-a823-bc5a7b67f79d/relationships/owners"
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
POST /object_occurrence_relations/125561c9-ec69-4126-862d-3945d605c9ef/relationships/owners
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
    "id": "8aa6a615-0658-407f-8fd0-08d3fac5190e"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8fa157eb-2834-4fe7-915e-97b368a3e113
201 Created
```


```json
{
  "data": {
    "id": "8aa6a615-0658-407f-8fd0-08d3fac5190e",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 3",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/125561c9-ec69-4126-862d-3945d605c9ef/relationships/owners"
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
DELETE /object_occurrence_relations/af706dd9-25db-47b6-8591-c74c3496f82a/relationships/owners/1b26e4b4-56e1-44c0-b56a-54bffb216184
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5c1fa113-6487-4b8c-a73a-80e3fe4fb7fe
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
X-Request-Id: 24f540b8-189e-4232-ae40-75609e1be454
200 OK
```


```json
{
  "data": [
    {
      "id": "a5a2942f-a6bb-48e4-b143-d38bc6e18873",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 78c9d1fec8e1",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=a5a2942f-a6bb-48e4-b143-d38bc6e18873",
            "self": "/object_occurrence_relations/a5a2942f-a6bb-48e4-b143-d38bc6e18873/relationships/tags"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=a5a2942f-a6bb-48e4-b143-d38bc6e18873"
          }
        },
        "classification_entry": {
          "data": {
            "id": "7f0f092e-a1fa-4cfc-8c6b-abc513bd375d",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/7f0f092e-a1fa-4cfc-8c6b-abc513bd375d",
            "self": "/object_occurrence_relations/a5a2942f-a6bb-48e4-b143-d38bc6e18873/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "3a3a23f0-031e-4d08-a0cd-2a57d477eb7e",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/3a3a23f0-031e-4d08-a0cd-2a57d477eb7e",
            "self": "/object_occurrence_relations/a5a2942f-a6bb-48e4-b143-d38bc6e18873/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "376eeea3-c427-4098-a35f-18158011b197",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/376eeea3-c427-4098-a35f-18158011b197",
            "self": "/object_occurrence_relations/a5a2942f-a6bb-48e4-b143-d38bc6e18873/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "7f0f092e-a1fa-4cfc-8c6b-abc513bd375d",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 844369ce5986",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=7f0f092e-a1fa-4cfc-8c6b-abc513bd375d",
            "self": "/classification_entries/7f0f092e-a1fa-4cfc-8c6b-abc513bd375d/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=7f0f092e-a1fa-4cfc-8c6b-abc513bd375d",
            "self": "/classification_entries/7f0f092e-a1fa-4cfc-8c6b-abc513bd375d/relationships/classification_entries",
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
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=2f36cb80-d50c-4ef6-8042-bad07732b000&amp;filter[object_occurrence_source_ids_cont][]=8199de95-6419-436e-b382-b47326dfe47b&amp;filter[object_occurrence_target_ids_cont][]=57a253e2-b183-41d7-b9e6-10cbf6f98f47
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;2f36cb80-d50c-4ef6-8042-bad07732b000&quot;, &quot;8199de95-6419-436e-b382-b47326dfe47b&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;57a253e2-b183-41d7-b9e6-10cbf6f98f47&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 22bb1a80-e3fd-4587-8198-159acc6a6164
200 OK
```


```json
{
  "data": [
    {
      "id": "b447777b-2a50-4f6e-8ec6-b5c5e960294a",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR b6fe4369bacb",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=b447777b-2a50-4f6e-8ec6-b5c5e960294a",
            "self": "/object_occurrence_relations/b447777b-2a50-4f6e-8ec6-b5c5e960294a/relationships/tags"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=b447777b-2a50-4f6e-8ec6-b5c5e960294a"
          }
        },
        "classification_entry": {
          "data": {
            "id": "a85dfdc1-b1f6-440d-baba-c209cba68d9e",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/a85dfdc1-b1f6-440d-baba-c209cba68d9e",
            "self": "/object_occurrence_relations/b447777b-2a50-4f6e-8ec6-b5c5e960294a/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "57a253e2-b183-41d7-b9e6-10cbf6f98f47",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/57a253e2-b183-41d7-b9e6-10cbf6f98f47",
            "self": "/object_occurrence_relations/b447777b-2a50-4f6e-8ec6-b5c5e960294a/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "2f36cb80-d50c-4ef6-8042-bad07732b000",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/2f36cb80-d50c-4ef6-8042-bad07732b000",
            "self": "/object_occurrence_relations/b447777b-2a50-4f6e-8ec6-b5c5e960294a/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "a85dfdc1-b1f6-440d-baba-c209cba68d9e",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 70c31e146c94",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=a85dfdc1-b1f6-440d-baba-c209cba68d9e",
            "self": "/classification_entries/a85dfdc1-b1f6-440d-baba-c209cba68d9e/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=a85dfdc1-b1f6-440d-baba-c209cba68d9e",
            "self": "/classification_entries/a85dfdc1-b1f6-440d-baba-c209cba68d9e/relationships/classification_entries",
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
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=2f36cb80-d50c-4ef6-8042-bad07732b000&filter[object_occurrence_source_ids_cont][]=8199de95-6419-436e-b382-b47326dfe47b&filter[object_occurrence_target_ids_cont][]=57a253e2-b183-41d7-b9e6-10cbf6f98f47",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=2f36cb80-d50c-4ef6-8042-bad07732b000&filter[object_occurrence_source_ids_cont][]=8199de95-6419-436e-b382-b47326dfe47b&filter[object_occurrence_target_ids_cont][]=57a253e2-b183-41d7-b9e6-10cbf6f98f47&include=tags,owners,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/883f1985-7335-43a1-9954-df3649484141
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
X-Request-Id: 4abb656f-69c1-489e-bf72-dcbcbc837c18
200 OK
```


```json
{
  "data": {
    "id": "883f1985-7335-43a1-9954-df3649484141",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "OOR b3e48ece7b4b",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=883f1985-7335-43a1-9954-df3649484141",
          "self": "/object_occurrence_relations/883f1985-7335-43a1-9954-df3649484141/relationships/tags"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=883f1985-7335-43a1-9954-df3649484141"
        }
      },
      "classification_entry": {
        "data": {
          "id": "3193052b-62ef-48c6-8cd1-eb4930cbb920",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/3193052b-62ef-48c6-8cd1-eb4930cbb920",
          "self": "/object_occurrence_relations/883f1985-7335-43a1-9954-df3649484141/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "806c8105-6978-4931-9db2-f7b4ea41d0d0",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/806c8105-6978-4931-9db2-f7b4ea41d0d0",
          "self": "/object_occurrence_relations/883f1985-7335-43a1-9954-df3649484141/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "704d981a-3661-49b7-9752-3f01a686946b",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/704d981a-3661-49b7-9752-3f01a686946b",
          "self": "/object_occurrence_relations/883f1985-7335-43a1-9954-df3649484141/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/883f1985-7335-43a1-9954-df3649484141"
  },
  "included": [

  ]
}
```



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
X-Request-Id: 09fa1512-e9cf-4dd5-994a-41d1169c5654
200 OK
```


```json
{
  "data": {
    "id": "b20ff7b0-389f-45ae-bdcd-6641b67d3f14",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "d81104e3-bc8a-4718-871b-6a9d3e7997ea"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/d81104e3-bc8a-4718-871b-6a9d3e7997ea"
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
X-Request-Id: f3a3d8f3-6c09-46e5-b478-ee8915a84aa4
200 OK
```


```json
{
  "data": {
    "id": "0c48087f-d78f-4302-8d69-1cca067cd240",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "9a0b9afc-e96d-4e88-bae9-6750a9cdff68"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/9a0b9afc-e96d-4e88-bae9-6750a9cdff68"
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


# Chain analysis

Chain analysis returns the Object Occurrences that's related to the source Object Occurrence
through Object Occurrence Relations n steps out.

A SIMO grid could look like this:

<pre>
| OOC1 |      |      |       |
|      | OOC2 | oor1 |       |
| oor3 |      | OOC3 | oor2  |
|      |      |      | OOC4  |
</pre>


## Result


### Request

#### Endpoint

```plaintext
GET /chain_analysis/10c3a8a1-84b5-4848-9024-435e6f8786f5?steps=2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /chain_analysis/:id`

#### Parameters


```json
steps: 2
```


| Name | Description |
|:-----|:------------|
| steps  | Steps to look out into the chain |
| filter[classification_code]  | Only with Object Occurrence Relations classified by this classification code |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 39338a42-e823-49c7-ae62-4a63823e29ae
200 OK
```


```json
{
  "data": [
    {
      "id": "261a46f2-ae40-4006-8654-3f3346ae6918",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC3",
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
            "related": "/tags?filter[target_id_eq]=261a46f2-ae40-4006-8654-3f3346ae6918",
            "self": "/object_occurrences/261a46f2-ae40-4006-8654-3f3346ae6918/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=261a46f2-ae40-4006-8654-3f3346ae6918&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/261a46f2-ae40-4006-8654-3f3346ae6918/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/4adaef5a-7440-487b-8075-cc94cb28eaf7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/38ddcd83-4278-4ef1-bba0-a072163a3e63",
            "self": "/object_occurrences/261a46f2-ae40-4006-8654-3f3346ae6918/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/261a46f2-ae40-4006-8654-3f3346ae6918/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=261a46f2-ae40-4006-8654-3f3346ae6918"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=261a46f2-ae40-4006-8654-3f3346ae6918"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=261a46f2-ae40-4006-8654-3f3346ae6918"
          }
        }
      }
    },
    {
      "id": "825722de-5c63-460c-8541-f9369d55f87c",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC1",
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
            "related": "/tags?filter[target_id_eq]=825722de-5c63-460c-8541-f9369d55f87c",
            "self": "/object_occurrences/825722de-5c63-460c-8541-f9369d55f87c/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=825722de-5c63-460c-8541-f9369d55f87c&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/825722de-5c63-460c-8541-f9369d55f87c/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/4adaef5a-7440-487b-8075-cc94cb28eaf7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/38ddcd83-4278-4ef1-bba0-a072163a3e63",
            "self": "/object_occurrences/825722de-5c63-460c-8541-f9369d55f87c/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/825722de-5c63-460c-8541-f9369d55f87c/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=825722de-5c63-460c-8541-f9369d55f87c"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=825722de-5c63-460c-8541-f9369d55f87c"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=825722de-5c63-460c-8541-f9369d55f87c"
          }
        }
      }
    },
    {
      "id": "b1051a84-5ec9-4f57-a1ec-85a83f8b5660",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC4",
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
            "related": "/tags?filter[target_id_eq]=b1051a84-5ec9-4f57-a1ec-85a83f8b5660",
            "self": "/object_occurrences/b1051a84-5ec9-4f57-a1ec-85a83f8b5660/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=b1051a84-5ec9-4f57-a1ec-85a83f8b5660&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/b1051a84-5ec9-4f57-a1ec-85a83f8b5660/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/4adaef5a-7440-487b-8075-cc94cb28eaf7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/38ddcd83-4278-4ef1-bba0-a072163a3e63",
            "self": "/object_occurrences/b1051a84-5ec9-4f57-a1ec-85a83f8b5660/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/b1051a84-5ec9-4f57-a1ec-85a83f8b5660/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b1051a84-5ec9-4f57-a1ec-85a83f8b5660"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b1051a84-5ec9-4f57-a1ec-85a83f8b5660"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b1051a84-5ec9-4f57-a1ec-85a83f8b5660"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/chain_analysis/10c3a8a1-84b5-4848-9024-435e6f8786f5?steps=2",
    "current": "http://example.org/chain_analysis/10c3a8a1-84b5-4848-9024-435e6f8786f5?page[number]=1&steps=2"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[steps] | n steps to look out |
| data[id] | Object Occurrence resource ID |
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
X-Request-Id: 71628dd6-ffc8-444a-bfd1-abec3149d5ea
200 OK
```


```json
{
  "data": [
    {
      "id": "57be0ffa-cbcd-4036-84c5-8958116232fd",
      "type": "tag",
      "attributes": {
        "value": "tag value 7"
      },
      "relationships": {
      }
    },
    {
      "id": "7ed03be3-c202-4182-82fd-78b7cdf76176",
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
X-Request-Id: d1d8d72f-706e-439b-a2a5-cf7c0dd23595
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
GET /utils/path/from/object_occurrence/8d24bd56-545b-4d66-8cba-c2b841ecc5fc/to/object_occurrence/dac3b9ea-e370-49dc-97d8-fafcd1275308
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
X-Request-Id: 43b35476-18a2-4509-8950-b70ca6be0739
200 OK
```


```json
[
  {
    "id": "8d24bd56-545b-4d66-8cba-c2b841ecc5fc",
    "type": "object_occurrence"
  },
  {
    "id": "74de1baf-177b-43a5-8b38-e1d4f81c8142",
    "type": "object_occurrence"
  },
  {
    "id": "ad500ad9-8385-4427-8c85-dfac242f5b90",
    "type": "object_occurrence"
  },
  {
    "id": "a88137c7-1a71-455a-b5ee-d896eadb3ecc",
    "type": "object_occurrence"
  },
  {
    "id": "0b4c8790-ee2b-4e73-81a5-763e970be997",
    "type": "object_occurrence"
  },
  {
    "id": "d1c629d2-bb7b-4acb-87e6-ee3094ef9224",
    "type": "object_occurrence"
  },
  {
    "id": "dac3b9ea-e370-49dc-97d8-fafcd1275308",
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
X-Request-Id: d947b7f2-a904-41b6-b329-b560697d567f
200 OK
```


```json
{
  "data": [
    {
      "id": "b56e039b-3ff8-4ecb-85b1-708a0aaf9e39",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/01792e74-b69e-4f41-80b7-a2553c9cbdab"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/4457bc69-15b8-485b-a10e-8ea0001305cf"
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
X-Request-Id: 4350346d-6135-436d-a782-4fd81c3396dd
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



