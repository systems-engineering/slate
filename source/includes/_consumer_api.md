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
X-Request-Id: 408125f0-4c9a-4948-a410-7f3069ea4e79
200 OK
```


```json
{
  "data": {
    "id": "c7147d13-e0c3-4aa2-9907-1fc91711b237",
    "type": "account",
    "attributes": {
      "name": "Account cb9d44d08edc"
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
X-Request-Id: cae18575-1c4f-431d-853e-8684ff132b00
200 OK
```


```json
{
  "data": {
    "id": "2869a622-3a6a-4029-978e-15dd2f266ebc",
    "type": "account",
    "attributes": {
      "name": "Account 5e1136a9a23f"
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
    "id": "42074338-ce9b-417a-bacf-c68fee915d1c",
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
X-Request-Id: 802943c0-ba8f-47be-9f0b-45fec20eb8be
200 OK
```


```json
{
  "data": {
    "id": "42074338-ce9b-417a-bacf-c68fee915d1c",
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
X-Request-Id: d475d952-6349-40c7-a298-a12021a7da79
200 OK
```


```json
{
  "data": [
    {
      "id": "4dca292d-4b17-4cc2-9a43-8b00a613addf",
      "type": "project",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": "Project description",
        "name": "project 1"
      },
      "relationships": {
        "progress_step_checked": {
          "data": [
            {
              "id": "bc7c9b63-56e5-4ea0-b109-e58a1147eb6e",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=4dca292d-4b17-4cc2-9a43-8b00a613addf"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=4dca292d-4b17-4cc2-9a43-8b00a613addf",
            "self": "/projects/4dca292d-4b17-4cc2-9a43-8b00a613addf/relationships/contexts"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "bc7c9b63-56e5-4ea0-b109-e58a1147eb6e",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "4b0011e9-cea4-4d06-9c89-89da13677df2",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/4b0011e9-cea4-4d06-9c89-89da13677df2"
          }
        },
        "target": {
          "links": {
            "related": "/projects/4dca292d-4b17-4cc2-9a43-8b00a613addf"
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
    "current": "http://example.org/projects?include=progress_step_checked&page[number]=1&sort=name"
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
GET /projects/eca7caf3-1995-4195-83e9-77bcf23dfa31
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
X-Request-Id: 4a786c53-86a7-4374-b4a1-2a5d4f7bfaff
200 OK
```


```json
{
  "data": {
    "id": "eca7caf3-1995-4195-83e9-77bcf23dfa31",
    "type": "project",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "56e8a17a-b3f3-4d60-9825-daa5b00e8062",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=eca7caf3-1995-4195-83e9-77bcf23dfa31"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=eca7caf3-1995-4195-83e9-77bcf23dfa31",
          "self": "/projects/eca7caf3-1995-4195-83e9-77bcf23dfa31/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/eca7caf3-1995-4195-83e9-77bcf23dfa31"
  },
  "included": [
    {
      "id": "56e8a17a-b3f3-4d60-9825-daa5b00e8062",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "abd7bb81-3f68-4038-9d33-195aee88b178",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/abd7bb81-3f68-4038-9d33-195aee88b178"
          }
        },
        "target": {
          "links": {
            "related": "/projects/eca7caf3-1995-4195-83e9-77bcf23dfa31"
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
| data[attributes][name] | Project name |


## Update


### Request

#### Endpoint

```plaintext
PATCH /projects/fba7db6a-51c7-49ae-bad6-e8adb741568f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "fba7db6a-51c7-49ae-bad6-e8adb741568f",
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
X-Request-Id: 4c00d759-3e43-43b0-b35b-3431fe9eba35
200 OK
```


```json
{
  "data": {
    "id": "fba7db6a-51c7-49ae-bad6-e8adb741568f",
    "type": "project",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": "Project description",
      "name": "New project name"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "527c1a36-7d62-4978-86ab-942c355d5ab9",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=fba7db6a-51c7-49ae-bad6-e8adb741568f"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=fba7db6a-51c7-49ae-bad6-e8adb741568f",
          "self": "/projects/fba7db6a-51c7-49ae-bad6-e8adb741568f/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/fba7db6a-51c7-49ae-bad6-e8adb741568f"
  },
  "included": [
    {
      "id": "527c1a36-7d62-4978-86ab-942c355d5ab9",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "ed081cbe-056b-41cc-aa34-daefa9ff75ce",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/ed081cbe-056b-41cc-aa34-daefa9ff75ce"
          }
        },
        "target": {
          "links": {
            "related": "/projects/fba7db6a-51c7-49ae-bad6-e8adb741568f"
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
| data[attributes][name] | Project name |


## Archive


### Request

#### Endpoint

```plaintext
POST /projects/ce4d10bb-2de7-4007-b87c-f1cb02d86237/archive
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
X-Request-Id: b6a90ad3-8d6c-47c5-a5a5-78eee2b569b0
200 OK
```


```json
{
  "data": {
    "id": "ce4d10bb-2de7-4007-b87c-f1cb02d86237",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-21T11:56:02.175Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "7e457677-42e6-4933-b6bc-8d57da44eaf8",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=ce4d10bb-2de7-4007-b87c-f1cb02d86237"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=ce4d10bb-2de7-4007-b87c-f1cb02d86237",
          "self": "/projects/ce4d10bb-2de7-4007-b87c-f1cb02d86237/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/ce4d10bb-2de7-4007-b87c-f1cb02d86237/archive"
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
DELETE /projects/0a34801c-505e-4c6c-8228-3a8789f29e05
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 688ab3cb-f820-40f8-acae-7c9701a3e10d
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
X-Request-Id: 796bd5b0-a24b-450b-9ef5-a15ea43d6de5
200 OK
```


```json
{
  "data": [
    {
      "id": "a8fe5084-125f-400c-a8d8-b31efc4a2320",
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
        "progress_step_checked": {
          "data": [
            {
              "id": "219e9ded-a723-4ce1-9395-e21b38395263",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=a8fe5084-125f-400c-a8d8-b31efc4a2320"
          }
        },
        "project": {
          "links": {
            "related": "/projects/a22691b2-1f40-414d-b481-2ab159aaf920"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/b46d8401-3fe1-4bca-aa6b-021d09be67cd"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/0638934e-a07a-4d87-a299-638a8a2092cd"
          }
        }
      }
    },
    {
      "id": "f1a232be-11c7-4866-9bc0-04e8141076e2",
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
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=f1a232be-11c7-4866-9bc0-04e8141076e2"
          }
        },
        "project": {
          "links": {
            "related": "/projects/a22691b2-1f40-414d-b481-2ab159aaf920"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/338bb90e-9703-490b-bb06-9613ba0521ce"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/0638934e-a07a-4d87-a299-638a8a2092cd"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "219e9ded-a723-4ce1-9395-e21b38395263",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "9b0bf3e2-166d-47b7-a4c1-f87f659c32a9",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/9b0bf3e2-166d-47b7-a4c1-f87f659c32a9"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/a8fe5084-125f-400c-a8d8-b31efc4a2320"
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
    "current": "http://example.org/contexts?include=progress_step_checked&page[number]=1&sort=name"
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
GET /contexts/4948d819-bc7f-40b8-9c82-62f4646e5ecb
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
X-Request-Id: 436e9bbf-3679-4de6-8323-e6a03a6d19fc
200 OK
```


```json
{
  "data": {
    "id": "4948d819-bc7f-40b8-9c82-62f4646e5ecb",
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
      "progress_step_checked": {
        "data": [
          {
            "id": "bdc7d804-a09a-4d66-ab29-f6d064d61a89",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=4948d819-bc7f-40b8-9c82-62f4646e5ecb"
        }
      },
      "project": {
        "links": {
          "related": "/projects/7b1778f1-27bb-4dc5-88d6-8b20115f4367"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/e6332ee8-fec5-4180-85f0-c4efeb64f41f"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/f1f9b42e-d765-4b0f-bd15-e07f8662b00b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/4948d819-bc7f-40b8-9c82-62f4646e5ecb"
  },
  "included": [
    {
      "id": "bdc7d804-a09a-4d66-ab29-f6d064d61a89",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "5c03d6e6-4203-4c02-a44a-31f2d2fe5eaf",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/5c03d6e6-4203-4c02-a44a-31f2d2fe5eaf"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/4948d819-bc7f-40b8-9c82-62f4646e5ecb"
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
PATCH /contexts/f8846ecc-7472-4fc1-ab29-bbfee36c2519
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "f8846ecc-7472-4fc1-ab29-bbfee36c2519",
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
X-Request-Id: 642f5ca6-17cf-42b4-bd47-0c286bf300d9
200 OK
```


```json
{
  "data": {
    "id": "f8846ecc-7472-4fc1-ab29-bbfee36c2519",
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
      "progress_step_checked": {
        "data": [
          {
            "id": "08a5850f-885b-40fa-9f69-e52a245d4c2d",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=f8846ecc-7472-4fc1-ab29-bbfee36c2519"
        }
      },
      "project": {
        "links": {
          "related": "/projects/b726ff64-6c0f-47b8-b147-4c21689ed7a7"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/625a13c1-3610-4d08-9db6-0ebd16e22851"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/d7c9c393-0225-4feb-bfc6-7cb66335d738"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/f8846ecc-7472-4fc1-ab29-bbfee36c2519"
  },
  "included": [
    {
      "id": "08a5850f-885b-40fa-9f69-e52a245d4c2d",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "49bc78c4-b141-4770-89b1-ca393edd2ef8",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/49bc78c4-b141-4770-89b1-ca393edd2ef8"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/f8846ecc-7472-4fc1-ab29-bbfee36c2519"
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
POST /projects/446dd8e8-b665-409b-b88e-bee8dc17dddf/relationships/contexts
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
          "id": "7dccde4d-4ce2-496b-9159-02a6ca819bf1"
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
X-Request-Id: 50d6fd41-122b-47b0-85e8-dc292b61075e
201 Created
```


```json
{
  "data": {
    "id": "7c440687-ffd1-43ad-9682-9ca0e26cd028",
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
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=7c440687-ffd1-43ad-9682-9ca0e26cd028"
        }
      },
      "project": {
        "links": {
          "related": "/projects/446dd8e8-b665-409b-b88e-bee8dc17dddf"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/6be911ef-7122-40a0-9641-8e44f278e1c5"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/7dccde4d-4ce2-496b-9159-02a6ca819bf1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/446dd8e8-b665-409b-b88e-bee8dc17dddf/relationships/contexts"
  },
  "included": [

  ]
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
POST /contexts/23b5e99f-2b66-408a-8754-3acc237116d8/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/a2ccb798bf6724b6bb53dbaf
Content-Type: text/html; charset=utf-8
X-Request-Id: e87fd230-2048-4e87-ad55-b8d5c904f791
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/a2ccb798bf6724b6bb53dbaf">redirected</a>.</body></html>
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
DELETE /contexts/c5f35ed2-3c1c-4b05-8dd4-1166e3119171
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a9235fe4-6406-4065-9de7-071b88491e01
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
POST /object_occurrences/374ad393-9b33-4c14-bf39-25ceb9d16437/relationships/tags
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
X-Request-Id: 07fdd0b1-759d-46b3-a162-1aeb7e993671
201 Created
```


```json
{
  "data": {
    "id": "af78b0fb-61d3-45c0-a972-7677db53edd6",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/374ad393-9b33-4c14-bf39-25ceb9d16437/relationships/tags"
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
POST /object_occurrences/f625f806-ff4e-4b43-b65b-7cb34dc58a81/relationships/tags
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
    "id": "4c842d84-0e38-4d07-86dc-1584d447738a"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0610d79a-4823-4da7-9532-02783a0514c8
201 Created
```


```json
{
  "data": {
    "id": "4c842d84-0e38-4d07-86dc-1584d447738a",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f625f806-ff4e-4b43-b65b-7cb34dc58a81/relationships/tags"
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
DELETE /object_occurrences/4a85d213-1c54-45d7-a163-94b8749143ef/relationships/tags/2d7aeeb5-ab6c-438a-a23d-731f95c5f5be
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cbf67d0e-277b-4419-aed3-1c9ec82e27d9
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/a2069162-216e-4545-81fa-9df6bf74ab4d/relationships/owners
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
X-Request-Id: 1ca8dcbf-c0d0-4e33-807e-7f98c27c51c4
201 Created
```


```json
{
  "data": {
    "id": "bf6976c9-45fe-46f7-ba86-bd008dc4cb3c",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a2069162-216e-4545-81fa-9df6bf74ab4d/relationships/owners"
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
POST /object_occurrences/a1657b12-68ff-4c71-810f-47738d2a0d8b/relationships/owners
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
X-Request-Id: 7d62ff2c-f93a-4a36-ad9d-ed0f2a29b898
201 Created
```


```json
{
  "data": {
    "id": "4f74193a-29d4-4876-8791-ca775cfc3b47",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a1657b12-68ff-4c71-810f-47738d2a0d8b/relationships/owners"
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
POST /object_occurrences/2aad3fd3-d485-4c71-9fbf-971cf362c385/relationships/owners
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
    "id": "b3170563-2924-48e3-a260-eed3ac7b10e9"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c2cdcfc2-81ea-4bf0-91f4-677922d48d6e
201 Created
```


```json
{
  "data": {
    "id": "b3170563-2924-48e3-a260-eed3ac7b10e9",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 7",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/2aad3fd3-d485-4c71-9fbf-971cf362c385/relationships/owners"
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
DELETE /object_occurrences/7c74e024-e2a5-4914-91e3-6cc00c01e3e2/relationships/owners/720af732-7c53-4741-a1f0-1c986c24062c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f5c30900-7245-4085-8c06-1f2ffcdfa1e7
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
X-Request-Id: af81531f-3df5-4569-b2c7-05de8e7f1eda
200 OK
```


```json
{
  "data": [
    {
      "id": "e7d9f180-710a-4312-8724-c0b8a8882fc8",
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
            "related": "/tags?filter[target_id_eq]=e7d9f180-710a-4312-8724-c0b8a8882fc8",
            "self": "/object_occurrences/e7d9f180-710a-4312-8724-c0b8a8882fc8/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e7d9f180-710a-4312-8724-c0b8a8882fc8&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e7d9f180-710a-4312-8724-c0b8a8882fc8/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=e7d9f180-710a-4312-8724-c0b8a8882fc8"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/f17acfde-1fed-421d-86f0-c7541332d1cc"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be",
            "self": "/object_occurrences/e7d9f180-710a-4312-8724-c0b8a8882fc8/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/e7d9f180-710a-4312-8724-c0b8a8882fc8/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e7d9f180-710a-4312-8724-c0b8a8882fc8"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e7d9f180-710a-4312-8724-c0b8a8882fc8"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e7d9f180-710a-4312-8724-c0b8a8882fc8"
          }
        }
      }
    },
    {
      "id": "8a4b9bec-09f0-4b89-884a-9da1dc939f07",
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
            "related": "/tags?filter[target_id_eq]=8a4b9bec-09f0-4b89-884a-9da1dc939f07",
            "self": "/object_occurrences/8a4b9bec-09f0-4b89-884a-9da1dc939f07/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=8a4b9bec-09f0-4b89-884a-9da1dc939f07&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/8a4b9bec-09f0-4b89-884a-9da1dc939f07/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=8a4b9bec-09f0-4b89-884a-9da1dc939f07"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e500d345-bf68-4e2c-a7db-d74b19f24d6a"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/e5d9bcc5-7e1c-4972-87fb-6cd417124756",
            "self": "/object_occurrences/8a4b9bec-09f0-4b89-884a-9da1dc939f07/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/8a4b9bec-09f0-4b89-884a-9da1dc939f07/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=8a4b9bec-09f0-4b89-884a-9da1dc939f07"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=8a4b9bec-09f0-4b89-884a-9da1dc939f07"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=8a4b9bec-09f0-4b89-884a-9da1dc939f07"
          }
        }
      }
    },
    {
      "id": "7cbdf1c2-1159-4b8f-85d3-6c132d831175",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "XYZ",
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
            "related": "/tags?filter[target_id_eq]=7cbdf1c2-1159-4b8f-85d3-6c132d831175",
            "self": "/object_occurrences/7cbdf1c2-1159-4b8f-85d3-6c132d831175/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=7cbdf1c2-1159-4b8f-85d3-6c132d831175&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/7cbdf1c2-1159-4b8f-85d3-6c132d831175/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=7cbdf1c2-1159-4b8f-85d3-6c132d831175"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/f17acfde-1fed-421d-86f0-c7541332d1cc"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be",
            "self": "/object_occurrences/7cbdf1c2-1159-4b8f-85d3-6c132d831175/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/7cbdf1c2-1159-4b8f-85d3-6c132d831175/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7cbdf1c2-1159-4b8f-85d3-6c132d831175"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7cbdf1c2-1159-4b8f-85d3-6c132d831175"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=7cbdf1c2-1159-4b8f-85d3-6c132d831175"
          }
        }
      }
    },
    {
      "id": "e5d9bcc5-7e1c-4972-87fb-6cd417124756",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 7f49102edf5b",
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
            "related": "/tags?filter[target_id_eq]=e5d9bcc5-7e1c-4972-87fb-6cd417124756",
            "self": "/object_occurrences/e5d9bcc5-7e1c-4972-87fb-6cd417124756/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e5d9bcc5-7e1c-4972-87fb-6cd417124756&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e5d9bcc5-7e1c-4972-87fb-6cd417124756/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=e5d9bcc5-7e1c-4972-87fb-6cd417124756"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e500d345-bf68-4e2c-a7db-d74b19f24d6a"
          }
        },
        "components": {
          "data": [
            {
              "id": "8a4b9bec-09f0-4b89-884a-9da1dc939f07",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/e5d9bcc5-7e1c-4972-87fb-6cd417124756/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e5d9bcc5-7e1c-4972-87fb-6cd417124756"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e5d9bcc5-7e1c-4972-87fb-6cd417124756"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e5d9bcc5-7e1c-4972-87fb-6cd417124756"
          }
        }
      }
    },
    {
      "id": "e512a98f-8bd6-4e89-bd3b-337a96bd2996",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 478e0a479787",
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
            "related": "/tags?filter[target_id_eq]=e512a98f-8bd6-4e89-bd3b-337a96bd2996",
            "self": "/object_occurrences/e512a98f-8bd6-4e89-bd3b-337a96bd2996/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e512a98f-8bd6-4e89-bd3b-337a96bd2996&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e512a98f-8bd6-4e89-bd3b-337a96bd2996/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=e512a98f-8bd6-4e89-bd3b-337a96bd2996"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/f17acfde-1fed-421d-86f0-c7541332d1cc"
          }
        },
        "components": {
          "data": [
            {
              "id": "f6091dc9-3200-47d2-851e-0fcf042eb5be",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/e512a98f-8bd6-4e89-bd3b-337a96bd2996/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e512a98f-8bd6-4e89-bd3b-337a96bd2996"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e512a98f-8bd6-4e89-bd3b-337a96bd2996"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e512a98f-8bd6-4e89-bd3b-337a96bd2996"
          }
        }
      }
    },
    {
      "id": "f6091dc9-3200-47d2-851e-0fcf042eb5be",
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
            {
              "id": "934a67fd-4965-41b8-99f9-0c0f8dedf075",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=f6091dc9-3200-47d2-851e-0fcf042eb5be",
            "self": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "30b07178-6127-4522-be4f-b4ed692a704b",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=f6091dc9-3200-47d2-851e-0fcf042eb5be&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "934a67fd-4965-41b8-99f9-0c0f8dedf075",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=f6091dc9-3200-47d2-851e-0fcf042eb5be"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/f17acfde-1fed-421d-86f0-c7541332d1cc"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/e512a98f-8bd6-4e89-bd3b-337a96bd2996",
            "self": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "e7d9f180-710a-4312-8724-c0b8a8882fc8",
              "type": "object_occurrence"
            },
            {
              "id": "7cbdf1c2-1159-4b8f-85d3-6c132d831175",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=f6091dc9-3200-47d2-851e-0fcf042eb5be"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=f6091dc9-3200-47d2-851e-0fcf042eb5be"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=f6091dc9-3200-47d2-851e-0fcf042eb5be"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "30b07178-6127-4522-be4f-b4ed692a704b",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 10",
        "title": null
      }
    },
    {
      "id": "018b1be8-9674-4782-8f9d-dc07392e0796",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "59cc8d6a-817c-4292-a54b-9d6ca269bb98",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/59cc8d6a-817c-4292-a54b-9d6ca269bb98"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/f6091dc9-3200-47d2-851e-0fcf042eb5be"
          }
        }
      }
    },
    {
      "id": "934a67fd-4965-41b8-99f9-0c0f8dedf075",
      "type": "tag",
      "attributes": {
        "value": "tag value 10"
      },
      "relationships": {
      }
    }
  ],
  "meta": {
    "total_count": 6
  },
  "links": {
    "self": "http://example.org/object_occurrences",
    "current": "http://example.org/object_occurrences?include=tags,owners,progress_step_checked&page[number]=1"
  }
}
```



## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4
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
X-Request-Id: 676989dd-4321-4c04-acd6-eb7b92490097
200 OK
```


```json
{
  "data": {
    "id": "1d844127-f1aa-4b55-b78c-39a078aa03a4",
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
          {
            "id": "b6dfddc3-187c-474b-95f1-715ec12e3c26",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=1d844127-f1aa-4b55-b78c-39a078aa03a4",
          "self": "/object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "5c6fefea-984e-4f2d-a334-14e616f5caa7",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=1d844127-f1aa-4b55-b78c-39a078aa03a4&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "b6dfddc3-187c-474b-95f1-715ec12e3c26",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=1d844127-f1aa-4b55-b78c-39a078aa03a4"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/e9c9f902-dc33-426a-8441-c19fbca38f1d"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/3ed28cb7-dc98-4bfb-b2c8-3d0ac50db03b",
          "self": "/object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "e313215b-d0af-4bc1-8ee4-f36c1b59421f",
            "type": "object_occurrence"
          },
          {
            "id": "c6998daa-b61f-4df6-9735-9c29cf07c7a4",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=1d844127-f1aa-4b55-b78c-39a078aa03a4"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=1d844127-f1aa-4b55-b78c-39a078aa03a4"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=1d844127-f1aa-4b55-b78c-39a078aa03a4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4"
  },
  "included": [
    {
      "id": "5c6fefea-984e-4f2d-a334-14e616f5caa7",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 11",
        "title": null
      }
    },
    {
      "id": "06b28183-a249-45c7-a710-e1d8f6cf0336",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "095c288f-499e-4579-b875-612b669341fe",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/095c288f-499e-4579-b875-612b669341fe"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/1d844127-f1aa-4b55-b78c-39a078aa03a4"
          }
        }
      }
    },
    {
      "id": "b6dfddc3-187c-474b-95f1-715ec12e3c26",
      "type": "tag",
      "attributes": {
        "value": "tag value 11"
      },
      "relationships": {
      }
    }
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
POST /object_occurrences/b88d6555-b323-4833-b5cb-61b024046849/relationships/components
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
X-Request-Id: 9f1058a4-7da4-48c1-a808-88ee391e7d14
201 Created
```


```json
{
  "data": {
    "id": "36c5bb5f-4661-46c6-a19f-392529f4e4f1",
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
          "related": "/tags?filter[target_id_eq]=36c5bb5f-4661-46c6-a19f-392529f4e4f1",
          "self": "/object_occurrences/36c5bb5f-4661-46c6-a19f-392529f4e4f1/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=36c5bb5f-4661-46c6-a19f-392529f4e4f1&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/36c5bb5f-4661-46c6-a19f-392529f4e4f1/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=36c5bb5f-4661-46c6-a19f-392529f4e4f1"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/0d7fe329-0d5c-4d79-bf06-d7361b81b8d5"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/b88d6555-b323-4833-b5cb-61b024046849",
          "self": "/object_occurrences/36c5bb5f-4661-46c6-a19f-392529f4e4f1/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/36c5bb5f-4661-46c6-a19f-392529f4e4f1/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=36c5bb5f-4661-46c6-a19f-392529f4e4f1"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=36c5bb5f-4661-46c6-a19f-392529f4e4f1"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=36c5bb5f-4661-46c6-a19f-392529f4e4f1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b88d6555-b323-4833-b5cb-61b024046849/relationships/components"
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
POST /object_occurrences/f78d4785-7a18-486b-a7e2-44c4e715595e/relationships/components
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
X-Request-Id: 385fae2b-0337-4860-8b17-bf01c14318c2
201 Created
```


```json
{
  "data": {
    "id": "84a9a576-c2f2-40d2-a8a9-8373a3429474",
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
          "related": "/tags?filter[target_id_eq]=84a9a576-c2f2-40d2-a8a9-8373a3429474",
          "self": "/object_occurrences/84a9a576-c2f2-40d2-a8a9-8373a3429474/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=84a9a576-c2f2-40d2-a8a9-8373a3429474&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/84a9a576-c2f2-40d2-a8a9-8373a3429474/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=84a9a576-c2f2-40d2-a8a9-8373a3429474"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/9f790090-d175-4096-a7ff-ca8d0a943885"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f78d4785-7a18-486b-a7e2-44c4e715595e/relationships/components"
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
PATCH /object_occurrences/83b2f7a2-77cc-4661-8878-503ef86c9dc2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "83b2f7a2-77cc-4661-8878-503ef86c9dc2",
    "type": "object_occurrence",
    "attributes": {
      "description": "New description",
      "name": "New name",
      "number": 3,
      "position": 2,
      "type": "regular",
      "hex_color": "#FFA500"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "01b01b55-101c-4280-a539-d58e7f3de38d"
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
X-Request-Id: 4b8421bb-228d-4e50-85da-a2059852998f
200 OK
```


```json
{
  "data": {
    "id": "83b2f7a2-77cc-4661-8878-503ef86c9dc2",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "ffa500",
      "number": "3",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=83b2f7a2-77cc-4661-8878-503ef86c9dc2",
          "self": "/object_occurrences/83b2f7a2-77cc-4661-8878-503ef86c9dc2/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=83b2f7a2-77cc-4661-8878-503ef86c9dc2&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/83b2f7a2-77cc-4661-8878-503ef86c9dc2/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=83b2f7a2-77cc-4661-8878-503ef86c9dc2"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/827a4af3-eafb-4220-ae71-8b5ece2c19c9"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/01b01b55-101c-4280-a539-d58e7f3de38d",
          "self": "/object_occurrences/83b2f7a2-77cc-4661-8878-503ef86c9dc2/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/83b2f7a2-77cc-4661-8878-503ef86c9dc2/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=83b2f7a2-77cc-4661-8878-503ef86c9dc2"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=83b2f7a2-77cc-4661-8878-503ef86c9dc2"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=83b2f7a2-77cc-4661-8878-503ef86c9dc2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/83b2f7a2-77cc-4661-8878-503ef86c9dc2"
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
POST /object_occurrences/4f59fd96-180a-409a-8826-f19c1162b998/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "62cb7f12-96c9-430b-b808-a28bd9c325a9",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/77e955f1455e40103bb309a9
Content-Type: text/html; charset=utf-8
X-Request-Id: c911789c-893f-44c3-889c-792a28dec0d2
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/77e955f1455e40103bb309a9">redirected</a>.</body></html>
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
DELETE /object_occurrences/8883ccc9-2633-4b94-854c-3c937f031b80
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 433bd5e7-06e1-4666-8437-43482b0cfd16
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/cddb885f-0132-4e47-bd04-08fc8217ef6a/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "6abe8d45-5497-4c4f-bdf3-737e8cbe298d",
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
X-Request-Id: a636bb07-834a-41b7-a7a5-3c689ba9c56a
200 OK
```


```json
{
  "data": {
    "id": "cddb885f-0132-4e47-bd04-08fc8217ef6a",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
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
          "related": "/tags?filter[target_id_eq]=cddb885f-0132-4e47-bd04-08fc8217ef6a",
          "self": "/object_occurrences/cddb885f-0132-4e47-bd04-08fc8217ef6a/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=cddb885f-0132-4e47-bd04-08fc8217ef6a&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/cddb885f-0132-4e47-bd04-08fc8217ef6a/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=cddb885f-0132-4e47-bd04-08fc8217ef6a"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/68693ce8-7d76-4a87-90ce-42d4ec498f1b"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6abe8d45-5497-4c4f-bdf3-737e8cbe298d",
          "self": "/object_occurrences/cddb885f-0132-4e47-bd04-08fc8217ef6a/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/cddb885f-0132-4e47-bd04-08fc8217ef6a/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=cddb885f-0132-4e47-bd04-08fc8217ef6a"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=cddb885f-0132-4e47-bd04-08fc8217ef6a"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=cddb885f-0132-4e47-bd04-08fc8217ef6a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/cddb885f-0132-4e47-bd04-08fc8217ef6a/relationships/part_of"
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
X-Request-Id: bef4e62b-0af5-44f7-8615-db643d126359
200 OK
```


```json
{
  "data": [
    {
      "id": "84b729a8636bc0fdc6bf43e5ea6092635cc5133460f6009db23b66dc1281f26d",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "b53a9053-455d-432c-85b4-28a0774b3570",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b53a9053-455d-432c-85b4-28a0774b3570"
          }
        }
      }
    },
    {
      "id": "b4cedc6f3178ff5d2f1daaf14b866f2a23c4301d0856a252cd38469d78a8a8d7",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "ed37715d-c28e-4909-89fd-df6d411d8ad8",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/ed37715d-c28e-4909-89fd-df6d411d8ad8"
          }
        }
      }
    },
    {
      "id": "fe643191fd8769b93e14b379532769ec3421cdd411dc581ad31ad6e21ae0a8d8",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "b085769b-979c-4045-bf59-03e206e33981",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b085769b-979c-4045-bf59-03e206e33981"
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



# Classification Tables

Classification tables represent a strategic breakdown of the company product(s) into a nuanced
and logically separated classification table structure.

Each classification table has multiple classification entries.


## Add new tag

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_tables/ae5c42cf-8cc5-47c0-a163-c60de71443a0/relationships/tags
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
X-Request-Id: 3767384a-6db4-4cc4-91d8-f31e4ac15550
201 Created
```


```json
{
  "data": {
    "id": "fda3cacb-8db6-4736-b575-f94054b55b96",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ae5c42cf-8cc5-47c0-a163-c60de71443a0/relationships/tags"
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
POST /classification_tables/c91bacad-78e7-4c15-9939-e1ffc8ce82c2/relationships/tags
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
    "id": "bb99987e-8c97-4dd3-aa6f-243b4ba32df1"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: cfb53cd7-7f69-47c1-815e-79f0535b8e8e
201 Created
```


```json
{
  "data": {
    "id": "bb99987e-8c97-4dd3-aa6f-243b4ba32df1",
    "type": "tag",
    "attributes": {
      "value": "tag value 18"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/c91bacad-78e7-4c15-9939-e1ffc8ce82c2/relationships/tags"
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
DELETE /classification_tables/4e3c285a-e28e-4d26-aca7-4adf27295c8e/relationships/tags/8428005d-167d-4545-97b4-5b37892cc4a8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: df56c9dd-badc-4903-872f-8bc25d103c59
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
X-Request-Id: c78c8410-271b-45b7-a5d9-4a9fc33c9aa5
200 OK
```


```json
{
  "data": [
    {
      "id": "1df73198-426d-4625-a202-091344f8f4dc",
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
            "related": "/tags?filter[target_id_eq]=1df73198-426d-4625-a202-091344f8f4dc",
            "self": "/classification_tables/1df73198-426d-4625-a202-091344f8f4dc/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=1df73198-426d-4625-a202-091344f8f4dc",
            "self": "/classification_tables/1df73198-426d-4625-a202-091344f8f4dc/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "e94b2b1c-2f0b-4cdc-868d-3e57d7be308d",
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
            "related": "/tags?filter[target_id_eq]=e94b2b1c-2f0b-4cdc-868d-3e57d7be308d",
            "self": "/classification_tables/e94b2b1c-2f0b-4cdc-868d-3e57d7be308d/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=e94b2b1c-2f0b-4cdc-868d-3e57d7be308d",
            "self": "/classification_tables/e94b2b1c-2f0b-4cdc-868d-3e57d7be308d/relationships/classification_entries",
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
GET /classification_tables/cab0bf51-36d6-46c3-a6d5-206e34c2080b
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
X-Request-Id: 977de2e5-056e-4f5c-83e0-bcbd18eabd0a
200 OK
```


```json
{
  "data": {
    "id": "cab0bf51-36d6-46c3-a6d5-206e34c2080b",
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
          "related": "/tags?filter[target_id_eq]=cab0bf51-36d6-46c3-a6d5-206e34c2080b",
          "self": "/classification_tables/cab0bf51-36d6-46c3-a6d5-206e34c2080b/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=cab0bf51-36d6-46c3-a6d5-206e34c2080b",
          "self": "/classification_tables/cab0bf51-36d6-46c3-a6d5-206e34c2080b/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/cab0bf51-36d6-46c3-a6d5-206e34c2080b"
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
PATCH /classification_tables/025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb",
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
X-Request-Id: d5160a35-222c-4dac-a8d8-a641f76dabe3
200 OK
```


```json
{
  "data": {
    "id": "025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb",
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
          "related": "/tags?filter[target_id_eq]=025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb",
          "self": "/classification_tables/025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb",
          "self": "/classification_tables/025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/025bb6e6-cb83-4a5d-8f71-a0c279ff2fbb"
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
DELETE /classification_tables/3275e882-b95e-4e0c-8705-86c923434b11
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e983b4d1-067b-4705-9525-81f370384dbb
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
POST /classification_tables/ab9c4c31-4d54-497b-a896-37c1e8f74e25/publish
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
X-Request-Id: 00b55afa-e1c6-447a-8e35-2a69e50525f4
200 OK
```


```json
{
  "data": {
    "id": "ab9c4c31-4d54-497b-a896-37c1e8f74e25",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-04-21T11:56:39.634Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=ab9c4c31-4d54-497b-a896-37c1e8f74e25",
          "self": "/classification_tables/ab9c4c31-4d54-497b-a896-37c1e8f74e25/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=ab9c4c31-4d54-497b-a896-37c1e8f74e25",
          "self": "/classification_tables/ab9c4c31-4d54-497b-a896-37c1e8f74e25/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ab9c4c31-4d54-497b-a896-37c1e8f74e25/publish"
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
POST /classification_tables/405c454c-4842-499d-a167-a96f21924981/archive
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
X-Request-Id: 6016889e-edb6-4e1b-b485-dea94c0e9a2c
200 OK
```


```json
{
  "data": {
    "id": "405c454c-4842-499d-a167-a96f21924981",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-21T11:56:40.329Z",
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
          "related": "/tags?filter[target_id_eq]=405c454c-4842-499d-a167-a96f21924981",
          "self": "/classification_tables/405c454c-4842-499d-a167-a96f21924981/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=405c454c-4842-499d-a167-a96f21924981",
          "self": "/classification_tables/405c454c-4842-499d-a167-a96f21924981/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/405c454c-4842-499d-a167-a96f21924981/archive"
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
X-Request-Id: db3c8318-05c0-4beb-a95f-1dd77cc6e7e1
201 Created
```


```json
{
  "data": {
    "id": "907fdf7a-e717-4b62-810b-cb6b9c0056b3",
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
          "related": "/tags?filter[target_id_eq]=907fdf7a-e717-4b62-810b-cb6b9c0056b3",
          "self": "/classification_tables/907fdf7a-e717-4b62-810b-cb6b9c0056b3/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=907fdf7a-e717-4b62-810b-cb6b9c0056b3",
          "self": "/classification_tables/907fdf7a-e717-4b62-810b-cb6b9c0056b3/relationships/classification_entries",
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
POST /classification_entries/bc33522e-51cc-438f-9e58-855f17c65227/relationships/tags
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
X-Request-Id: e6ffc20e-8ed1-4033-b41e-51220728a0de
201 Created
```


```json
{
  "data": {
    "id": "c9472d15-1e09-4bdf-92e6-d42c27536c98",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/bc33522e-51cc-438f-9e58-855f17c65227/relationships/tags"
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
POST /classification_entries/6e621628-f722-4c7d-a08d-d514915869cc/relationships/tags
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
    "id": "db6e0d83-af64-4dbc-ad3e-38f17b50e17c"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0e090c6b-8bbb-44ed-821d-5643eb1fee78
201 Created
```


```json
{
  "data": {
    "id": "db6e0d83-af64-4dbc-ad3e-38f17b50e17c",
    "type": "tag",
    "attributes": {
      "value": "tag value 20"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/6e621628-f722-4c7d-a08d-d514915869cc/relationships/tags"
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
DELETE /classification_entries/14c17220-fc58-45b6-ae27-5bd7e922e778/relationships/tags/313ad932-3e88-4fb3-bc32-cb6bd8171a86
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1d8c8a2a-e5e7-4452-a94d-979402b8a58f
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
X-Request-Id: 3539a166-ed11-4d25-aa71-8cbf6a782efa
200 OK
```


```json
{
  "data": [
    {
      "id": "efb647e6-af93-4134-86f9-2149bc79c6f9",
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
            "related": "/tags?filter[target_id_eq]=efb647e6-af93-4134-86f9-2149bc79c6f9",
            "self": "/classification_entries/efb647e6-af93-4134-86f9-2149bc79c6f9/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=efb647e6-af93-4134-86f9-2149bc79c6f9",
            "self": "/classification_entries/efb647e6-af93-4134-86f9-2149bc79c6f9/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "f7f9a784-2d59-4b09-b927-22f7832e3848",
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
            "related": "/tags?filter[target_id_eq]=f7f9a784-2d59-4b09-b927-22f7832e3848",
            "self": "/classification_entries/f7f9a784-2d59-4b09-b927-22f7832e3848/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "efb647e6-af93-4134-86f9-2149bc79c6f9",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/f7f9a784-2d59-4b09-b927-22f7832e3848"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=f7f9a784-2d59-4b09-b927-22f7832e3848",
            "self": "/classification_entries/f7f9a784-2d59-4b09-b927-22f7832e3848/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "52405d21-6fcb-49ba-9ddf-5b23a1d2594d",
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
            "related": "/tags?filter[target_id_eq]=52405d21-6fcb-49ba-9ddf-5b23a1d2594d",
            "self": "/classification_entries/52405d21-6fcb-49ba-9ddf-5b23a1d2594d/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=52405d21-6fcb-49ba-9ddf-5b23a1d2594d",
            "self": "/classification_entries/52405d21-6fcb-49ba-9ddf-5b23a1d2594d/relationships/classification_entries",
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
GET /classification_entries/342d5228-b41a-4662-9a88-84a7d4dd4afb
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
X-Request-Id: 04bb3a4f-226e-45ab-806b-fcb87f8e98b9
200 OK
```


```json
{
  "data": {
    "id": "342d5228-b41a-4662-9a88-84a7d4dd4afb",
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
          "related": "/tags?filter[target_id_eq]=342d5228-b41a-4662-9a88-84a7d4dd4afb",
          "self": "/classification_entries/342d5228-b41a-4662-9a88-84a7d4dd4afb/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=342d5228-b41a-4662-9a88-84a7d4dd4afb",
          "self": "/classification_entries/342d5228-b41a-4662-9a88-84a7d4dd4afb/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/342d5228-b41a-4662-9a88-84a7d4dd4afb"
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
PATCH /classification_entries/33857830-3db3-4123-be10-588d3ab69bda
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "33857830-3db3-4123-be10-588d3ab69bda",
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
X-Request-Id: 1c0f7f77-b894-4abb-9eb9-904ce73fd948
200 OK
```


```json
{
  "data": {
    "id": "33857830-3db3-4123-be10-588d3ab69bda",
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
          "related": "/tags?filter[target_id_eq]=33857830-3db3-4123-be10-588d3ab69bda",
          "self": "/classification_entries/33857830-3db3-4123-be10-588d3ab69bda/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "673d15ca-7e3b-4fe1-9f12-7825ce9b443b",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/33857830-3db3-4123-be10-588d3ab69bda"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=33857830-3db3-4123-be10-588d3ab69bda",
          "self": "/classification_entries/33857830-3db3-4123-be10-588d3ab69bda/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/33857830-3db3-4123-be10-588d3ab69bda"
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
DELETE /classification_entries/e5d0df25-5067-4d5c-89c1-35901c16634e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6176f9d4-dd1d-45a8-9018-2b38f87ee249
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
POST /classification_tables/0860fead-f3be-4ac8-9e6b-d1059fc37a91/relationships/classification_entries
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
X-Request-Id: 4273dbb7-96e5-4090-8618-0f706dc366c7
201 Created
```


```json
{
  "data": {
    "id": "86d14f9f-ba22-45bd-8256-a5ef5b5b8781",
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
          "related": "/tags?filter[target_id_eq]=86d14f9f-ba22-45bd-8256-a5ef5b5b8781",
          "self": "/classification_entries/86d14f9f-ba22-45bd-8256-a5ef5b5b8781/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=86d14f9f-ba22-45bd-8256-a5ef5b5b8781",
          "self": "/classification_entries/86d14f9f-ba22-45bd-8256-a5ef5b5b8781/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0860fead-f3be-4ac8-9e6b-d1059fc37a91/relationships/classification_entries"
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
X-Request-Id: 7286c6d0-4fe6-479b-9b24-61f52ba77c04
200 OK
```


```json
{
  "data": [
    {
      "id": "79ed8a49-7100-441b-96e8-1e081563db77",
      "type": "syntax",
      "attributes": {
        "account_id": "5526de0b-a06d-4f21-ae7a-5726e858a6f6",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 3c45d830627d",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=79ed8a49-7100-441b-96e8-1e081563db77",
            "self": "/syntaxes/79ed8a49-7100-441b-96e8-1e081563db77/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/6e04d968-0fc8-4299-9324-031ce4d24db2",
            "self": "/syntax_nodes/6e04d968-0fc8-4299-9324-031ce4d24db2/relationships/components"
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
GET /syntaxes/e97cb85b-f3c9-4de6-9246-0a9ad645aac8
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
X-Request-Id: bdaa52e8-6367-4148-8617-f332aae9a17c
200 OK
```


```json
{
  "data": {
    "id": "e97cb85b-f3c9-4de6-9246-0a9ad645aac8",
    "type": "syntax",
    "attributes": {
      "account_id": "21387c8a-c20e-4a39-8021-42f7bc17d24a",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax f66581521519",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=e97cb85b-f3c9-4de6-9246-0a9ad645aac8",
          "self": "/syntaxes/e97cb85b-f3c9-4de6-9246-0a9ad645aac8/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/0f2d31ee-e848-4143-bed6-d9dafa796347",
          "self": "/syntax_nodes/0f2d31ee-e848-4143-bed6-d9dafa796347/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/e97cb85b-f3c9-4de6-9246-0a9ad645aac8"
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
X-Request-Id: 5393000a-22a7-478a-9d7f-a98fb62d503f
201 Created
```


```json
{
  "data": {
    "id": "432a7ee3-86a1-4087-9308-07b141a76bb3",
    "type": "syntax",
    "attributes": {
      "account_id": "9934f8cb-609b-451b-b337-32fe845d18c7",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=432a7ee3-86a1-4087-9308-07b141a76bb3",
          "self": "/syntaxes/432a7ee3-86a1-4087-9308-07b141a76bb3/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/c72bc497-3acf-4730-9336-833f0b1805a7",
          "self": "/syntax_nodes/c72bc497-3acf-4730-9336-833f0b1805a7/relationships/components"
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
PATCH /syntaxes/ca34387e-defa-4be9-8f73-9f22260331b9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "ca34387e-defa-4be9-8f73-9f22260331b9",
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
X-Request-Id: cd90cc5a-8b88-4230-858a-a4a92d3c837c
200 OK
```


```json
{
  "data": {
    "id": "ca34387e-defa-4be9-8f73-9f22260331b9",
    "type": "syntax",
    "attributes": {
      "account_id": "f0c99c16-ca80-45d9-91c8-56b79d978e4b",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ca34387e-defa-4be9-8f73-9f22260331b9",
          "self": "/syntaxes/ca34387e-defa-4be9-8f73-9f22260331b9/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/f3cd64e9-2afd-4674-a0c2-cb1478024299",
          "self": "/syntax_nodes/f3cd64e9-2afd-4674-a0c2-cb1478024299/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ca34387e-defa-4be9-8f73-9f22260331b9"
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
DELETE /syntaxes/7182c42a-202a-4c7e-9020-eb528aa398db
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: dd04860c-7828-4d12-bbe9-1ba0af797ccf
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
POST /syntaxes/5e938379-3677-4968-a6c9-7a2cf57f21e6/publish
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
X-Request-Id: e1bd3ffd-b10a-485b-a780-5d156a3fac04
200 OK
```


```json
{
  "data": {
    "id": "5e938379-3677-4968-a6c9-7a2cf57f21e6",
    "type": "syntax",
    "attributes": {
      "account_id": "d3d7048c-acb2-43ef-97b0-09d2c55f8747",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 2711bea93f93",
      "published": true,
      "published_at": "2020-04-21T11:56:52.857Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=5e938379-3677-4968-a6c9-7a2cf57f21e6",
          "self": "/syntaxes/5e938379-3677-4968-a6c9-7a2cf57f21e6/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/ad40ee91-18f7-48d6-8d2e-06564b42e18d",
          "self": "/syntax_nodes/ad40ee91-18f7-48d6-8d2e-06564b42e18d/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/5e938379-3677-4968-a6c9-7a2cf57f21e6/publish"
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
POST /syntaxes/f4a5a2fc-fc6f-4b9f-9978-52b6c6ea6180/archive
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
X-Request-Id: 0f6f0e1a-496f-4802-b6d6-3d8ca2a3eb20
200 OK
```


```json
{
  "data": {
    "id": "f4a5a2fc-fc6f-4b9f-9978-52b6c6ea6180",
    "type": "syntax",
    "attributes": {
      "account_id": "0cd8682d-3657-4757-ba9d-c18784bf8a01",
      "archived": true,
      "archived_at": "2020-04-21T11:56:53.702Z",
      "description": "Description",
      "name": "Syntax bcdddec600c7",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=f4a5a2fc-fc6f-4b9f-9978-52b6c6ea6180",
          "self": "/syntaxes/f4a5a2fc-fc6f-4b9f-9978-52b6c6ea6180/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/8ab2f973-c26c-42b1-8dae-57cd1d51fe56",
          "self": "/syntax_nodes/8ab2f973-c26c-42b1-8dae-57cd1d51fe56/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/f4a5a2fc-fc6f-4b9f-9978-52b6c6ea6180/archive"
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
X-Request-Id: e023efb1-7796-4922-831a-aaaa52bfa7f3
200 OK
```


```json
{
  "data": [
    {
      "id": "00986a11-954f-4efa-ae52-bf9c4dc974dc",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 18",
        "hex_color": "b8eb3b"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/86715c4c-1aa4-437f-b6c1-ca9a8023568f"
          }
        },
        "classification_table": {
          "data": {
            "id": "c756f5b8-da53-4a9a-8b64-da1bda42107d",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/c756f5b8-da53-4a9a-8b64-da1bda42107d",
            "self": "/syntax_elements/00986a11-954f-4efa-ae52-bf9c4dc974dc/relationships/classification_table"
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
GET /syntax_elements/49d84573-90d1-4078-8208-40555e5f49ee
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
X-Request-Id: ce5a8dca-4bb3-47bd-9bbd-fc62cbb6d9cb
200 OK
```


```json
{
  "data": {
    "id": "49d84573-90d1-4078-8208-40555e5f49ee",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 19",
      "hex_color": "6812c4"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/ce8e6f75-4739-4b4b-b1d0-281dd151b5cb"
        }
      },
      "classification_table": {
        "data": {
          "id": "52769af8-1d43-41dd-a509-0702ae87cc66",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/52769af8-1d43-41dd-a509-0702ae87cc66",
          "self": "/syntax_elements/49d84573-90d1-4078-8208-40555e5f49ee/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/49d84573-90d1-4078-8208-40555e5f49ee"
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
POST /syntaxes/8dab0b12-b83f-4920-9102-afeabe4156a8/relationships/syntax_elements
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
          "id": "913cc428-1149-4d87-9d69-ac11b19c6e9b"
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
X-Request-Id: 22d30f74-6186-4265-99d4-06bc09d7d1ab
201 Created
```


```json
{
  "data": {
    "id": "29b82585-3080-4bd9-83d7-b13919d898ed",
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
          "related": "/syntaxes/8dab0b12-b83f-4920-9102-afeabe4156a8"
        }
      },
      "classification_table": {
        "data": {
          "id": "913cc428-1149-4d87-9d69-ac11b19c6e9b",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/913cc428-1149-4d87-9d69-ac11b19c6e9b",
          "self": "/syntax_elements/29b82585-3080-4bd9-83d7-b13919d898ed/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/8dab0b12-b83f-4920-9102-afeabe4156a8/relationships/syntax_elements"
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
PATCH /syntax_elements/5e9a2f32-84f7-4aaf-ac79-e296a0c94001
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "5e9a2f32-84f7-4aaf-ac79-e296a0c94001",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "5085039f-b82b-4c5e-96ce-547eb7e9f5fa"
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
X-Request-Id: dc69a92a-5854-4ce9-9686-dc49042db68b
200 OK
```


```json
{
  "data": {
    "id": "5e9a2f32-84f7-4aaf-ac79-e296a0c94001",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "hex_color": "da79a1"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/57d238d0-b0d4-4dde-8558-0999ce7915b8"
        }
      },
      "classification_table": {
        "data": {
          "id": "5085039f-b82b-4c5e-96ce-547eb7e9f5fa",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/5085039f-b82b-4c5e-96ce-547eb7e9f5fa",
          "self": "/syntax_elements/5e9a2f32-84f7-4aaf-ac79-e296a0c94001/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/5e9a2f32-84f7-4aaf-ac79-e296a0c94001"
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
DELETE /syntax_elements/7f743542-4884-420e-abb6-026feb3a16dc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3ea2eded-237b-440e-bbfc-a041b3779b69
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
PATCH /syntax_elements/2b0309b3-1f2b-45d1-8d16-30ba1ddb47c7/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "214aa98f-00e8-4829-bf07-b65f935a53e7",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3850fea4-f187-452c-9a92-b9aa91fafee0
200 OK
```


```json
{
  "data": {
    "id": "2b0309b3-1f2b-45d1-8d16-30ba1ddb47c7",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 23",
      "hex_color": "2644c7"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/818f2f9c-f345-40ea-bbac-e4305998acb3"
        }
      },
      "classification_table": {
        "data": {
          "id": "214aa98f-00e8-4829-bf07-b65f935a53e7",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/214aa98f-00e8-4829-bf07-b65f935a53e7",
          "self": "/syntax_elements/2b0309b3-1f2b-45d1-8d16-30ba1ddb47c7/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/2b0309b3-1f2b-45d1-8d16-30ba1ddb47c7/relationships/classification_table"
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
DELETE /syntax_elements/cf04d63d-2d76-4195-a56c-619dd079f32d/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a0ca88d7-4834-4db6-83d1-a75488531e32
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
X-Request-Id: f75a1168-5581-414c-a35e-83d1b4f2f2db
200 OK
```


```json
{
  "data": [
    {
      "id": "3d8fae13-4fb4-4930-9340-9f7af5278863",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/0b416eac-4000-4829-aa02-0725797f695b"
          }
        },
        "components": {
          "data": [
            {
              "id": "2e3f6e2a-6c18-45aa-a082-32f1436177db",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/3d8fae13-4fb4-4930-9340-9f7af5278863/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/3d8fae13-4fb4-4930-9340-9f7af5278863/relationships/parent",
            "related": "/syntax_nodes/3d8fae13-4fb4-4930-9340-9f7af5278863"
          }
        }
      }
    },
    {
      "id": "2e3f6e2a-6c18-45aa-a082-32f1436177db",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/0b416eac-4000-4829-aa02-0725797f695b"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/2e3f6e2a-6c18-45aa-a082-32f1436177db/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/2e3f6e2a-6c18-45aa-a082-32f1436177db/relationships/parent",
            "related": "/syntax_nodes/2e3f6e2a-6c18-45aa-a082-32f1436177db"
          }
        }
      }
    },
    {
      "id": "10015e75-f8ea-4d5f-a37f-01fff961a474",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/0b416eac-4000-4829-aa02-0725797f695b"
          }
        },
        "components": {
          "data": [
            {
              "id": "3d8fae13-4fb4-4930-9340-9f7af5278863",
              "type": "syntax_node"
            },
            {
              "id": "3aff4488-5c3e-46f9-81ea-413d59684e30",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/10015e75-f8ea-4d5f-a37f-01fff961a474/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/10015e75-f8ea-4d5f-a37f-01fff961a474/relationships/parent",
            "related": "/syntax_nodes/10015e75-f8ea-4d5f-a37f-01fff961a474"
          }
        }
      }
    },
    {
      "id": "bcbc26de-fb14-4af7-8bc0-59df658641ac",
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
              "id": "10015e75-f8ea-4d5f-a37f-01fff961a474",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/bcbc26de-fb14-4af7-8bc0-59df658641ac/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/bcbc26de-fb14-4af7-8bc0-59df658641ac/relationships/parent",
            "related": "/syntax_nodes/bcbc26de-fb14-4af7-8bc0-59df658641ac"
          }
        }
      }
    },
    {
      "id": "3aff4488-5c3e-46f9-81ea-413d59684e30",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/0b416eac-4000-4829-aa02-0725797f695b"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/3aff4488-5c3e-46f9-81ea-413d59684e30/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/3aff4488-5c3e-46f9-81ea-413d59684e30/relationships/parent",
            "related": "/syntax_nodes/3aff4488-5c3e-46f9-81ea-413d59684e30"
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
GET /syntax_nodes/3b4997ef-082d-4642-a517-ab56dadfa8fa?depth=2
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
X-Request-Id: cf64ecaf-7f79-4e06-a94f-8a935ed8fa01
200 OK
```


```json
{
  "data": {
    "id": "3b4997ef-082d-4642-a517-ab56dadfa8fa",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/d8bec02b-cfed-43eb-b227-955cdf435440"
        }
      },
      "components": {
        "data": [
          {
            "id": "f8b42aae-5e76-408c-ac4f-c73c560f7c29",
            "type": "syntax_node"
          },
          {
            "id": "e44ed334-5388-4ed8-b935-0c7ce2a6c2d9",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/3b4997ef-082d-4642-a517-ab56dadfa8fa/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/3b4997ef-082d-4642-a517-ab56dadfa8fa/relationships/parent",
          "related": "/syntax_nodes/3b4997ef-082d-4642-a517-ab56dadfa8fa"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/3b4997ef-082d-4642-a517-ab56dadfa8fa?depth=2"
  },
  "included": [
    {
      "id": "e44ed334-5388-4ed8-b935-0c7ce2a6c2d9",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/d8bec02b-cfed-43eb-b227-955cdf435440"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/e44ed334-5388-4ed8-b935-0c7ce2a6c2d9/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e44ed334-5388-4ed8-b935-0c7ce2a6c2d9/relationships/parent",
            "related": "/syntax_nodes/e44ed334-5388-4ed8-b935-0c7ce2a6c2d9"
          }
        }
      }
    },
    {
      "id": "f8b42aae-5e76-408c-ac4f-c73c560f7c29",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/d8bec02b-cfed-43eb-b227-955cdf435440"
          }
        },
        "components": {
          "data": [
            {
              "id": "084d149f-358f-497e-bcc6-61275c536e86",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/f8b42aae-5e76-408c-ac4f-c73c560f7c29/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/f8b42aae-5e76-408c-ac4f-c73c560f7c29/relationships/parent",
            "related": "/syntax_nodes/f8b42aae-5e76-408c-ac4f-c73c560f7c29"
          }
        }
      }
    },
    {
      "id": "084d149f-358f-497e-bcc6-61275c536e86",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/d8bec02b-cfed-43eb-b227-955cdf435440"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/084d149f-358f-497e-bcc6-61275c536e86/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/084d149f-358f-497e-bcc6-61275c536e86/relationships/parent",
            "related": "/syntax_nodes/084d149f-358f-497e-bcc6-61275c536e86"
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
POST /syntax_nodes/14b56917-db9c-4d51-873a-ee3f03442b16/relationships/components
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
          "id": "f46782cd-6b00-40a8-926d-9d85744d7087"
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
X-Request-Id: 42acfd87-082b-4f37-9533-fc48afbf6be0
201 Created
```


```json
{
  "data": {
    "id": "8dd16204-dcbc-4527-ae7d-8f1f9fa12f84",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/f46782cd-6b00-40a8-926d-9d85744d7087"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/8dd16204-dcbc-4527-ae7d-8f1f9fa12f84/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/8dd16204-dcbc-4527-ae7d-8f1f9fa12f84/relationships/parent",
          "related": "/syntax_nodes/8dd16204-dcbc-4527-ae7d-8f1f9fa12f84"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/14b56917-db9c-4d51-873a-ee3f03442b16/relationships/components"
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
PATCH /syntax_nodes/cee2ce35-81f6-4023-9c27-a0cfece109b0/relationships/parent
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
    "id": "a515e279-ef87-4e93-9942-4b3e700a2df5"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 29c0ca31-92a8-4608-8279-2a4a60de2999
200 OK
```


```json
{
  "data": {
    "id": "cee2ce35-81f6-4023-9c27-a0cfece109b0",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/530f5419-0cc7-407a-866d-d1e77ebedc65"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/cee2ce35-81f6-4023-9c27-a0cfece109b0/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/cee2ce35-81f6-4023-9c27-a0cfece109b0/relationships/parent",
          "related": "/syntax_nodes/cee2ce35-81f6-4023-9c27-a0cfece109b0"
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
PATCH /syntax_nodes/7ed49779-302d-494d-b1e7-83b32b8c3e90
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "7ed49779-302d-494d-b1e7-83b32b8c3e90",
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
X-Request-Id: e7e89e62-98cb-4c20-a3d9-5a9aaa1728f8
200 OK
```


```json
{
  "data": {
    "id": "7ed49779-302d-494d-b1e7-83b32b8c3e90",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/b7e89f99-7b40-4606-ab86-57f9b0444d63"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/7ed49779-302d-494d-b1e7-83b32b8c3e90/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/7ed49779-302d-494d-b1e7-83b32b8c3e90/relationships/parent",
          "related": "/syntax_nodes/7ed49779-302d-494d-b1e7-83b32b8c3e90"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/7ed49779-302d-494d-b1e7-83b32b8c3e90"
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
DELETE /syntax_nodes/ee16d7b5-2a59-4d5f-a1ca-57a1f57ae749
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5c832836-dbac-4999-8e05-93ab37465c04
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
X-Request-Id: 1464213f-7b1f-4371-8faf-bcc25724d9c5
200 OK
```


```json
{
  "data": [
    {
      "id": "b408aace-b1d7-46c9-a22e-abc4e5f1de9e",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 105,
        "published": true,
        "published_at": "2020-04-21T11:57:04.097Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b408aace-b1d7-46c9-a22e-abc4e5f1de9e",
            "self": "/progress_models/b408aace-b1d7-46c9-a22e-abc4e5f1de9e/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "9f722d12-4eeb-4ee8-8caf-04c294e8cbc2",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 2",
        "order": 106,
        "published": false,
        "published_at": null,
        "type": "object_occurrence_relation"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=9f722d12-4eeb-4ee8-8caf-04c294e8cbc2",
            "self": "/progress_models/9f722d12-4eeb-4ee8-8caf-04c294e8cbc2/relationships/progress_steps"
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
GET /progress_models/a145b36c-fa5c-46a4-93d5-ce14cf8b47d8
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
X-Request-Id: 1e2f277f-bd34-4848-b99c-1ebfa8b26571
200 OK
```


```json
{
  "data": {
    "id": "a145b36c-fa5c-46a4-93d5-ce14cf8b47d8",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 107,
      "published": true,
      "published_at": "2020-04-21T11:57:04.896Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a145b36c-fa5c-46a4-93d5-ce14cf8b47d8",
          "self": "/progress_models/a145b36c-fa5c-46a4-93d5-ce14cf8b47d8/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/a145b36c-fa5c-46a4-93d5-ce14cf8b47d8"
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
PATCH /progress_models/9ea72a96-5b2f-4e43-9931-72ad91cd0290
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "9ea72a96-5b2f-4e43-9931-72ad91cd0290",
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
X-Request-Id: e4c04f7a-084c-4dff-96b4-444c0a302450
200 OK
```


```json
{
  "data": {
    "id": "9ea72a96-5b2f-4e43-9931-72ad91cd0290",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 110,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=9ea72a96-5b2f-4e43-9931-72ad91cd0290",
          "self": "/progress_models/9ea72a96-5b2f-4e43-9931-72ad91cd0290/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/9ea72a96-5b2f-4e43-9931-72ad91cd0290"
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
DELETE /progress_models/1e4df94e-839b-4f9e-8bd9-07a9e7fbe8d9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 73b327c5-93b2-4b5e-9e0f-923856ffe781
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
POST /progress_models/b5d71f27-5e52-465f-b484-fbd47f8ebacd/publish
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
X-Request-Id: 3d1ddcd7-2a3a-4ec7-aa37-7a928967a6a3
200 OK
```


```json
{
  "data": {
    "id": "b5d71f27-5e52-465f-b484-fbd47f8ebacd",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 114,
      "published": true,
      "published_at": "2020-04-21T11:57:07.498Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b5d71f27-5e52-465f-b484-fbd47f8ebacd",
          "self": "/progress_models/b5d71f27-5e52-465f-b484-fbd47f8ebacd/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/b5d71f27-5e52-465f-b484-fbd47f8ebacd/publish"
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
POST /progress_models/7015a0ae-ce05-4962-b8e8-294350a503f6/archive
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
X-Request-Id: 4ec3b90c-47da-4a73-9b96-cd3e5d42630f
200 OK
```


```json
{
  "data": {
    "id": "7015a0ae-ce05-4962-b8e8-294350a503f6",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-21T11:57:08.206Z",
      "name": "pm 2",
      "order": 116,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=7015a0ae-ce05-4962-b8e8-294350a503f6",
          "self": "/progress_models/7015a0ae-ce05-4962-b8e8-294350a503f6/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/7015a0ae-ce05-4962-b8e8-294350a503f6/archive"
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
X-Request-Id: 4927517f-3231-4a3e-8988-c0c205df95da
201 Created
```


```json
{
  "data": {
    "id": "39eb149a-a47c-4ed1-9856-73100194d620",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=39eb149a-a47c-4ed1-9856-73100194d620",
          "self": "/progress_models/39eb149a-a47c-4ed1-9856-73100194d620/relationships/progress_steps"
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
X-Request-Id: cb3c97d0-9274-4d2d-b853-2ab5ff620048
200 OK
```


```json
{
  "data": [
    {
      "id": "50592041-2337-4c85-974b-78eb9ea0476d",
      "type": "progress_step",
      "attributes": {
        "name": "ps context",
        "order": 105,
        "hex_color": "5c1944"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/d44d0305-ce13-4c3a-86e1-25f32237bc39"
          }
        }
      }
    },
    {
      "id": "93f81601-a4e0-46a4-88de-c5cc1064fcec",
      "type": "progress_step",
      "attributes": {
        "name": "ps ooc",
        "order": 106,
        "hex_color": "f00897"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/95edb521-e291-40a9-b07e-f70ace8b601d"
          }
        }
      }
    },
    {
      "id": "8c757a4c-cbab-430f-bde8-cc24914e8ec4",
      "type": "progress_step",
      "attributes": {
        "name": "ps oor",
        "order": 107,
        "hex_color": "83c3c2"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/5474734e-1546-41d1-a8a3-f588f2fbf1fd"
          }
        }
      }
    },
    {
      "id": "810d0c1a-2edd-4fab-b754-3d234c1ccbb1",
      "type": "progress_step",
      "attributes": {
        "name": "ps project",
        "order": 108,
        "hex_color": "ccbc80"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/9e1e0caa-b8d5-4e47-9a78-016bbbd12cc6"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 4
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
GET /progress_steps/185986cf-a974-4047-b715-8b43a0dd7fd1
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
X-Request-Id: f47ddcf7-c6ac-4602-b6ec-e3e620f33c99
200 OK
```


```json
{
  "data": {
    "id": "185986cf-a974-4047-b715-8b43a0dd7fd1",
    "type": "progress_step",
    "attributes": {
      "name": "ps oor",
      "order": 111,
      "hex_color": "122a48"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/4d86b2f7-ccb8-4bc3-b391-7452301f6984"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/185986cf-a974-4047-b715-8b43a0dd7fd1"
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
PATCH /progress_steps/39290093-8441-40ad-88ac-f21c90746499
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "39290093-8441-40ad-88ac-f21c90746499",
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
X-Request-Id: c06e4873-2a49-495a-8175-1f4fb69736a4
200 OK
```


```json
{
  "data": {
    "id": "39290093-8441-40ad-88ac-f21c90746499",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 115,
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/fb2d9e69-a083-43cf-bffc-80032839466d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/39290093-8441-40ad-88ac-f21c90746499"
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
DELETE /progress_steps/c2821f77-e6c6-464e-814f-a1ba977acdfa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9bfe63f6-9bde-4fac-84b6-82509b84ea5f
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
POST /progress_models/2783bec2-a2bb-42c7-adb4-9d2678ae2c0b/relationships/progress_steps
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
X-Request-Id: 8d30ce1d-40ae-42a2-900b-bdc1367bd4a7
201 Created
```


```json
{
  "data": {
    "id": "f74c9995-8701-440b-8616-1eef2e0a4007",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/2783bec2-a2bb-42c7-adb4-9d2678ae2c0b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/2783bec2-a2bb-42c7-adb4-9d2678ae2c0b/relationships/progress_steps"
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
X-Request-Id: 4a252878-6f42-463b-8a63-63ec8c466d01
200 OK
```


```json
{
  "data": [
    {
      "id": "9a54bf93-88d0-4021-b430-4e572c1f36da",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "3e8cf612-e777-419b-aad3-db534c860c7e",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/3e8cf612-e777-419b-aad3-db534c860c7e"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/391cfcf6-bedf-41a9-8e51-57afefad0315"
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
GET /progress/cf5520d1-7f6a-4b32-ad69-c03b7892eef1
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
X-Request-Id: 925e1818-185c-4f6f-9c41-dd2942b5248b
200 OK
```


```json
{
  "data": {
    "id": "cf5520d1-7f6a-4b32-ad69-c03b7892eef1",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "20049876-f77e-4a19-bd33-8b302a61a0d0",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/20049876-f77e-4a19-bd33-8b302a61a0d0"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/ee93adf7-73e3-47ce-87e6-04a67523670a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/cf5520d1-7f6a-4b32-ad69-c03b7892eef1"
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
DELETE /progress/dd97f221-edd6-48ab-be7d-7ae1a7271f38
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0c3cccaa-14c6-47db-9bc1-71aea4784a68
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
          "id": "98660515-ca06-4b69-ae0a-d13e942d191b"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "c07aef02-c24b-4cf7-90aa-ea9d5e472a71"
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
X-Request-Id: 98fd45f1-ab69-4c87-97e5-155b016226f3
201 Created
```


```json
{
  "data": {
    "id": "ec7c9e43-09b1-490a-892c-a4f0dcf701c6",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "98660515-ca06-4b69-ae0a-d13e942d191b",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/98660515-ca06-4b69-ae0a-d13e942d191b"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/c07aef02-c24b-4cf7-90aa-ea9d5e472a71"
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
X-Request-Id: 9a9d0f00-7c7f-462c-8b48-9acc5ed6b650
200 OK
```


```json
{
  "data": [
    {
      "id": "9821d827-62bf-43f2-bd75-51d11c768cd6",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "24b1d921-326f-4ca5-a81c-be9f6a34290c"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/24b1d921-326f-4ca5-a81c-be9f6a34290c"
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
GET /projects/39d2c744-09cf-46ec-90d1-0669dfc51fdd/relationships/project_setting
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
X-Request-Id: 3f8fdb8b-6ca9-477e-ab15-7583022e0303
200 OK
```


```json
{
  "data": {
    "id": "843f0b73-9164-4cd9-b5a1-f5505d824006",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "39d2c744-09cf-46ec-90d1-0669dfc51fdd"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/39d2c744-09cf-46ec-90d1-0669dfc51fdd"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/39d2c744-09cf-46ec-90d1-0669dfc51fdd/relationships/project_setting"
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
PATCH /projects/25d28420-a584-4608-9f15-96063a74709f/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "25d28420-a584-4608-9f15-96063a74709f",
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
X-Request-Id: 9cf16995-3ab8-4399-850d-60bb9bc6f667
200 OK
```


```json
{
  "data": {
    "id": "afaaf73a-f627-47a1-8983-9b52f84d1a86",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "25d28420-a584-4608-9f15-96063a74709f"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/25d28420-a584-4608-9f15-96063a74709f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/25d28420-a584-4608-9f15-96063a74709f/relationships/project_setting"
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
X-Request-Id: 62f69217-9e00-45f9-adfb-29657150b341
200 OK
```


```json
{
  "data": [
    {
      "id": "7a353d81-d75e-4713-92b4-4eb2e13aafef",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/7a353d81-d75e-4713-92b4-4eb2e13aafef"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/7a353d81-d75e-4713-92b4-4eb2e13aafef"
          }
        }
      }
    },
    {
      "id": "a5971f6a-9d0a-434e-891e-4efe0c9f1af4",
      "type": "system_element",
      "attributes": {
        "name": "OOC 5c77c55c93ef-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/a5971f6a-9d0a-434e-891e-4efe0c9f1af4"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/a5971f6a-9d0a-434e-891e-4efe0c9f1af4"
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
GET /system_elements/0b7ce781-5e7a-43e3-80a9-111be97676e5
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
X-Request-Id: 79671297-9fe5-4d35-bbe7-b3cb9ed7ec85
200 OK
```


```json
{
  "data": {
    "id": "0b7ce781-5e7a-43e3-80a9-111be97676e5",
    "type": "system_element",
    "attributes": {
      "name": "OOC 60e0fe683d2c-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/0b7ce781-5e7a-43e3-80a9-111be97676e5"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/0b7ce781-5e7a-43e3-80a9-111be97676e5"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/0b7ce781-5e7a-43e3-80a9-111be97676e5"
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
POST /object_occurrences/24cdcc61-ac3f-4e4d-b935-ca2546aabf4e/relationships/system_elements
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
      "target_id": "89d7609f-dd89-49d0-80d2-bcb00f147278"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 78015b4e-07f6-44ea-b57b-3556bab551cd
201 Created
```


```json
{
  "data": {
    "id": "0ebb8bee-d7f6-49d9-a8fe-29224ffecfe6",
    "type": "system_element",
    "attributes": {
      "name": "OOC e696f071206e-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/0ebb8bee-d7f6-49d9-a8fe-29224ffecfe6"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/0ebb8bee-d7f6-49d9-a8fe-29224ffecfe6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/24cdcc61-ac3f-4e4d-b935-ca2546aabf4e/relationships/system_elements"
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
DELETE /object_occurrences/bf30d7bc-0c0d-465f-a51f-e2d484c87f00/relationships/system_elements/38b4b7dd-4bb6-4b17-a94a-162eb4ac74a4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 60bc7b4f-73bc-4340-aef1-e840e6e98849
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
POST /object_occurrence_relations/4b738806-8aa3-44bd-a36c-41c80fd663fb/relationships/owners
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
X-Request-Id: d7d819ce-5559-4eff-86e1-e672f54b030e
201 Created
```


```json
{
  "data": {
    "id": "471b9756-84e5-416b-816b-83a4b1363a8a",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/4b738806-8aa3-44bd-a36c-41c80fd663fb/relationships/owners"
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
POST /object_occurrence_relations/54f34c55-f90a-4193-a8ee-d1bd778c91b2/relationships/owners
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
X-Request-Id: d1ea0a03-9f32-47a1-99a2-c9cc69ee36fd
201 Created
```


```json
{
  "data": {
    "id": "091aa402-b43d-489c-8ad6-d672e3b2866e",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/54f34c55-f90a-4193-a8ee-d1bd778c91b2/relationships/owners"
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
POST /object_occurrence_relations/2858fd14-8e19-4170-a9c7-385c3acac265/relationships/owners
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
    "id": "88a0913d-f83f-4d04-b646-d883a6ff85fb"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fc8e5375-d0db-41a5-88e1-31195ac1ea8b
201 Created
```


```json
{
  "data": {
    "id": "88a0913d-f83f-4d04-b646-d883a6ff85fb",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 21",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/2858fd14-8e19-4170-a9c7-385c3acac265/relationships/owners"
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
DELETE /object_occurrence_relations/02194295-66c4-422b-bb34-3b6443322034/relationships/owners/ae9ddcd9-a783-4730-831b-9884f215f53c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 32de17a5-7144-4d4e-87ed-853699ac0ac3
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
X-Request-Id: 36652537-0a84-4402-be52-90316fbaa725
200 OK
```


```json
{
  "data": [
    {
      "id": "efeb7514-befd-4082-a07b-ea175ff7abba",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 3109010d6364",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "7463e027-9252-4fa4-9932-9274ec32af07",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=efeb7514-befd-4082-a07b-ea175ff7abba",
            "self": "/object_occurrence_relations/efeb7514-befd-4082-a07b-ea175ff7abba/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "1185cc04-1038-4e4d-9d57-5304fd02b89a",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=efeb7514-befd-4082-a07b-ea175ff7abba&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/efeb7514-befd-4082-a07b-ea175ff7abba/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "7463e027-9252-4fa4-9932-9274ec32af07",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=efeb7514-befd-4082-a07b-ea175ff7abba"
          }
        },
        "classification_entry": {
          "data": {
            "id": "b6214c94-c896-4348-b2c3-d7d376e38b1c",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b6214c94-c896-4348-b2c3-d7d376e38b1c",
            "self": "/object_occurrence_relations/efeb7514-befd-4082-a07b-ea175ff7abba/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "8aa5281f-ed54-4c0f-ba37-968cffc66355",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/8aa5281f-ed54-4c0f-ba37-968cffc66355",
            "self": "/object_occurrence_relations/efeb7514-befd-4082-a07b-ea175ff7abba/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "3591436e-7877-46cb-ad85-4623a330b8e7",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/3591436e-7877-46cb-ad85-4623a330b8e7",
            "self": "/object_occurrence_relations/efeb7514-befd-4082-a07b-ea175ff7abba/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "b6214c94-c896-4348-b2c3-d7d376e38b1c",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 12da31c4dbc8",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=b6214c94-c896-4348-b2c3-d7d376e38b1c",
            "self": "/classification_entries/b6214c94-c896-4348-b2c3-d7d376e38b1c/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=b6214c94-c896-4348-b2c3-d7d376e38b1c",
            "self": "/classification_entries/b6214c94-c896-4348-b2c3-d7d376e38b1c/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "1185cc04-1038-4e4d-9d57-5304fd02b89a",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 24",
        "title": null
      }
    },
    {
      "id": "01cd1ad1-6be8-4b14-889c-409297fde567",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "ea2c386e-16e6-4b15-8858-dae1ed488abe",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/ea2c386e-16e6-4b15-8858-dae1ed488abe"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/efeb7514-befd-4082-a07b-ea175ff7abba"
          }
        }
      }
    },
    {
      "id": "7463e027-9252-4fa4-9932-9274ec32af07",
      "type": "tag",
      "attributes": {
        "value": "tag value 26"
      },
      "relationships": {
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations",
    "current": "http://example.org/object_occurrence_relations?include=tags,owners,progress_step_checked,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Filter by object_occurrence_source_ids_cont and object_occurrence_target_ids_cont


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=1c925b0d-10d2-4606-b340-6c97d8cf981d&amp;filter[object_occurrence_source_ids_cont][]=95ba3ef2-3df4-4c72-bdce-5b166c0bf661&amp;filter[object_occurrence_target_ids_cont][]=6c694cfe-7904-4450-a3cb-1f0f333cbf6f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;1c925b0d-10d2-4606-b340-6c97d8cf981d&quot;, &quot;95ba3ef2-3df4-4c72-bdce-5b166c0bf661&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;6c694cfe-7904-4450-a3cb-1f0f333cbf6f&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ad3b81b5-c9bf-423c-99ca-fb611d9fc4a9
200 OK
```


```json
{
  "data": [
    {
      "id": "737e6fb6-bd9f-4b8e-896a-68bace46e256",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 6ed1c048105e",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "9e104012-5951-42ff-9d27-c2c0f9ee788b",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=737e6fb6-bd9f-4b8e-896a-68bace46e256",
            "self": "/object_occurrence_relations/737e6fb6-bd9f-4b8e-896a-68bace46e256/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "40e6c7d6-4bb4-49dd-8f03-c46257d8a4e4",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=737e6fb6-bd9f-4b8e-896a-68bace46e256&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/737e6fb6-bd9f-4b8e-896a-68bace46e256/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "9e104012-5951-42ff-9d27-c2c0f9ee788b",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=737e6fb6-bd9f-4b8e-896a-68bace46e256"
          }
        },
        "classification_entry": {
          "data": {
            "id": "79f55d1d-0e98-4f20-8383-8ab341a0693c",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/79f55d1d-0e98-4f20-8383-8ab341a0693c",
            "self": "/object_occurrence_relations/737e6fb6-bd9f-4b8e-896a-68bace46e256/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "6c694cfe-7904-4450-a3cb-1f0f333cbf6f",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6c694cfe-7904-4450-a3cb-1f0f333cbf6f",
            "self": "/object_occurrence_relations/737e6fb6-bd9f-4b8e-896a-68bace46e256/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "1c925b0d-10d2-4606-b340-6c97d8cf981d",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/1c925b0d-10d2-4606-b340-6c97d8cf981d",
            "self": "/object_occurrence_relations/737e6fb6-bd9f-4b8e-896a-68bace46e256/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "79f55d1d-0e98-4f20-8383-8ab341a0693c",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 02eedef7af33",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=79f55d1d-0e98-4f20-8383-8ab341a0693c",
            "self": "/classification_entries/79f55d1d-0e98-4f20-8383-8ab341a0693c/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=79f55d1d-0e98-4f20-8383-8ab341a0693c",
            "self": "/classification_entries/79f55d1d-0e98-4f20-8383-8ab341a0693c/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "40e6c7d6-4bb4-49dd-8f03-c46257d8a4e4",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 25",
        "title": null
      }
    },
    {
      "id": "927e1bad-b50f-436a-abe1-9a0ca457e600",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "ee7a8030-340a-485b-8191-75f460943de7",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/ee7a8030-340a-485b-8191-75f460943de7"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/737e6fb6-bd9f-4b8e-896a-68bace46e256"
          }
        }
      }
    },
    {
      "id": "9e104012-5951-42ff-9d27-c2c0f9ee788b",
      "type": "tag",
      "attributes": {
        "value": "tag value 27"
      },
      "relationships": {
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=1c925b0d-10d2-4606-b340-6c97d8cf981d&filter[object_occurrence_source_ids_cont][]=95ba3ef2-3df4-4c72-bdce-5b166c0bf661&filter[object_occurrence_target_ids_cont][]=6c694cfe-7904-4450-a3cb-1f0f333cbf6f",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=1c925b0d-10d2-4606-b340-6c97d8cf981d&filter[object_occurrence_source_ids_cont][]=95ba3ef2-3df4-4c72-bdce-5b166c0bf661&filter[object_occurrence_target_ids_cont][]=6c694cfe-7904-4450-a3cb-1f0f333cbf6f&include=tags,owners,progress_step_checked,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830
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
X-Request-Id: 3c06d381-f0a3-4ee3-b93a-987baa4bb13e
200 OK
```


```json
{
  "data": {
    "id": "868bf554-1f52-44e7-864d-db41c3db2830",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "OOR 0c433f60df9d",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "1fe43c9e-4205-412b-944b-d4ccc841a78c",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=868bf554-1f52-44e7-864d-db41c3db2830",
          "self": "/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "40f1fa1e-d629-42dd-80a4-145a8aab9a40",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=868bf554-1f52-44e7-864d-db41c3db2830&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "1fe43c9e-4205-412b-944b-d4ccc841a78c",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=868bf554-1f52-44e7-864d-db41c3db2830"
        }
      },
      "classification_entry": {
        "data": {
          "id": "50a448aa-7152-41d9-8c79-c5e69edfe7c9",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/50a448aa-7152-41d9-8c79-c5e69edfe7c9",
          "self": "/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "488cf8ae-1d5a-4038-a380-66683ee3ee4b",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/488cf8ae-1d5a-4038-a380-66683ee3ee4b",
          "self": "/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "d87e3d70-70a4-4279-9805-0d5108f97a33",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/d87e3d70-70a4-4279-9805-0d5108f97a33",
          "self": "/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830"
  },
  "included": [
    {
      "id": "50a448aa-7152-41d9-8c79-c5e69edfe7c9",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 3e598993dc6e",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=50a448aa-7152-41d9-8c79-c5e69edfe7c9",
            "self": "/classification_entries/50a448aa-7152-41d9-8c79-c5e69edfe7c9/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=50a448aa-7152-41d9-8c79-c5e69edfe7c9",
            "self": "/classification_entries/50a448aa-7152-41d9-8c79-c5e69edfe7c9/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "40f1fa1e-d629-42dd-80a4-145a8aab9a40",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 26",
        "title": null
      }
    },
    {
      "id": "a82a0e84-d5ae-46e6-b040-77c3c10eed8f",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "e74094b4-68f9-4713-8c00-850a078c1b43",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/e74094b4-68f9-4713-8c00-850a078c1b43"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/868bf554-1f52-44e7-864d-db41c3db2830"
          }
        }
      }
    },
    {
      "id": "1fe43c9e-4205-412b-944b-d4ccc841a78c",
      "type": "tag",
      "attributes": {
        "value": "tag value 28"
      },
      "relationships": {
      }
    }
  ]
}
```



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
X-Request-Id: cdd8344b-1c8b-4334-a8c7-f6094daa17f0
200 OK
```


```json
{
  "data": [
    {
      "id": "f783cc26165e280aa3eedbabf4a7f385d12333e9e2b7dcad5aec20d8742f80bb",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "32370bf6-a228-4c01-90f0-6342650d4804",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/32370bf6-a228-4c01-90f0-6342650d4804"
          }
        }
      }
    },
    {
      "id": "c4abf9d51d7a222574d00c5bbcac824a4ecd2da2ce46af34c975a9e046883a69",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "c0884add-5f7c-42b3-b44c-b26b6f4e2bf5",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/c0884add-5f7c-42b3-b44c-b26b6f4e2bf5"
          }
        }
      }
    },
    {
      "id": "c19debc765d6f55e403751d6abb920ab818f13179c3b3893d9aad9461ab07803",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "6c396b14-2a4c-4484-81ef-c42990165e91",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/6c396b14-2a4c-4484-81ef-c42990165e91"
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



# User permissions

Manage the user's permissions for various resources.


## List


### Request

#### Endpoint

```plaintext
GET /user_permissions
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6e04bb3a-5b37-438f-9b2b-577406d1bc66
200 OK
```


```json
{
  "data": [
    {
      "id": "f3e760e2-a2b5-478a-b162-97a8edde1c6f",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "fcc30ecf-22b3-4713-8e22-3009e0311d66",
            "type": "project"
          },
          "links": {
            "related": "/projects/fcc30ecf-22b3-4713-8e22-3009e0311d66"
          }
        },
        "user": {
          "data": {
            "id": "a8610e9f-ee6c-4f8f-89ce-9b30f9836e14",
            "type": "user"
          },
          "links": {
            "related": "/users/a8610e9f-ee6c-4f8f-89ce-9b30f9836e14"
          }
        },
        "permission": {
          "data": {
            "id": "e858aae7-20eb-423d-b9ab-5312971ada26",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/e858aae7-20eb-423d-b9ab-5312971ada26"
          }
        }
      }
    },
    {
      "id": "45bf810e-23de-44a5-a7cb-56df1f2db220",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "50c66643-ce49-4d81-9a75-ca5db69eff20",
            "type": "context"
          },
          "links": {
            "related": "/contexts/50c66643-ce49-4d81-9a75-ca5db69eff20"
          }
        },
        "user": {
          "data": {
            "id": "a8610e9f-ee6c-4f8f-89ce-9b30f9836e14",
            "type": "user"
          },
          "links": {
            "related": "/users/a8610e9f-ee6c-4f8f-89ce-9b30f9836e14"
          }
        },
        "permission": {
          "data": {
            "id": "b10305a2-5fdf-4b8b-9dcc-887a1a6b05ce",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/b10305a2-5fdf-4b8b-9dcc-887a1a6b05ce"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/user_permissions",
    "current": "http://example.org/user_permissions?page[number]=1"
  }
}
```



## Filter


### Request

#### Endpoint

```plaintext
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=9a6e4a5a-c8ba-402f-89b1-0098aa2b99f2&amp;filter[user_id_eq]=8bc871e0-facf-4146-8b89-6f50d7bf1b6d&amp;filter[permission_id_eq]=bfa88365-bc85-40e5-8f57-65bae933f512
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;9a6e4a5a-c8ba-402f-89b1-0098aa2b99f2&quot;, &quot;user_id_eq&quot;=&gt;&quot;8bc871e0-facf-4146-8b89-6f50d7bf1b6d&quot;, &quot;permission_id_eq&quot;=&gt;&quot;bfa88365-bc85-40e5-8f57-65bae933f512&quot;}
```


| Name | Description |
|:-----|:------------|
| filter[target_type_eq]  | Filter target type eq |
| filter[target_id_eq]  | Filter target id eq |
| filter[user_id_eq]  | Filter user id eq |
| filter[permission_id_eq]  | Filter permission id eq |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f3545106-9fb8-4082-ac6c-25abed038ce3
200 OK
```


```json
{
  "data": [
    {
      "id": "1712253d-3747-4d66-8542-8362f58c9152",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "9a6e4a5a-c8ba-402f-89b1-0098aa2b99f2",
            "type": "project"
          },
          "links": {
            "related": "/projects/9a6e4a5a-c8ba-402f-89b1-0098aa2b99f2"
          }
        },
        "user": {
          "data": {
            "id": "8bc871e0-facf-4146-8b89-6f50d7bf1b6d",
            "type": "user"
          },
          "links": {
            "related": "/users/8bc871e0-facf-4146-8b89-6f50d7bf1b6d"
          }
        },
        "permission": {
          "data": {
            "id": "bfa88365-bc85-40e5-8f57-65bae933f512",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/bfa88365-bc85-40e5-8f57-65bae933f512"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/user_permissions?filter[target_type_eq]=project&filter[target_id_eq]=9a6e4a5a-c8ba-402f-89b1-0098aa2b99f2&filter[user_id_eq]=8bc871e0-facf-4146-8b89-6f50d7bf1b6d&filter[permission_id_eq]=bfa88365-bc85-40e5-8f57-65bae933f512",
    "current": "http://example.org/user_permissions?filter[permission_id_eq]=bfa88365-bc85-40e5-8f57-65bae933f512&filter[target_id_eq]=9a6e4a5a-c8ba-402f-89b1-0098aa2b99f2&filter[target_type_eq]=project&filter[user_id_eq]=8bc871e0-facf-4146-8b89-6f50d7bf1b6d&page[number]=1"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /user_permissions/899d9694-0187-4f7e-a921-468e01aefc74
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 088659c8-5418-4c7c-8247-0d6815135365
200 OK
```


```json
{
  "data": {
    "id": "899d9694-0187-4f7e-a921-468e01aefc74",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "d82888bb-26db-458d-a5d8-afd75af271d0",
          "type": "project"
        },
        "links": {
          "related": "/projects/d82888bb-26db-458d-a5d8-afd75af271d0"
        }
      },
      "user": {
        "data": {
          "id": "b873a478-be66-4187-8ffd-51cb2f68664e",
          "type": "user"
        },
        "links": {
          "related": "/users/b873a478-be66-4187-8ffd-51cb2f68664e"
        }
      },
      "permission": {
        "data": {
          "id": "1a713afe-d02c-4e91-898c-28204e6339ec",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/1a713afe-d02c-4e91-898c-28204e6339ec"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions/899d9694-0187-4f7e-a921-468e01aefc74"
  }
}
```



## Assign permission


### Request

#### Endpoint

```plaintext
POST /user_permissions
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /user_permissions`

#### Parameters


```json
{
  "data": {
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "type": "project",
          "id": "079fc859-6522-43ed-8ada-03d80a0f5b72"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "729f934a-4805-4599-a083-2d20fa107ca2"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "426a5d47-e195-4819-a336-f41a50e0d2f2"
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
X-Request-Id: 15a376da-cfcd-4419-8002-dd2ed16a2bb2
201 Created
```


```json
{
  "data": {
    "id": "2f735b69-6c8a-4e59-9a0e-6bf29d141e5a",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "079fc859-6522-43ed-8ada-03d80a0f5b72",
          "type": "project"
        },
        "links": {
          "related": "/projects/079fc859-6522-43ed-8ada-03d80a0f5b72"
        }
      },
      "user": {
        "data": {
          "id": "426a5d47-e195-4819-a336-f41a50e0d2f2",
          "type": "user"
        },
        "links": {
          "related": "/users/426a5d47-e195-4819-a336-f41a50e0d2f2"
        }
      },
      "permission": {
        "data": {
          "id": "729f934a-4805-4599-a083-2d20fa107ca2",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/729f934a-4805-4599-a083-2d20fa107ca2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions"
  }
}
```



## Remove permission


### Request

#### Endpoint

```plaintext
DELETE /user_permissions/e37b2d39-696b-49ce-ab9a-67dce7ec879d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9842e088-8c10-4b03-82b3-dd25ed0a9aca
204 No Content
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
X-Request-Id: f001a9f6-a76e-4979-96ca-f965af712749
200 OK
```


```json
{
  "data": {
    "id": "4423fd37-71ab-41d0-9b6f-b29878645a56",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "5f130a85-f1ac-4c30-9cc0-e3d8da133c03"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/5f130a85-f1ac-4c30-9cc0-e3d8da133c03"
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
X-Request-Id: b4394d41-a30b-4f9d-b228-e20c0ce3e2e4
200 OK
```


```json
{
  "data": {
    "id": "5cfb1a13-9108-44c9-b12f-1fa47fca342c",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "eeb5aa68-48d7-441d-a34d-8044d843bc76"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/eeb5aa68-48d7-441d-a34d-8044d843bc76"
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
GET /chain_analysis/4e4c6638-1797-4b36-a157-372ac1079e0d?steps=2
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
X-Request-Id: c6bd7541-69bb-4126-929c-e697b89eab2f
200 OK
```


```json
{
  "data": [
    {
      "id": "6da09a36-10d9-409a-b39a-b14f8b63082a",
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
            "related": "/tags?filter[target_id_eq]=6da09a36-10d9-409a-b39a-b14f8b63082a",
            "self": "/object_occurrences/6da09a36-10d9-409a-b39a-b14f8b63082a/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=6da09a36-10d9-409a-b39a-b14f8b63082a&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/6da09a36-10d9-409a-b39a-b14f8b63082a/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=6da09a36-10d9-409a-b39a-b14f8b63082a"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/35dbf588-a08a-46a0-86b5-55a5d3ba3ee7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ef9bc3bc-1f17-4d39-bd81-b85d0eb6cca6",
            "self": "/object_occurrences/6da09a36-10d9-409a-b39a-b14f8b63082a/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/6da09a36-10d9-409a-b39a-b14f8b63082a/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=6da09a36-10d9-409a-b39a-b14f8b63082a"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=6da09a36-10d9-409a-b39a-b14f8b63082a"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=6da09a36-10d9-409a-b39a-b14f8b63082a"
          }
        }
      }
    },
    {
      "id": "9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42",
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
            "related": "/tags?filter[target_id_eq]=9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42",
            "self": "/object_occurrences/9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/35dbf588-a08a-46a0-86b5-55a5d3ba3ee7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ef9bc3bc-1f17-4d39-bd81-b85d0eb6cca6",
            "self": "/object_occurrences/9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=9db3fdbb-ff8d-4ca7-b0f3-d0ce4bc77a42"
          }
        }
      }
    },
    {
      "id": "6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff",
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
            "related": "/tags?filter[target_id_eq]=6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff",
            "self": "/object_occurrences/6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/35dbf588-a08a-46a0-86b5-55a5d3ba3ee7"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ef9bc3bc-1f17-4d39-bd81-b85d0eb6cca6",
            "self": "/object_occurrences/6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=6a9bd5bf-0215-43e6-98a2-6ab9c3ada6ff"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/chain_analysis/4e4c6638-1797-4b36-a157-372ac1079e0d?steps=2",
    "current": "http://example.org/chain_analysis/4e4c6638-1797-4b36-a157-372ac1079e0d?page[number]=1&steps=2"
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
X-Request-Id: e8c78c23-1e3c-431e-b7b8-f15d793348bd
200 OK
```


```json
{
  "data": [
    {
      "id": "e7f21612-411d-4def-8238-08c8b3c13442",
      "type": "tag",
      "attributes": {
        "value": "tag value 29"
      },
      "relationships": {
      }
    },
    {
      "id": "f6b122cd-8f3c-4561-b56a-0c76dcbc9c97",
      "type": "tag",
      "attributes": {
        "value": "tag value 30"
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
X-Request-Id: e9d7e718-4e8c-444c-9381-fc9117a7ddea
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


## Show


### Request

#### Endpoint

```plaintext
GET /permissions/19b5baa8-a783-4381-8bae-78454452ebdc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /permissions/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c604d809-8d2b-4629-b114-9dba5117ecd3
200 OK
```


```json
{
  "data": {
    "id": "19b5baa8-a783-4381-8bae-78454452ebdc",
    "type": "permission",
    "attributes": {
      "name": "account:write",
      "description": "MyText"
    }
  },
  "links": {
    "self": "http://example.org/permissions/19b5baa8-a783-4381-8bae-78454452ebdc"
  }
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
GET /utils/path/from/object_occurrence/d2887bac-f2b8-465a-a50b-db982437a3dc/to/object_occurrence/8937af21-2530-4c35-bf88-5790f5a59070
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
X-Request-Id: 62d6cdfc-3422-4551-be65-e2f11f41f4be
200 OK
```


```json
[
  {
    "id": "d2887bac-f2b8-465a-a50b-db982437a3dc",
    "type": "object_occurrence"
  },
  {
    "id": "4b94203c-5588-4a2b-a89c-bd7e467003c9",
    "type": "object_occurrence"
  },
  {
    "id": "0f3625f7-f45c-42a9-8f7d-ed9bbd15f6b5",
    "type": "object_occurrence"
  },
  {
    "id": "848aac12-7af1-4737-832a-8b019c36fe5a",
    "type": "object_occurrence"
  },
  {
    "id": "aad30230-e34e-43f0-b46d-74019ecb6432",
    "type": "object_occurrence"
  },
  {
    "id": "cfec0a4f-cb78-40d3-b138-14f19fb62a08",
    "type": "object_occurrence"
  },
  {
    "id": "8937af21-2530-4c35-bf88-5790f5a59070",
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
X-Request-Id: 5df2e476-cbbe-4f04-b38d-ccc336c46d25
200 OK
```


```json
{
  "data": [
    {
      "id": "6eec3da5-7f1e-42a7-a15a-c2ff06f670f0",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/a6928a9f-0e04-4511-9985-da0254982e69"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/e1b99c57-dba6-4f4c-a98f-506833df26f6"
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
X-Request-Id: b40c3925-f5ee-4d44-869c-5bb1acdd5892
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



