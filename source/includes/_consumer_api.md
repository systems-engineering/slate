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

## Rate limiting

All the API endpoints are rate limited.

This means that clients may receive a 429 Too Many Requests error if exceeding the rate limit.

```
GET /

200 OK
X-RateLimit-Limit: 1000,
X-RateLimit-Remaining: 998,
```

This example response informs the client that there are 1000 tokens in total for this endpoint,
and that there is 998 tokens left.

```
GET /

429 Too Many Requests
Content-Type: "text/plain",
Retry-After: 38,
```

This example response informs the client to wait 38 seconds before retrying the request.

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
X-Request-Id: 42ec9a93-ec67-4d8f-8570-d299e5c15072
200 OK
```


```json
{
  "data": {
    "id": "e881eb66-d96a-4059-b364-ebc9e721e0f3",
    "type": "account",
    "attributes": {
      "name": "Account 1a7f5e7ff9d6"
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
X-Request-Id: d373d9c8-3970-437a-8b22-0aed71cd5624
200 OK
```


```json
{
  "data": {
    "id": "6c4bf62c-aa1c-41cf-a463-aec816308f10",
    "type": "account",
    "attributes": {
      "name": "Account 809a2c941e6f"
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
    "id": "47f31355-f50b-4a1c-931a-df6b1c94894b",
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
X-Request-Id: 35b24dba-9996-4783-8310-aa5e80c5a8f2
200 OK
```


```json
{
  "data": {
    "id": "47f31355-f50b-4a1c-931a-df6b1c94894b",
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
X-Request-Id: d38cc117-cb42-4d16-87a6-c051a0f1ac3f
200 OK
```


```json
{
  "data": [
    {
      "id": "3477c9bc-d7d9-41bc-9411-e46447ac32d2",
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
              "id": "50d462f2-1f5d-4dec-8eab-e4c57be4dd2e",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=3477c9bc-d7d9-41bc-9411-e46447ac32d2"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=3477c9bc-d7d9-41bc-9411-e46447ac32d2",
            "self": "/projects/3477c9bc-d7d9-41bc-9411-e46447ac32d2/relationships/contexts"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "50d462f2-1f5d-4dec-8eab-e4c57be4dd2e",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "abe94eac-2845-4006-a12e-cc5455e77815",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/abe94eac-2845-4006-a12e-cc5455e77815"
          }
        },
        "target": {
          "links": {
            "related": "/projects/3477c9bc-d7d9-41bc-9411-e46447ac32d2"
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
GET /projects/f8291961-34d9-4a31-a007-811b2507e91d
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
X-Request-Id: a3ddf789-b68a-4196-86af-5c50d97151cc
200 OK
```


```json
{
  "data": {
    "id": "f8291961-34d9-4a31-a007-811b2507e91d",
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
            "id": "ddc47d3c-0fd6-4499-b7fd-9171deefb7ef",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=f8291961-34d9-4a31-a007-811b2507e91d"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=f8291961-34d9-4a31-a007-811b2507e91d",
          "self": "/projects/f8291961-34d9-4a31-a007-811b2507e91d/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/f8291961-34d9-4a31-a007-811b2507e91d"
  },
  "included": [
    {
      "id": "ddc47d3c-0fd6-4499-b7fd-9171deefb7ef",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "ef366782-2e79-4dbc-8b76-d38ff47dcb5c",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/ef366782-2e79-4dbc-8b76-d38ff47dcb5c"
          }
        },
        "target": {
          "links": {
            "related": "/projects/f8291961-34d9-4a31-a007-811b2507e91d"
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
PATCH /projects/234d885a-a7c6-4428-9135-57538d73b5b2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "234d885a-a7c6-4428-9135-57538d73b5b2",
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
X-Request-Id: b286e78c-5792-4fd8-b7b6-f37f17675b23
200 OK
```


```json
{
  "data": {
    "id": "234d885a-a7c6-4428-9135-57538d73b5b2",
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
            "id": "685eb767-42b0-4a60-9054-a05325b2f85f",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=234d885a-a7c6-4428-9135-57538d73b5b2"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=234d885a-a7c6-4428-9135-57538d73b5b2",
          "self": "/projects/234d885a-a7c6-4428-9135-57538d73b5b2/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/234d885a-a7c6-4428-9135-57538d73b5b2"
  },
  "included": [
    {
      "id": "685eb767-42b0-4a60-9054-a05325b2f85f",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "476c85bf-5368-4315-ad75-df2eb9546a8e",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/476c85bf-5368-4315-ad75-df2eb9546a8e"
          }
        },
        "target": {
          "links": {
            "related": "/projects/234d885a-a7c6-4428-9135-57538d73b5b2"
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
POST /projects/7cbb2e56-fb41-4873-9134-8a423a05eca8/archive
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
X-Request-Id: 71c5394d-3618-42b1-96a3-fdbb5d410c99
200 OK
```


```json
{
  "data": {
    "id": "7cbb2e56-fb41-4873-9134-8a423a05eca8",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-16T12:39:15.271Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "2238b7c9-3eaf-4f80-a168-fb2b370a8d7b",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=7cbb2e56-fb41-4873-9134-8a423a05eca8"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=7cbb2e56-fb41-4873-9134-8a423a05eca8",
          "self": "/projects/7cbb2e56-fb41-4873-9134-8a423a05eca8/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7cbb2e56-fb41-4873-9134-8a423a05eca8/archive"
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
DELETE /projects/ba6259e5-c07d-4f04-be0c-5a4afdbfc0e0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0a6db313-d25e-456f-9d40-08448d1b808e
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
X-Request-Id: 8636a436-1760-42c5-bafe-6b3e1f04deec
200 OK
```


```json
{
  "data": [
    {
      "id": "35632d0d-eeed-4194-9a2b-c427ee974353",
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
              "id": "60e339d3-f6fa-4ca6-b39b-31494311caf4",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=35632d0d-eeed-4194-9a2b-c427ee974353"
          }
        },
        "project": {
          "links": {
            "related": "/projects/f342a07a-e833-4e88-9a50-a39f2af8c19f"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/c80e0451-9e92-4b59-8ad7-fbc7036a1942"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/76aee272-e459-4843-abbb-9a8d45d14609"
          }
        }
      }
    },
    {
      "id": "7d2cfcb6-5af3-4ff8-ae81-83130e54a2bf",
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
            "related": "/progress?filter[target_id_eq]=7d2cfcb6-5af3-4ff8-ae81-83130e54a2bf"
          }
        },
        "project": {
          "links": {
            "related": "/projects/f342a07a-e833-4e88-9a50-a39f2af8c19f"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/b8382147-ce0f-48ea-8ad5-d459bc844b8b"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/76aee272-e459-4843-abbb-9a8d45d14609"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "60e339d3-f6fa-4ca6-b39b-31494311caf4",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "a13cc485-d618-46ca-bc69-854988c8b4eb",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/a13cc485-d618-46ca-bc69-854988c8b4eb"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/35632d0d-eeed-4194-9a2b-c427ee974353"
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
GET /contexts/519e36cf-908e-4cb7-8af6-ebe643e7d75c
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
X-Request-Id: d618c5c8-091c-4620-b0b3-8cba8da3d71f
200 OK
```


```json
{
  "data": {
    "id": "519e36cf-908e-4cb7-8af6-ebe643e7d75c",
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
            "id": "4eee09b2-7b8b-425d-a42d-e36b7a8d8fab",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=519e36cf-908e-4cb7-8af6-ebe643e7d75c"
        }
      },
      "project": {
        "links": {
          "related": "/projects/e9e68474-e257-4a4a-9802-e00d80660ed1"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/7fe1a506-4151-4e03-8122-2e017a40a062"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/4c27ab19-7917-4dad-a7cd-5519b54dbd21"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/519e36cf-908e-4cb7-8af6-ebe643e7d75c"
  },
  "included": [
    {
      "id": "4eee09b2-7b8b-425d-a42d-e36b7a8d8fab",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "08811fc7-a42c-4505-9539-4b6a57f35660",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/08811fc7-a42c-4505-9539-4b6a57f35660"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/519e36cf-908e-4cb7-8af6-ebe643e7d75c"
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
PATCH /contexts/87bfa1eb-3ce7-4d1f-95dc-aa2d9edb2733
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "87bfa1eb-3ce7-4d1f-95dc-aa2d9edb2733",
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
X-Request-Id: 0618d4d5-499c-46fc-a981-f7f8d732f565
200 OK
```


```json
{
  "data": {
    "id": "87bfa1eb-3ce7-4d1f-95dc-aa2d9edb2733",
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
            "id": "b0c2a0a1-932c-4125-9094-7455d8ca00f4",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=87bfa1eb-3ce7-4d1f-95dc-aa2d9edb2733"
        }
      },
      "project": {
        "links": {
          "related": "/projects/62ea0ca3-71f8-4cad-add5-393db7da84a3"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/6b7ffd58-8d45-4d59-a09e-a3aae01f33bd"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/71e6b092-bad1-4bf8-b1ee-5841f4de57c9"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/87bfa1eb-3ce7-4d1f-95dc-aa2d9edb2733"
  },
  "included": [
    {
      "id": "b0c2a0a1-932c-4125-9094-7455d8ca00f4",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "7afb5b22-58f3-4f9a-90d1-867a434bbcc3",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/7afb5b22-58f3-4f9a-90d1-867a434bbcc3"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/87bfa1eb-3ce7-4d1f-95dc-aa2d9edb2733"
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
POST /projects/633c8886-71da-4a4f-bd64-720488e3d6cc/relationships/contexts
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
          "id": "5b7c3f25-18e0-44ec-958e-93477a890a65"
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
X-Request-Id: 7affd529-82aa-4c86-bb49-41cfa166c565
201 Created
```


```json
{
  "data": {
    "id": "629d865c-ab1e-4961-bd74-c8c3859c8c87",
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
          "related": "/progress?filter[target_id_eq]=629d865c-ab1e-4961-bd74-c8c3859c8c87"
        }
      },
      "project": {
        "links": {
          "related": "/projects/633c8886-71da-4a4f-bd64-720488e3d6cc"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/a8bd37cf-2645-4dcf-ae9c-89afcf47f27d"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/5b7c3f25-18e0-44ec-958e-93477a890a65"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/633c8886-71da-4a4f-bd64-720488e3d6cc/relationships/contexts"
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
POST /contexts/050b948d-b559-455f-92bb-07544dcfbfa2/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/8b280c976e2964bff6a556dc
Content-Type: text/html; charset=utf-8
X-Request-Id: 5cb9863d-6896-478c-bc91-ec98c7dc821c
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/8b280c976e2964bff6a556dc">redirected</a>.</body></html>
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
DELETE /contexts/5783255a-a2a7-4788-b0c1-086d740e8d49
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 35f2e1a8-b4a5-4ae2-80bf-9da7500434cd
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
POST /object_occurrences/e11b13e3-9677-48f5-9120-72be738deade/relationships/tags
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
X-Request-Id: 36535a73-f93f-4360-94dd-74a6a1a5e961
201 Created
```


```json
{
  "data": {
    "id": "73bdd666-e180-4e24-a500-c1229e0b9c8c",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/e11b13e3-9677-48f5-9120-72be738deade/relationships/tags"
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
POST /object_occurrences/652f838b-0282-4aa9-bbdd-c0f1f9251fc0/relationships/tags
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
    "id": "6ebd9aa6-a939-41ee-ba2f-451ec26e6d90"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 49e18219-952a-4877-8a07-31086203ecf2
201 Created
```


```json
{
  "data": {
    "id": "6ebd9aa6-a939-41ee-ba2f-451ec26e6d90",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/652f838b-0282-4aa9-bbdd-c0f1f9251fc0/relationships/tags"
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
DELETE /object_occurrences/028e899e-f67d-4e18-a5eb-f8bcc7f1292b/relationships/tags/b20fbaf7-1fdb-45ad-b4ef-a49dd59c1b40
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f206715c-a713-45b9-948f-dcdb6c41e48d
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/418a93c7-e424-4e35-b405-05d3be0e0b20/relationships/owners
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
X-Request-Id: b21e5621-631f-4536-ad2f-4e29c2896d32
201 Created
```


```json
{
  "data": {
    "id": "98f32549-8a19-41f2-8fd4-24fb69dfa6aa",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/418a93c7-e424-4e35-b405-05d3be0e0b20/relationships/owners"
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
POST /object_occurrences/a140da0d-2dbb-40c5-8310-df8d81bd6253/relationships/owners
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
X-Request-Id: 044bec12-3f4b-46c4-b11e-5c3a480ad842
201 Created
```


```json
{
  "data": {
    "id": "4cb2d8fe-866b-4ac1-831d-2bf78eb8f6aa",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a140da0d-2dbb-40c5-8310-df8d81bd6253/relationships/owners"
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
POST /object_occurrences/48750dab-e7d6-49a7-ae3d-5629f7cd1c74/relationships/owners
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
    "id": "6e803d3f-8589-4188-80b8-852197940fb3"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4766d770-5d55-4d18-b9c8-63d3ba51c5d8
201 Created
```


```json
{
  "data": {
    "id": "6e803d3f-8589-4188-80b8-852197940fb3",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 7",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/48750dab-e7d6-49a7-ae3d-5629f7cd1c74/relationships/owners"
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
DELETE /object_occurrences/4d9a2183-0567-4732-9619-8da7878d37ac/relationships/owners/8ce067f6-44c1-4d1c-908e-8200456f3563
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8e3d3973-b614-4b40-b22f-91fabd58d60e
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
X-Request-Id: 0ab020c6-456f-40c4-ba76-5ade43ca1a37
200 OK
```


```json
{
  "data": [
    {
      "id": "12c3c185-9e62-4d2b-900c-950bdaffdf4b",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC 1",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "54385b",
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "dbf9ed15-2384-448b-ba91-82145033c59a",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=12c3c185-9e62-4d2b-900c-950bdaffdf4b",
            "self": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "c77e7f5b-959d-4542-a2e9-292e00317419",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=12c3c185-9e62-4d2b-900c-950bdaffdf4b&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "ee1dd3e3-25dc-462c-a9ad-bbe4d52debdb",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=12c3c185-9e62-4d2b-900c-950bdaffdf4b"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffbd5998-3eea-4f66-bdd8-4e6e38a65e02"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/fc15b7a2-c144-4b46-a707-1cbdf94860e1",
            "self": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/3123e192-43b7-4c7f-9f27-15752749d0d2"
          }
        },
        "components": {
          "data": [
            {
              "id": "9651e885-038c-423a-a224-9d359ee2f981",
              "type": "object_occurrence"
            },
            {
              "id": "5ae781ac-78cf-485c-8bc5-028c7da36b62",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "96fd0de3-0e16-43c8-9f5c-02f173164086",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=12c3c185-9e62-4d2b-900c-950bdaffdf4b"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=12c3c185-9e62-4d2b-900c-950bdaffdf4b"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=12c3c185-9e62-4d2b-900c-950bdaffdf4b"
          }
        }
      }
    },
    {
      "id": "5ae781ac-78cf-485c-8bc5-028c7da36b62",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC 2",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "54385b",
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "XYZ"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=5ae781ac-78cf-485c-8bc5-028c7da36b62",
            "self": "/object_occurrences/5ae781ac-78cf-485c-8bc5-028c7da36b62/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=5ae781ac-78cf-485c-8bc5-028c7da36b62&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/5ae781ac-78cf-485c-8bc5-028c7da36b62/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=5ae781ac-78cf-485c-8bc5-028c7da36b62"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffbd5998-3eea-4f66-bdd8-4e6e38a65e02"
          }
        },
        "classification_table": {
          "data": {
            "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b",
            "self": "/object_occurrences/5ae781ac-78cf-485c-8bc5-028c7da36b62/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/3123e192-43b7-4c7f-9f27-15752749d0d2"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/5ae781ac-78cf-485c-8bc5-028c7da36b62/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "96fd0de3-0e16-43c8-9f5c-02f173164086",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=5ae781ac-78cf-485c-8bc5-028c7da36b62"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=5ae781ac-78cf-485c-8bc5-028c7da36b62"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=5ae781ac-78cf-485c-8bc5-028c7da36b62"
          }
        }
      }
    },
    {
      "id": "9651e885-038c-423a-a224-9d359ee2f981",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC 2a",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "54385b",
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=9651e885-038c-423a-a224-9d359ee2f981",
            "self": "/object_occurrences/9651e885-038c-423a-a224-9d359ee2f981/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=9651e885-038c-423a-a224-9d359ee2f981&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/9651e885-038c-423a-a224-9d359ee2f981/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=9651e885-038c-423a-a224-9d359ee2f981"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffbd5998-3eea-4f66-bdd8-4e6e38a65e02"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b",
            "self": "/object_occurrences/9651e885-038c-423a-a224-9d359ee2f981/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/3123e192-43b7-4c7f-9f27-15752749d0d2"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/9651e885-038c-423a-a224-9d359ee2f981/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "96fd0de3-0e16-43c8-9f5c-02f173164086",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=9651e885-038c-423a-a224-9d359ee2f981"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=9651e885-038c-423a-a224-9d359ee2f981"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=9651e885-038c-423a-a224-9d359ee2f981"
          }
        }
      }
    },
    {
      "id": "6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC 3",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "54385b",
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2",
            "self": "/object_occurrences/6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/3fb9c34d-7d6c-46dc-b55e-6b5382299ed2"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/2793147d-81fc-4351-97a4-6e5737645040",
            "self": "/object_occurrences/6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/3123e192-43b7-4c7f-9f27-15752749d0d2"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "96fd0de3-0e16-43c8-9f5c-02f173164086",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2"
          }
        }
      }
    },
    {
      "id": "2793147d-81fc-4351-97a4-6e5737645040",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "ObjectOccurrence 96ec2c5e2cae",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=2793147d-81fc-4351-97a4-6e5737645040",
            "self": "/object_occurrences/2793147d-81fc-4351-97a4-6e5737645040/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=2793147d-81fc-4351-97a4-6e5737645040&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/2793147d-81fc-4351-97a4-6e5737645040/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=2793147d-81fc-4351-97a4-6e5737645040"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/3fb9c34d-7d6c-46dc-b55e-6b5382299ed2"
          }
        },
        "components": {
          "data": [
            {
              "id": "6e46410d-abbb-4cf1-9e6e-e6f01f25a7b2",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/2793147d-81fc-4351-97a4-6e5737645040/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "96fd0de3-0e16-43c8-9f5c-02f173164086",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=2793147d-81fc-4351-97a4-6e5737645040"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=2793147d-81fc-4351-97a4-6e5737645040"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=2793147d-81fc-4351-97a4-6e5737645040"
          }
        }
      }
    },
    {
      "id": "fc15b7a2-c144-4b46-a707-1cbdf94860e1",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "ObjectOccurrence b048646664e5",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=fc15b7a2-c144-4b46-a707-1cbdf94860e1",
            "self": "/object_occurrences/fc15b7a2-c144-4b46-a707-1cbdf94860e1/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=fc15b7a2-c144-4b46-a707-1cbdf94860e1&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/fc15b7a2-c144-4b46-a707-1cbdf94860e1/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=fc15b7a2-c144-4b46-a707-1cbdf94860e1"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffbd5998-3eea-4f66-bdd8-4e6e38a65e02"
          }
        },
        "components": {
          "data": [
            {
              "id": "12c3c185-9e62-4d2b-900c-950bdaffdf4b",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/fc15b7a2-c144-4b46-a707-1cbdf94860e1/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "96fd0de3-0e16-43c8-9f5c-02f173164086",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=fc15b7a2-c144-4b46-a707-1cbdf94860e1"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=fc15b7a2-c144-4b46-a707-1cbdf94860e1"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=fc15b7a2-c144-4b46-a707-1cbdf94860e1"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "c77e7f5b-959d-4542-a2e9-292e00317419",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 10",
        "title": null
      }
    },
    {
      "id": "ee1dd3e3-25dc-462c-a9ad-bbe4d52debdb",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "71bac8d4-c548-479c-aa75-2f5ec52eb3d5",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/71bac8d4-c548-479c-aa75-2f5ec52eb3d5"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/12c3c185-9e62-4d2b-900c-950bdaffdf4b"
          }
        }
      }
    },
    {
      "id": "3123e192-43b7-4c7f-9f27-15752749d0d2",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 8",
        "hex_color": "54385b"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/6fef5342-4f47-49bc-a720-a3318e0a55cd"
          }
        },
        "classification_table": {
          "data": {
            "id": "2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/2bf2c0fc-23c7-4245-98b1-bd4c7be69fc3",
            "self": "/syntax_elements/3123e192-43b7-4c7f-9f27-15752749d0d2/relationships/classification_table"
          }
        }
      }
    },
    {
      "id": "dbf9ed15-2384-448b-ba91-82145033c59a",
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
    "current": "http://example.org/object_occurrences?include=tags,owners,progress_step_checked,syntax_element&page[number]=1&sort=name,number"
  }
}
```



## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/60e84905-f7ce-425e-98f3-af485069470d
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
X-Request-Id: 5041c711-fedb-4d49-b823-490807d8e349
200 OK
```


```json
{
  "data": {
    "id": "60e84905-f7ce-425e-98f3-af485069470d",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "image_key": null,
      "name": "OOC 1",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "3c6d2b",
      "number": "1",
      "validation_errors": [

      ],
      "classification_code": "A"
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "680f423a-c09b-498c-9c97-24986e1c154e",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=60e84905-f7ce-425e-98f3-af485069470d",
          "self": "/object_occurrences/60e84905-f7ce-425e-98f3-af485069470d/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "57270234-930b-4be4-948a-4856c2a9e3ec",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=60e84905-f7ce-425e-98f3-af485069470d&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/60e84905-f7ce-425e-98f3-af485069470d/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "fdb93ce2-356b-4174-a322-e749d1c29145",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=60e84905-f7ce-425e-98f3-af485069470d"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/6ee29adb-63bc-4073-90fe-44e4a4cc9d86"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/3bcb5861-701d-4c6b-ae6b-80dd1f6e9b9a",
          "self": "/object_occurrences/60e84905-f7ce-425e-98f3-af485069470d/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "e88d9a98-cd6c-44c7-ae08-612b268e75d2",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/e88d9a98-cd6c-44c7-ae08-612b268e75d2"
        }
      },
      "components": {
        "data": [
          {
            "id": "88a09eb0-2e1b-41ae-aeb3-874d740f5edf",
            "type": "object_occurrence"
          },
          {
            "id": "17634de2-0720-40f4-a566-8959c2169929",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/60e84905-f7ce-425e-98f3-af485069470d/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "cfac0a0d-1c28-407d-8abf-7c2cbe926a63",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=60e84905-f7ce-425e-98f3-af485069470d"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "e88d9a98-cd6c-44c7-ae08-612b268e75d2",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=60e84905-f7ce-425e-98f3-af485069470d"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "65383923-bbc3-4389-a8dd-d679aa80445e",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=60e84905-f7ce-425e-98f3-af485069470d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/60e84905-f7ce-425e-98f3-af485069470d"
  },
  "included": [
    {
      "id": "57270234-930b-4be4-948a-4856c2a9e3ec",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 12",
        "title": null
      }
    },
    {
      "id": "fdb93ce2-356b-4174-a322-e749d1c29145",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "4dc2966f-dfe8-4e80-bcb4-dae2fe0267f3",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/4dc2966f-dfe8-4e80-bcb4-dae2fe0267f3"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/60e84905-f7ce-425e-98f3-af485069470d"
          }
        }
      }
    },
    {
      "id": "e88d9a98-cd6c-44c7-ae08-612b268e75d2",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 10",
        "hex_color": "3c6d2b"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/4aef7b86-ec80-450d-afc9-e8e73c74db03"
          }
        },
        "classification_table": {
          "data": {
            "id": "65383923-bbc3-4389-a8dd-d679aa80445e",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/65383923-bbc3-4389-a8dd-d679aa80445e",
            "self": "/syntax_elements/e88d9a98-cd6c-44c7-ae08-612b268e75d2/relationships/classification_table"
          }
        }
      }
    },
    {
      "id": "680f423a-c09b-498c-9c97-24986e1c154e",
      "type": "tag",
      "attributes": {
        "value": "tag value 12"
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
| data[attributes][image_url] | Url to image stored with OOC |
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
POST /object_occurrences/50428330-8ad9-4f98-9113-6fe00b6f5501/relationships/components
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
X-Request-Id: 0dd3b681-8ad8-4758-b980-30dfe7242e99
201 Created
```


```json
{
  "data": {
    "id": "66771a5c-86dc-4311-8cd0-eeb527ef25eb",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "image_key": null,
      "name": "ooc",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "9d6717",
      "number": "1",
      "validation_errors": [

      ],
      "classification_code": "XYZ"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=66771a5c-86dc-4311-8cd0-eeb527ef25eb",
          "self": "/object_occurrences/66771a5c-86dc-4311-8cd0-eeb527ef25eb/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=66771a5c-86dc-4311-8cd0-eeb527ef25eb&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/66771a5c-86dc-4311-8cd0-eeb527ef25eb/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=66771a5c-86dc-4311-8cd0-eeb527ef25eb"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/973e1afb-eab6-4142-a3ca-92edac5d70ed"
        }
      },
      "classification_table": {
        "data": {
          "id": "69d1474d-8457-424a-a0b0-c1829cf53c38",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/69d1474d-8457-424a-a0b0-c1829cf53c38"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/50428330-8ad9-4f98-9113-6fe00b6f5501",
          "self": "/object_occurrences/66771a5c-86dc-4311-8cd0-eeb527ef25eb/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "d4acf393-5fba-4f46-8fb4-e4911071d1a8",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/d4acf393-5fba-4f46-8fb4-e4911071d1a8"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/66771a5c-86dc-4311-8cd0-eeb527ef25eb/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "055ce639-00fc-471e-97b1-6c922bcffaf4",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=66771a5c-86dc-4311-8cd0-eeb527ef25eb"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "d4acf393-5fba-4f46-8fb4-e4911071d1a8",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=66771a5c-86dc-4311-8cd0-eeb527ef25eb"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "69d1474d-8457-424a-a0b0-c1829cf53c38",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=66771a5c-86dc-4311-8cd0-eeb527ef25eb"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/50428330-8ad9-4f98-9113-6fe00b6f5501/relationships/components"
  },
  "included": [
    {
      "id": "d4acf393-5fba-4f46-8fb4-e4911071d1a8",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 12",
        "hex_color": "9d6717"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/7134ec36-a769-4d06-8cab-cd50acdacea1"
          }
        },
        "classification_table": {
          "data": {
            "id": "69d1474d-8457-424a-a0b0-c1829cf53c38",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/69d1474d-8457-424a-a0b0-c1829cf53c38",
            "self": "/syntax_elements/d4acf393-5fba-4f46-8fb4-e4911071d1a8/relationships/classification_table"
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
| data[type] | Resource type |
| data[id] | Resource ID |
| data[links] | JSON:API links data |
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][image_url] | Url to image stored with OOC |
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
POST /object_occurrences/cf213a89-161b-4495-853d-aaf6161dca98/relationships/components
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
X-Request-Id: fc02371e-361e-4063-bcc0-e801ab98d31a
201 Created
```


```json
{
  "data": {
    "id": "91e5e654-d5b4-44c0-8f27-4ebc374caa67",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "image_key": null,
      "name": "external OOC",
      "position": 1,
      "prefix": null,
      "reference_designation": null,
      "type": "external",
      "hex_color": null,
      "number": "",
      "validation_errors": [

      ],
      "classification_code": null
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=91e5e654-d5b4-44c0-8f27-4ebc374caa67",
          "self": "/object_occurrences/91e5e654-d5b4-44c0-8f27-4ebc374caa67/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=91e5e654-d5b4-44c0-8f27-4ebc374caa67&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/91e5e654-d5b4-44c0-8f27-4ebc374caa67/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=91e5e654-d5b4-44c0-8f27-4ebc374caa67"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/c03bc1b8-5fb1-4f24-9430-9b278a314dc6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/cf213a89-161b-4495-853d-aaf6161dca98/relationships/components"
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
PATCH /object_occurrences/85e5d79f-5e30-4e8c-b3bd-72a8ace2f903
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "85e5d79f-5e30-4e8c-b3bd-72a8ace2f903",
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
          "id": "08bf650e-7493-4f43-9704-7604b19aab2c"
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
X-Request-Id: bd874980-15cc-4edb-aabc-d79528e9f45e
200 OK
```


```json
{
  "data": {
    "id": "85e5d79f-5e30-4e8c-b3bd-72a8ace2f903",
    "type": "object_occurrence",
    "attributes": {
      "description": "New description",
      "image_key": null,
      "name": "New name",
      "position": 2,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "ffa500",
      "number": "3",
      "validation_errors": [

      ],
      "classification_code": "XYZ"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=85e5d79f-5e30-4e8c-b3bd-72a8ace2f903",
          "self": "/object_occurrences/85e5d79f-5e30-4e8c-b3bd-72a8ace2f903/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=85e5d79f-5e30-4e8c-b3bd-72a8ace2f903&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/85e5d79f-5e30-4e8c-b3bd-72a8ace2f903/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=85e5d79f-5e30-4e8c-b3bd-72a8ace2f903"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/e9adb7c3-cb10-4886-9a2a-697123dc4f94"
        }
      },
      "classification_table": {
        "data": {
          "id": "ac5244e0-1e2c-4c41-8aad-696be0cf56a9",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/ac5244e0-1e2c-4c41-8aad-696be0cf56a9"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/08bf650e-7493-4f43-9704-7604b19aab2c",
          "self": "/object_occurrences/85e5d79f-5e30-4e8c-b3bd-72a8ace2f903/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "92455c79-a007-4966-a057-8f577ed10d31",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/92455c79-a007-4966-a057-8f577ed10d31"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/85e5d79f-5e30-4e8c-b3bd-72a8ace2f903/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "6af22380-46f6-4a64-80b3-4f61722b6022",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=85e5d79f-5e30-4e8c-b3bd-72a8ace2f903"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "92455c79-a007-4966-a057-8f577ed10d31",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=85e5d79f-5e30-4e8c-b3bd-72a8ace2f903"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "ac5244e0-1e2c-4c41-8aad-696be0cf56a9",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=85e5d79f-5e30-4e8c-b3bd-72a8ace2f903"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/85e5d79f-5e30-4e8c-b3bd-72a8ace2f903"
  },
  "included": [
    {
      "id": "92455c79-a007-4966-a057-8f577ed10d31",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 20",
        "hex_color": "0d155c"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/c0a49868-7d56-4945-a723-9abba3f3cbae"
          }
        },
        "classification_table": {
          "data": {
            "id": "ac5244e0-1e2c-4c41-8aad-696be0cf56a9",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/ac5244e0-1e2c-4c41-8aad-696be0cf56a9",
            "self": "/syntax_elements/92455c79-a007-4966-a057-8f577ed10d31/relationships/classification_table"
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
POST /object_occurrences/3adc6832-fedf-4797-86f0-2c44f4a86a51/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "bb1aa1df-5719-445f-82df-10e73941be61",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/60884aad249894fdccac97b4
Content-Type: text/html; charset=utf-8
X-Request-Id: 68450ac2-4682-4767-b45a-ca2a37c6eaff
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/60884aad249894fdccac97b4">redirected</a>.</body></html>
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
DELETE /object_occurrences/66d995ec-253e-4cee-8da6-416cb795c5d8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f53295be-a0b1-40ec-9ce5-11887b0fd484
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/27ef1d62-5bc0-4749-8417-12b900da606b/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "045a0fc9-769d-4654-bb3d-65ac2fab2da0",
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
X-Request-Id: f7fffffe-21e8-4cde-a3f3-418b4a63d87c
200 OK
```


```json
{
  "data": {
    "id": "27ef1d62-5bc0-4749-8417-12b900da606b",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "image_key": null,
      "name": "OOC 2",
      "position": 2,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "c99657",
      "number": "1",
      "validation_errors": [

      ],
      "classification_code": "XYZ"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=27ef1d62-5bc0-4749-8417-12b900da606b",
          "self": "/object_occurrences/27ef1d62-5bc0-4749-8417-12b900da606b/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=27ef1d62-5bc0-4749-8417-12b900da606b&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/27ef1d62-5bc0-4749-8417-12b900da606b/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=27ef1d62-5bc0-4749-8417-12b900da606b"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/61959241-deff-41ea-92dc-2561eb198fa3"
        }
      },
      "classification_table": {
        "data": {
          "id": "31f53e11-c557-4beb-b93b-849ae1dd033b",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/31f53e11-c557-4beb-b93b-849ae1dd033b"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/045a0fc9-769d-4654-bb3d-65ac2fab2da0",
          "self": "/object_occurrences/27ef1d62-5bc0-4749-8417-12b900da606b/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "25b932e5-2a75-4d5f-83c2-41cf31fd3c36",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/25b932e5-2a75-4d5f-83c2-41cf31fd3c36"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/27ef1d62-5bc0-4749-8417-12b900da606b/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "d513bc15-ff7e-4130-9a17-fe224ea07bcb",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=27ef1d62-5bc0-4749-8417-12b900da606b"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "25b932e5-2a75-4d5f-83c2-41cf31fd3c36",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=27ef1d62-5bc0-4749-8417-12b900da606b"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "31f53e11-c557-4beb-b93b-849ae1dd033b",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=27ef1d62-5bc0-4749-8417-12b900da606b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/27ef1d62-5bc0-4749-8417-12b900da606b/relationships/part_of"
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
X-Request-Id: b7295a7d-7fec-4fe4-97dd-995a276be38f
200 OK
```


```json
{
  "data": [
    {
      "id": "a64fbc90b11145d50232e8c065172a1c2ffbece6f8850407e6894cc2fc037cfe",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "43b31991-3dd5-46f8-88d6-3d10d9de11ba",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/43b31991-3dd5-46f8-88d6-3d10d9de11ba"
          }
        }
      }
    },
    {
      "id": "0eef156ae7a169242690d40eb7751cca2fc255550f9c6bbea72fd52e1a212efb",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "45c366f7-ebf5-49f2-add8-1909921c9d72",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/45c366f7-ebf5-49f2-add8-1909921c9d72"
          }
        }
      }
    },
    {
      "id": "0606e50316c6fc61f3ba6dbba3a59710f08eb774045640bb1739cc90de15ffa3",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "86423b44-21ce-45e3-8fa6-9366bde8b7f8",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/86423b44-21ce-45e3-8fa6-9366bde8b7f8"
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



## Generate URL for direct upload


### Request

#### Endpoint

```plaintext
GET /object_occurrences/2070efa6-4fad-48f6-9d1e-571609af55d4/relationships/image/upload_url?extension=jpg
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/:object_occurrence_id/relationships/image/upload_url?extension=jpg`

#### Parameters


```json
extension: jpg
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0ad8eb6d-0ba6-4196-a816-eec694265069
200 OK
```


```json
{
  "data": {
    "id": "ooc/2070efa6-4fad-48f6-9d1e-571609af55d4/1234abcde.jpg",
    "type": "url_struct",
    "attributes": {
      "id": "ooc/2070efa6-4fad-48f6-9d1e-571609af55d4/1234abcde.jpg",
      "url": "https://qa-sec-hub-document-bucket.s3.eu-west-1.amazonaws.com/ooc/2070efa6-4fad-48f6-9d1e-571609af55d4/1234abcde.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20200516%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20200516T124114Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=282a1a37557f672b28c3387916e3c7eb15f30d1fc0d8a9d6ae29be4f0de0bd55",
      "extension": "jpg"
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][url] | URL which might be used in next 15 minutes for direct upload |
| data[attributes][id] | Randomly generated key of file which will be a name of uploaded file |
| data[attributes][extension] | Extension provided with request for file |


## Replace image key with provided in params


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/0a233d57-e0cb-4dc6-bbac-e97cb8f69e93/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/image`

#### Parameters


```json
{
  "data": {
    "type": "object_occurrence",
    "attributes": {
      "image_key": "ooc/1234abcde.jpg"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][image_key]  | Value which will identify associated image |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 83c5facc-5bd4-463b-b4a4-e8bb4079994f
200 OK
```


```json
{
  "data": {
    "id": "0a233d57-e0cb-4dc6-bbac-e97cb8f69e93",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "image_key": "ooc/1234abcde.jpg",
      "name": "ooc 1",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "1bef48",
      "number": "1",
      "validation_errors": [

      ],
      "classification_code": "A"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=0a233d57-e0cb-4dc6-bbac-e97cb8f69e93",
          "self": "/object_occurrences/0a233d57-e0cb-4dc6-bbac-e97cb8f69e93/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=0a233d57-e0cb-4dc6-bbac-e97cb8f69e93&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/0a233d57-e0cb-4dc6-bbac-e97cb8f69e93/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=0a233d57-e0cb-4dc6-bbac-e97cb8f69e93"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/9a2bd888-5072-467b-a409-b9c64dad4381"
        }
      },
      "classification_table": {
        "data": {
          "id": "81ff6f34-3ea2-46fb-867a-42dcd76972a1",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/81ff6f34-3ea2-46fb-867a-42dcd76972a1"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/8ab7cc44-93e9-4dc2-84a5-538feba6533b",
          "self": "/object_occurrences/0a233d57-e0cb-4dc6-bbac-e97cb8f69e93/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "976353e8-af6c-4241-ac98-17477d51a8a0",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/976353e8-af6c-4241-ac98-17477d51a8a0"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/0a233d57-e0cb-4dc6-bbac-e97cb8f69e93/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "07e223e8-6875-41a3-97eb-a52f98e25689",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a233d57-e0cb-4dc6-bbac-e97cb8f69e93"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "976353e8-af6c-4241-ac98-17477d51a8a0",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a233d57-e0cb-4dc6-bbac-e97cb8f69e93"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "81ff6f34-3ea2-46fb-867a-42dcd76972a1",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a233d57-e0cb-4dc6-bbac-e97cb8f69e93"
        }
      }
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][classification_code] | Reference designation classification code |
| data[attributes][description] | Custom description of the Object Occurrence |
| data[attributes][hex_color] | Custom color |
| data[attributes][image_url] | Url to image stored with OOC |
| data[attributes][name] | Custom name for the OOC |
| data[attributes][number] | Reference designation number |
| data[attributes][position] | Custom sorting position within siblings |
| data[attributes][prefix] | Reference designation aspect/prefix |
| data[attributes][type] | Type of Object Occurrence |


## Delete image


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/e3635d45-55bb-4f56-83ff-4eb97aa8a33f/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5a74fe85-d221-4ba3-9cb7-24ea0a558a59
204 No Content
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
POST /classification_tables/d02bf5ea-c478-4306-9a40-8426230945f5/relationships/tags
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
X-Request-Id: acb763f7-65da-46e0-b194-bf428b92b656
201 Created
```


```json
{
  "data": {
    "id": "01258f44-6c40-41a2-910a-a01c8d5ff39e",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d02bf5ea-c478-4306-9a40-8426230945f5/relationships/tags"
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
POST /classification_tables/75f4e4a4-ac0b-41b5-936d-ac0e4ff26d0a/relationships/tags
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
    "id": "0f8990a4-19ab-45df-a02c-92de5c69c95c"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c2b02989-98c3-49a5-80d1-c13cfda44867
201 Created
```


```json
{
  "data": {
    "id": "0f8990a4-19ab-45df-a02c-92de5c69c95c",
    "type": "tag",
    "attributes": {
      "value": "tag value 25"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/75f4e4a4-ac0b-41b5-936d-ac0e4ff26d0a/relationships/tags"
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
DELETE /classification_tables/a3798cc8-ebd1-4250-ab63-3f7564f4f612/relationships/tags/f97e699d-e06a-457f-b6c1-78c9e5913c23
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9df7943a-6e57-40ea-a246-dd382ae1bd44
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
X-Request-Id: 0cfb184b-1705-44e9-a8b9-940dcc85618f
200 OK
```


```json
{
  "data": [
    {
      "id": "c599a59c-9878-466d-a246-ebbf6527d2be",
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
            "related": "/tags?filter[target_id_eq]=c599a59c-9878-466d-a246-ebbf6527d2be",
            "self": "/classification_tables/c599a59c-9878-466d-a246-ebbf6527d2be/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=c599a59c-9878-466d-a246-ebbf6527d2be",
            "self": "/classification_tables/c599a59c-9878-466d-a246-ebbf6527d2be/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "dfd7d465-a59d-4957-98ff-c0ac65f353e9",
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
            "related": "/tags?filter[target_id_eq]=dfd7d465-a59d-4957-98ff-c0ac65f353e9",
            "self": "/classification_tables/dfd7d465-a59d-4957-98ff-c0ac65f353e9/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=dfd7d465-a59d-4957-98ff-c0ac65f353e9",
            "self": "/classification_tables/dfd7d465-a59d-4957-98ff-c0ac65f353e9/relationships/classification_entries",
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
GET /classification_tables/c8b218f9-ed89-4578-81a6-444bbfc7966e
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
X-Request-Id: 8309b9d3-18f0-438f-957c-9f9a1d696808
200 OK
```


```json
{
  "data": {
    "id": "c8b218f9-ed89-4578-81a6-444bbfc7966e",
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
          "related": "/tags?filter[target_id_eq]=c8b218f9-ed89-4578-81a6-444bbfc7966e",
          "self": "/classification_tables/c8b218f9-ed89-4578-81a6-444bbfc7966e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=c8b218f9-ed89-4578-81a6-444bbfc7966e",
          "self": "/classification_tables/c8b218f9-ed89-4578-81a6-444bbfc7966e/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/c8b218f9-ed89-4578-81a6-444bbfc7966e"
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
PATCH /classification_tables/4c1f8a56-b9c2-41af-a7e3-647a13043f5b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "4c1f8a56-b9c2-41af-a7e3-647a13043f5b",
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
X-Request-Id: 5263af62-e97b-492d-9cc2-dc2e053d3f61
200 OK
```


```json
{
  "data": {
    "id": "4c1f8a56-b9c2-41af-a7e3-647a13043f5b",
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
          "related": "/tags?filter[target_id_eq]=4c1f8a56-b9c2-41af-a7e3-647a13043f5b",
          "self": "/classification_tables/4c1f8a56-b9c2-41af-a7e3-647a13043f5b/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=4c1f8a56-b9c2-41af-a7e3-647a13043f5b",
          "self": "/classification_tables/4c1f8a56-b9c2-41af-a7e3-647a13043f5b/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/4c1f8a56-b9c2-41af-a7e3-647a13043f5b"
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
DELETE /classification_tables/3ff97b94-ec9c-40d3-9bf0-042f8b7ad87d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 91395645-1731-4afc-85db-5487739b7052
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
POST /classification_tables/11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6/publish
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
X-Request-Id: 65365881-1da9-4466-adc9-49b03ae80664
200 OK
```


```json
{
  "data": {
    "id": "11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-05-16T12:40:00.994Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6",
          "self": "/classification_tables/11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6",
          "self": "/classification_tables/11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/11e231e0-d6d2-4a3d-a6b7-5647bf2c70a6/publish"
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
POST /classification_tables/7dd89921-cf2c-467d-913d-93f627ddf018/archive
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
X-Request-Id: 0a6ccc97-53a4-444e-ad99-571ee19f4d7b
200 OK
```


```json
{
  "data": {
    "id": "7dd89921-cf2c-467d-913d-93f627ddf018",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-16T12:40:01.907Z",
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
          "related": "/tags?filter[target_id_eq]=7dd89921-cf2c-467d-913d-93f627ddf018",
          "self": "/classification_tables/7dd89921-cf2c-467d-913d-93f627ddf018/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=7dd89921-cf2c-467d-913d-93f627ddf018",
          "self": "/classification_tables/7dd89921-cf2c-467d-913d-93f627ddf018/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/7dd89921-cf2c-467d-913d-93f627ddf018/archive"
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
X-Request-Id: e7d757e7-cd8a-4792-9417-d63f7b69d196
201 Created
```


```json
{
  "data": {
    "id": "35a20104-8b48-49cf-aff0-3309ef329b3c",
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
          "related": "/tags?filter[target_id_eq]=35a20104-8b48-49cf-aff0-3309ef329b3c",
          "self": "/classification_tables/35a20104-8b48-49cf-aff0-3309ef329b3c/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=35a20104-8b48-49cf-aff0-3309ef329b3c",
          "self": "/classification_tables/35a20104-8b48-49cf-aff0-3309ef329b3c/relationships/classification_entries",
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
POST /classification_entries/aafe7f46-4457-45e9-a923-10b9feba937e/relationships/tags
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
X-Request-Id: d0fda209-8fd9-46dc-9f0b-5766e19eb3d8
201 Created
```


```json
{
  "data": {
    "id": "f668bf40-5c8e-4768-aec2-3e531e2f98a5",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/aafe7f46-4457-45e9-a923-10b9feba937e/relationships/tags"
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
POST /classification_entries/fbd48125-b20f-4b27-92f2-d75e88377802/relationships/tags
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
    "id": "151fff23-3e0b-4ffe-a646-947d0496faee"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 70129fad-6d74-4b0b-8c54-4b2c3935d2ba
201 Created
```


```json
{
  "data": {
    "id": "151fff23-3e0b-4ffe-a646-947d0496faee",
    "type": "tag",
    "attributes": {
      "value": "tag value 27"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/fbd48125-b20f-4b27-92f2-d75e88377802/relationships/tags"
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
DELETE /classification_entries/53168bfe-570b-4e71-8d8a-b19bfd939b14/relationships/tags/e5cc7697-9227-4d0d-a591-1f0493b2b367
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 268a68a7-f2b4-49ab-ba92-3c5065fb5d57
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
X-Request-Id: 7cbb7e3c-31a5-4578-85be-35b9a65ca8a8
200 OK
```


```json
{
  "data": [
    {
      "id": "e0379b80-bf0c-4388-a059-9a411d12209a",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal A",
        "name": "CE 1",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=e0379b80-bf0c-4388-a059-9a411d12209a",
            "self": "/classification_entries/e0379b80-bf0c-4388-a059-9a411d12209a/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=e0379b80-bf0c-4388-a059-9a411d12209a",
            "self": "/classification_entries/e0379b80-bf0c-4388-a059-9a411d12209a/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "ee29541c-24cb-45d7-ab5c-5760310884c8",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal AA",
        "name": "CE 11",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=ee29541c-24cb-45d7-ab5c-5760310884c8",
            "self": "/classification_entries/ee29541c-24cb-45d7-ab5c-5760310884c8/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "e0379b80-bf0c-4388-a059-9a411d12209a",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/ee29541c-24cb-45d7-ab5c-5760310884c8"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=ee29541c-24cb-45d7-ab5c-5760310884c8",
            "self": "/classification_entries/ee29541c-24cb-45d7-ab5c-5760310884c8/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "30030626-f861-485f-bc93-4a260dd2e226",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal B",
        "name": "CE 2",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=30030626-f861-485f-bc93-4a260dd2e226",
            "self": "/classification_entries/30030626-f861-485f-bc93-4a260dd2e226/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=30030626-f861-485f-bc93-4a260dd2e226",
            "self": "/classification_entries/30030626-f861-485f-bc93-4a260dd2e226/relationships/classification_entries",
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
GET /classification_entries/23c22c3d-2b93-440a-8b23-93af4e18a582
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
X-Request-Id: ca8bcc9b-0132-4413-87b0-5bcc4cb5efcc
200 OK
```


```json
{
  "data": {
    "id": "23c22c3d-2b93-440a-8b23-93af4e18a582",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "Alarm signal A",
      "name": "CE 1",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=23c22c3d-2b93-440a-8b23-93af4e18a582",
          "self": "/classification_entries/23c22c3d-2b93-440a-8b23-93af4e18a582/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=23c22c3d-2b93-440a-8b23-93af4e18a582",
          "self": "/classification_entries/23c22c3d-2b93-440a-8b23-93af4e18a582/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/23c22c3d-2b93-440a-8b23-93af4e18a582"
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
PATCH /classification_entries/fa3ffc41-f23c-43f9-9aba-e0a60f4abccd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "fa3ffc41-f23c-43f9-9aba-e0a60f4abccd",
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
X-Request-Id: 3c919544-1732-49b1-97cb-92e8cb153063
200 OK
```


```json
{
  "data": {
    "id": "fa3ffc41-f23c-43f9-9aba-e0a60f4abccd",
    "type": "classification_entry",
    "attributes": {
      "code": "AA",
      "definition": "Alarm signal AA",
      "name": "New classification entry name",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=fa3ffc41-f23c-43f9-9aba-e0a60f4abccd",
          "self": "/classification_entries/fa3ffc41-f23c-43f9-9aba-e0a60f4abccd/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "8e75f414-64cb-40bf-a22a-4b1e8ac47b64",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/fa3ffc41-f23c-43f9-9aba-e0a60f4abccd"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=fa3ffc41-f23c-43f9-9aba-e0a60f4abccd",
          "self": "/classification_entries/fa3ffc41-f23c-43f9-9aba-e0a60f4abccd/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/fa3ffc41-f23c-43f9-9aba-e0a60f4abccd"
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
DELETE /classification_entries/79165b2d-7ae6-480e-a569-ba29e589e0fd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 374e0774-22d4-40e8-b559-fead5b6c7efb
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
POST /classification_tables/65141272-3e56-402f-a521-2a1bc59c365c/relationships/classification_entries
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
X-Request-Id: ac68ba95-88c5-4b39-ab57-efbb83065714
201 Created
```


```json
{
  "data": {
    "id": "d891d53b-68f5-4f70-9cc1-877e83d7e9c3",
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
          "related": "/tags?filter[target_id_eq]=d891d53b-68f5-4f70-9cc1-877e83d7e9c3",
          "self": "/classification_entries/d891d53b-68f5-4f70-9cc1-877e83d7e9c3/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=d891d53b-68f5-4f70-9cc1-877e83d7e9c3",
          "self": "/classification_entries/d891d53b-68f5-4f70-9cc1-877e83d7e9c3/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/65141272-3e56-402f-a521-2a1bc59c365c/relationships/classification_entries"
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
X-Request-Id: 91014d4e-b6aa-4077-a62c-50e31e4ee178
200 OK
```


```json
{
  "data": [
    {
      "id": "b8f59943-f117-4652-84d1-9bd3a6498566",
      "type": "syntax",
      "attributes": {
        "account_id": "27039f47-89fa-47c0-b18a-34afbcda9f8c",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 833f50caeb80",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=b8f59943-f117-4652-84d1-9bd3a6498566",
            "self": "/syntaxes/b8f59943-f117-4652-84d1-9bd3a6498566/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/1badbec6-6981-4708-88f7-298ddbbb7105",
            "self": "/syntax_nodes/1badbec6-6981-4708-88f7-298ddbbb7105/relationships/components"
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
GET /syntaxes/ec84d909-7633-44c5-a699-86dabb92ddbd
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
X-Request-Id: 1070dc15-bd99-4a25-a557-a3b83f70d470
200 OK
```


```json
{
  "data": {
    "id": "ec84d909-7633-44c5-a699-86dabb92ddbd",
    "type": "syntax",
    "attributes": {
      "account_id": "03d8a840-a7a8-4a52-99c0-1da6c80fbb69",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax d4d38ec8e2d3",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ec84d909-7633-44c5-a699-86dabb92ddbd",
          "self": "/syntaxes/ec84d909-7633-44c5-a699-86dabb92ddbd/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/fdeef9e6-2984-415c-894d-ef8325057edb",
          "self": "/syntax_nodes/fdeef9e6-2984-415c-894d-ef8325057edb/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ec84d909-7633-44c5-a699-86dabb92ddbd"
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
X-Request-Id: 36220f94-44ba-4632-9ed3-7892441ca966
201 Created
```


```json
{
  "data": {
    "id": "fa274d1f-bbee-4558-98fc-1a6ec7f087a6",
    "type": "syntax",
    "attributes": {
      "account_id": "4dcddfc7-0e73-45ae-b29c-1ad8fa61e0b1",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=fa274d1f-bbee-4558-98fc-1a6ec7f087a6",
          "self": "/syntaxes/fa274d1f-bbee-4558-98fc-1a6ec7f087a6/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/7f22dac7-b251-4753-a743-8bef6ea96da3",
          "self": "/syntax_nodes/7f22dac7-b251-4753-a743-8bef6ea96da3/relationships/components"
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
PATCH /syntaxes/97ad6913-8de7-48df-bd6b-06ada128874e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "97ad6913-8de7-48df-bd6b-06ada128874e",
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
X-Request-Id: 54943af9-4a45-4aeb-9240-9b497ceea9d7
200 OK
```


```json
{
  "data": {
    "id": "97ad6913-8de7-48df-bd6b-06ada128874e",
    "type": "syntax",
    "attributes": {
      "account_id": "29bb568c-d881-4195-bd8e-6094f39896f6",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=97ad6913-8de7-48df-bd6b-06ada128874e",
          "self": "/syntaxes/97ad6913-8de7-48df-bd6b-06ada128874e/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/911347e4-b621-4b33-80c1-c18ae3793126",
          "self": "/syntax_nodes/911347e4-b621-4b33-80c1-c18ae3793126/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/97ad6913-8de7-48df-bd6b-06ada128874e"
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
DELETE /syntaxes/c44f4113-421c-47db-9527-2c624e894eea
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a8d7d12e-a273-4739-b17f-aed5983b13eb
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
POST /syntaxes/c06c270a-a00a-4da4-9bfc-277fce56caf6/publish
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
X-Request-Id: 684b273f-5738-4fac-9764-9929837a12e3
200 OK
```


```json
{
  "data": {
    "id": "c06c270a-a00a-4da4-9bfc-277fce56caf6",
    "type": "syntax",
    "attributes": {
      "account_id": "81d6dd94-a3ee-43d1-b777-01e336245daa",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 8a42b84e8a3d",
      "published": true,
      "published_at": "2020-05-16T12:40:13.878Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=c06c270a-a00a-4da4-9bfc-277fce56caf6",
          "self": "/syntaxes/c06c270a-a00a-4da4-9bfc-277fce56caf6/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/2f9b0402-72f7-495e-b4e8-380beda8251d",
          "self": "/syntax_nodes/2f9b0402-72f7-495e-b4e8-380beda8251d/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/c06c270a-a00a-4da4-9bfc-277fce56caf6/publish"
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
POST /syntaxes/93c94f6c-2523-4bc2-9803-6083aac9e79c/archive
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
X-Request-Id: b16a2bf4-0a71-4183-b6e0-f69edd9f9990
200 OK
```


```json
{
  "data": {
    "id": "93c94f6c-2523-4bc2-9803-6083aac9e79c",
    "type": "syntax",
    "attributes": {
      "account_id": "6b5074e1-7e6f-4dac-8392-1c9f17c68b4d",
      "archived": true,
      "archived_at": "2020-05-16T12:40:14.556Z",
      "description": "Description",
      "name": "Syntax fa3b5601c897",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=93c94f6c-2523-4bc2-9803-6083aac9e79c",
          "self": "/syntaxes/93c94f6c-2523-4bc2-9803-6083aac9e79c/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/2f497a14-f59d-4f93-8ade-b1397dade51f",
          "self": "/syntax_nodes/2f497a14-f59d-4f93-8ade-b1397dade51f/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/93c94f6c-2523-4bc2-9803-6083aac9e79c/archive"
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
X-Request-Id: f3c596f6-3cd7-405c-99be-009f3197a1e4
200 OK
```


```json
{
  "data": [
    {
      "id": "f3ae6a17-cc3c-4551-8885-7747a268ab70",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 27",
        "hex_color": "cebdd1"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/a0d097f0-ff6d-46ff-b02c-713b9b8ce587"
          }
        },
        "classification_table": {
          "data": {
            "id": "ac6d18c4-4e1f-489b-86a0-786969fd5b19",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/ac6d18c4-4e1f-489b-86a0-786969fd5b19",
            "self": "/syntax_elements/f3ae6a17-cc3c-4551-8885-7747a268ab70/relationships/classification_table"
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
GET /syntax_elements/7d4f93db-0839-4cf8-9e9c-8c7b5e55de1f
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
X-Request-Id: 060ac974-768f-45b4-9e35-290853356ad2
200 OK
```


```json
{
  "data": {
    "id": "7d4f93db-0839-4cf8-9e9c-8c7b5e55de1f",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 29",
      "hex_color": "96ff4a"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/bcaf6277-b4cd-43f7-b280-3727f08e0f84"
        }
      },
      "classification_table": {
        "data": {
          "id": "224d779f-8f95-4d8a-8d20-f26276c04778",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/224d779f-8f95-4d8a-8d20-f26276c04778",
          "self": "/syntax_elements/7d4f93db-0839-4cf8-9e9c-8c7b5e55de1f/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/7d4f93db-0839-4cf8-9e9c-8c7b5e55de1f"
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
POST /syntaxes/82f5d97b-7e21-4944-a283-7542aa8dedb7/relationships/syntax_elements
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
          "id": "9f292622-6830-4f63-be3f-97cfbd391035"
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
X-Request-Id: bc696c34-9da8-4637-91fe-5c0b725ec854
201 Created
```


```json
{
  "data": {
    "id": "15c8dc12-4242-4422-8098-424209110ceb",
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
          "related": "/syntaxes/82f5d97b-7e21-4944-a283-7542aa8dedb7"
        }
      },
      "classification_table": {
        "data": {
          "id": "9f292622-6830-4f63-be3f-97cfbd391035",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/9f292622-6830-4f63-be3f-97cfbd391035",
          "self": "/syntax_elements/15c8dc12-4242-4422-8098-424209110ceb/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/82f5d97b-7e21-4944-a283-7542aa8dedb7/relationships/syntax_elements"
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
PATCH /syntax_elements/cbfdfc08-1791-4c24-8098-7fef256b8cec
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "cbfdfc08-1791-4c24-8098-7fef256b8cec",
    "type": "syntax_element",
    "attributes": {
      "name": "New element",
      "hex_color": "ffffff"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "3231b1a8-a832-407d-b8f4-286a4a8d1d2e"
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
X-Request-Id: d57d8f29-1db0-40d1-8e28-8817ac93c03e
200 OK
```


```json
{
  "data": {
    "id": "cbfdfc08-1791-4c24-8098-7fef256b8cec",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "hex_color": "ffffff"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/fe54e921-e989-4e4b-abb7-819bfe5a94c6"
        }
      },
      "classification_table": {
        "data": {
          "id": "3231b1a8-a832-407d-b8f4-286a4a8d1d2e",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/3231b1a8-a832-407d-b8f4-286a4a8d1d2e",
          "self": "/syntax_elements/cbfdfc08-1791-4c24-8098-7fef256b8cec/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/cbfdfc08-1791-4c24-8098-7fef256b8cec"
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
DELETE /syntax_elements/251b2285-ec0e-48d2-a258-164292eb0a7e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5b0626fd-d097-46ca-8c67-6333d3d9abdc
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
PATCH /syntax_elements/82d926af-5594-4074-a0de-7b603d69008f/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "fd111acd-3704-4ea9-8136-e7d5da8b7332",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 205bbdf8-4737-4e14-a193-1baa8887c72e
200 OK
```


```json
{
  "data": {
    "id": "82d926af-5594-4074-a0de-7b603d69008f",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 37",
      "hex_color": "1b1e9b"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/b12fc2ca-0ed1-45f2-bd60-4538954f22db"
        }
      },
      "classification_table": {
        "data": {
          "id": "fd111acd-3704-4ea9-8136-e7d5da8b7332",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/fd111acd-3704-4ea9-8136-e7d5da8b7332",
          "self": "/syntax_elements/82d926af-5594-4074-a0de-7b603d69008f/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/82d926af-5594-4074-a0de-7b603d69008f/relationships/classification_table"
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
DELETE /syntax_elements/a4c92582-1810-45b6-9fae-1e8efb51497a/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4372e6e4-870d-4b8f-9949-86db3429b50f
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
X-Request-Id: 6d0c9279-2f8f-423f-b137-19d5fc1893ca
200 OK
```


```json
{
  "data": [
    {
      "id": "41273b1f-1dac-4083-b15b-d4fcb3a2d762",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/da7ae9fb-1648-4cd1-a448-6b00988fab5b"
          }
        },
        "components": {
          "data": [
            {
              "id": "1f509f13-1651-48c2-8f48-f9ada7e01157",
              "type": "syntax_node"
            },
            {
              "id": "f55b90e7-a5d2-42e0-9f62-0bc959331924",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/41273b1f-1dac-4083-b15b-d4fcb3a2d762/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/41273b1f-1dac-4083-b15b-d4fcb3a2d762/relationships/parent",
            "related": "/syntax_nodes/41273b1f-1dac-4083-b15b-d4fcb3a2d762"
          }
        }
      }
    },
    {
      "id": "f55b90e7-a5d2-42e0-9f62-0bc959331924",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/da7ae9fb-1648-4cd1-a448-6b00988fab5b"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/f55b90e7-a5d2-42e0-9f62-0bc959331924/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/f55b90e7-a5d2-42e0-9f62-0bc959331924/relationships/parent",
            "related": "/syntax_nodes/f55b90e7-a5d2-42e0-9f62-0bc959331924"
          }
        }
      }
    },
    {
      "id": "e12b8ef0-ddff-4e4f-9cf0-bd0130306f37",
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
              "id": "41273b1f-1dac-4083-b15b-d4fcb3a2d762",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/e12b8ef0-ddff-4e4f-9cf0-bd0130306f37/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e12b8ef0-ddff-4e4f-9cf0-bd0130306f37/relationships/parent",
            "related": "/syntax_nodes/e12b8ef0-ddff-4e4f-9cf0-bd0130306f37"
          }
        }
      }
    },
    {
      "id": "492561ef-145c-4add-896a-c15570be067e",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/da7ae9fb-1648-4cd1-a448-6b00988fab5b"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/492561ef-145c-4add-896a-c15570be067e/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/492561ef-145c-4add-896a-c15570be067e/relationships/parent",
            "related": "/syntax_nodes/492561ef-145c-4add-896a-c15570be067e"
          }
        }
      }
    },
    {
      "id": "1f509f13-1651-48c2-8f48-f9ada7e01157",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/da7ae9fb-1648-4cd1-a448-6b00988fab5b"
          }
        },
        "components": {
          "data": [
            {
              "id": "492561ef-145c-4add-896a-c15570be067e",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/1f509f13-1651-48c2-8f48-f9ada7e01157/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/1f509f13-1651-48c2-8f48-f9ada7e01157/relationships/parent",
            "related": "/syntax_nodes/1f509f13-1651-48c2-8f48-f9ada7e01157"
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
GET /syntax_nodes/18b1e724-6968-40a1-ad52-32818c8554fb?depth=2
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
X-Request-Id: d3bfd68e-6406-4368-b4ed-5d750ad6f6db
200 OK
```


```json
{
  "data": {
    "id": "18b1e724-6968-40a1-ad52-32818c8554fb",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/043b1087-6bef-438e-bf3d-a896ec5ca622"
        }
      },
      "components": {
        "data": [
          {
            "id": "8390f8aa-5f0e-4f6b-9c9a-2955666c2dbc",
            "type": "syntax_node"
          },
          {
            "id": "454a0576-fa7d-46f3-8993-07f62631014d",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/18b1e724-6968-40a1-ad52-32818c8554fb/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/18b1e724-6968-40a1-ad52-32818c8554fb/relationships/parent",
          "related": "/syntax_nodes/18b1e724-6968-40a1-ad52-32818c8554fb"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/18b1e724-6968-40a1-ad52-32818c8554fb?depth=2"
  },
  "included": [
    {
      "id": "454a0576-fa7d-46f3-8993-07f62631014d",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/043b1087-6bef-438e-bf3d-a896ec5ca622"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/454a0576-fa7d-46f3-8993-07f62631014d/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/454a0576-fa7d-46f3-8993-07f62631014d/relationships/parent",
            "related": "/syntax_nodes/454a0576-fa7d-46f3-8993-07f62631014d"
          }
        }
      }
    },
    {
      "id": "8390f8aa-5f0e-4f6b-9c9a-2955666c2dbc",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/043b1087-6bef-438e-bf3d-a896ec5ca622"
          }
        },
        "components": {
          "data": [
            {
              "id": "c09b6131-7c1a-4d7f-a460-ab0ec3af1482",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/8390f8aa-5f0e-4f6b-9c9a-2955666c2dbc/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/8390f8aa-5f0e-4f6b-9c9a-2955666c2dbc/relationships/parent",
            "related": "/syntax_nodes/8390f8aa-5f0e-4f6b-9c9a-2955666c2dbc"
          }
        }
      }
    },
    {
      "id": "c09b6131-7c1a-4d7f-a460-ab0ec3af1482",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/043b1087-6bef-438e-bf3d-a896ec5ca622"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/c09b6131-7c1a-4d7f-a460-ab0ec3af1482/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/c09b6131-7c1a-4d7f-a460-ab0ec3af1482/relationships/parent",
            "related": "/syntax_nodes/c09b6131-7c1a-4d7f-a460-ab0ec3af1482"
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
POST /syntax_nodes/e7d8968c-4b7f-4149-b6ae-d54d72069391/relationships/components
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
          "id": "707a5ab1-f2c1-4754-adfc-1b8146c35e1a"
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
X-Request-Id: 38e98a9d-f743-42b2-b9b7-bea04b49d6b3
201 Created
```


```json
{
  "data": {
    "id": "67da0a8b-e662-40ec-b47a-0ee529d09b58",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/707a5ab1-f2c1-4754-adfc-1b8146c35e1a"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/67da0a8b-e662-40ec-b47a-0ee529d09b58/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/67da0a8b-e662-40ec-b47a-0ee529d09b58/relationships/parent",
          "related": "/syntax_nodes/67da0a8b-e662-40ec-b47a-0ee529d09b58"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/e7d8968c-4b7f-4149-b6ae-d54d72069391/relationships/components"
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
PATCH /syntax_nodes/511b2123-4bee-46b2-bfee-48c07aee8266/relationships/parent
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
    "id": "f50125f5-e4f1-4a11-ac90-57610d90b12a"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e771bda2-09b7-438b-95b8-1ae7412c1878
200 OK
```


```json
{
  "data": {
    "id": "511b2123-4bee-46b2-bfee-48c07aee8266",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 2
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/1734167b-30ed-43cb-9682-57aa5ec96962"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/511b2123-4bee-46b2-bfee-48c07aee8266/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/511b2123-4bee-46b2-bfee-48c07aee8266/relationships/parent",
          "related": "/syntax_nodes/511b2123-4bee-46b2-bfee-48c07aee8266"
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
PATCH /syntax_nodes/7cdc885e-465d-45f6-a13c-f77c11e26b46
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "7cdc885e-465d-45f6-a13c-f77c11e26b46",
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
X-Request-Id: e6551940-4ff7-4e93-b25a-51954a21715a
200 OK
```


```json
{
  "data": {
    "id": "7cdc885e-465d-45f6-a13c-f77c11e26b46",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/ade9119f-e73d-4521-ae02-9ba839304ae5"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/7cdc885e-465d-45f6-a13c-f77c11e26b46/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/7cdc885e-465d-45f6-a13c-f77c11e26b46/relationships/parent",
          "related": "/syntax_nodes/7cdc885e-465d-45f6-a13c-f77c11e26b46"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/7cdc885e-465d-45f6-a13c-f77c11e26b46"
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
DELETE /syntax_nodes/f621c84d-0e50-45b7-9f97-1e47b2fd5f24
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a2b897be-1bc3-4708-8e3c-cb36be56d725
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
X-Request-Id: 046e9da2-76f5-42d9-b513-ec51ea917905
200 OK
```


```json
{
  "data": [
    {
      "id": "09de59fe-0c51-4af8-95bf-1ac4be2665ac",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 177,
        "published": true,
        "published_at": "2020-05-16T12:40:27.566Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=09de59fe-0c51-4af8-95bf-1ac4be2665ac",
            "self": "/progress_models/09de59fe-0c51-4af8-95bf-1ac4be2665ac/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "480a3adf-469d-48ca-bf71-f790482612fd",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 2",
        "order": 178,
        "published": false,
        "published_at": null,
        "type": "object_occurrence_relation"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=480a3adf-469d-48ca-bf71-f790482612fd",
            "self": "/progress_models/480a3adf-469d-48ca-bf71-f790482612fd/relationships/progress_steps"
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
    "current": "http://example.org/progress_models?page[number]=1&sort=name"
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
GET /progress_models/7d1138b2-8b52-4330-93f6-47cb04edb70c
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
X-Request-Id: 8e7a0d79-1f08-4fae-b602-b818973fa400
200 OK
```


```json
{
  "data": {
    "id": "7d1138b2-8b52-4330-93f6-47cb04edb70c",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 181,
      "published": true,
      "published_at": "2020-05-16T12:40:28.173Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=7d1138b2-8b52-4330-93f6-47cb04edb70c",
          "self": "/progress_models/7d1138b2-8b52-4330-93f6-47cb04edb70c/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/7d1138b2-8b52-4330-93f6-47cb04edb70c"
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
PATCH /progress_models/0013e474-20ee-4379-80d9-19ba19302aec
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "0013e474-20ee-4379-80d9-19ba19302aec",
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
X-Request-Id: da34eea8-6805-4910-ad81-a372666ab731
200 OK
```


```json
{
  "data": {
    "id": "0013e474-20ee-4379-80d9-19ba19302aec",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "New progress model name",
      "order": 186,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=0013e474-20ee-4379-80d9-19ba19302aec",
          "self": "/progress_models/0013e474-20ee-4379-80d9-19ba19302aec/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0013e474-20ee-4379-80d9-19ba19302aec"
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
DELETE /progress_models/f869cef0-54c4-4afd-b32b-c4dc2e326983
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3a6e84b9-725c-46e0-a7dc-0e31f58e5af6
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
POST /progress_models/a151ac88-2e43-49bc-ba96-36db654cc665/publish
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
X-Request-Id: ec84750b-5f44-4c98-97ab-400cb73fdbea
200 OK
```


```json
{
  "data": {
    "id": "a151ac88-2e43-49bc-ba96-36db654cc665",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 194,
      "published": true,
      "published_at": "2020-05-16T12:40:30.257Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a151ac88-2e43-49bc-ba96-36db654cc665",
          "self": "/progress_models/a151ac88-2e43-49bc-ba96-36db654cc665/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/a151ac88-2e43-49bc-ba96-36db654cc665/publish"
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
POST /progress_models/3882945e-5499-4e03-b0ed-1c799e0ae633/archive
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
X-Request-Id: 0c0bb2be-997f-47aa-b048-fa40d08caf72
200 OK
```


```json
{
  "data": {
    "id": "3882945e-5499-4e03-b0ed-1c799e0ae633",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-16T12:40:30.929Z",
      "name": "pm 2",
      "order": 198,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=3882945e-5499-4e03-b0ed-1c799e0ae633",
          "self": "/progress_models/3882945e-5499-4e03-b0ed-1c799e0ae633/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/3882945e-5499-4e03-b0ed-1c799e0ae633/archive"
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
X-Request-Id: 17737c09-a39d-40cf-96b2-e81da1316181
201 Created
```


```json
{
  "data": {
    "id": "ae1c5e95-01c8-4d9b-a517-e3db58d642be",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=ae1c5e95-01c8-4d9b-a517-e3db58d642be",
          "self": "/progress_models/ae1c5e95-01c8-4d9b-a517-e3db58d642be/relationships/progress_steps"
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
X-Request-Id: 6e384e28-2782-44fa-b354-4d23025fd04f
200 OK
```


```json
{
  "data": [
    {
      "id": "4e9b0d49-22b1-4238-b7bc-585bff429dcb",
      "type": "progress_step",
      "attributes": {
        "name": "ps context",
        "order": 1,
        "hex_color": "b2da6d"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/9780c6bd-346f-4128-8637-217c5f337c59"
          }
        }
      }
    },
    {
      "id": "2ad2689c-d250-4ce8-8d1c-34155495b247",
      "type": "progress_step",
      "attributes": {
        "name": "ps ooc",
        "order": 1,
        "hex_color": "8c582a"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/0c90145b-cd26-4388-9bf1-34ad68e3d196"
          }
        }
      }
    },
    {
      "id": "b76cef67-4dc2-463b-bc6a-13b62464b093",
      "type": "progress_step",
      "attributes": {
        "name": "ps oor",
        "order": 1,
        "hex_color": "1198c4"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/d8115593-44f1-4d95-a777-9a4f3f0c2fb9"
          }
        }
      }
    },
    {
      "id": "57774eab-9a09-49e7-8284-adfb79fa6b87",
      "type": "progress_step",
      "attributes": {
        "name": "ps project",
        "order": 1,
        "hex_color": "cf6118"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/8881c997-3b79-4319-b6b7-e72a9f45deec"
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
GET /progress_steps/742bd0c0-49be-4e96-abed-8982bc56962a
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
X-Request-Id: 1a490f7a-2778-426c-9b13-a303c2148df0
200 OK
```


```json
{
  "data": {
    "id": "742bd0c0-49be-4e96-abed-8982bc56962a",
    "type": "progress_step",
    "attributes": {
      "name": "ps oor",
      "order": 1,
      "hex_color": "281b1b"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/1c8d0e9e-0beb-4d2f-803a-a9272282e884"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/742bd0c0-49be-4e96-abed-8982bc56962a"
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
PATCH /progress_steps/114f8dbf-3998-4afa-ab90-f7fb18e7e143
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "114f8dbf-3998-4afa-ab90-f7fb18e7e143",
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
X-Request-Id: 6bc6d2fa-fb6e-4c22-9b3f-7b3d64fedfca
200 OK
```


```json
{
  "data": {
    "id": "114f8dbf-3998-4afa-ab90-f7fb18e7e143",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 1,
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/c6510340-2ea5-46a0-a248-20c7095c04d6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/114f8dbf-3998-4afa-ab90-f7fb18e7e143"
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
DELETE /progress_steps/ec3ac9d6-27f8-4449-b18e-7bfe81ad99d5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c3a146f0-98f4-48ea-8ad1-f7a19754f977
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
POST /progress_models/5da5accf-9de9-4934-abc1-2eef039fdd8f/relationships/progress_steps
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
X-Request-Id: 6543b4b6-f28d-475e-8ac8-5bf5e8a3a9da
201 Created
```


```json
{
  "data": {
    "id": "1e255109-04b8-49d2-9663-ca40cbe6577a",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/5da5accf-9de9-4934-abc1-2eef039fdd8f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/5da5accf-9de9-4934-abc1-2eef039fdd8f/relationships/progress_steps"
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
X-Request-Id: 3c5782e3-8dd3-446f-93ac-05633adb1fd3
200 OK
```


```json
{
  "data": [
    {
      "id": "fae0da6d-0d6d-4cf8-ae11-c7fb9381aaf1",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "905beb43-4e3f-4b30-8781-28090bd1c3cc",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/905beb43-4e3f-4b30-8781-28090bd1c3cc"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/1fbf039b-07f4-467b-a1c9-3b64c54adb51"
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
GET /progress/ce8ba8b5-2e2d-4ff2-bf49-7ee093a515c6
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
X-Request-Id: 1f18493d-f91b-4bcd-9d66-4a2924758020
200 OK
```


```json
{
  "data": {
    "id": "ce8ba8b5-2e2d-4ff2-bf49-7ee093a515c6",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "de8b3f13-3c9f-4022-9e6f-c94bd0e42685",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/de8b3f13-3c9f-4022-9e6f-c94bd0e42685"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/24f7e019-f2e2-4471-b1c6-0ba003bf0818"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/ce8ba8b5-2e2d-4ff2-bf49-7ee093a515c6"
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
DELETE /progress/4de2d578-dd86-43dc-8914-c6db299e4d5b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f7bfd3af-ab71-453d-9ba0-6fe092bc52c1
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
          "id": "487434f3-7355-4d14-99b1-40b30e55e332"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "48292c2c-692d-4d3a-b3e5-e7d9c16ebbd0"
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
X-Request-Id: e8ba3cfc-b99d-42b1-a3fb-f51ed006b235
201 Created
```


```json
{
  "data": {
    "id": "50b404f0-68c6-424e-ab52-6a1eb806cbf9",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "487434f3-7355-4d14-99b1-40b30e55e332",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/487434f3-7355-4d14-99b1-40b30e55e332"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/48292c2c-692d-4d3a-b3e5-e7d9c16ebbd0"
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
X-Request-Id: 5c4df437-fc0a-4ee4-bdde-25b44cf82601
200 OK
```


```json
{
  "data": [
    {
      "id": "f6a2d998-4ff3-4039-ba36-7e589cbcd646",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "e87ce8ff-80e5-4b92-af6d-d299a7de7050"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/e87ce8ff-80e5-4b92-af6d-d299a7de7050"
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
GET /projects/4568d044-893e-4a7c-ba40-0c822f108404/relationships/project_setting
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
X-Request-Id: 51f5136e-f294-4bab-8e54-5b1ffa85e698
200 OK
```


```json
{
  "data": {
    "id": "45f13756-f518-4c36-bc74-8060188e2e39",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "4568d044-893e-4a7c-ba40-0c822f108404"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/4568d044-893e-4a7c-ba40-0c822f108404"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/4568d044-893e-4a7c-ba40-0c822f108404/relationships/project_setting"
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
PATCH /projects/805a72c9-aa5e-47a9-b3a6-f8ca366a6e90/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "805a72c9-aa5e-47a9-b3a6-f8ca366a6e90",
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
X-Request-Id: c247817c-53d6-41f5-80e4-b38bea6a69a9
200 OK
```


```json
{
  "data": {
    "id": "0d9ecd8e-623d-4622-897e-1feb9c5b4311",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "805a72c9-aa5e-47a9-b3a6-f8ca366a6e90"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/805a72c9-aa5e-47a9-b3a6-f8ca366a6e90"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/805a72c9-aa5e-47a9-b3a6-f8ca366a6e90/relationships/project_setting"
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
X-Request-Id: 743e005e-3845-4e14-a8f6-a69f4d4b06e5
200 OK
```


```json
{
  "data": [
    {
      "id": "0b2387c5-0543-4348-a04e-ed20780debbe",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/0b2387c5-0543-4348-a04e-ed20780debbe"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/0b2387c5-0543-4348-a04e-ed20780debbe"
          }
        }
      }
    },
    {
      "id": "2850acaf-2bcc-436c-ae5f-7ade381e59ed",
      "type": "system_element",
      "attributes": {
        "name": "ObjectOccurrence 58441866e2d6-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/2850acaf-2bcc-436c-ae5f-7ade381e59ed"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/2850acaf-2bcc-436c-ae5f-7ade381e59ed"
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
GET /system_elements/abe8950f-f413-473d-83ba-c15a171f2d54
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
X-Request-Id: a7e9112d-981c-43c4-8cdf-2582daa17d17
200 OK
```


```json
{
  "data": {
    "id": "abe8950f-f413-473d-83ba-c15a171f2d54",
    "type": "system_element",
    "attributes": {
      "name": "ObjectOccurrence 3ff08a0b36c8-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/abe8950f-f413-473d-83ba-c15a171f2d54"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/abe8950f-f413-473d-83ba-c15a171f2d54"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/abe8950f-f413-473d-83ba-c15a171f2d54"
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
POST /object_occurrences/04682182-3abd-4717-bd09-4e3bf49abf08/relationships/system_elements
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
      "target_id": "b95a05af-c260-4ca7-847e-11fa3fbe9a21"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 015042b5-d74e-40de-8cc4-ff77cff39278
201 Created
```


```json
{
  "data": {
    "id": "c413f055-a697-4e7b-8d4d-36e3ec16f264",
    "type": "system_element",
    "attributes": {
      "name": "ObjectOccurrence b028249e6a0b-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/c413f055-a697-4e7b-8d4d-36e3ec16f264"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/c413f055-a697-4e7b-8d4d-36e3ec16f264"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/04682182-3abd-4717-bd09-4e3bf49abf08/relationships/system_elements"
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
DELETE /object_occurrences/7a452757-b317-4687-ae52-a587dd71ba89/relationships/system_elements/2826849e-ada5-4060-9e76-1ab0b5bf84b2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5a4c36af-d6eb-403c-a74d-2e1721a82af6
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
POST /object_occurrence_relations/d19cc9a7-8529-4454-97d9-4fe4942e43c7/relationships/owners
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
X-Request-Id: 8e782528-3b72-4ac5-9c0a-c9c8aa3313a0
201 Created
```


```json
{
  "data": {
    "id": "8ac3ea48-693f-4b3a-9e40-509b8b2674ec",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/d19cc9a7-8529-4454-97d9-4fe4942e43c7/relationships/owners"
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
POST /object_occurrence_relations/58cb44d0-dbc7-45c0-a734-ab40ae44d388/relationships/owners
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
X-Request-Id: 4f5ccd16-9d67-4333-b273-31d08cf533f0
201 Created
```


```json
{
  "data": {
    "id": "9a6caf66-6a5e-44a1-af3c-e0a060a30641",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/58cb44d0-dbc7-45c0-a734-ab40ae44d388/relationships/owners"
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
POST /object_occurrence_relations/e26da32e-5a96-42a4-9c4a-2216bd0f736b/relationships/owners
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
    "id": "d3b976eb-fce6-442a-a4eb-fe6814217848"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: af730aae-6f7a-4ac6-96e1-6541a655afca
201 Created
```


```json
{
  "data": {
    "id": "d3b976eb-fce6-442a-a4eb-fe6814217848",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 28",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/e26da32e-5a96-42a4-9c4a-2216bd0f736b/relationships/owners"
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
DELETE /object_occurrence_relations/76267258-d065-433a-b2e5-5612a08a1949/relationships/owners/c3d6299c-b22a-49de-9ca0-a959297644d2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c2cd7971-e50e-4c43-b463-f0f806b681c9
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
X-Request-Id: 36aefde2-8757-4fed-8b16-03639c6cf919
200 OK
```


```json
{
  "data": [
    {
      "id": "8248aa9b-764b-4f78-95f6-03f5d0a6ca92",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation 2377db99f4d9",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "71abdf25-9768-4a34-99d8-5c314fb24d56",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=8248aa9b-764b-4f78-95f6-03f5d0a6ca92",
            "self": "/object_occurrence_relations/8248aa9b-764b-4f78-95f6-03f5d0a6ca92/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "510c9925-a564-4f57-beb0-b39898b87e67",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=8248aa9b-764b-4f78-95f6-03f5d0a6ca92&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/8248aa9b-764b-4f78-95f6-03f5d0a6ca92/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "f641dc16-91f8-4eab-a4e3-9852b3cd94d9",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=8248aa9b-764b-4f78-95f6-03f5d0a6ca92"
          }
        },
        "classification_entry": {
          "data": {
            "id": "02f934c3-46cc-47c0-b767-f9345d0375c6",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/02f934c3-46cc-47c0-b767-f9345d0375c6",
            "self": "/object_occurrence_relations/8248aa9b-764b-4f78-95f6-03f5d0a6ca92/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "38a330bb-727e-4e58-a530-02be627cc2bd",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/38a330bb-727e-4e58-a530-02be627cc2bd",
            "self": "/object_occurrence_relations/8248aa9b-764b-4f78-95f6-03f5d0a6ca92/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "f288b72f-1955-4c35-87b1-6590ce76d759",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/f288b72f-1955-4c35-87b1-6590ce76d759",
            "self": "/object_occurrence_relations/8248aa9b-764b-4f78-95f6-03f5d0a6ca92/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "02f934c3-46cc-47c0-b767-f9345d0375c6",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm e66f05abe051",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=02f934c3-46cc-47c0-b767-f9345d0375c6",
            "self": "/classification_entries/02f934c3-46cc-47c0-b767-f9345d0375c6/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=02f934c3-46cc-47c0-b767-f9345d0375c6",
            "self": "/classification_entries/02f934c3-46cc-47c0-b767-f9345d0375c6/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "510c9925-a564-4f57-beb0-b39898b87e67",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 31",
        "title": null
      }
    },
    {
      "id": "f641dc16-91f8-4eab-a4e3-9852b3cd94d9",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "38b7111c-17e0-4c3f-be4c-c8d05c6dad90",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/38b7111c-17e0-4c3f-be4c-c8d05c6dad90"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/8248aa9b-764b-4f78-95f6-03f5d0a6ca92"
          }
        }
      }
    },
    {
      "id": "71abdf25-9768-4a34-99d8-5c314fb24d56",
      "type": "tag",
      "attributes": {
        "value": "tag value 33"
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
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=9171e5c7-e285-49f3-825c-fa76daa337a7&amp;filter[object_occurrence_source_ids_cont][]=400c8919-1136-476d-b642-d2cc87183724&amp;filter[object_occurrence_target_ids_cont][]=d3d292f7-901e-4cac-b860-098e798b4ded
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;9171e5c7-e285-49f3-825c-fa76daa337a7&quot;, &quot;400c8919-1136-476d-b642-d2cc87183724&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;d3d292f7-901e-4cac-b860-098e798b4ded&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6ca61ac6-939c-4251-adf8-754eea8e5f8d
200 OK
```


```json
{
  "data": [
    {
      "id": "71d896b5-b75b-49bb-8c09-3791358c70b3",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation 1802f60eed66",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "23a736d0-9425-4e67-91ca-55b8df7c5f62",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=71d896b5-b75b-49bb-8c09-3791358c70b3",
            "self": "/object_occurrence_relations/71d896b5-b75b-49bb-8c09-3791358c70b3/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "7a792633-eefb-4501-8892-f5551e96167e",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=71d896b5-b75b-49bb-8c09-3791358c70b3&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/71d896b5-b75b-49bb-8c09-3791358c70b3/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "57ad5fb7-6bc8-4237-8ff4-c06eb27da774",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=71d896b5-b75b-49bb-8c09-3791358c70b3"
          }
        },
        "classification_entry": {
          "data": {
            "id": "c1b8c929-5b6d-4db4-8043-d9c5264b6a97",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/c1b8c929-5b6d-4db4-8043-d9c5264b6a97",
            "self": "/object_occurrence_relations/71d896b5-b75b-49bb-8c09-3791358c70b3/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "d3d292f7-901e-4cac-b860-098e798b4ded",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/d3d292f7-901e-4cac-b860-098e798b4ded",
            "self": "/object_occurrence_relations/71d896b5-b75b-49bb-8c09-3791358c70b3/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "9171e5c7-e285-49f3-825c-fa76daa337a7",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/9171e5c7-e285-49f3-825c-fa76daa337a7",
            "self": "/object_occurrence_relations/71d896b5-b75b-49bb-8c09-3791358c70b3/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "c1b8c929-5b6d-4db4-8043-d9c5264b6a97",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 3d2ed3c3ea11",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=c1b8c929-5b6d-4db4-8043-d9c5264b6a97",
            "self": "/classification_entries/c1b8c929-5b6d-4db4-8043-d9c5264b6a97/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=c1b8c929-5b6d-4db4-8043-d9c5264b6a97",
            "self": "/classification_entries/c1b8c929-5b6d-4db4-8043-d9c5264b6a97/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "7a792633-eefb-4501-8892-f5551e96167e",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 33",
        "title": null
      }
    },
    {
      "id": "57ad5fb7-6bc8-4237-8ff4-c06eb27da774",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "e946ef54-2c3a-4e79-b7e9-832668959e25",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/e946ef54-2c3a-4e79-b7e9-832668959e25"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/71d896b5-b75b-49bb-8c09-3791358c70b3"
          }
        }
      }
    },
    {
      "id": "23a736d0-9425-4e67-91ca-55b8df7c5f62",
      "type": "tag",
      "attributes": {
        "value": "tag value 35"
      },
      "relationships": {
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=9171e5c7-e285-49f3-825c-fa76daa337a7&filter[object_occurrence_source_ids_cont][]=400c8919-1136-476d-b642-d2cc87183724&filter[object_occurrence_target_ids_cont][]=d3d292f7-901e-4cac-b860-098e798b4ded",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=9171e5c7-e285-49f3-825c-fa76daa337a7&filter[object_occurrence_source_ids_cont][]=400c8919-1136-476d-b642-d2cc87183724&filter[object_occurrence_target_ids_cont][]=d3d292f7-901e-4cac-b860-098e798b4ded&include=tags,owners,progress_step_checked,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3
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
X-Request-Id: 4eadaa9f-79b3-4827-8e7b-456a5a00ce26
200 OK
```


```json
{
  "data": {
    "id": "f77748d3-9ad3-4367-b068-3270567a41d3",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "ObjectOccurrenceRelation 3f9c57a15bae",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "091f4791-4b10-4fe7-86f9-57d84cf6cae7",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=f77748d3-9ad3-4367-b068-3270567a41d3",
          "self": "/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "9261afcb-d363-46a1-b527-f5a3a5a02255",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=f77748d3-9ad3-4367-b068-3270567a41d3&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "5dbe45e7-a5d7-43a3-97ab-3a9b5d817218",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=f77748d3-9ad3-4367-b068-3270567a41d3"
        }
      },
      "classification_entry": {
        "data": {
          "id": "7870aac2-0c76-4a6a-9321-08d48c8d66d0",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/7870aac2-0c76-4a6a-9321-08d48c8d66d0",
          "self": "/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "baddc667-ecac-4153-8433-10bd84163d38",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/baddc667-ecac-4153-8433-10bd84163d38",
          "self": "/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "3e1b9325-2436-447f-8235-739463564bc9",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/3e1b9325-2436-447f-8235-739463564bc9",
          "self": "/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3"
  },
  "included": [
    {
      "id": "7870aac2-0c76-4a6a-9321-08d48c8d66d0",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm ccf23328bb73",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=7870aac2-0c76-4a6a-9321-08d48c8d66d0",
            "self": "/classification_entries/7870aac2-0c76-4a6a-9321-08d48c8d66d0/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=7870aac2-0c76-4a6a-9321-08d48c8d66d0",
            "self": "/classification_entries/7870aac2-0c76-4a6a-9321-08d48c8d66d0/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "9261afcb-d363-46a1-b527-f5a3a5a02255",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 35",
        "title": null
      }
    },
    {
      "id": "5dbe45e7-a5d7-43a3-97ab-3a9b5d817218",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "6e5b5c77-fb20-4500-aa3e-09e63b811270",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/6e5b5c77-fb20-4500-aa3e-09e63b811270"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/f77748d3-9ad3-4367-b068-3270567a41d3"
          }
        }
      }
    },
    {
      "id": "091f4791-4b10-4fe7-86f9-57d84cf6cae7",
      "type": "tag",
      "attributes": {
        "value": "tag value 37"
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
X-Request-Id: 0534e4e0-cd03-4686-866d-109f43814859
200 OK
```


```json
{
  "data": [
    {
      "id": "78af9efa07423993974d277bbe9fb5b784b9a1246fed2f4f511d9ebcb6108e81",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "778a0d7f-4796-4a85-87ac-87bc8246fac8",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/778a0d7f-4796-4a85-87ac-87bc8246fac8"
          }
        }
      }
    },
    {
      "id": "4342a2f3a4a69b4d1bce4e0b0594e555323429ae6381b20f1c53aacac015a3ae",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "bc1b58d0-9e9c-4c62-b075-4f96afc4d23d",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/bc1b58d0-9e9c-4c62-b075-4f96afc4d23d"
          }
        }
      }
    },
    {
      "id": "6a312e74933ebe4fe4a6ed4fafb06617c8db4d05b6dfb4a0cfe641187f7af0b3",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "b98e1a8d-5d82-49af-afcd-9c126e75f8e9",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b98e1a8d-5d82-49af-afcd-9c126e75f8e9"
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
X-Request-Id: 37ff7c98-4981-4733-9a8a-f758e6d1ba5d
200 OK
```


```json
{
  "data": [
    {
      "id": "bc868f6c-dfba-4e78-ad6c-3c5369fb921c",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "688ab88f-5f3c-479d-a12a-17c13dfdf51d",
            "type": "project"
          },
          "links": {
            "related": "/projects/688ab88f-5f3c-479d-a12a-17c13dfdf51d"
          }
        },
        "user": {
          "data": {
            "id": "0ef9571e-e8c9-4be8-84a3-0cb7ea4f7717",
            "type": "user"
          },
          "links": {
            "related": "/users/0ef9571e-e8c9-4be8-84a3-0cb7ea4f7717"
          }
        },
        "permission": {
          "data": {
            "id": "76195744-a8e0-47e5-8d8e-3bec58ca7dcd",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/76195744-a8e0-47e5-8d8e-3bec58ca7dcd"
          }
        }
      }
    },
    {
      "id": "41f1363e-f4c0-44d3-a5f0-495fb19deff4",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "da207b2c-4fbf-49f7-bab8-cbfdb7ae2f97",
            "type": "context"
          },
          "links": {
            "related": "/contexts/da207b2c-4fbf-49f7-bab8-cbfdb7ae2f97"
          }
        },
        "user": {
          "data": {
            "id": "0ef9571e-e8c9-4be8-84a3-0cb7ea4f7717",
            "type": "user"
          },
          "links": {
            "related": "/users/0ef9571e-e8c9-4be8-84a3-0cb7ea4f7717"
          }
        },
        "permission": {
          "data": {
            "id": "cbfcea73-6aea-4061-9458-7039a216e7d2",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/cbfcea73-6aea-4061-9458-7039a216e7d2"
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
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=641f5388-b4bd-4571-a9e5-b4b6ea71295b&amp;filter[user_id_eq]=3a036975-57f1-4fd9-8d54-a36aeecbe380&amp;filter[permission_id_eq]=b6d11147-8a15-4f5b-8631-f08574695d6f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;641f5388-b4bd-4571-a9e5-b4b6ea71295b&quot;, &quot;user_id_eq&quot;=&gt;&quot;3a036975-57f1-4fd9-8d54-a36aeecbe380&quot;, &quot;permission_id_eq&quot;=&gt;&quot;b6d11147-8a15-4f5b-8631-f08574695d6f&quot;}
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
X-Request-Id: 68e55018-5d8b-4bb3-8e81-054761fc3bd9
200 OK
```


```json
{
  "data": [
    {
      "id": "e17f3098-973c-4b6f-a418-538848bfcfd9",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "641f5388-b4bd-4571-a9e5-b4b6ea71295b",
            "type": "project"
          },
          "links": {
            "related": "/projects/641f5388-b4bd-4571-a9e5-b4b6ea71295b"
          }
        },
        "user": {
          "data": {
            "id": "3a036975-57f1-4fd9-8d54-a36aeecbe380",
            "type": "user"
          },
          "links": {
            "related": "/users/3a036975-57f1-4fd9-8d54-a36aeecbe380"
          }
        },
        "permission": {
          "data": {
            "id": "b6d11147-8a15-4f5b-8631-f08574695d6f",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/b6d11147-8a15-4f5b-8631-f08574695d6f"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/user_permissions?filter[target_type_eq]=project&filter[target_id_eq]=641f5388-b4bd-4571-a9e5-b4b6ea71295b&filter[user_id_eq]=3a036975-57f1-4fd9-8d54-a36aeecbe380&filter[permission_id_eq]=b6d11147-8a15-4f5b-8631-f08574695d6f",
    "current": "http://example.org/user_permissions?filter[permission_id_eq]=b6d11147-8a15-4f5b-8631-f08574695d6f&filter[target_id_eq]=641f5388-b4bd-4571-a9e5-b4b6ea71295b&filter[target_type_eq]=project&filter[user_id_eq]=3a036975-57f1-4fd9-8d54-a36aeecbe380&page[number]=1"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /user_permissions/e15e48e5-fd79-4263-b67c-d636064266c4
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
X-Request-Id: 4bdea228-64f1-46cd-a671-7da5320d3d52
200 OK
```


```json
{
  "data": {
    "id": "e15e48e5-fd79-4263-b67c-d636064266c4",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "7129cd22-9ef9-49eb-8903-189635946899",
          "type": "project"
        },
        "links": {
          "related": "/projects/7129cd22-9ef9-49eb-8903-189635946899"
        }
      },
      "user": {
        "data": {
          "id": "36a76959-1453-4618-9712-c10e04a89405",
          "type": "user"
        },
        "links": {
          "related": "/users/36a76959-1453-4618-9712-c10e04a89405"
        }
      },
      "permission": {
        "data": {
          "id": "caf9cd41-5af4-4cc8-a513-f1fc2f7849c0",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/caf9cd41-5af4-4cc8-a513-f1fc2f7849c0"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions/e15e48e5-fd79-4263-b67c-d636064266c4"
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
          "id": "d343eb4f-d2fc-42d0-927d-5455c388107e"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "dc1902fc-6e62-4267-af47-fba4a1dfdd80"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "89b4f3a5-0179-4371-90cc-b2624132e1f0"
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
X-Request-Id: 90cb9f23-4de4-433e-b609-b14d059ce10e
201 Created
```


```json
{
  "data": {
    "id": "daae4899-02f4-46a5-a06b-aba8cf3bba6c",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "d343eb4f-d2fc-42d0-927d-5455c388107e",
          "type": "project"
        },
        "links": {
          "related": "/projects/d343eb4f-d2fc-42d0-927d-5455c388107e"
        }
      },
      "user": {
        "data": {
          "id": "89b4f3a5-0179-4371-90cc-b2624132e1f0",
          "type": "user"
        },
        "links": {
          "related": "/users/89b4f3a5-0179-4371-90cc-b2624132e1f0"
        }
      },
      "permission": {
        "data": {
          "id": "dc1902fc-6e62-4267-af47-fba4a1dfdd80",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/dc1902fc-6e62-4267-af47-fba4a1dfdd80"
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
DELETE /user_permissions/40fd363e-f9be-4cfa-a17c-0b636a863391
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a12ffc9e-0901-4aba-aaad-46328130e1e1
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
X-Request-Id: 10d325c5-f773-4992-bb24-6401608ce0ab
200 OK
```


```json
{
  "data": {
    "id": "b8932855-e3b0-40aa-bd6e-a8a428db817c",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "8831c2f9-d024-45bc-9036-925d7aab83d1"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/8831c2f9-d024-45bc-9036-925d7aab83d1"
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
X-Request-Id: 7a892d82-7b9a-4659-8b28-7f6b4427547a
200 OK
```


```json
{
  "data": {
    "id": "c4a993dd-c72f-445b-b27e-cded2bd8f499",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "0e7214c2-3277-43b0-b985-2d731a0640fd"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/0e7214c2-3277-43b0-b985-2d731a0640fd"
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
GET /chain_analysis/ff9359a2-dc40-4faa-9243-b8c3aa2108e7?steps=2
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
X-Request-Id: 8a8acb3a-2367-45ee-90fb-f2b071bc9a64
200 OK
```


```json
{
  "data": [
    {
      "id": "6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC3",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45",
            "self": "/object_occurrences/6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/2a62f465-cd9b-4127-a109-56778ff3a06f"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ee1dccf9-05c3-42c8-8edb-a7ddd851b138",
            "self": "/object_occurrences/6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=6d6e30bf-72a5-4ff5-a2cb-b85ecdaf5f45"
          }
        }
      }
    },
    {
      "id": "be1c339f-1a36-4ad7-a9f2-939ae50b74db",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC1",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=be1c339f-1a36-4ad7-a9f2-939ae50b74db",
            "self": "/object_occurrences/be1c339f-1a36-4ad7-a9f2-939ae50b74db/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=be1c339f-1a36-4ad7-a9f2-939ae50b74db&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/be1c339f-1a36-4ad7-a9f2-939ae50b74db/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=be1c339f-1a36-4ad7-a9f2-939ae50b74db"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/2a62f465-cd9b-4127-a109-56778ff3a06f"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ee1dccf9-05c3-42c8-8edb-a7ddd851b138",
            "self": "/object_occurrences/be1c339f-1a36-4ad7-a9f2-939ae50b74db/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/be1c339f-1a36-4ad7-a9f2-939ae50b74db/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=be1c339f-1a36-4ad7-a9f2-939ae50b74db"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=be1c339f-1a36-4ad7-a9f2-939ae50b74db"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=be1c339f-1a36-4ad7-a9f2-939ae50b74db"
          }
        }
      }
    },
    {
      "id": "bbc2da99-50b4-453b-a564-b9bb74562ebe",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "image_key": null,
        "name": "OOC4",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": null,
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=bbc2da99-50b4-453b-a564-b9bb74562ebe",
            "self": "/object_occurrences/bbc2da99-50b4-453b-a564-b9bb74562ebe/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=bbc2da99-50b4-453b-a564-b9bb74562ebe&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/bbc2da99-50b4-453b-a564-b9bb74562ebe/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=bbc2da99-50b4-453b-a564-b9bb74562ebe"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/2a62f465-cd9b-4127-a109-56778ff3a06f"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ee1dccf9-05c3-42c8-8edb-a7ddd851b138",
            "self": "/object_occurrences/bbc2da99-50b4-453b-a564-b9bb74562ebe/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/bbc2da99-50b4-453b-a564-b9bb74562ebe/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=bbc2da99-50b4-453b-a564-b9bb74562ebe"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=bbc2da99-50b4-453b-a564-b9bb74562ebe"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=bbc2da99-50b4-453b-a564-b9bb74562ebe"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/chain_analysis/ff9359a2-dc40-4faa-9243-b8c3aa2108e7?steps=2",
    "current": "http://example.org/chain_analysis/ff9359a2-dc40-4faa-9243-b8c3aa2108e7?page[number]=1&steps=2"
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


# Files

Fetch get url which will be available for next 15 minutes. URL might be directly applied like a link to file -
depends on type of object, might be downloaded or even inline attached if it's kind of image.


## Generate GET URL


### Request

#### Endpoint

```plaintext
GET utils/files?key=directory%2F1234abcde%2Epng
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET utils/files?key=directory%2F1234abcde%2Epng`

#### Parameters


```json
key: directory/1234abcde.png
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2d797c37-1c07-4560-9f09-dfcc250ad2d8
200 OK
```


```json
{
  "data": {
    "id": "directory/1234abcde.png",
    "type": "url_struct",
    "attributes": {
      "id": "directory/1234abcde.png",
      "url": "https://qa-sec-hub-document-bucket.s3.eu-west-1.amazonaws.com/directory/1234abcde.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20200516%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20200516T124119Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=e5161167bc3655e146dbaf14df0faef1e8dab42893ea1be85d0cfce77371634c",
      "extension": null
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][url] | URL which might be used in next 15 minutes for fetch file |
| data[attributes][id] | Randomly generated key of file which will be a name of uploaded file |


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
X-Request-Id: 4bb0c7d1-73e1-4353-9b4a-c78f192e5348
200 OK
```


```json
{
  "data": [
    {
      "id": "eb6faaee-dc7e-476f-a9fd-444fe9b1022f",
      "type": "tag",
      "attributes": {
        "value": "tag value 39"
      },
      "relationships": {
      }
    },
    {
      "id": "bb507e0b-f75e-488e-a058-5a96a598a3d4",
      "type": "tag",
      "attributes": {
        "value": "tag value 40"
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
X-Request-Id: 7712454d-a2e2-4ad5-ab5f-7fdd53056b5c
200 OK
```


```json
{
  "meta": {
    "total_count": 0
  },
  "links": {
    "self": "http://example.org/permissions",
    "current": "http://example.org/permissions?page[number]=1&sort=name"
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
GET /permissions/4d6173ee-f9ee-4623-8c80-8288df3094fa
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
X-Request-Id: eea2c70d-9eaf-4bf3-9806-6678129f0875
200 OK
```


```json
{
  "data": {
    "id": "4d6173ee-f9ee-4623-8c80-8288df3094fa",
    "type": "permission",
    "attributes": {
      "name": "account:write",
      "description": "MyText"
    }
  },
  "links": {
    "self": "http://example.org/permissions/4d6173ee-f9ee-4623-8c80-8288df3094fa"
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
GET /utils/path/from/object_occurrence/5f2e5a70-2255-4e12-b4ef-050a8e807de7/to/object_occurrence/c4663137-4c1e-4e1a-8d38-18f7115f2c9d
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
X-Request-Id: 71f1dbd7-9c71-4543-af33-5e18bd5924da
200 OK
```


```json
[
  {
    "id": "5f2e5a70-2255-4e12-b4ef-050a8e807de7",
    "type": "object_occurrence"
  },
  {
    "id": "7a7869cc-c852-4b18-8d4e-6da30f7108b8",
    "type": "object_occurrence"
  },
  {
    "id": "94d2ef32-3761-497b-b32f-a8b76a085413",
    "type": "object_occurrence"
  },
  {
    "id": "4156c44b-a1d2-460c-a327-564d13a19246",
    "type": "object_occurrence"
  },
  {
    "id": "f0126603-c9f8-414c-895c-f1729b4e18f0",
    "type": "object_occurrence"
  },
  {
    "id": "1d31c623-19a6-40a6-ac62-f70a7a36e298",
    "type": "object_occurrence"
  },
  {
    "id": "c4663137-4c1e-4e1a-8d38-18f7115f2c9d",
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
X-Request-Id: dfcbc6eb-6e51-4b66-96c6-62eecbab3cc7
200 OK
```


```json
{
  "data": [
    {
      "id": "8bdb04d1-07d5-4cb9-beaa-e35d0744bfb4",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/c00a1a48-a345-4e78-9a2c-2d4e7a7439eb"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/c9240078-7b31-4697-8084-c42ff27c401e"
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
    "current": "http://example.org/events?page[number]=1&sort=created_at"
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
X-Request-Id: 60d59936-5b38-4cc5-b42a-82390934fd37
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



