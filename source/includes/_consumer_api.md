# SEC-Hub Consumer API

This API exposes information that allowes an authenticated client to manipulate the CORE, SIMO,
DOCU, DOMA, and STEM concepts.

This documentation's permalink is: [https://docs.sec-hub.com](https://docs.sec-hub.com)

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

## File uploading

File uploading happens through direct binary file upload to S3: Because the JSON:API doens't
support binary data, because pushing images through the API creates a bottle-neck, and because
direct S3 file upload allows the client to initiate chunked upload.

The flow is as follows:

<ol>
  <li><code>POST</code> to the file/image relationship endpoint to retrieve the direct S3 file upload.</li>
  <li>Then upload the file to S3</li>
  <li>Then <code>GET</code> the file/image relationship endpoint to retrieve a link to the file</li>
</ol>

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

Example:

When classification table is created using using default locale (no `Accept-Language` header),
translated attributes (name & description) are saved as english translations and there
will be `"current_locale": "en", "locales": ["en"]` in the meta data of given classification
table. But when we edit it with `"Accept-Language": "da-DK"`, new name & description
will be saved ad danish translation. (`"current_locale": "da", "locales": ["en", "da"]`).
But when we switch back to the english header, the old values will be served with
`"current_locale": "en", "locales": ["en", "da"]` meta data.

## Indirect responses

```
POST /contexts/be1b08ae-0bc6-496b-9416-9e87e1239d25/revision

202 Accepted
```

```js
const subdomain = "<your account subdomain>";
const id = "<context ID>";
const token = "<OAuth2 bearer token>";
const url = `wss://${subdomain}-wss.sec.hub.com/?type=context&item_id=${id}&authorization=${token}`;
const socket = new WebSocket(url);
```

Some endpoints of the API are designed to start long-running background processes.
These will respond with 202 Accepted. When the background process consludes a message will be send via WebSockets to the client.
The client should connect to the websockets channel for the related context
before executing requests that returns 202 Accepted to ensure that the
response is caught. The act of connecting to WebSockets may take longer than
sending the response in which case the response will be missed by the client.

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
X-Request-Id: 62e35184-3472-4e3f-a708-2996e78094e8
200 OK
```


```json
{
  "data": {
    "id": "7b953799-92c4-4cfa-8f0e-a6f2bea4259e",
    "type": "account",
    "attributes": {
      "name": "Account 7f43a272f99d"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects",
          "self": "/projects"
        }
      }
    },
    "meta": {
    }
  },
  "meta": {
    "version": "0.9.1-rc1",
    "changelog_link": "http://sec-hub-api-changelog.s3-website-eu-west-1.amazonaws.com/CHANGELOG-0.9.1-rc1.md"
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
X-Request-Id: c1c9ff2d-1724-464c-8179-bf3d28d38ecb
200 OK
```


```json
{
  "data": {
    "id": "86df2ba4-d990-4e3f-8f4c-9b16635a33f3",
    "type": "account",
    "attributes": {
      "name": "Account 1b6e81fb90dc"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects",
          "self": "/projects"
        }
      }
    },
    "meta": {
    }
  },
  "meta": {
    "version": "0.9.1-rc1",
    "changelog_link": "http://sec-hub-api-changelog.s3-website-eu-west-1.amazonaws.com/CHANGELOG-0.9.1-rc1.md"
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
    "id": "143facd4-71c9-4ba1-bda2-56db7f2cc427",
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
X-Request-Id: bada7360-1989-4547-9a73-4a58106e5d6f
200 OK
```


```json
{
  "data": {
    "id": "143facd4-71c9-4ba1-bda2-56db7f2cc427",
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
    },
    "meta": {
    }
  },
  "meta": {
    "version": "0.9.1-rc1",
    "changelog_link": "http://sec-hub-api-changelog.s3-website-eu-west-1.amazonaws.com/CHANGELOG-0.9.1-rc1.md"
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
X-Request-Id: fe9e7a14-b4c4-43fe-b26d-8b97d97c8401
200 OK
```


```json
{
  "data": [
    {
      "id": "62886117-7c52-4520-a30a-441e83dc0294",
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
              "id": "7546d5e1-f324-46fa-95c6-5a299357f401_62886117-7c52-4520-a30a-441e83dc0294",
              "type": "progress_step_checked"
            }
          ]
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=62886117-7c52-4520-a30a-441e83dc0294",
            "self": "/projects/62886117-7c52-4520-a30a-441e83dc0294/relationships/contexts",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "7546d5e1-f324-46fa-95c6-5a299357f401_62886117-7c52-4520-a30a-441e83dc0294",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "7546d5e1-f324-46fa-95c6-5a299357f401",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/7546d5e1-f324-46fa-95c6-5a299357f401"
          }
        },
        "target": {
          "links": {
            "related": "/projects/62886117-7c52-4520-a30a-441e83dc0294"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
GET /projects/f8c27c50-d242-4ed7-9448-1bc042743d72
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
X-Request-Id: 7518f729-9b11-4215-81d6-854ae86a5ebe
200 OK
```


```json
{
  "data": {
    "id": "f8c27c50-d242-4ed7-9448-1bc042743d72",
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
            "id": "3d7d6490-df48-4583-a2fd-0e7ee2ec1f65_f8c27c50-d242-4ed7-9448-1bc042743d72",
            "type": "progress_step_checked"
          }
        ]
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=f8c27c50-d242-4ed7-9448-1bc042743d72",
          "self": "/projects/f8c27c50-d242-4ed7-9448-1bc042743d72/relationships/contexts",
          "meta": {
            "count": 0
          }
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/projects/f8c27c50-d242-4ed7-9448-1bc042743d72"
  },
  "included": [
    {
      "id": "3d7d6490-df48-4583-a2fd-0e7ee2ec1f65_f8c27c50-d242-4ed7-9448-1bc042743d72",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "3d7d6490-df48-4583-a2fd-0e7ee2ec1f65",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/3d7d6490-df48-4583-a2fd-0e7ee2ec1f65"
          }
        },
        "target": {
          "links": {
            "related": "/projects/f8c27c50-d242-4ed7-9448-1bc042743d72"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
PATCH /projects/376b047e-08f5-4f33-8eba-539a7d49b363
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "376b047e-08f5-4f33-8eba-539a7d49b363",
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
X-Request-Id: db361b0d-8ae2-4bf1-af64-72b9612dd62e
200 OK
```


```json
{
  "data": {
    "id": "376b047e-08f5-4f33-8eba-539a7d49b363",
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
            "id": "bae055fb-a221-41a2-90cd-6869fa4025f1_376b047e-08f5-4f33-8eba-539a7d49b363",
            "type": "progress_step_checked"
          }
        ]
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=376b047e-08f5-4f33-8eba-539a7d49b363",
          "self": "/projects/376b047e-08f5-4f33-8eba-539a7d49b363/relationships/contexts",
          "meta": {
            "count": 0
          }
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/projects/376b047e-08f5-4f33-8eba-539a7d49b363"
  },
  "included": [
    {
      "id": "bae055fb-a221-41a2-90cd-6869fa4025f1_376b047e-08f5-4f33-8eba-539a7d49b363",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "bae055fb-a221-41a2-90cd-6869fa4025f1",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/bae055fb-a221-41a2-90cd-6869fa4025f1"
          }
        },
        "target": {
          "links": {
            "related": "/projects/376b047e-08f5-4f33-8eba-539a7d49b363"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
POST /projects/2500f8e6-3025-4d69-90ad-87c792ea7613/archive
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
X-Request-Id: fd56a26f-1f19-4491-af6d-c23320f36be4
200 OK
```


```json
{
  "data": {
    "id": "2500f8e6-3025-4d69-90ad-87c792ea7613",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-11-20T12:44:37.341Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "183ebcb4-c23b-43ce-8af4-0558c7989ee6_2500f8e6-3025-4d69-90ad-87c792ea7613",
            "type": "progress_step_checked"
          }
        ]
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=2500f8e6-3025-4d69-90ad-87c792ea7613",
          "self": "/projects/2500f8e6-3025-4d69-90ad-87c792ea7613/relationships/contexts",
          "meta": {
            "count": 0
          }
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/projects/2500f8e6-3025-4d69-90ad-87c792ea7613/archive"
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
DELETE /projects/fdfa6769-9c93-49fd-bff6-cdcefbf5af5c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2181525a-2058-487a-aee4-95fc0553b13e
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
X-Request-Id: c78903ff-fe30-4397-8e14-60c0a038c81b
200 OK
```


```json
{
  "data": [
    {
      "id": "92655d53-8373-40e5-800c-b0f4343c7443",
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
              "id": "625014d9-eb8e-4d51-bd85-eb38bd121fc9_92655d53-8373-40e5-800c-b0f4343c7443",
              "type": "progress_step_checked"
            }
          ]
        },
        "project": {
          "links": {
            "related": "/projects/4a35eafb-69d9-4ef7-92ad-763e73d1df16"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/43f75ac8-7908-4531-9a10-89397c956072"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/03410093-ad3b-4529-a35a-7da531e00aff"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "f2b2671f-62b1-417e-a516-0d38210177ab",
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

          ]
        },
        "project": {
          "links": {
            "related": "/projects/4a35eafb-69d9-4ef7-92ad-763e73d1df16"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/7fe8a2d2-50c9-4c4e-a184-addb0225c792"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/03410093-ad3b-4529-a35a-7da531e00aff"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "dbc99368-a3e6-4d12-8135-1cea28c609fd",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context e9b4dc875502",
        "published_at": null,
        "revision": 0,
        "validation_level": "strict"
      },
      "relationships": {
        "progress_step_checked": {
          "data": [

          ]
        },
        "project": {
          "links": {
            "related": "/projects/4a35eafb-69d9-4ef7-92ad-763e73d1df16"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/e3165633-648e-4fee-ba07-83aaf383073e"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/03410093-ad3b-4529-a35a-7da531e00aff"
          }
        },
        "trade_study": {
          "data": {
            "id": "e0d7d3d0-7755-427e-a442-7ce1910eed63",
            "type": "trade_study"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "625014d9-eb8e-4d51-bd85-eb38bd121fc9_92655d53-8373-40e5-800c-b0f4343c7443",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "625014d9-eb8e-4d51-bd85-eb38bd121fc9",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/625014d9-eb8e-4d51-bd85-eb38bd121fc9"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/92655d53-8373-40e5-800c-b0f4343c7443"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 3
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
GET /contexts/5fc80b9e-5434-4dc2-8d97-994d3a4ab0a7
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
X-Request-Id: 01edf243-b0a1-4104-8eb8-2d721aa1693d
200 OK
```


```json
{
  "data": {
    "id": "5fc80b9e-5434-4dc2-8d97-994d3a4ab0a7",
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
            "id": "485172db-6817-4b94-9458-824ccac06e25_5fc80b9e-5434-4dc2-8d97-994d3a4ab0a7",
            "type": "progress_step_checked"
          }
        ]
      },
      "project": {
        "links": {
          "related": "/projects/bcc0dcb4-7eaa-4894-b93e-104df86bbe63"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/fbc71aba-f726-4aa1-8713-049f7ab70c5b"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/782bdd65-4026-4aab-9174-f90d2844cbb6"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/contexts/5fc80b9e-5434-4dc2-8d97-994d3a4ab0a7"
  },
  "included": [
    {
      "id": "485172db-6817-4b94-9458-824ccac06e25_5fc80b9e-5434-4dc2-8d97-994d3a4ab0a7",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "485172db-6817-4b94-9458-824ccac06e25",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/485172db-6817-4b94-9458-824ccac06e25"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/5fc80b9e-5434-4dc2-8d97-994d3a4ab0a7"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
PATCH /contexts/124aede7-1a81-4413-88cd-7f61e4369184
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "124aede7-1a81-4413-88cd-7f61e4369184",
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
X-Request-Id: 8192d9a5-cf97-4ab3-99fb-69dedd62f630
200 OK
```


```json
{
  "data": {
    "id": "124aede7-1a81-4413-88cd-7f61e4369184",
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
            "id": "9751dd5b-86a0-434c-bc38-84e871b9ffce_124aede7-1a81-4413-88cd-7f61e4369184",
            "type": "progress_step_checked"
          }
        ]
      },
      "project": {
        "links": {
          "related": "/projects/1af72416-a756-43f7-9bc2-9f7d58f1eb8a"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/9bae3365-a127-4395-a07c-42e27c000947"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/399f7352-e21d-4968-81a3-116e4f04e8dd"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/contexts/124aede7-1a81-4413-88cd-7f61e4369184"
  },
  "included": [
    {
      "id": "9751dd5b-86a0-434c-bc38-84e871b9ffce_124aede7-1a81-4413-88cd-7f61e4369184",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "9751dd5b-86a0-434c-bc38-84e871b9ffce",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/9751dd5b-86a0-434c-bc38-84e871b9ffce"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/124aede7-1a81-4413-88cd-7f61e4369184"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
POST /projects/2ecee9b7-24f1-464b-abaa-cc3edf07f33c/relationships/contexts
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
          "id": "3abddb54-3f9e-4faa-afef-2441b43ebef3"
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
X-Request-Id: b68aa8ec-b63e-4c11-94e8-be6999d04369
201 Created
```


```json
{
  "data": {
    "id": "bce73de1-e8ec-43b5-8301-485a68ecaa40",
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

        ]
      },
      "project": {
        "links": {
          "related": "/projects/2ecee9b7-24f1-464b-abaa-cc3edf07f33c"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/3265f568-4c17-4e55-be48-acb1ca4df1b5"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/3abddb54-3f9e-4faa-afef-2441b43ebef3"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/projects/2ecee9b7-24f1-464b-abaa-cc3edf07f33c/relationships/contexts"
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
POST /contexts/d9fd072f-fb25-41df-ba98-f640e67280e2/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/6ac3b3a9dd97c8c075798241
Content-Type: application/vnd.api+json
X-Request-Id: bd0e96a0-7c34-423e-a9ee-1c52bc74f980
202 Accepted
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
DELETE /contexts/d5b25a79-86f4-4371-8895-054381f05861
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6cf9aabf-11c1-43c7-8edb-1fefd4aa1b15
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
POST /object_occurrences/352e7010-2547-414a-bede-73d7f6a92fe6/relationships/tags
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
X-Request-Id: 5113c641-7843-4284-90f8-221d87ff65c5
201 Created
```


```json
{
  "data": {
    "id": "6bddfc18-11b6-4a79-9ef7-12b028318dae",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/352e7010-2547-414a-bede-73d7f6a92fe6/relationships/tags"
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
POST /object_occurrences/918c8105-2bf1-4b72-ad2c-a464c3b9e22c/relationships/tags
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
    "id": "d500d379-5e01-459a-bcab-604ac92e4bc8"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 582fbc06-cf65-4def-b7e5-c78cd0aa8b3d
201 Created
```


```json
{
  "data": {
    "id": "d500d379-5e01-459a-bcab-604ac92e4bc8",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/918c8105-2bf1-4b72-ad2c-a464c3b9e22c/relationships/tags"
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
DELETE /object_occurrences/ae52384b-7631-45a4-83f7-735cea43c83f/relationships/tags/9812cfbe-885f-478d-9cde-4be36fe983a7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 28156f79-46da-4122-9108-be64b39c9f17
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/10a90cbf-dc14-4838-a66f-2cf9f070f0c7/relationships/owners
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
X-Request-Id: 2ad1f4a8-a93f-47da-bfd6-97da0c951424
201 Created
```


```json
{
  "data": {
    "id": "c2b003f5-c4b7-41b7-9bc8-351bf323c88d",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/10a90cbf-dc14-4838-a66f-2cf9f070f0c7/relationships/owners"
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
POST /object_occurrences/826688fe-8d5d-497f-a5d6-b79fb8306417/relationships/owners
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
X-Request-Id: 08e89b52-749a-4b76-a65f-f5d7b45b4503
201 Created
```


```json
{
  "data": {
    "id": "0c88e282-13e1-4827-98f5-52c02a76a3e5",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/826688fe-8d5d-497f-a5d6-b79fb8306417/relationships/owners"
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
POST /object_occurrences/f8c2d5bf-5580-4bb7-a612-8401fa0b8b91/relationships/owners
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
    "id": "2eefdf38-6e5d-4b29-80b9-ae512eae4dab"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 96c4ab8c-634a-4add-af52-07e399d5748b
201 Created
```


```json
{
  "data": {
    "id": "2eefdf38-6e5d-4b29-80b9-ae512eae4dab",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 7",
      "title": null
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f8c2d5bf-5580-4bb7-a612-8401fa0b8b91/relationships/owners"
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
DELETE /object_occurrences/64ef4ed2-0b6e-4103-8735-b2db857456d8/relationships/owners/92997e11-854e-4de9-b224-f011682194f5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e8cf9c5c-de9b-4cc5-9579-36530bc05b19
204 No Content
```




## Image upload URL

Generate a direct upload URL to use when uploading the image.

After calling this endpoint use the generated URL to upload the image directly to S3.

<aside class="notice">
  The generated URL is only valid for 15 minutes
</aside>

<aside class="notice">
  The <code>content_type</code> parameter value should be send as the <code>Content-Type</code>
  header when uploading the file to the resulting URL.
</aside>


### Request

#### Endpoint

```plaintext
POST /object_occurrences/c604ca06-5f7d-45bd-a28c-34d7b8f5a931/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/relationships/image`

#### Parameters


```json
{
  "data": {
    "type": "url_struct",
    "attributes": {
      "content_type": "plain/text"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][content_type] *required* | File HTTP Content-Type of the file to upload to S3 |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8329ebb1-8c5f-434a-ab66-d4dbbf8c3669
201 Created
```


```json
{
  "data": {
    "id": "c604ca06-5f7d-45bd-a28c-34d7b8f5a931",
    "type": "url_struct",
    "attributes": {
      "url": "http://localstack:4566/qa-sec-hub-document-bucket/c604ca06-5f7d-45bd-a28c-34d7b8f5a931?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stub%2F20201120%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20201120T124548Z&X-Amz-Expires=900&X-Amz-SignedHeaders=content-type%3Bhost&X-Amz-Signature=7faeb45aaef779dc3ef4702b0b0ab4bb0876dc68042fbbd393f332f6b8e1c738"
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c604ca06-5f7d-45bd-a28c-34d7b8f5a931/relationships/image"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[id] | S3 object ID |
| data[type] | Data type |
| data[attributes][url] | Upload URL |


## Image URL

Get attached image URL


### Request

#### Endpoint

```plaintext
GET /object_occurrences/b854d2d2-fbd4-48a9-b7bf-833b4120468c/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/:id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e3fd70cf-f75a-4083-b93d-2c2849b301aa
200 OK
```


```json
{
  "data": {
    "id": "b854d2d2-fbd4-48a9-b7bf-833b4120468c",
    "type": "url_struct",
    "attributes": {
      "url": "http://localstack:4566/qa-sec-hub-document-bucket/b854d2d2-fbd4-48a9-b7bf-833b4120468c?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stub%2F20201120%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20201120T124551Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=87279b23e5774cb8c82ef2c742c7605e4bab87aa512dbba245f22eb2ce6c500f"
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b854d2d2-fbd4-48a9-b7bf-833b4120468c/relationships/image"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[id] | S3 object ID |
| data[type] | Data type |
| data[attributes][url] | URL |


## is expected to eql 404


### Request

#### Endpoint

```plaintext
GET /object_occurrences/ef25351d-cbe2-4bff-aeaf-a9d3918348dc/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/:id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b5183925-79ca-4d48-a48a-0a61fe4e1252
404 Not Found
```


```json
{
  "errors": [
    {
      "code": "1005",
      "silence": true,
      "id": "b5183925-79ca-4d48-a48a-0a61fe4e1252",
      "links": {
        "about": "https://docs.sec-hub.com"
      },
      "status": 404,
      "title": "File doesn't exist"
    }
  ]
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[id] | S3 object ID |
| data[type] | Data type |
| data[attributes][url] | URL |


## Delete image

Deletes the image (if any) associated with the resource


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/3166b43d-ab7f-4782-bee9-886afcb0571c/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 111440e0-887c-428f-ae1b-59b81a9d2881
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
| filter[with_externals]  | filter by type, it might be true or false what means, we are able to show all OOC's or only internal ones |
| filter[syntax_element_id_in]  | filter by syntax elements ids |
| filter[ooc_classification_code_in]  | filter by classification codes |
| filter[components_blank]  | filter by blank components |
| filter[exclude]  | exclude object occurrences by ids |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f22902c8-774f-4146-aa9c-10099b6a38e1
200 OK
```


```json
{
  "data": [
    {
      "id": "b58cd525-f399-4faf-ab68-23ff84febe3f",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "Context 1",
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
            "related": "/tags?filter[target_id_eq]=b58cd525-f399-4faf-ab68-23ff84febe3f",
            "self": "/object_occurrences/b58cd525-f399-4faf-ab68-23ff84febe3f/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=b58cd525-f399-4faf-ab68-23ff84febe3f&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/b58cd525-f399-4faf-ab68-23ff84febe3f/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "b58cd525-f399-4faf-ab68-23ff84febe3f",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/b58cd525-f399-4faf-ab68-23ff84febe3f/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/996fa5b5-7584-4df7-8212-18fd03daaaf3"
          }
        },
        "components": {
          "data": [
            {
              "id": "391f2b73-3b36-4eae-bb68-fdbb4029cfce",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/b58cd525-f399-4faf-ab68-23ff84febe3f/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "7e4e4ad8-de2f-47ce-a41d-e84695bec20b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b58cd525-f399-4faf-ab68-23ff84febe3f"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b58cd525-f399-4faf-ab68-23ff84febe3f"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "f122b371-807a-40af-8844-d23fc71856f8",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "Context 2",
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
            "related": "/tags?filter[target_id_eq]=f122b371-807a-40af-8844-d23fc71856f8",
            "self": "/object_occurrences/f122b371-807a-40af-8844-d23fc71856f8/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=f122b371-807a-40af-8844-d23fc71856f8&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/f122b371-807a-40af-8844-d23fc71856f8/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "f122b371-807a-40af-8844-d23fc71856f8",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/f122b371-807a-40af-8844-d23fc71856f8/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/b0e298b8-c2d2-455d-8a2c-1820591e2e37"
          }
        },
        "components": {
          "data": [
            {
              "id": "a9020ebd-aaa5-453e-a1b2-af8df6fad2e8",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/f122b371-807a-40af-8844-d23fc71856f8/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "7e4e4ad8-de2f-47ce-a41d-e84695bec20b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=f122b371-807a-40af-8844-d23fc71856f8"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=f122b371-807a-40af-8844-d23fc71856f8"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "391f2b73-3b36-4eae-bb68-fdbb4029cfce",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC 1",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "177967",
        "number": "1",
        "validation_errors": [

        ],
        "classification_code": "A"
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "99d1a9ec-99ff-4ec1-829b-c83a9ceadd3f",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=391f2b73-3b36-4eae-bb68-fdbb4029cfce",
            "self": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "0f086c7b-aa4b-4481-9658-9c36b5d1f238",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=391f2b73-3b36-4eae-bb68-fdbb4029cfce&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "54cec733-00ab-41ad-bbde-c2ba345b1789_391f2b73-3b36-4eae-bb68-fdbb4029cfce",
              "type": "progress_step_checked"
            }
          ]
        },
        "image": {
          "data": {
            "id": "391f2b73-3b36-4eae-bb68-fdbb4029cfce",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/996fa5b5-7584-4df7-8212-18fd03daaaf3"
          }
        },
        "syntax_node": {
          "links": {
            "related": "/syntax_nodes.7e4e4ad8-de2f-47ce-a41d-e84695bec20b"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/b58cd525-f399-4faf-ab68-23ff84febe3f",
            "self": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/75f80a9f-a6db-48dd-a4c0-669b6bffa024"
          }
        },
        "components": {
          "data": [
            {
              "id": "d8535a25-abf9-4570-a46c-63116499e34a",
              "type": "object_occurrence"
            },
            {
              "id": "86fab670-5d13-4fc9-ac9d-ce0d5efd327e",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "7e4e4ad8-de2f-47ce-a41d-e84695bec20b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=391f2b73-3b36-4eae-bb68-fdbb4029cfce"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=391f2b73-3b36-4eae-bb68-fdbb4029cfce"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "86fab670-5d13-4fc9-ac9d-ce0d5efd327e",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC 2",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "177967",
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
            "related": "/tags?filter[target_id_eq]=86fab670-5d13-4fc9-ac9d-ce0d5efd327e",
            "self": "/object_occurrences/86fab670-5d13-4fc9-ac9d-ce0d5efd327e/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=86fab670-5d13-4fc9-ac9d-ce0d5efd327e&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/86fab670-5d13-4fc9-ac9d-ce0d5efd327e/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "86fab670-5d13-4fc9-ac9d-ce0d5efd327e",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/86fab670-5d13-4fc9-ac9d-ce0d5efd327e/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/996fa5b5-7584-4df7-8212-18fd03daaaf3"
          }
        },
        "syntax_node": {
          "links": {
            "related": "/syntax_nodes.7e4e4ad8-de2f-47ce-a41d-e84695bec20b"
          }
        },
        "classification_table": {
          "data": {
            "id": "ac316d3c-c1ea-4f50-b805-212c8305a0a2",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/ac316d3c-c1ea-4f50-b805-212c8305a0a2"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce",
            "self": "/object_occurrences/86fab670-5d13-4fc9-ac9d-ce0d5efd327e/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/75f80a9f-a6db-48dd-a4c0-669b6bffa024"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/86fab670-5d13-4fc9-ac9d-ce0d5efd327e/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "7e4e4ad8-de2f-47ce-a41d-e84695bec20b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=86fab670-5d13-4fc9-ac9d-ce0d5efd327e"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=86fab670-5d13-4fc9-ac9d-ce0d5efd327e"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "d8535a25-abf9-4570-a46c-63116499e34a",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC 2a",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "177967",
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
            "related": "/tags?filter[target_id_eq]=d8535a25-abf9-4570-a46c-63116499e34a",
            "self": "/object_occurrences/d8535a25-abf9-4570-a46c-63116499e34a/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=d8535a25-abf9-4570-a46c-63116499e34a&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/d8535a25-abf9-4570-a46c-63116499e34a/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "d8535a25-abf9-4570-a46c-63116499e34a",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/d8535a25-abf9-4570-a46c-63116499e34a/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/996fa5b5-7584-4df7-8212-18fd03daaaf3"
          }
        },
        "syntax_node": {
          "links": {
            "related": "/syntax_nodes.7e4e4ad8-de2f-47ce-a41d-e84695bec20b"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce",
            "self": "/object_occurrences/d8535a25-abf9-4570-a46c-63116499e34a/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/75f80a9f-a6db-48dd-a4c0-669b6bffa024"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/d8535a25-abf9-4570-a46c-63116499e34a/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "7e4e4ad8-de2f-47ce-a41d-e84695bec20b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=d8535a25-abf9-4570-a46c-63116499e34a"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=d8535a25-abf9-4570-a46c-63116499e34a"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "a9020ebd-aaa5-453e-a1b2-af8df6fad2e8",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC 3",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "177967",
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
            "related": "/tags?filter[target_id_eq]=a9020ebd-aaa5-453e-a1b2-af8df6fad2e8",
            "self": "/object_occurrences/a9020ebd-aaa5-453e-a1b2-af8df6fad2e8/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=a9020ebd-aaa5-453e-a1b2-af8df6fad2e8&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/a9020ebd-aaa5-453e-a1b2-af8df6fad2e8/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "a9020ebd-aaa5-453e-a1b2-af8df6fad2e8",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/a9020ebd-aaa5-453e-a1b2-af8df6fad2e8/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/b0e298b8-c2d2-455d-8a2c-1820591e2e37"
          }
        },
        "syntax_node": {
          "links": {
            "related": "/syntax_nodes.7e4e4ad8-de2f-47ce-a41d-e84695bec20b"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/f122b371-807a-40af-8844-d23fc71856f8",
            "self": "/object_occurrences/a9020ebd-aaa5-453e-a1b2-af8df6fad2e8/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/75f80a9f-a6db-48dd-a4c0-669b6bffa024"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/a9020ebd-aaa5-453e-a1b2-af8df6fad2e8/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "7e4e4ad8-de2f-47ce-a41d-e84695bec20b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=a9020ebd-aaa5-453e-a1b2-af8df6fad2e8"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=a9020ebd-aaa5-453e-a1b2-af8df6fad2e8"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "0f086c7b-aa4b-4481-9658-9c36b5d1f238",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 14",
        "title": null
      },
      "meta": {
      }
    },
    {
      "id": "54cec733-00ab-41ad-bbde-c2ba345b1789_391f2b73-3b36-4eae-bb68-fdbb4029cfce",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "54cec733-00ab-41ad-bbde-c2ba345b1789",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/54cec733-00ab-41ad-bbde-c2ba345b1789"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/391f2b73-3b36-4eae-bb68-fdbb4029cfce"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "75f80a9f-a6db-48dd-a4c0-669b6bffa024",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 12",
        "hex_color": "177967"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/9735bfaa-2dd0-49f5-8a50-039cb06e4ad1"
          }
        },
        "classification_table": {
          "data": {
            "id": "ac316d3c-c1ea-4f50-b805-212c8305a0a2",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/ac316d3c-c1ea-4f50-b805-212c8305a0a2",
            "self": "/syntax_elements/75f80a9f-a6db-48dd-a4c0-669b6bffa024/relationships/classification_table"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "99d1a9ec-99ff-4ec1-829b-c83a9ceadd3f",
      "type": "tag",
      "attributes": {
        "value": "Tag value 14"
      },
      "relationships": {
      },
      "meta": {
      }
    }
  ],
  "meta": {
    "total_count": 6
  },
  "links": {
    "self": "http://example.org/object_occurrences",
    "current": "http://example.org/object_occurrences?include=tags,owners,progress_step_checked,syntax_element&page[number]=1&sort=-type,name,number"
  }
}
```



## Show

Display a single Object Occurrence.

To include additional, children object occurrences, supply the <code>depth=1</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231?depth=1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrences/:id?depth=:depth`

#### Parameters


```json
depth: 1
```


| Name | Description |
|:-----|:------------|
| depth  | Components depth |
| filter[type_eq]  | Only of specific type |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6043c312-6371-49c3-afce-57a86b8d479a
200 OK
```


```json
{
  "data": {
    "id": "5f67b626-1ec3-4b60-aa8c-e682f5570231",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "name": "OOC 1",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "39539f",
      "number": "1",
      "validation_errors": [

      ],
      "classification_code": "A"
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "4ae4712d-9b2f-4a1d-8a4c-44abd13a4d17",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=5f67b626-1ec3-4b60-aa8c-e682f5570231",
          "self": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "85b0e226-e6e3-4017-8be3-dd77deeb7fa7",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=5f67b626-1ec3-4b60-aa8c-e682f5570231&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "e71f3115-d93f-41a7-bcfa-991d771ac229_5f67b626-1ec3-4b60-aa8c-e682f5570231",
            "type": "progress_step_checked"
          }
        ]
      },
      "image": {
        "data": {
          "id": "5f67b626-1ec3-4b60-aa8c-e682f5570231",
          "type": "url_struct"
        },
        "links": {
          "self": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231/relationships/image"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/2092f0d5-a5d5-4fa8-b440-1797d9fa3f11"
        }
      },
      "syntax_node": {
        "links": {
          "related": "/syntax_nodes.a98cd2e2-30ea-45f2-910b-85064c996398"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/c720a68e-f38a-417c-a329-c90109d12e98",
          "self": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/255f40e1-8cea-4407-9abe-4f0fdb43741c"
        }
      },
      "components": {
        "data": [
          {
            "id": "7a70f469-0d4f-4d08-b714-2e4943b2bce7",
            "type": "object_occurrence"
          },
          {
            "id": "3ed333be-45c2-4073-b391-83f807d418e5",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "a98cd2e2-30ea-45f2-910b-85064c996398",
            "type": "syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=5f67b626-1ec3-4b60-aa8c-e682f5570231"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
            "type": "syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=5f67b626-1ec3-4b60-aa8c-e682f5570231"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231?depth=1"
  },
  "included": [
    {
      "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 15",
        "hex_color": "39539f"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/d8a3f5e3-ad9b-49e8-b87c-3ac7ebec39b5"
          }
        },
        "classification_table": {
          "data": {
            "id": "309e36cf-10ba-4919-afa7-9c398d55ad09",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/309e36cf-10ba-4919-afa7-9c398d55ad09",
            "self": "/syntax_elements/255f40e1-8cea-4407-9abe-4f0fdb43741c/relationships/classification_table"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "7a70f469-0d4f-4d08-b714-2e4943b2bce7",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC 2a",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "39539f",
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
            "related": "/tags?filter[target_id_eq]=7a70f469-0d4f-4d08-b714-2e4943b2bce7",
            "self": "/object_occurrences/7a70f469-0d4f-4d08-b714-2e4943b2bce7/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=7a70f469-0d4f-4d08-b714-2e4943b2bce7&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/7a70f469-0d4f-4d08-b714-2e4943b2bce7/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "7a70f469-0d4f-4d08-b714-2e4943b2bce7",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/7a70f469-0d4f-4d08-b714-2e4943b2bce7/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/2092f0d5-a5d5-4fa8-b440-1797d9fa3f11"
          }
        },
        "syntax_node": {
          "links": {
            "related": "/syntax_nodes.a98cd2e2-30ea-45f2-910b-85064c996398"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231",
            "self": "/object_occurrences/7a70f469-0d4f-4d08-b714-2e4943b2bce7/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/255f40e1-8cea-4407-9abe-4f0fdb43741c"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/7a70f469-0d4f-4d08-b714-2e4943b2bce7/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "a98cd2e2-30ea-45f2-910b-85064c996398",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7a70f469-0d4f-4d08-b714-2e4943b2bce7"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7a70f469-0d4f-4d08-b714-2e4943b2bce7"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "3ed333be-45c2-4073-b391-83f807d418e5",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC 2",
        "position": 1,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "39539f",
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
            "related": "/tags?filter[target_id_eq]=3ed333be-45c2-4073-b391-83f807d418e5",
            "self": "/object_occurrences/3ed333be-45c2-4073-b391-83f807d418e5/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=3ed333be-45c2-4073-b391-83f807d418e5&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/3ed333be-45c2-4073-b391-83f807d418e5/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "3ed333be-45c2-4073-b391-83f807d418e5",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/3ed333be-45c2-4073-b391-83f807d418e5/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/2092f0d5-a5d5-4fa8-b440-1797d9fa3f11"
          }
        },
        "syntax_node": {
          "links": {
            "related": "/syntax_nodes.a98cd2e2-30ea-45f2-910b-85064c996398"
          }
        },
        "classification_table": {
          "data": {
            "id": "309e36cf-10ba-4919-afa7-9c398d55ad09",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/309e36cf-10ba-4919-afa7-9c398d55ad09"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231",
            "self": "/object_occurrences/3ed333be-45c2-4073-b391-83f807d418e5/relationships/part_of"
          }
        },
        "syntax_element": {
          "data": {
            "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
            "type": "syntax_element"
          },
          "links": {
            "related": "/syntax_elements/255f40e1-8cea-4407-9abe-4f0fdb43741c"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/3ed333be-45c2-4073-b391-83f807d418e5/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "a98cd2e2-30ea-45f2-910b-85064c996398",
              "type": "syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=3ed333be-45c2-4073-b391-83f807d418e5"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "255f40e1-8cea-4407-9abe-4f0fdb43741c",
              "type": "syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=3ed333be-45c2-4073-b391-83f807d418e5"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "e71f3115-d93f-41a7-bcfa-991d771ac229_5f67b626-1ec3-4b60-aa8c-e682f5570231",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "e71f3115-d93f-41a7-bcfa-991d771ac229",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/e71f3115-d93f-41a7-bcfa-991d771ac229"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/5f67b626-1ec3-4b60-aa8c-e682f5570231"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "85b0e226-e6e3-4017-8be3-dd77deeb7fa7",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 17",
        "title": null
      },
      "meta": {
      }
    },
    {
      "id": "4ae4712d-9b2f-4a1d-8a4c-44abd13a4d17",
      "type": "tag",
      "attributes": {
        "value": "Tag value 17"
      },
      "relationships": {
      },
      "meta": {
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


## Create

Create a single Object Occurrence.

<aside class="notice">
  Some of the requirements, which are marked with <em>required</em> isn't always required.
  This is completely dependent on the syntax (if any) that governs the context.
</aside>


### Request

#### Endpoint

```plaintext
POST /object_occurrences/f8cd94be-a745-4c51-8111-7d82d35c299f/relationships/components
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
X-Request-Id: 32cfd870-519d-461a-9d88-dc06436193f2
201 Created
```


```json
{
  "data": {
    "id": "d4712be7-40a9-4b0d-a5b1-39b44a24eca4",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "name": "ooc",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "d57b37",
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
          "related": "/tags?filter[target_id_eq]=d4712be7-40a9-4b0d-a5b1-39b44a24eca4",
          "self": "/object_occurrences/d4712be7-40a9-4b0d-a5b1-39b44a24eca4/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=d4712be7-40a9-4b0d-a5b1-39b44a24eca4&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/d4712be7-40a9-4b0d-a5b1-39b44a24eca4/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ]
      },
      "image": {
        "data": {
          "id": "d4712be7-40a9-4b0d-a5b1-39b44a24eca4",
          "type": "url_struct"
        },
        "links": {
          "self": "/object_occurrences/d4712be7-40a9-4b0d-a5b1-39b44a24eca4/relationships/image"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/ce881652-f726-423d-817a-d457a5e56e0a"
        }
      },
      "syntax_node": {
        "links": {
          "related": "/syntax_nodes.0a77ec3f-2166-438f-a82b-46f91b8cf0d4"
        }
      },
      "classification_table": {
        "data": {
          "id": "bf8dc586-f25a-4282-b9af-7fd2344ff29a",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/bf8dc586-f25a-4282-b9af-7fd2344ff29a"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/f8cd94be-a745-4c51-8111-7d82d35c299f",
          "self": "/object_occurrences/d4712be7-40a9-4b0d-a5b1-39b44a24eca4/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "9a14eafd-3a18-43a6-bad9-249c30378bc9",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/9a14eafd-3a18-43a6-bad9-249c30378bc9"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/d4712be7-40a9-4b0d-a5b1-39b44a24eca4/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "0a77ec3f-2166-438f-a82b-46f91b8cf0d4",
            "type": "syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=d4712be7-40a9-4b0d-a5b1-39b44a24eca4"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "9a14eafd-3a18-43a6-bad9-249c30378bc9",
            "type": "syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=d4712be7-40a9-4b0d-a5b1-39b44a24eca4"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f8cd94be-a745-4c51-8111-7d82d35c299f/relationships/components"
  },
  "included": [
    {
      "id": "9a14eafd-3a18-43a6-bad9-249c30378bc9",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 18",
        "hex_color": "d57b37"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/b95d15d3-8131-4e55-acd5-de86a549be29"
          }
        },
        "classification_table": {
          "data": {
            "id": "bf8dc586-f25a-4282-b9af-7fd2344ff29a",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/bf8dc586-f25a-4282-b9af-7fd2344ff29a",
            "self": "/syntax_elements/9a14eafd-3a18-43a6-bad9-249c30378bc9/relationships/classification_table"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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


## Create external

Create a single, external Object Occurrence.

External Object Occurrences represent external systems which this design depends on,
such as GPS or the power grid.


### Request

#### Endpoint

```plaintext
POST /object_occurrences/960473a4-1ebc-41bc-842f-d40be72a444a/relationships/components
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
X-Request-Id: 8226244a-d94b-47be-b52f-f653037efe30
201 Created
```


```json
{
  "data": {
    "id": "a21168d4-abea-454e-a7ef-a2120175ede6",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
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
          "related": "/tags?filter[target_id_eq]=a21168d4-abea-454e-a7ef-a2120175ede6",
          "self": "/object_occurrences/a21168d4-abea-454e-a7ef-a2120175ede6/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=a21168d4-abea-454e-a7ef-a2120175ede6&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/a21168d4-abea-454e-a7ef-a2120175ede6/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ]
      },
      "image": {
        "data": {
          "id": "a21168d4-abea-454e-a7ef-a2120175ede6",
          "type": "url_struct"
        },
        "links": {
          "self": "/object_occurrences/a21168d4-abea-454e-a7ef-a2120175ede6/relationships/image"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/8a776774-7616-41c9-ad38-3601a4f91183"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/960473a4-1ebc-41bc-842f-d40be72a444a/relationships/components"
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
PATCH /object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "f37c5390-d8d5-4591-8e79-9bb970a61d42",
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
          "id": "92454e7a-ceff-4900-a670-20269e7d583a"
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
X-Request-Id: b4a463a0-7680-48a8-a853-b215aee2a350
200 OK
```


```json
{
  "data": {
    "id": "f37c5390-d8d5-4591-8e79-9bb970a61d42",
    "type": "object_occurrence",
    "attributes": {
      "description": "New description",
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
          "related": "/tags?filter[target_id_eq]=f37c5390-d8d5-4591-8e79-9bb970a61d42",
          "self": "/object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=f37c5390-d8d5-4591-8e79-9bb970a61d42&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ]
      },
      "image": {
        "data": {
          "id": "f37c5390-d8d5-4591-8e79-9bb970a61d42",
          "type": "url_struct"
        },
        "links": {
          "self": "/object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42/relationships/image"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/a2e57ab1-bfd3-4c29-bc1b-2939452cf37b"
        }
      },
      "syntax_node": {
        "links": {
          "related": "/syntax_nodes.b345078c-e3cb-4714-ab04-9188adaa18ef"
        }
      },
      "classification_table": {
        "data": {
          "id": "10fbbffc-6062-4329-a5d4-5dcb9bdee6e9",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/10fbbffc-6062-4329-a5d4-5dcb9bdee6e9"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/92454e7a-ceff-4900-a670-20269e7d583a",
          "self": "/object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "68f854dc-e92d-4750-8eaf-afc6c3c7da54",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/68f854dc-e92d-4750-8eaf-afc6c3c7da54"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "b345078c-e3cb-4714-ab04-9188adaa18ef",
            "type": "syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=f37c5390-d8d5-4591-8e79-9bb970a61d42"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "68f854dc-e92d-4750-8eaf-afc6c3c7da54",
            "type": "syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=f37c5390-d8d5-4591-8e79-9bb970a61d42"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f37c5390-d8d5-4591-8e79-9bb970a61d42"
  },
  "included": [
    {
      "id": "68f854dc-e92d-4750-8eaf-afc6c3c7da54",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 3,
        "min_number": 0,
        "name": "Syntax element 26",
        "hex_color": "1fb02c"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/c9019371-e767-405f-a4d3-b5fe8c53ed83"
          }
        },
        "classification_table": {
          "data": {
            "id": "10fbbffc-6062-4329-a5d4-5dcb9bdee6e9",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/10fbbffc-6062-4329-a5d4-5dcb9bdee6e9",
            "self": "/syntax_elements/68f854dc-e92d-4750-8eaf-afc6c3c7da54/relationships/classification_table"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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


## Copy

Copy the (target) Object Occurrence resource (indicated in URL parameter) and all its components
as a component of the (source) Object Occurrence resource (indicated by request body).

Copy node 1 into 3
```
A (id 1)
  B (id 2)
C (id 3)

POST /object_occurrences/1/copy
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

Copy node 1 into self
```
A (id 1)
  B (id 2)

POST /object_occurrences/1/copy
{
  data: {
    "id": 1,
    "type": "object_occurrences"
  }
}

Results in:
A (id 1)
  B (id 2)
  A (id 3)
    B (id 4)
```

Copy node 1 into descendant
```
A (id 1)
  B (id 2)
    C (id 3)

POST /object_occurrences/1/copy
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
          C (id 6)
```

Copy node 3 into ancestor
```
A (id 1)
  B (id 2)
    C (id 3)

POST /object_occurrences/3/copy
{
  data: {
    "id": 1,
    "type": "object_occurrences"
  }
}

Results in:
A (id 1)
  B (id 2)
    C (id 3)
  C (id 4)
```


### Request

#### Endpoint

```plaintext
POST /object_occurrences/5bd90395-2f93-4e8b-9696-8fcfc1318341/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "28726e0e-a2f4-45a9-8368-9adb87e58726",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/572e350ddc93afa01b3d6fec
Content-Type: application/vnd.api+json
X-Request-Id: 4ed574e4-6b98-47c2-8423-5b65c66d8aab
202 Accepted
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


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/ba60f7e8-a69e-431b-a878-c2d2b034deb2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d29d8874-6124-4f89-aa87-e2e1a57f2491
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "6c611334-742a-4717-ba08-cf1e5c95df5e",
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
X-Request-Id: 98b70810-448b-47e5-bce8-a509ecf0ea04
200 OK
```


```json
{
  "data": {
    "id": "5567e47b-3298-40b5-9b5f-cd5a4572a96a",
    "type": "object_occurrence",
    "attributes": {
      "description": null,
      "name": "OOC 2",
      "position": 1,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "cd05a8",
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
          "related": "/tags?filter[target_id_eq]=5567e47b-3298-40b5-9b5f-cd5a4572a96a",
          "self": "/object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=5567e47b-3298-40b5-9b5f-cd5a4572a96a&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ]
      },
      "image": {
        "data": {
          "id": "5567e47b-3298-40b5-9b5f-cd5a4572a96a",
          "type": "url_struct"
        },
        "links": {
          "self": "/object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/image"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/aafea254-2ec4-48ec-94f7-d8e8c49335d8"
        }
      },
      "syntax_node": {
        "links": {
          "related": "/syntax_nodes.a54f119d-4571-418c-bbab-4795ad4e3f3a"
        }
      },
      "classification_table": {
        "data": {
          "id": "9f678665-bb46-435c-86e6-ed02ae5d9cee",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/9f678665-bb46-435c-86e6-ed02ae5d9cee"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6c611334-742a-4717-ba08-cf1e5c95df5e",
          "self": "/object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/part_of"
        }
      },
      "syntax_element": {
        "data": {
          "id": "6e11fbb2-ced4-46f1-ab4d-abeac0ba0318",
          "type": "syntax_element"
        },
        "links": {
          "related": "/syntax_elements/6e11fbb2-ced4-46f1-ab4d-abeac0ba0318"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "a54f119d-4571-418c-bbab-4795ad4e3f3a",
            "type": "syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=5567e47b-3298-40b5-9b5f-cd5a4572a96a"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "6e11fbb2-ced4-46f1-ab4d-abeac0ba0318",
            "type": "syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=5567e47b-3298-40b5-9b5f-cd5a4572a96a"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/5567e47b-3298-40b5-9b5f-cd5a4572a96a/relationships/part_of"
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
X-Request-Id: cc9d0662-3c05-4e4a-a1e4-64ac2a336612
200 OK
```


```json
{
  "data": [
    {
      "id": "d999bc5c4cab60897a24dda808d6e33e985c88a85fdabfd7449f2944258ff077",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "4348254b-e51e-450d-827d-3b7ad51e68fe",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/4348254b-e51e-450d-827d-3b7ad51e68fe"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "5cdfca3b0cf590b8264eec0437cc78c9fc58ff17a16ca6962017a73ca8dd8b5a",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "a477af43-8839-40d1-beae-07b5225fa8a0",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/a477af43-8839-40d1-beae-07b5225fa8a0"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "9a6954619cb8e9c34ec59dd62d930281992a2537e68514e2b63663c695967222",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "257ebfb5-f95b-4d6c-bd41-b91c74a5178c",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/257ebfb5-f95b-4d6c-bd41-b91c74a5178c"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "4348254b-e51e-450d-827d-3b7ad51e68fe",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal A",
        "name": "Alarm 97b312ca62ac",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=4348254b-e51e-450d-827d-3b7ad51e68fe",
            "self": "/classification_entries/4348254b-e51e-450d-827d-3b7ad51e68fe/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "549f12db-6532-498d-aaf3-217e4e1a5ef0",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/549f12db-6532-498d-aaf3-217e4e1a5ef0"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=4348254b-e51e-450d-827d-3b7ad51e68fe",
            "self": "/classification_entries/4348254b-e51e-450d-827d-3b7ad51e68fe/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "a477af43-8839-40d1-beae-07b5225fa8a0",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal B",
        "name": "Alarm 769a9805ba42",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=a477af43-8839-40d1-beae-07b5225fa8a0",
            "self": "/classification_entries/a477af43-8839-40d1-beae-07b5225fa8a0/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "549f12db-6532-498d-aaf3-217e4e1a5ef0",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/549f12db-6532-498d-aaf3-217e4e1a5ef0"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=a477af43-8839-40d1-beae-07b5225fa8a0",
            "self": "/classification_entries/a477af43-8839-40d1-beae-07b5225fa8a0/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "257ebfb5-f95b-4d6c-bd41-b91c74a5178c",
      "type": "classification_entry",
      "attributes": {
        "code": "C",
        "definition": "Alarm signal C",
        "name": "Alarm 309b3aa1a3b2",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=257ebfb5-f95b-4d6c-bd41-b91c74a5178c",
            "self": "/classification_entries/257ebfb5-f95b-4d6c-bd41-b91c74a5178c/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "549f12db-6532-498d-aaf3-217e4e1a5ef0",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/549f12db-6532-498d-aaf3-217e4e1a5ef0"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=257ebfb5-f95b-4d6c-bd41-b91c74a5178c",
            "self": "/classification_entries/257ebfb5-f95b-4d6c-bd41-b91c74a5178c/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/object_occurrences/classification_entries_stats",
    "current": "http://example.org/object_occurrences/classification_entries_stats?include=classification_entry&page[number]=1&sort=code"
  }
}
```



# Classification Tables

Classification tables represent a strategic breakdown of the company product(s) into a nuanced
and logically separated classification table structure.

Each classification table has multiple classification entries.


## Modify translations

Adds new translation to resource based on Accept-Language header.
There is an information about available locales in the meta data.


### Request

#### Endpoint

```plaintext
PATCH /classification_tables/2d6dd3a6-147b-421d-b2b1-8649513afe86
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: da,en-US;q=0.9,en;q=0.8,da-DK;q=0.7
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "2d6dd3a6-147b-421d-b2b1-8649513afe86",
    "type": "classification_table",
    "attributes": {
      "name": "name - DA",
      "description": "description - DA"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | Translated name |
| data[attributes][description]  | Translated description |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4c08c949-aa3a-4d68-99c1-a7f9d2192e3f
200 OK
```


```json
{
  "data": {
    "id": "2d6dd3a6-147b-421d-b2b1-8649513afe86",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3,
      "description": "description - DA",
      "name": "name - DA"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=2d6dd3a6-147b-421d-b2b1-8649513afe86",
          "self": "/classification_tables/2d6dd3a6-147b-421d-b2b1-8649513afe86/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=2d6dd3a6-147b-421d-b2b1-8649513afe86",
          "self": "/classification_tables/2d6dd3a6-147b-421d-b2b1-8649513afe86/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "da",
        "en"
      ],
      "current_locale": "da",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/2d6dd3a6-147b-421d-b2b1-8649513afe86"
  },
  "included": [

  ]
}
```



## Add new tag

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_tables/396e95e5-762f-4961-a1e5-af1fcc0058af/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
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
X-Request-Id: f621279a-a7c0-4d8f-9772-4fc75b5c7375
201 Created
```


```json
{
  "data": {
    "id": "24113862-bd00-4064-b2d6-5cf581de1bd2",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/396e95e5-762f-4961-a1e5-af1fcc0058af/relationships/tags"
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
POST /classification_tables/4c88a8cb-a2ad-4f8b-95de-1ce0d1ce5730/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`POST /classification_tables/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "cd207c9c-9705-457f-86b0-4638b20c6184"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 18e322e7-9868-411c-adfc-943195193512
201 Created
```


```json
{
  "data": {
    "id": "cd207c9c-9705-457f-86b0-4638b20c6184",
    "type": "tag",
    "attributes": {
      "value": "Tag value 32"
    },
    "relationships": {
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/4c88a8cb-a2ad-4f8b-95de-1ce0d1ce5730/relationships/tags"
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
DELETE /classification_tables/912e8686-a6d0-4e68-970f-c69668534a5d/relationships/tags/7304bc51-3d23-4c90-8b0b-5216d2fe47a5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: eb3a2f46-dd90-4934-8836-6336d6f615eb
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
Accept-Language: en-US
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
| filter[tag_id_in]  | filter by tag ids |
| filter[locale_eq]  | filter by locale |
| filter[allowed_for_object_occurrence_id_eq]  | filter by allowed for children of OOC with id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: d1d58dd7-ecc1-4547-b59b-2d3ca8530760
200 OK
```


```json
{
  "data": [
    {
      "id": "f5d6b534-e1ee-4a5c-9e5c-d2e8ec67a111",
      "type": "classification_table",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "published": false,
        "published_at": null,
        "type": "core",
        "max_classification_entries_depth": 3,
        "description": null,
        "name": "CT 1"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=f5d6b534-e1ee-4a5c-9e5c-d2e8ec67a111",
            "self": "/classification_tables/f5d6b534-e1ee-4a5c-9e5c-d2e8ec67a111/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=f5d6b534-e1ee-4a5c-9e5c-d2e8ec67a111",
            "self": "/classification_tables/f5d6b534-e1ee-4a5c-9e5c-d2e8ec67a111/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "29656a91-f49d-4a4f-a6da-fed507cac600",
      "type": "classification_table",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "published": false,
        "published_at": null,
        "type": "core",
        "max_classification_entries_depth": 3,
        "description": null,
        "name": "CT 2"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=29656a91-f49d-4a4f-a6da-fed507cac600",
            "self": "/classification_tables/29656a91-f49d-4a4f-a6da-fed507cac600/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=29656a91-f49d-4a4f-a6da-fed507cac600",
            "self": "/classification_tables/29656a91-f49d-4a4f-a6da-fed507cac600/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
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
GET /classification_tables/9dd6ce98-5755-43f0-a915-4cefc9fecb15
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 188ef90d-dbaa-4a83-8719-4ba46dd68518
200 OK
```


```json
{
  "data": {
    "id": "9dd6ce98-5755-43f0-a915-4cefc9fecb15",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3,
      "description": null,
      "name": "CT 1"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=9dd6ce98-5755-43f0-a915-4cefc9fecb15",
          "self": "/classification_tables/9dd6ce98-5755-43f0-a915-4cefc9fecb15/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=9dd6ce98-5755-43f0-a915-4cefc9fecb15",
          "self": "/classification_tables/9dd6ce98-5755-43f0-a915-4cefc9fecb15/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/9dd6ce98-5755-43f0-a915-4cefc9fecb15"
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
PATCH /classification_tables/046c538d-32e6-4b7a-b793-27f647ffd692
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "046c538d-32e6-4b7a-b793-27f647ffd692",
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
X-Request-Id: 403cac55-d0e7-4858-bf34-7377b14d9b21
200 OK
```


```json
{
  "data": {
    "id": "046c538d-32e6-4b7a-b793-27f647ffd692",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3,
      "description": null,
      "name": "New classification table name"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=046c538d-32e6-4b7a-b793-27f647ffd692",
          "self": "/classification_tables/046c538d-32e6-4b7a-b793-27f647ffd692/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=046c538d-32e6-4b7a-b793-27f647ffd692",
          "self": "/classification_tables/046c538d-32e6-4b7a-b793-27f647ffd692/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/046c538d-32e6-4b7a-b793-27f647ffd692"
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
DELETE /classification_tables/39cf1fe3-3767-4850-bde1-d337e424445b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9c145651-5224-43a0-91bd-8265330dfc4b
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
POST /classification_tables/76e55544-b2c9-4324-9972-c9d7fdb03f27/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2addeff4-94d3-4759-a621-7f47d7e1b91a
200 OK
```


```json
{
  "data": {
    "id": "76e55544-b2c9-4324-9972-c9d7fdb03f27",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "published": true,
      "published_at": "2020-11-20T12:47:28.664Z",
      "type": "core",
      "max_classification_entries_depth": 3,
      "description": null,
      "name": "CT 1"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=76e55544-b2c9-4324-9972-c9d7fdb03f27",
          "self": "/classification_tables/76e55544-b2c9-4324-9972-c9d7fdb03f27/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=76e55544-b2c9-4324-9972-c9d7fdb03f27",
          "self": "/classification_tables/76e55544-b2c9-4324-9972-c9d7fdb03f27/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/76e55544-b2c9-4324-9972-c9d7fdb03f27/publish"
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
POST /classification_tables/d4cb89a1-48e8-462a-80df-397cab82ca05/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 25efbd5c-8724-4f10-990d-a1831b459ea1
200 OK
```


```json
{
  "data": {
    "id": "d4cb89a1-48e8-462a-80df-397cab82ca05",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-11-20T12:47:30.823Z",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3,
      "description": null,
      "name": "CT 1"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=d4cb89a1-48e8-462a-80df-397cab82ca05",
          "self": "/classification_tables/d4cb89a1-48e8-462a-80df-397cab82ca05/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=d4cb89a1-48e8-462a-80df-397cab82ca05",
          "self": "/classification_tables/d4cb89a1-48e8-462a-80df-397cab82ca05/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d4cb89a1-48e8-462a-80df-397cab82ca05/archive"
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
Accept-Language: en-US
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
X-Request-Id: 66bae061-c5f1-47a6-83e9-c7c337429584
201 Created
```


```json
{
  "data": {
    "id": "18d2977d-4eb2-4deb-801e-061cc8f6abd2",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3,
      "description": "New description",
      "name": "New classification table name"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=18d2977d-4eb2-4deb-801e-061cc8f6abd2",
          "self": "/classification_tables/18d2977d-4eb2-4deb-801e-061cc8f6abd2/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=18d2977d-4eb2-4deb-801e-061cc8f6abd2",
          "self": "/classification_tables/18d2977d-4eb2-4deb-801e-061cc8f6abd2/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
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
POST /classification_entries/5ad5a790-579c-4304-9522-580b2bb4f202/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
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
X-Request-Id: ad16bb9f-cbdf-4f20-92b3-4eab0fff0be0
201 Created
```


```json
{
  "data": {
    "id": "bfa95919-b452-4f00-b7f4-d0d2b53e3f46",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/5ad5a790-579c-4304-9522-580b2bb4f202/relationships/tags"
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
POST /classification_entries/5f2936d9-5553-45d5-9e0e-5a62df16a3f7/relationships/tags
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`POST /classification_entries/:id/relationships/tags`

#### Parameters


```json
{
  "data": {
    "type": "tags",
    "id": "c9ca6b7b-7b2b-4ad8-b885-c60682ac689e"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 69aa7a5a-9866-4850-862d-7d01a51f2acc
201 Created
```


```json
{
  "data": {
    "id": "c9ca6b7b-7b2b-4ad8-b885-c60682ac689e",
    "type": "tag",
    "attributes": {
      "value": "Tag value 34"
    },
    "relationships": {
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/5f2936d9-5553-45d5-9e0e-5a62df16a3f7/relationships/tags"
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
DELETE /classification_entries/e94d02e9-f8d8-47f6-a5ea-cadfb0d14809/relationships/tags/05a2cca6-aa7d-447e-8d62-2c901151f973
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f252a3b8-e626-4537-b744-3c0570b65cc3
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## Modify translations

Adds new translation to resource based on Accept-Language header.
There is an information about available locales in the meta data.


### Request

#### Endpoint

```plaintext
PATCH /classification_entries/169aceb6-7482-4e29-afc0-f3273943509c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: da,en-US;q=0.9,en;q=0.8,da-DK;q=0.7
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "169aceb6-7482-4e29-afc0-f3273943509c",
    "type": "classification_entry",
    "attributes": {
      "name": "name - DA",
      "definition": "definition - DA",
      "reciprocal_name": "reciprocal_name - DA"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | Translated name |
| data[attributes][definition]  | Translated definition |
| data[attributes][reciprocal_name]  | Translated reciprocal_name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4dac7c59-0c5b-4e97-a568-a4094db03c44
200 OK
```


```json
{
  "data": {
    "id": "169aceb6-7482-4e29-afc0-f3273943509c",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "definition - DA",
      "name": "name - DA",
      "reciprocal_name": "reciprocal_name - DA"
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=169aceb6-7482-4e29-afc0-f3273943509c",
          "self": "/classification_entries/169aceb6-7482-4e29-afc0-f3273943509c/relationships/tags"
        }
      },
      "classification_table": {
        "data": {
          "id": "ef53a090-ae0d-4bc4-a1ca-6707904cc07d",
          "type": "classification_table"
        },
        "links": {
          "self": "/classification_tables/ef53a090-ae0d-4bc4-a1ca-6707904cc07d"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=169aceb6-7482-4e29-afc0-f3273943509c",
          "self": "/classification_entries/169aceb6-7482-4e29-afc0-f3273943509c/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "da",
        "en"
      ],
      "current_locale": "da",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/169aceb6-7482-4e29-afc0-f3273943509c"
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


## List


### Request

#### Endpoint

```plaintext
GET /classification_entries
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`GET /classification_entries`

#### Parameters



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: code, name, classification_table_name |
| query  | search query |
| filter[classification_entry_id_eq]  | filter by classification_entry_id |
| filter[classification_table_id_eq]  | filter by classification_table_id |
| filter[classification_table_id_in]  | filter by classification_table_id (multiple) |
| filter[classification_entry_id_blank]  | filter by blank classification_entry_id |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fe43db64-1cff-424a-b0c6-50a4bf8bb52e
200 OK
```


```json
{
  "data": [
    {
      "id": "41dc6019-2fed-4f0c-af63-09d5beea9b69",
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
            "related": "/tags?filter[target_id_eq]=41dc6019-2fed-4f0c-af63-09d5beea9b69",
            "self": "/classification_entries/41dc6019-2fed-4f0c-af63-09d5beea9b69/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "858bc44f-05b1-453c-8038-86f18e724c80",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/858bc44f-05b1-453c-8038-86f18e724c80"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=41dc6019-2fed-4f0c-af63-09d5beea9b69",
            "self": "/classification_entries/41dc6019-2fed-4f0c-af63-09d5beea9b69/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "c55daeb7-8168-4e3a-9fcd-9e9d1ddd52e2",
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
            "related": "/tags?filter[target_id_eq]=c55daeb7-8168-4e3a-9fcd-9e9d1ddd52e2",
            "self": "/classification_entries/c55daeb7-8168-4e3a-9fcd-9e9d1ddd52e2/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "858bc44f-05b1-453c-8038-86f18e724c80",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/858bc44f-05b1-453c-8038-86f18e724c80"
          }
        },
        "classification_entry": {
          "data": {
            "id": "41dc6019-2fed-4f0c-af63-09d5beea9b69",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/41dc6019-2fed-4f0c-af63-09d5beea9b69"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=c55daeb7-8168-4e3a-9fcd-9e9d1ddd52e2",
            "self": "/classification_entries/c55daeb7-8168-4e3a-9fcd-9e9d1ddd52e2/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "b629c374-f07e-468c-8a1f-b5694c819107",
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
            "related": "/tags?filter[target_id_eq]=b629c374-f07e-468c-8a1f-b5694c819107",
            "self": "/classification_entries/b629c374-f07e-468c-8a1f-b5694c819107/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "858bc44f-05b1-453c-8038-86f18e724c80",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/858bc44f-05b1-453c-8038-86f18e724c80"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=b629c374-f07e-468c-8a1f-b5694c819107",
            "self": "/classification_entries/b629c374-f07e-468c-8a1f-b5694c819107/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
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
GET /classification_entries/116e332f-a94e-4777-8665-b83aa03e148f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`GET /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 59cd0450-8000-463a-9f7a-17532120d8aa
200 OK
```


```json
{
  "data": {
    "id": "116e332f-a94e-4777-8665-b83aa03e148f",
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
          "related": "/tags?filter[target_id_eq]=116e332f-a94e-4777-8665-b83aa03e148f",
          "self": "/classification_entries/116e332f-a94e-4777-8665-b83aa03e148f/relationships/tags"
        }
      },
      "classification_table": {
        "data": {
          "id": "f22eef03-4959-4d90-8d35-2fa37ea8c0f9",
          "type": "classification_table"
        },
        "links": {
          "self": "/classification_tables/f22eef03-4959-4d90-8d35-2fa37ea8c0f9"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=116e332f-a94e-4777-8665-b83aa03e148f",
          "self": "/classification_entries/116e332f-a94e-4777-8665-b83aa03e148f/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/116e332f-a94e-4777-8665-b83aa03e148f"
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
PATCH /classification_entries/8e9b696b-dc47-4290-905f-0cbe12655bb0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "8e9b696b-dc47-4290-905f-0cbe12655bb0",
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
X-Request-Id: b1e7eefc-7e74-4496-af9b-b06d6f1028f1
200 OK
```


```json
{
  "data": {
    "id": "8e9b696b-dc47-4290-905f-0cbe12655bb0",
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
          "related": "/tags?filter[target_id_eq]=8e9b696b-dc47-4290-905f-0cbe12655bb0",
          "self": "/classification_entries/8e9b696b-dc47-4290-905f-0cbe12655bb0/relationships/tags"
        }
      },
      "classification_table": {
        "data": {
          "id": "075d01ca-3128-4220-892e-21aa6166589e",
          "type": "classification_table"
        },
        "links": {
          "self": "/classification_tables/075d01ca-3128-4220-892e-21aa6166589e"
        }
      },
      "classification_entry": {
        "data": {
          "id": "6834722d-4299-44d9-80c4-ab8ff56f78eb",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/6834722d-4299-44d9-80c4-ab8ff56f78eb"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=8e9b696b-dc47-4290-905f-0cbe12655bb0",
          "self": "/classification_entries/8e9b696b-dc47-4290-905f-0cbe12655bb0/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/8e9b696b-dc47-4290-905f-0cbe12655bb0"
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
DELETE /classification_entries/dafea5ee-c367-4f6b-a07e-ee97ddba7164
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0fac0db8-8807-4a24-b368-35c693d5a463
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
POST /classification_tables/b362be0b-f758-4d75-b2b9-ae7b241b4e2d/relationships/classification_entries
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
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
X-Request-Id: ae9e3f6f-c65e-46eb-a20a-0e82a69efec3
201 Created
```


```json
{
  "data": {
    "id": "34632c93-39ab-4e9d-a99d-47e00877f618",
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
          "related": "/tags?filter[target_id_eq]=34632c93-39ab-4e9d-a99d-47e00877f618",
          "self": "/classification_entries/34632c93-39ab-4e9d-a99d-47e00877f618/relationships/tags"
        }
      },
      "classification_table": {
        "data": {
          "id": "b362be0b-f758-4d75-b2b9-ae7b241b4e2d",
          "type": "classification_table"
        },
        "links": {
          "self": "/classification_tables/b362be0b-f758-4d75-b2b9-ae7b241b4e2d"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=34632c93-39ab-4e9d-a99d-47e00877f618",
          "self": "/classification_entries/34632c93-39ab-4e9d-a99d-47e00877f618/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/b362be0b-f758-4d75-b2b9-ae7b241b4e2d/relationships/classification_entries"
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
X-Request-Id: 275f35f3-ab1e-48d2-87fa-8651201eaf44
200 OK
```


```json
{
  "data": [
    {
      "id": "dba15f4b-4e32-4431-bdd5-4a967a4c9ed0",
      "type": "syntax",
      "attributes": {
        "account_id": "9e4af74c-4734-47ae-a71f-0b42da52f0b9",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 22d9d53a9029",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=dba15f4b-4e32-4431-bdd5-4a967a4c9ed0",
            "self": "/syntaxes/dba15f4b-4e32-4431-bdd5-4a967a4c9ed0/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/6068393f-5071-4f27-bbbf-8481b23b9e45",
            "self": "/syntax_nodes/6068393f-5071-4f27-bbbf-8481b23b9e45/relationships/components"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
GET /syntaxes/970d66ec-9e64-41ab-859c-7c7ea5950e79
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
X-Request-Id: 474d92c1-121a-4538-a668-18e75b9aa724
200 OK
```


```json
{
  "data": {
    "id": "970d66ec-9e64-41ab-859c-7c7ea5950e79",
    "type": "syntax",
    "attributes": {
      "account_id": "5c2a6ff3-a2be-4597-9188-9499277ea46e",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 2a94b191e8cb",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=970d66ec-9e64-41ab-859c-7c7ea5950e79",
          "self": "/syntaxes/970d66ec-9e64-41ab-859c-7c7ea5950e79/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/736213ea-3846-48f1-adaa-f6943b85e230",
          "self": "/syntax_nodes/736213ea-3846-48f1-adaa-f6943b85e230/relationships/components"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/970d66ec-9e64-41ab-859c-7c7ea5950e79"
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
X-Request-Id: 9334b1d4-2fe0-4e4c-873c-d6cccc20dded
201 Created
```


```json
{
  "data": {
    "id": "8cfafb22-5730-4c67-b6d9-decbf481866a",
    "type": "syntax",
    "attributes": {
      "account_id": "f9e32f88-4e34-441a-a5ba-2904441798ae",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=8cfafb22-5730-4c67-b6d9-decbf481866a",
          "self": "/syntaxes/8cfafb22-5730-4c67-b6d9-decbf481866a/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/8648a7be-4e36-409a-a527-ac4c7aa96764",
          "self": "/syntax_nodes/8648a7be-4e36-409a-a527-ac4c7aa96764/relationships/components"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
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
PATCH /syntaxes/79222b93-7695-4ee2-8e3c-e4bdb4cb3146
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "79222b93-7695-4ee2-8e3c-e4bdb4cb3146",
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
X-Request-Id: e47cbed4-89a6-4406-92d2-9f057a9d3c9c
200 OK
```


```json
{
  "data": {
    "id": "79222b93-7695-4ee2-8e3c-e4bdb4cb3146",
    "type": "syntax",
    "attributes": {
      "account_id": "ef09f17c-d2eb-4e60-9165-24c55cee4574",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=79222b93-7695-4ee2-8e3c-e4bdb4cb3146",
          "self": "/syntaxes/79222b93-7695-4ee2-8e3c-e4bdb4cb3146/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/b332562d-bfcd-441c-b2c5-da765b538f50",
          "self": "/syntax_nodes/b332562d-bfcd-441c-b2c5-da765b538f50/relationships/components"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/79222b93-7695-4ee2-8e3c-e4bdb4cb3146"
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
DELETE /syntaxes/ac410382-b7a3-491f-a818-045a757413c2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 562b179c-4b5b-4d7f-a91d-4992f4f288a0
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
POST /syntaxes/955ee178-bacc-4547-a1e1-227d1d3b8259/publish
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
X-Request-Id: 12d76beb-7a1f-4910-9676-dc0bb73746bb
200 OK
```


```json
{
  "data": {
    "id": "955ee178-bacc-4547-a1e1-227d1d3b8259",
    "type": "syntax",
    "attributes": {
      "account_id": "57fca0ae-1689-40a5-bd3e-22d9ee54061b",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax b02f56702acb",
      "published": true,
      "published_at": "2020-11-20T12:48:01.878Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=955ee178-bacc-4547-a1e1-227d1d3b8259",
          "self": "/syntaxes/955ee178-bacc-4547-a1e1-227d1d3b8259/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/b0473cc6-8d03-487b-83bf-89f7d550f045",
          "self": "/syntax_nodes/b0473cc6-8d03-487b-83bf-89f7d550f045/relationships/components"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/955ee178-bacc-4547-a1e1-227d1d3b8259/publish"
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
POST /syntaxes/1c23684e-9ce3-419b-bf89-59713b9aaead/archive
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
X-Request-Id: 594a4e7a-ed95-4f80-9d58-9906e5ec99f5
200 OK
```


```json
{
  "data": {
    "id": "1c23684e-9ce3-419b-bf89-59713b9aaead",
    "type": "syntax",
    "attributes": {
      "account_id": "439adf08-0c68-42ee-a6eb-d1d5d4263a85",
      "archived": true,
      "archived_at": "2020-11-20T12:48:03.037Z",
      "description": "Description",
      "name": "Syntax 7e91c8bbcd82",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=1c23684e-9ce3-419b-bf89-59713b9aaead",
          "self": "/syntaxes/1c23684e-9ce3-419b-bf89-59713b9aaead/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/05b5132f-6f03-41cb-bc60-dbd29ba69e35",
          "self": "/syntax_nodes/05b5132f-6f03-41cb-bc60-dbd29ba69e35/relationships/components"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/1c23684e-9ce3-419b-bf89-59713b9aaead/archive"
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
X-Request-Id: 01a21239-957b-48db-b869-d6d0003acc32
200 OK
```


```json
{
  "data": [
    {
      "id": "03e17b7d-c1b5-4c36-9745-7545a97e08f0",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 34",
        "hex_color": "3855de"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/2f138550-12cb-40de-aa89-0909ce79dcb0"
          }
        },
        "classification_table": {
          "data": {
            "id": "63b779fd-3d3d-41e1-8c4c-8a2a65f019f1",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/63b779fd-3d3d-41e1-8c4c-8a2a65f019f1",
            "self": "/syntax_elements/03e17b7d-c1b5-4c36-9745-7545a97e08f0/relationships/classification_table"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
GET /syntax_elements/4efec96e-357f-40c7-8d59-969f2d5b8217
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
X-Request-Id: fc828ad6-fe2a-43fc-af99-e226b7325517
200 OK
```


```json
{
  "data": {
    "id": "4efec96e-357f-40c7-8d59-969f2d5b8217",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 37",
      "hex_color": "2fde4b"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/bc065bc2-bf20-40a4-acb9-81aa377bc628"
        }
      },
      "classification_table": {
        "data": {
          "id": "da5d8068-b950-4b24-ab17-ef837b2816ad",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/da5d8068-b950-4b24-ab17-ef837b2816ad",
          "self": "/syntax_elements/4efec96e-357f-40c7-8d59-969f2d5b8217/relationships/classification_table"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/4efec96e-357f-40c7-8d59-969f2d5b8217"
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
POST /syntaxes/11b75a87-73e1-4507-9134-dcb736ca74f5/relationships/syntax_elements
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
          "id": "f14e632c-22fe-4ef0-be40-3c210a2c0437"
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
X-Request-Id: f6f142d4-a2cf-4310-a368-240740913324
201 Created
```


```json
{
  "data": {
    "id": "b54bc2d5-23b1-4900-ab24-d38391b86c6e",
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
          "related": "/syntaxes/11b75a87-73e1-4507-9134-dcb736ca74f5"
        }
      },
      "classification_table": {
        "data": {
          "id": "f14e632c-22fe-4ef0-be40-3c210a2c0437",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/f14e632c-22fe-4ef0-be40-3c210a2c0437",
          "self": "/syntax_elements/b54bc2d5-23b1-4900-ab24-d38391b86c6e/relationships/classification_table"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/11b75a87-73e1-4507-9134-dcb736ca74f5/relationships/syntax_elements"
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
PATCH /syntax_elements/f6ccb285-8574-42bc-90fb-40402f254775
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "f6ccb285-8574-42bc-90fb-40402f254775",
    "type": "syntax_element",
    "attributes": {
      "name": "New element",
      "hex_color": "ffffff"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "9d018004-3415-4db5-8dcb-f761094e0b46"
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
X-Request-Id: 6e5804cc-8da6-41ae-ac6f-0b432ead563c
200 OK
```


```json
{
  "data": {
    "id": "f6ccb285-8574-42bc-90fb-40402f254775",
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
          "related": "/syntaxes/520b39ed-ddc2-4aab-b1a5-d82ab8e8d285"
        }
      },
      "classification_table": {
        "data": {
          "id": "9d018004-3415-4db5-8dcb-f761094e0b46",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/9d018004-3415-4db5-8dcb-f761094e0b46",
          "self": "/syntax_elements/f6ccb285-8574-42bc-90fb-40402f254775/relationships/classification_table"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/f6ccb285-8574-42bc-90fb-40402f254775"
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
DELETE /syntax_elements/f1b96920-7c85-4cff-9254-e135c08adcd0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e12e3966-ee1d-422b-9249-5b7265a6796e
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
PATCH /syntax_elements/48cab424-6be6-466a-a8a0-5a361273b7f0/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "c434202c-3acd-4f81-9683-020547354863",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a8c687f4-0e76-4bc3-adca-207754f9604f
200 OK
```


```json
{
  "data": {
    "id": "48cab424-6be6-466a-a8a0-5a361273b7f0",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 46",
      "hex_color": "456645"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/0e553e1e-5282-4bf7-aeee-e37a39488b43"
        }
      },
      "classification_table": {
        "data": {
          "id": "c434202c-3acd-4f81-9683-020547354863",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/c434202c-3acd-4f81-9683-020547354863",
          "self": "/syntax_elements/48cab424-6be6-466a-a8a0-5a361273b7f0/relationships/classification_table"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/48cab424-6be6-466a-a8a0-5a361273b7f0/relationships/classification_table"
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
DELETE /syntax_elements/bdd328be-d231-48a2-8997-7a72ec1a2cd3/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 43512b62-5a5b-4adc-a1a1-b3ab69f1cd30
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
X-Request-Id: c0176f39-ff4d-4515-9bbc-4ea8e57a5240
200 OK
```


```json
{
  "data": [
    {
      "id": "67a74f21-55b7-4e21-bf2a-d09af5c7f1c7",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/51a2118b-a163-413a-8801-ba7f2017a0bc"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/67a74f21-55b7-4e21-bf2a-d09af5c7f1c7/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/67a74f21-55b7-4e21-bf2a-d09af5c7f1c7/relationships/parent",
            "related": "/syntax_nodes/67a74f21-55b7-4e21-bf2a-d09af5c7f1c7"
          }
        }
      },
      "meta": {
      }
    },
    {
      "id": "efbb8833-5ba6-423d-b3e1-98c6a76fcbfb",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/51a2118b-a163-413a-8801-ba7f2017a0bc"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/efbb8833-5ba6-423d-b3e1-98c6a76fcbfb/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/efbb8833-5ba6-423d-b3e1-98c6a76fcbfb/relationships/parent",
            "related": "/syntax_nodes/efbb8833-5ba6-423d-b3e1-98c6a76fcbfb"
          }
        }
      },
      "meta": {
      }
    },
    {
      "id": "7eed91ac-ad3b-493f-a18e-e9cef5460a6c",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/51a2118b-a163-413a-8801-ba7f2017a0bc"
          }
        },
        "components": {
          "data": [
            {
              "id": "2ae7df40-bfe1-44c4-b216-664bdf5e0691",
              "type": "syntax_node"
            },
            {
              "id": "67a74f21-55b7-4e21-bf2a-d09af5c7f1c7",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/7eed91ac-ad3b-493f-a18e-e9cef5460a6c/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/7eed91ac-ad3b-493f-a18e-e9cef5460a6c/relationships/parent",
            "related": "/syntax_nodes/7eed91ac-ad3b-493f-a18e-e9cef5460a6c"
          }
        }
      },
      "meta": {
      }
    },
    {
      "id": "2ae7df40-bfe1-44c4-b216-664bdf5e0691",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/51a2118b-a163-413a-8801-ba7f2017a0bc"
          }
        },
        "components": {
          "data": [
            {
              "id": "efbb8833-5ba6-423d-b3e1-98c6a76fcbfb",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/2ae7df40-bfe1-44c4-b216-664bdf5e0691/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/2ae7df40-bfe1-44c4-b216-664bdf5e0691/relationships/parent",
            "related": "/syntax_nodes/2ae7df40-bfe1-44c4-b216-664bdf5e0691"
          }
        }
      },
      "meta": {
      }
    },
    {
      "id": "d74e168c-07c8-4990-9a3a-3d2c4d84abba",
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
              "id": "7eed91ac-ad3b-493f-a18e-e9cef5460a6c",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/d74e168c-07c8-4990-9a3a-3d2c4d84abba/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/d74e168c-07c8-4990-9a3a-3d2c4d84abba/relationships/parent",
            "related": "/syntax_nodes/d74e168c-07c8-4990-9a3a-3d2c4d84abba"
          }
        }
      },
      "meta": {
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
GET /syntax_nodes/1af3d833-ae25-4e25-a007-ec783a382fd2?depth=1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_nodes/:id?depth=:depth`

#### Parameters


```json
depth: 1
```


| Name | Description |
|:-----|:------------|
| depth  | Components depth |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a6611291-4ec4-443e-86b2-89aa3093d83a
200 OK
```


```json
{
  "data": {
    "id": "1af3d833-ae25-4e25-a007-ec783a382fd2",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/bc9fcace-e876-4e9c-882e-a4d0bda9f928"
        }
      },
      "components": {
        "data": [
          {
            "id": "89c60f6f-66da-4c4b-8996-52b046e8f3fd",
            "type": "syntax_node"
          },
          {
            "id": "114f4419-8477-4a48-a49b-f7226fccd11a",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/1af3d833-ae25-4e25-a007-ec783a382fd2/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/1af3d833-ae25-4e25-a007-ec783a382fd2/relationships/parent",
          "related": "/syntax_nodes/1af3d833-ae25-4e25-a007-ec783a382fd2"
        }
      }
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/1af3d833-ae25-4e25-a007-ec783a382fd2?depth=1"
  },
  "included": [
    {
      "id": "89c60f6f-66da-4c4b-8996-52b046e8f3fd",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/bc9fcace-e876-4e9c-882e-a4d0bda9f928"
          }
        },
        "components": {
          "data": [
            {
              "id": "35b942bc-d311-46d2-9a5a-1653d5cd49cd",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/89c60f6f-66da-4c4b-8996-52b046e8f3fd/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/89c60f6f-66da-4c4b-8996-52b046e8f3fd/relationships/parent",
            "related": "/syntax_nodes/89c60f6f-66da-4c4b-8996-52b046e8f3fd"
          }
        }
      },
      "meta": {
      }
    },
    {
      "id": "114f4419-8477-4a48-a49b-f7226fccd11a",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/bc9fcace-e876-4e9c-882e-a4d0bda9f928"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/114f4419-8477-4a48-a49b-f7226fccd11a/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/114f4419-8477-4a48-a49b-f7226fccd11a/relationships/parent",
            "related": "/syntax_nodes/114f4419-8477-4a48-a49b-f7226fccd11a"
          }
        }
      },
      "meta": {
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
POST /syntax_nodes/6d8df26a-5805-40b2-acfb-87fa19614962/relationships/components
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
          "id": "7f65138f-a97a-4e3a-87ee-3ec5242e77b1"
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
X-Request-Id: 06a26e96-1f07-48a8-b245-b9d6f2c6a9fb
201 Created
```


```json
{
  "data": {
    "id": "8893d1bf-c88b-4fce-9d73-703be6e6b92c",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/7f65138f-a97a-4e3a-87ee-3ec5242e77b1"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/8893d1bf-c88b-4fce-9d73-703be6e6b92c/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/8893d1bf-c88b-4fce-9d73-703be6e6b92c/relationships/parent",
          "related": "/syntax_nodes/8893d1bf-c88b-4fce-9d73-703be6e6b92c"
        }
      }
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/6d8df26a-5805-40b2-acfb-87fa19614962/relationships/components"
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
PATCH /syntax_nodes/65d269d2-72f3-4b23-a72c-81899a97d08e/relationships/parent
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
    "id": "7092c451-f535-4b51-85e5-634e621fc9b2"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 690431e3-3f9c-4269-bc58-8d987b1297a6
200 OK
```


```json
{
  "data": {
    "id": "65d269d2-72f3-4b23-a72c-81899a97d08e",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 2
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/438bcdba-0f30-46ce-b259-a688b496e9f3"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/65d269d2-72f3-4b23-a72c-81899a97d08e/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/65d269d2-72f3-4b23-a72c-81899a97d08e/relationships/parent",
          "related": "/syntax_nodes/65d269d2-72f3-4b23-a72c-81899a97d08e"
        }
      }
    },
    "meta": {
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
PATCH /syntax_nodes/9b751b42-b08a-4363-943a-ddce4910f85e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "9b751b42-b08a-4363-943a-ddce4910f85e",
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
X-Request-Id: a7108447-10d2-4761-88cf-18ba5b394eb6
200 OK
```


```json
{
  "data": {
    "id": "9b751b42-b08a-4363-943a-ddce4910f85e",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/b3d98b8a-7d13-4223-ae0a-e4578911a91b"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/9b751b42-b08a-4363-943a-ddce4910f85e/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/9b751b42-b08a-4363-943a-ddce4910f85e/relationships/parent",
          "related": "/syntax_nodes/9b751b42-b08a-4363-943a-ddce4910f85e"
        }
      }
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/9b751b42-b08a-4363-943a-ddce4910f85e"
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
DELETE /syntax_nodes/8cb40220-d9c2-46de-8537-0c16ba28c5f2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8c4e0f6c-e07d-4396-86d1-bd1f3d7f419d
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


## Modify translations

Adds new translation to resource based on Accept-Language header.
There is an information about available locales in the meta data.


### Request

#### Endpoint

```plaintext
PATCH /progress_models/63a50d34-e0b4-4ada-b2c6-59edc4d0ca3e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: da,en-US;q=0.9,en;q=0.8,da-DK;q=0.7
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "63a50d34-e0b4-4ada-b2c6-59edc4d0ca3e",
    "type": "progress_model",
    "attributes": {
      "name": "name - DA"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | Translated name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: beaccd1e-d0f5-46e8-b39e-b5978e48f85f
200 OK
```


```json
{
  "data": {
    "id": "63a50d34-e0b4-4ada-b2c6-59edc4d0ca3e",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "order": 222,
      "published": false,
      "published_at": null,
      "name": "name - DA",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=63a50d34-e0b4-4ada-b2c6-59edc4d0ca3e",
          "self": "/progress_models/63a50d34-e0b4-4ada-b2c6-59edc4d0ca3e/relationships/progress_steps"
        }
      }
    },
    "meta": {
      "locales": [
        "da",
        "en"
      ],
      "current_locale": "da"
    }
  },
  "links": {
    "self": "http://example.org/progress_models/63a50d34-e0b4-4ada-b2c6-59edc4d0ca3e"
  }
}
```



## List


### Request

#### Endpoint

```plaintext
GET /progress_models
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
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
X-Request-Id: bea55ac3-c68b-4a33-9a0c-f0778b500a59
200 OK
```


```json
{
  "data": [
    {
      "id": "ab76d2e0-4bb5-403e-b77b-b297b8452c60",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "order": 223,
        "published": true,
        "published_at": "2020-11-20T12:48:33.626+00:00",
        "name": "pm 1",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=ab76d2e0-4bb5-403e-b77b-b297b8452c60",
            "self": "/progress_models/ab76d2e0-4bb5-403e-b77b-b297b8452c60/relationships/progress_steps"
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en"
      }
    },
    {
      "id": "885af1a7-36a4-4cf1-b672-a4d0fb630e26",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "order": 224,
        "published": false,
        "published_at": null,
        "name": "pm 2",
        "type": "object_occurrence_relation"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=885af1a7-36a4-4cf1-b672-a4d0fb630e26",
            "self": "/progress_models/885af1a7-36a4-4cf1-b672-a4d0fb630e26/relationships/progress_steps"
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en"
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
GET /progress_models/5a6dc0c8-f4fa-488b-a390-4f4b7213bc6b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`GET /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ba6ecfe1-707b-4b6e-acdf-4889d4ccc539
200 OK
```


```json
{
  "data": {
    "id": "5a6dc0c8-f4fa-488b-a390-4f4b7213bc6b",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "order": 229,
      "published": true,
      "published_at": "2020-11-20T12:48:35.377+00:00",
      "name": "pm 1",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=5a6dc0c8-f4fa-488b-a390-4f4b7213bc6b",
          "self": "/progress_models/5a6dc0c8-f4fa-488b-a390-4f4b7213bc6b/relationships/progress_steps"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en"
    }
  },
  "links": {
    "self": "http://example.org/progress_models/5a6dc0c8-f4fa-488b-a390-4f4b7213bc6b"
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
PATCH /progress_models/1d72c8d8-185e-4087-a185-40d8864804f4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "1d72c8d8-185e-4087-a185-40d8864804f4",
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
X-Request-Id: 33525a3b-6c21-4bfa-8f1e-6dbf9f138f2e
200 OK
```


```json
{
  "data": {
    "id": "1d72c8d8-185e-4087-a185-40d8864804f4",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "order": 236,
      "published": false,
      "published_at": null,
      "name": "New progress model name",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=1d72c8d8-185e-4087-a185-40d8864804f4",
          "self": "/progress_models/1d72c8d8-185e-4087-a185-40d8864804f4/relationships/progress_steps"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en"
    }
  },
  "links": {
    "self": "http://example.org/progress_models/1d72c8d8-185e-4087-a185-40d8864804f4"
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
DELETE /progress_models/a1eb9d54-6a55-4ac8-a42e-6dcf59f7b086
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1ecf90e3-119b-448a-8fd0-896a0f2d402e
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
POST /progress_models/5687ba54-38aa-485c-b937-abe0653d6a78/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`POST /progress_models/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 24df91a2-39b9-4b72-8ba7-39c1b36670de
200 OK
```


```json
{
  "data": {
    "id": "5687ba54-38aa-485c-b937-abe0653d6a78",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "order": 244,
      "published": true,
      "published_at": "2020-11-20T12:48:40.137Z",
      "name": "pm 2",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=5687ba54-38aa-485c-b937-abe0653d6a78",
          "self": "/progress_models/5687ba54-38aa-485c-b937-abe0653d6a78/relationships/progress_steps"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en"
    }
  },
  "links": {
    "self": "http://example.org/progress_models/5687ba54-38aa-485c-b937-abe0653d6a78/publish"
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
POST /progress_models/cd5df89d-ed35-4e59-bafe-0ea49d0546e2/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`POST /progress_models/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 1d21e729-ea54-4b3f-88ab-4f5ca486d217
200 OK
```


```json
{
  "data": {
    "id": "cd5df89d-ed35-4e59-bafe-0ea49d0546e2",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-11-20T12:48:41.766Z",
      "order": 248,
      "published": false,
      "published_at": null,
      "name": "pm 2",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=cd5df89d-ed35-4e59-bafe-0ea49d0546e2",
          "self": "/progress_models/cd5df89d-ed35-4e59-bafe-0ea49d0546e2/relationships/progress_steps"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en"
    }
  },
  "links": {
    "self": "http://example.org/progress_models/cd5df89d-ed35-4e59-bafe-0ea49d0546e2/archive"
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
Accept-Language: en-US
```

`POST /progress_models`

#### Parameters


```json
{
  "data": {
    "type": "progress_model",
    "attributes": {
      "name": "New progress model name",
      "order": 999,
      "type": "Project"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: cf97223d-0527-4470-805b-db6722f0cd27
201 Created
```


```json
{
  "data": {
    "id": "d8ad57ef-b958-44be-8512-070bfaf9f1c2",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "order": 999,
      "published": false,
      "published_at": null,
      "name": "New progress model name",
      "type": "project"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=d8ad57ef-b958-44be-8512-070bfaf9f1c2",
          "self": "/progress_models/d8ad57ef-b958-44be-8512-070bfaf9f1c2/relationships/progress_steps"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en"
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


## Modify translations

Adds new translation to resource based on Accept-Language header.
There is an information about available locales in the meta data.


### Request

#### Endpoint

```plaintext
PATCH /progress_steps/b1e3af2c-9f57-49c1-b302-350f395ccb1e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: da,en-US;q=0.9,en;q=0.8,da-DK;q=0.7
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "b1e3af2c-9f57-49c1-b302-350f395ccb1e",
    "type": "progress_step",
    "attributes": {
      "name": "name - DA"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | Translated name |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ac834fd7-6a6a-47ef-8f39-c62246cb8585
200 OK
```


```json
{
  "data": {
    "id": "b1e3af2c-9f57-49c1-b302-350f395ccb1e",
    "type": "progress_step",
    "attributes": {
      "order": 1,
      "name": "name - DA",
      "hex_color": "1c6c74"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/32ff7cc9-e3e3-4362-b793-838362835fd7"
        }
      }
    },
    "meta": {
      "locales": [
        "da",
        "en"
      ],
      "current_locale": "da",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/b1e3af2c-9f57-49c1-b302-350f395ccb1e"
  }
}
```



## List


### Request

#### Endpoint

```plaintext
GET /progress_steps
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
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
X-Request-Id: 4f4f85bb-f696-41e3-9dfb-f92fe347f57a
200 OK
```


```json
{
  "data": [
    {
      "id": "f6ab51b6-5292-4cdc-b653-52650eabb489",
      "type": "progress_step",
      "attributes": {
        "order": 1,
        "name": "ps ooc",
        "hex_color": "eec1da"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/0f0d5b97-b8c5-4177-87c4-ced6ae9c90bd"
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "25db4304-a788-4f51-92b5-495861dd3bb8",
      "type": "progress_step",
      "attributes": {
        "order": 1,
        "name": "ps oor",
        "hex_color": "a9c2f4"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/216500c3-6304-418d-b199-3a0db66954f4"
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "958ffc13-121f-4415-88a0-9fbd184faff5",
      "type": "progress_step",
      "attributes": {
        "order": 1,
        "name": "ps context",
        "hex_color": "336de6"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/9efc88b6-13a3-4407-b1ca-81d99df66e13"
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "f75a29fb-8974-4183-bba8-73d7b4569b32",
      "type": "progress_step",
      "attributes": {
        "order": 1,
        "name": "ps project",
        "hex_color": "5edb0a"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/154952f6-a37a-45fd-a3a6-2d9f4a8db607"
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
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
GET /progress_steps/e44a109c-560d-4276-a612-d230b56c08be
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`GET /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a7cd240f-da57-4a43-85e4-7770f1e56584
200 OK
```


```json
{
  "data": {
    "id": "e44a109c-560d-4276-a612-d230b56c08be",
    "type": "progress_step",
    "attributes": {
      "order": 1,
      "name": "ps oor",
      "hex_color": "1a3c25"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/dd7db0dc-7b15-4ac1-9faf-e06e0eddff47"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/e44a109c-560d-4276-a612-d230b56c08be"
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
PATCH /progress_steps/17c7dffb-9cdd-40f1-a8dd-48f022c3ae74
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "17c7dffb-9cdd-40f1-a8dd-48f022c3ae74",
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
X-Request-Id: 7f7e4294-30f3-4966-96ba-44b2d3de937b
200 OK
```


```json
{
  "data": {
    "id": "17c7dffb-9cdd-40f1-a8dd-48f022c3ae74",
    "type": "progress_step",
    "attributes": {
      "order": 1,
      "name": "New progress step name",
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/2c425a50-fec2-46d9-957c-6d993fdd2ace"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/17c7dffb-9cdd-40f1-a8dd-48f022c3ae74"
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
DELETE /progress_steps/8b2cf4e2-ba3d-4c44-873b-52979291c664
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5a5f9def-6661-4de2-8857-23f698446c5b
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
POST /progress_models/8b47964c-3b8f-42e1-afcc-2976b2e327cc/relationships/progress_steps
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
Accept-Language: en-US
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
X-Request-Id: c260c77d-6128-4607-9335-30e7b9d72b0f
201 Created
```


```json
{
  "data": {
    "id": "369d0c39-1da9-4434-aa3b-5fe6b67423a0",
    "type": "progress_step",
    "attributes": {
      "order": 999,
      "name": "New progress step name",
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/8b47964c-3b8f-42e1-afcc-2976b2e327cc"
        }
      }
    },
    "meta": {
      "locales": [
        "en"
      ],
      "current_locale": "en",
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/progress_models/8b47964c-3b8f-42e1-afcc-2976b2e327cc/relationships/progress_steps"
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


## Delete


### Request

#### Endpoint

```plaintext
DELETE /progress/5c0d768a-1a9c-4809-8258-4c25e7c4da1e_b63aa30c-b97f-4269-8ac0-c640908c11a4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b630cc64-47d9-41fd-8b4c-bead18d13ba8
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
          "id": "216a4655-354e-4e7b-8426-00d24fde642e"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "23feada4-762a-4f85-928e-79c3b29723ac"
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
X-Request-Id: 24bf5b78-9999-44e5-9fff-1becfd0f47f8
201 Created
```


```json
{
  "data": {
    "id": "216a4655-354e-4e7b-8426-00d24fde642e_23feada4-762a-4f85-928e-79c3b29723ac",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "216a4655-354e-4e7b-8426-00d24fde642e",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/216a4655-354e-4e7b-8426-00d24fde642e"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/23feada4-762a-4f85-928e-79c3b29723ac"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
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
X-Request-Id: a5a6aa6a-e84b-438d-93c0-1ce2ecb9972a
200 OK
```


```json
{
  "data": [
    {
      "id": "2877f42e-954c-4992-b2de-1fe07af24ad6",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/20cc67a0-0c29-4797-b10d-da43df908815"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
GET /projects/6f77622f-3e65-412e-a718-81105a2029f7/relationships/project_setting
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
X-Request-Id: c53b8ddc-ff71-492c-8b65-6c5cd2ef07d0
200 OK
```


```json
{
  "data": {
    "id": "349c3bb0-9d0d-4aa5-8eda-772ea76d8d48",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/6f77622f-3e65-412e-a718-81105a2029f7"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/projects/6f77622f-3e65-412e-a718-81105a2029f7/relationships/project_setting"
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
PATCH /projects/d4098dae-20e2-41d8-b53d-cc0c6e130dff/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "d4098dae-20e2-41d8-b53d-cc0c6e130dff",
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
X-Request-Id: 4015d058-6147-4512-8f70-6e4c199dc96b
200 OK
```


```json
{
  "data": {
    "id": "1cb364a0-a0ea-457a-9413-ddd58e6ce61c",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/d4098dae-20e2-41d8-b53d-cc0c6e130dff"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/projects/d4098dae-20e2-41d8-b53d-cc0c6e130dff/relationships/project_setting"
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
X-Request-Id: 463d8e43-e7bc-48e8-ba2a-efed116aacab
200 OK
```


```json
{
  "data": [
    {
      "id": "d45c0b7c-0693-49f6-8de6-45890512ed8b",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/d45c0b7c-0693-49f6-8de6-45890512ed8b"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/d45c0b7c-0693-49f6-8de6-45890512ed8b"
          }
        }
      },
      "meta": {
      }
    },
    {
      "id": "d8512d22-420b-4cfb-9d04-4b84d6be3f23",
      "type": "system_element",
      "attributes": {
        "name": "Context 155975944579-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/d8512d22-420b-4cfb-9d04-4b84d6be3f23"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/d8512d22-420b-4cfb-9d04-4b84d6be3f23"
          }
        }
      },
      "meta": {
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/system_elements",
    "current": "http://example.org/system_elements?page[number]=1&sort=name"
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
GET /system_elements/3d1c8ef0-6473-490b-bec6-7f0e05400a38
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
X-Request-Id: e692510e-da79-40fe-83b8-191ccff6c2a2
200 OK
```


```json
{
  "data": {
    "id": "3d1c8ef0-6473-490b-bec6-7f0e05400a38",
    "type": "system_element",
    "attributes": {
      "name": "Context cf2832cccbb3-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/3d1c8ef0-6473-490b-bec6-7f0e05400a38"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/3d1c8ef0-6473-490b-bec6-7f0e05400a38"
        }
      }
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/system_elements/3d1c8ef0-6473-490b-bec6-7f0e05400a38"
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
POST /object_occurrences/6e5aaee4-2aeb-440a-8fd8-a5d6776c5b9d/relationships/system_elements
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
      "target_id": "0c493b4b-4261-415c-833b-7d688a75c79b"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 30974525-625b-4402-a610-172f46f1fc54
201 Created
```


```json
{
  "data": {
    "id": "579e112c-df26-40c5-9dc3-77b006146ee4",
    "type": "system_element",
    "attributes": {
      "name": "Context 65055938ddd2-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/579e112c-df26-40c5-9dc3-77b006146ee4"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/579e112c-df26-40c5-9dc3-77b006146ee4"
        }
      }
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/6e5aaee4-2aeb-440a-8fd8-a5d6776c5b9d/relationships/system_elements"
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
DELETE /object_occurrences/c59b8e0a-e47d-44a3-a8e2-a80325baaab3/relationships/system_elements/ca2fd200-4565-4ddb-837f-0d527b912405
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1288cbd0-85ab-41b6-b223-0de51e33133a
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
POST /object_occurrence_relations/54db9a89-80a1-4d4f-9efc-fd86e5fa72b0/relationships/owners
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
X-Request-Id: 5c662e2b-ddce-435c-b227-4ad771ef68cf
201 Created
```


```json
{
  "data": {
    "id": "33f19b42-6a14-4e03-a9fc-96df3003dcb0",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/54db9a89-80a1-4d4f-9efc-fd86e5fa72b0/relationships/owners"
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
POST /object_occurrence_relations/4594e3ec-aefa-415b-9f5e-e9535bc6aae2/relationships/owners
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
X-Request-Id: 892eae51-fec0-4dce-9a96-549f0cd87e96
201 Created
```


```json
{
  "data": {
    "id": "e4005b5d-d531-4d2a-ad1c-06d089d84b7a",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/4594e3ec-aefa-415b-9f5e-e9535bc6aae2/relationships/owners"
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
POST /object_occurrence_relations/c16c30af-2f54-4e48-b92d-ffc86e5e7d78/relationships/owners
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
    "id": "f541d418-840d-44c7-9d3d-a9b3e98ef4a1"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 88827c4f-408c-45a7-8707-f52d04fdba26
201 Created
```


```json
{
  "data": {
    "id": "f541d418-840d-44c7-9d3d-a9b3e98ef4a1",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 35",
      "title": null
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/c16c30af-2f54-4e48-b92d-ffc86e5e7d78/relationships/owners"
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
DELETE /object_occurrence_relations/8de0d363-f26c-446e-9199-d73d09a71bdb/relationships/owners/12e87cda-987e-4489-b7f0-a5de38c09400
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fd92136a-3f87-40e1-898b-05cf65e8069b
204 No Content
```




## List


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=fbc4dad6-a5b1-4d0a-8089-387a994e00b0&amp;filter[object_occurrence_source_ids_cont][]=70542bc1-4cfe-4979-8afb-c36c26ccde8f&amp;filter[object_occurrence_target_ids_cont][]=790196c6-048d-4a38-8da1-e96f5c5fa1cc&amp;filter[progress_steps_gte]=3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;fbc4dad6-a5b1-4d0a-8089-387a994e00b0&quot;, &quot;70542bc1-4cfe-4979-8afb-c36c26ccde8f&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;790196c6-048d-4a38-8da1-e96f5c5fa1cc&quot;], &quot;progress_steps_gte&quot;=&gt;&quot;3&quot;}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | filter by source relationships |
| filter[object_occurrence_target_ids_cont]  | filter by target relationships |
| filter[progress_steps_gte]  | filtering by at least one checked step that is ≥ provided value |
| filter[progress_steps_lte]  | filtering by at least one not checked step that is ≤ provided value |
| filter[oor_classification_code_in]  | filter by classification codes |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ddb121a1-b655-4bd7-897e-603d66d348c7
200 OK
```


```json
{
  "data": [
    {
      "id": "ff8ac4ca-3eb9-4d53-a8d0-61765b42039e",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation 437f53536ef7",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=ff8ac4ca-3eb9-4d53-a8d0-61765b42039e",
            "self": "/object_occurrence_relations/ff8ac4ca-3eb9-4d53-a8d0-61765b42039e/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=ff8ac4ca-3eb9-4d53-a8d0-61765b42039e&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/ff8ac4ca-3eb9-4d53-a8d0-61765b42039e/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "eaffa40f-c3d9-48ac-8f77-0b136e35d648_ff8ac4ca-3eb9-4d53-a8d0-61765b42039e",
              "type": "progress_step_checked"
            }
          ]
        },
        "classification_entry": {
          "data": {
            "id": "996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5",
            "self": "/object_occurrence_relations/ff8ac4ca-3eb9-4d53-a8d0-61765b42039e/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "790196c6-048d-4a38-8da1-e96f5c5fa1cc",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/790196c6-048d-4a38-8da1-e96f5c5fa1cc",
            "self": "/object_occurrence_relations/ff8ac4ca-3eb9-4d53-a8d0-61765b42039e/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "fbc4dad6-a5b1-4d0a-8089-387a994e00b0",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/fbc4dad6-a5b1-4d0a-8089-387a994e00b0",
            "self": "/object_occurrence_relations/ff8ac4ca-3eb9-4d53-a8d0-61765b42039e/relationships/source"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 99e89f4185f7",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5",
            "self": "/classification_entries/996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "7aac20ee-4c12-48ed-bc54-16b6cac8eb19",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/7aac20ee-4c12-48ed-bc54-16b6cac8eb19"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5",
            "self": "/classification_entries/996b6f66-dd02-4d6e-8f6a-6dd63f75b9f5/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "eaffa40f-c3d9-48ac-8f77-0b136e35d648_ff8ac4ca-3eb9-4d53-a8d0-61765b42039e",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "eaffa40f-c3d9-48ac-8f77-0b136e35d648",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/eaffa40f-c3d9-48ac-8f77-0b136e35d648"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/ff8ac4ca-3eb9-4d53-a8d0-61765b42039e"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=fbc4dad6-a5b1-4d0a-8089-387a994e00b0&filter[object_occurrence_source_ids_cont][]=70542bc1-4cfe-4979-8afb-c36c26ccde8f&filter[object_occurrence_target_ids_cont][]=790196c6-048d-4a38-8da1-e96f5c5fa1cc&filter[progress_steps_gte]=3",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=fbc4dad6-a5b1-4d0a-8089-387a994e00b0&filter[object_occurrence_source_ids_cont][]=70542bc1-4cfe-4979-8afb-c36c26ccde8f&filter[object_occurrence_target_ids_cont][]=790196c6-048d-4a38-8da1-e96f5c5fa1cc&filter[progress_steps_gte]=3&include=tags,owners,progress_step_checked,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98
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
X-Request-Id: 906b8ae7-50c3-4adb-8158-99784877fc01
200 OK
```


```json
{
  "data": {
    "id": "d3fcca21-0dc7-4947-8787-7ef618062d98",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "ObjectOccurrenceRelation 08ae16b58717",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "360dea1e-62f5-4f20-9df3-b344ca1bf926",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=d3fcca21-0dc7-4947-8787-7ef618062d98",
          "self": "/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "166e6bf4-ac0c-452d-bcf2-d973c5f218da",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=d3fcca21-0dc7-4947-8787-7ef618062d98&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "22226cae-81c8-4c40-b08f-cc31a4345a1c_d3fcca21-0dc7-4947-8787-7ef618062d98",
            "type": "progress_step_checked"
          }
        ]
      },
      "classification_entry": {
        "data": {
          "id": "4f5b8f8e-7e7b-4164-8c0a-624384edd4be",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/4f5b8f8e-7e7b-4164-8c0a-624384edd4be",
          "self": "/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "c460d24f-b3e6-4645-881e-9e13b79e02a6",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/c460d24f-b3e6-4645-881e-9e13b79e02a6",
          "self": "/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "60113b5c-57cb-4e0d-8840-dfebcbf4af31",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/60113b5c-57cb-4e0d-8840-dfebcbf4af31",
          "self": "/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98/relationships/source"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98"
  },
  "included": [
    {
      "id": "4f5b8f8e-7e7b-4164-8c0a-624384edd4be",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 27b383aa82bd",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=4f5b8f8e-7e7b-4164-8c0a-624384edd4be",
            "self": "/classification_entries/4f5b8f8e-7e7b-4164-8c0a-624384edd4be/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "9af766f0-d160-4a14-b6c9-c39b735e1f22",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/9af766f0-d160-4a14-b6c9-c39b735e1f22"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=4f5b8f8e-7e7b-4164-8c0a-624384edd4be",
            "self": "/classification_entries/4f5b8f8e-7e7b-4164-8c0a-624384edd4be/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "166e6bf4-ac0c-452d-bcf2-d973c5f218da",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 42",
        "title": null
      },
      "meta": {
      }
    },
    {
      "id": "22226cae-81c8-4c40-b08f-cc31a4345a1c_d3fcca21-0dc7-4947-8787-7ef618062d98",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "22226cae-81c8-4c40-b08f-cc31a4345a1c",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/22226cae-81c8-4c40-b08f-cc31a4345a1c"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/d3fcca21-0dc7-4947-8787-7ef618062d98"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "360dea1e-62f5-4f20-9df3-b344ca1bf926",
      "type": "tag",
      "attributes": {
        "value": "Tag value 44"
      },
      "relationships": {
      },
      "meta": {
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
X-Request-Id: 6e04b61e-7015-4917-90d0-af018235df5c
200 OK
```


```json
{
  "data": [
    {
      "id": "cf6db622f4da7df887cac6acdb4c800c27ddc428bc3e9dfd3da8dd325d2b05ae",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "58f5c210-7ae4-4a11-867c-846bbfb4038a",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/58f5c210-7ae4-4a11-867c-846bbfb4038a"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "0830f41bcd4f9a9e352b428b114d327ccdea1a35fa7b459f176ceb848321b8a6",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "bff073da-9d0a-4387-8ec5-2419aaf8de75",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/bff073da-9d0a-4387-8ec5-2419aaf8de75"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "829b46ecb6478465b5f1f6397cbff683402e448bc4b2e91ea24dabd59ff5c68f",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "6aba76da-f2d2-427f-9f13-f327c1bed83d",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/6aba76da-f2d2-427f-9f13-f327c1bed83d"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "58f5c210-7ae4-4a11-867c-846bbfb4038a",
      "type": "classification_entry",
      "attributes": {
        "code": "RA",
        "definition": "Alarm signal RA",
        "name": "Alarm 75a153c0733b",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=58f5c210-7ae4-4a11-867c-846bbfb4038a",
            "self": "/classification_entries/58f5c210-7ae4-4a11-867c-846bbfb4038a/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "c4a69b58-10b6-410b-93be-0506dcc0cfed",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/c4a69b58-10b6-410b-93be-0506dcc0cfed"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=58f5c210-7ae4-4a11-867c-846bbfb4038a",
            "self": "/classification_entries/58f5c210-7ae4-4a11-867c-846bbfb4038a/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "bff073da-9d0a-4387-8ec5-2419aaf8de75",
      "type": "classification_entry",
      "attributes": {
        "code": "RB",
        "definition": "Alarm signal RB",
        "name": "Alarm cf34c96b8f1b",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=bff073da-9d0a-4387-8ec5-2419aaf8de75",
            "self": "/classification_entries/bff073da-9d0a-4387-8ec5-2419aaf8de75/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "c4a69b58-10b6-410b-93be-0506dcc0cfed",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/c4a69b58-10b6-410b-93be-0506dcc0cfed"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=bff073da-9d0a-4387-8ec5-2419aaf8de75",
            "self": "/classification_entries/bff073da-9d0a-4387-8ec5-2419aaf8de75/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "6aba76da-f2d2-427f-9f13-f327c1bed83d",
      "type": "classification_entry",
      "attributes": {
        "code": "RC",
        "definition": "Alarm signal RC",
        "name": "Alarm a1526e842d9e",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=6aba76da-f2d2-427f-9f13-f327c1bed83d",
            "self": "/classification_entries/6aba76da-f2d2-427f-9f13-f327c1bed83d/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "9fc50f6d-ac51-4ce2-b768-1e2e6ff53d0f",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/9fc50f6d-ac51-4ce2-b768-1e2e6ff53d0f"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=6aba76da-f2d2-427f-9f13-f327c1bed83d",
            "self": "/classification_entries/6aba76da-f2d2-427f-9f13-f327c1bed83d/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/classification_entries_stats",
    "current": "http://example.org/object_occurrence_relations/classification_entries_stats?include=classification_entry&page[number]=1&sort=code"
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
X-Request-Id: adf62b9c-ace8-4e0a-b0c8-8b04218476d2
200 OK
```


```json
{
  "data": [
    {
      "id": "30e61e81-a985-4600-9730-4c1d00432ebd",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "8602511c-ca44-4945-b15e-1b26fb612d6f",
            "type": "context"
          },
          "links": {
            "related": "/contexts/8602511c-ca44-4945-b15e-1b26fb612d6f"
          }
        },
        "user": {
          "data": {
            "id": "auth0|558964d25542c02474fb206276580e0de2663a57f976c778",
            "type": "user"
          },
          "links": {
            "related": "/users/%23%3Cstruct%20User%20account_id=%22d41a5b1b-281f-444d-9e92-febfe27b5bde%22,%20id=%22auth0%7C558964d25542c02474fb206276580e0de2663a57f976c778%22,%20name=%22emk@syseng.dk%22,%20email=%22emk@syseng.dk%22,%20updated_at=2020-02-12%2012:07:35.98%20UTC%3E"
          }
        },
        "permission": {
          "data": {
            "id": "54911179-a185-40a8-945b-4e99712604b2",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/54911179-a185-40a8-945b-4e99712604b2"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "a8eb3f1e-fd7f-4839-995e-60274b993bc1",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "adce6a29-cc0b-4f86-bd2c-902f3ccfa902",
            "type": "project"
          },
          "links": {
            "related": "/projects/adce6a29-cc0b-4f86-bd2c-902f3ccfa902"
          }
        },
        "user": {
          "data": {
            "id": "auth0|558964d25542c02474fb206276580e0de2663a57f976c778",
            "type": "user"
          },
          "links": {
            "related": "/users/%23%3Cstruct%20User%20account_id=%22d41a5b1b-281f-444d-9e92-febfe27b5bde%22,%20id=%22auth0%7C558964d25542c02474fb206276580e0de2663a57f976c778%22,%20name=%22emk@syseng.dk%22,%20email=%22emk@syseng.dk%22,%20updated_at=2020-02-12%2012:07:35.98%20UTC%3E"
          }
        },
        "permission": {
          "data": {
            "id": "3fb85e04-b0e4-48a2-bb00-253ffc0bac40",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/3fb85e04-b0e4-48a2-bb00-253ffc0bac40"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
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
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=f84a5eb0-6c37-4757-b230-67a06d95099c&amp;filter[user_id_eq]=auth0%7C6245b0b623a9355215e1b2bec6f5509d4840482236761e85&amp;filter[permission_id_eq]=e3143388-a7e8-40af-a222-3301105be220
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;f84a5eb0-6c37-4757-b230-67a06d95099c&quot;, &quot;user_id_eq&quot;=&gt;&quot;auth0|6245b0b623a9355215e1b2bec6f5509d4840482236761e85&quot;, &quot;permission_id_eq&quot;=&gt;&quot;e3143388-a7e8-40af-a222-3301105be220&quot;}
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
X-Request-Id: bcf4d018-83ff-41d6-998b-0895a7c98d6f
200 OK
```


```json
{
  "data": [
    {
      "id": "8384f611-9243-49af-98a0-94033a0a0cfc",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "f84a5eb0-6c37-4757-b230-67a06d95099c",
            "type": "project"
          },
          "links": {
            "related": "/projects/f84a5eb0-6c37-4757-b230-67a06d95099c"
          }
        },
        "user": {
          "data": {
            "id": "auth0|6245b0b623a9355215e1b2bec6f5509d4840482236761e85",
            "type": "user"
          },
          "links": {
            "related": "/users/%23%3Cstruct%20User%20account_id=%22571e541f-c98c-4af7-a5a2-4434b74d3acf%22,%20id=%22auth0%7C6245b0b623a9355215e1b2bec6f5509d4840482236761e85%22,%20name=%22emk@syseng.dk%22,%20email=%22emk@syseng.dk%22,%20updated_at=2020-02-12%2012:07:35.98%20UTC%3E"
          }
        },
        "permission": {
          "data": {
            "id": "e3143388-a7e8-40af-a222-3301105be220",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/e3143388-a7e8-40af-a222-3301105be220"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/user_permissions?filter[target_type_eq]=project&filter[target_id_eq]=f84a5eb0-6c37-4757-b230-67a06d95099c&filter[user_id_eq]=auth0%7C6245b0b623a9355215e1b2bec6f5509d4840482236761e85&filter[permission_id_eq]=e3143388-a7e8-40af-a222-3301105be220",
    "current": "http://example.org/user_permissions?filter[permission_id_eq]=e3143388-a7e8-40af-a222-3301105be220&filter[target_id_eq]=f84a5eb0-6c37-4757-b230-67a06d95099c&filter[target_type_eq]=project&filter[user_id_eq]=auth0|6245b0b623a9355215e1b2bec6f5509d4840482236761e85&page[number]=1"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /user_permissions/d132566b-c419-4aca-8bb1-3f361dfefc4a
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
X-Request-Id: 209668a6-c176-497e-9956-d64fd843c5a0
200 OK
```


```json
{
  "data": {
    "id": "d132566b-c419-4aca-8bb1-3f361dfefc4a",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "27469140-d082-4df4-ae8f-573700e7b354",
          "type": "project"
        },
        "links": {
          "related": "/projects/27469140-d082-4df4-ae8f-573700e7b354"
        }
      },
      "user": {
        "data": {
          "id": "auth0|f07c3152bc1634c271b4b38a7e10fc01ad63d777f1e0a8df",
          "type": "user"
        },
        "links": {
          "related": "/users/%23%3Cstruct%20User%20account_id=%229ba99d25-b09d-484e-8b89-dfa889483d86%22,%20id=%22auth0%7Cf07c3152bc1634c271b4b38a7e10fc01ad63d777f1e0a8df%22,%20name=%22emk@syseng.dk%22,%20email=%22emk@syseng.dk%22,%20updated_at=2020-02-12%2012:07:35.98%20UTC%3E"
        }
      },
      "permission": {
        "data": {
          "id": "c955d116-fa97-4fec-aa03-6658e241dc9e",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/c955d116-fa97-4fec-aa03-6658e241dc9e"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/user_permissions/d132566b-c419-4aca-8bb1-3f361dfefc4a"
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
          "id": "36788250-689a-448e-9755-6fe9d1a8c530"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "0d21efce-0bbf-4638-8580-e9e0d3e5a0a7"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "auth0|6fdfa351e033bcdc7bcbdce6c0be55810bd2ef8bf84cdf5f"
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
X-Request-Id: 33dde138-cf12-4f31-b290-e03dee8171ba
201 Created
```


```json
{
  "data": {
    "id": "603639a4-72d8-4b0c-a49d-b12239b4f1e5",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "36788250-689a-448e-9755-6fe9d1a8c530",
          "type": "project"
        },
        "links": {
          "related": "/projects/36788250-689a-448e-9755-6fe9d1a8c530"
        }
      },
      "user": {
        "data": {
          "id": "auth0|6fdfa351e033bcdc7bcbdce6c0be55810bd2ef8bf84cdf5f",
          "type": "user"
        },
        "links": {
          "related": "/users/%23%3Cstruct%20User%20account_id=%22b17462bb-e8ca-479c-a77d-3c982eaa3cbf%22,%20id=%22auth0%7C6fdfa351e033bcdc7bcbdce6c0be55810bd2ef8bf84cdf5f%22,%20name=%22emk@syseng.dk%22,%20email=%22emk@syseng.dk%22,%20updated_at=2020-02-12%2012:07:35.98%20UTC%3E"
        }
      },
      "permission": {
        "data": {
          "id": "0d21efce-0bbf-4638-8580-e9e0d3e5a0a7",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/0d21efce-0bbf-4638-8580-e9e0d3e5a0a7"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
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
DELETE /user_permissions/611af184-2832-4359-918a-c826e1163065
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0f523bf7-440b-4801-b1f1-55952e2311c7
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
X-Request-Id: c2c6e9d8-0eb9-450c-bd57-f9e5ea6051b6
200 OK
```


```json
{
  "data": {
    "id": "9fe08601-401d-47f8-a2f4-7f1398a25677",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "auth0|5b9fdc8c6e143345cea369c40b4a11a8fbca21c1057696b6"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/auth0%7C5b9fdc8c6e143345cea369c40b4a11a8fbca21c1057696b6"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
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
X-Request-Id: 1373cb1c-e0c8-4cfb-b464-d18a9b26f155
200 OK
```


```json
{
  "data": {
    "id": "d5cc7f57-6091-4402-b436-b50385aa1216",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "auth0|73b940d5d9418fa08806c688b9c59a672b2a85c1c5ad5cfe"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/auth0%7C73b940d5d9418fa08806c688b9c59a672b2a85c1c5ad5cfe"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][newsletter] | Value which tell if user give consent for neewsletter. |


# Chain analysis

Chain analysis returns the Object Occurrences / Object Occurrence Relations
that's related to the source Object Occurrence through Object Occurrence Relations
limited to givent steps forward & backward

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
GET /chain_analysis/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/object_occurrences?steps_forward=2&amp;steps_backward=2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /chain_analysis/:id/object_occurrences`

#### Parameters


```json
steps_forward: 2
steps_backward: 2
```


| Name | Description |
|:-----|:------------|
| steps_forward  | Steps forward to look out into the chain |
| steps_backward  | Steps backward to look out into the chain |
| sort  | available sort fields: classification_code, name, number, type |
| query  | search query |
| filter[context_id_eq]  | filter by context id |
| filter[progress_steps_gte]  | filtering by at least one checked step that is ≥ provided value |
| filter[progress_steps_lte]  | filtering by at least one not checked step that is ≤ provided value |
| filter[syntax_element_id_in]  | filter by syntax elements ids |
| filter[oor_classification_code_in]  | filter by classification codes |
| filter[components_blank]  | filter by blank components |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 523af2de-d456-464e-b3fa-147b442c2a5a
200 OK
```


```json
{
  "data": [
    {
      "id": "cc2f900b-d3d5-4993-a0d0-99bf81cd8a74",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
        "name": "OOC2",
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
            "related": "/tags?filter[target_id_eq]=cc2f900b-d3d5-4993-a0d0-99bf81cd8a74",
            "self": "/object_occurrences/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=cc2f900b-d3d5-4993-a0d0-99bf81cd8a74&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "cc2f900b-d3d5-4993-a0d0-99bf81cd8a74",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e07ab576-0a74-45a4-a5be-53898293bff9"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/bec3715c-e8ac-41fa-b297-42a965720a19",
            "self": "/object_occurrences/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=cc2f900b-d3d5-4993-a0d0-99bf81cd8a74"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=cc2f900b-d3d5-4993-a0d0-99bf81cd8a74"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "cb6183f9-edd5-4acf-9dea-2ff2d6aabe26",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
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
            "related": "/tags?filter[target_id_eq]=cb6183f9-edd5-4acf-9dea-2ff2d6aabe26",
            "self": "/object_occurrences/cb6183f9-edd5-4acf-9dea-2ff2d6aabe26/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=cb6183f9-edd5-4acf-9dea-2ff2d6aabe26&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/cb6183f9-edd5-4acf-9dea-2ff2d6aabe26/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "cb6183f9-edd5-4acf-9dea-2ff2d6aabe26",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/cb6183f9-edd5-4acf-9dea-2ff2d6aabe26/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e07ab576-0a74-45a4-a5be-53898293bff9"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/bec3715c-e8ac-41fa-b297-42a965720a19",
            "self": "/object_occurrences/cb6183f9-edd5-4acf-9dea-2ff2d6aabe26/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/cb6183f9-edd5-4acf-9dea-2ff2d6aabe26/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=cb6183f9-edd5-4acf-9dea-2ff2d6aabe26"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=cb6183f9-edd5-4acf-9dea-2ff2d6aabe26"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "7613043d-1055-4f8f-ad00-a2d78d30a888",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
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
            "related": "/tags?filter[target_id_eq]=7613043d-1055-4f8f-ad00-a2d78d30a888",
            "self": "/object_occurrences/7613043d-1055-4f8f-ad00-a2d78d30a888/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=7613043d-1055-4f8f-ad00-a2d78d30a888&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/7613043d-1055-4f8f-ad00-a2d78d30a888/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "7613043d-1055-4f8f-ad00-a2d78d30a888",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/7613043d-1055-4f8f-ad00-a2d78d30a888/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e07ab576-0a74-45a4-a5be-53898293bff9"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/bec3715c-e8ac-41fa-b297-42a965720a19",
            "self": "/object_occurrences/7613043d-1055-4f8f-ad00-a2d78d30a888/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/7613043d-1055-4f8f-ad00-a2d78d30a888/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7613043d-1055-4f8f-ad00-a2d78d30a888"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7613043d-1055-4f8f-ad00-a2d78d30a888"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "8271338c-d15e-4244-a8e5-8f028651e5bd",
      "type": "object_occurrence",
      "attributes": {
        "description": null,
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
            "related": "/tags?filter[target_id_eq]=8271338c-d15e-4244-a8e5-8f028651e5bd",
            "self": "/object_occurrences/8271338c-d15e-4244-a8e5-8f028651e5bd/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=8271338c-d15e-4244-a8e5-8f028651e5bd&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/8271338c-d15e-4244-a8e5-8f028651e5bd/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "image": {
          "data": {
            "id": "8271338c-d15e-4244-a8e5-8f028651e5bd",
            "type": "url_struct"
          },
          "links": {
            "self": "/object_occurrences/8271338c-d15e-4244-a8e5-8f028651e5bd/relationships/image"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e07ab576-0a74-45a4-a5be-53898293bff9"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/bec3715c-e8ac-41fa-b297-42a965720a19",
            "self": "/object_occurrences/8271338c-d15e-4244-a8e5-8f028651e5bd/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/8271338c-d15e-4244-a8e5-8f028651e5bd/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=8271338c-d15e-4244-a8e5-8f028651e5bd"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=8271338c-d15e-4244-a8e5-8f028651e5bd"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [

  ],
  "meta": {
    "total_count": 4
  },
  "links": {
    "self": "http://example.org/chain_analysis/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/object_occurrences?steps_forward=2&steps_backward=2",
    "current": "http://example.org/chain_analysis/cc2f900b-d3d5-4993-a0d0-99bf81cd8a74/object_occurrences?include=syntax_element,tags,owners,progress_step_checked&page[number]=1&steps_backward=2&steps_forward=2"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[steps_forward] | n steps forward to look out |
| data[steps_backward] | n steps backward to look out |
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
| data[steps_forward] | n steps forward to look out |
| data[steps_backward] | n steps backward to look out |
| data[id] | Object Occurrence resource ID |
| data[links] | JSON:API links data |
| data[attributes][steps] | chain steps for given OOR |
| data[relationships][object_occurrence_relation] | OOR |


## Result


### Request

#### Endpoint

```plaintext
GET /chain_analysis/e590b3c6-4aec-4b33-89e9-4e9b3a7aac65/object_occurrence_relations?steps_forward=2&amp;steps_backward=2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /chain_analysis/:id/object_occurrence_relations`

#### Parameters


```json
steps_forward: 2
steps_backward: 2
```


| Name | Description |
|:-----|:------------|
| steps_forward  | Steps forward to look out into the chain |
| steps_backward  | Steps backward to look out into the chain |
| filter[object_occurrence_source_ids_cont]  | filter by source relationships |
| filter[object_occurrence_target_ids_cont]  | filter by target relationships |
| filter[progress_steps_gte]  | filtering by at least one checked step that is ≥ provided value |
| filter[progress_steps_lte]  | filtering by at least one not checked step that is ≤ provided value |
| filter[oor_classification_code_in]  | filter by classification codes |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8db23bb8-f121-465d-88fa-e12f3b956696
200 OK
```


```json
{
  "data": [
    {
      "id": "2a151a8a122b8445ab2633b047e664d9cf04492bd463845f62da30a1a7e8a6d3",
      "type": "oor_chain_element",
      "attributes": {
        "steps": [
          1
        ]
      },
      "relationships": {
        "object_occurrence_relation": {
          "data": {
            "id": "d46165c9-0977-4c8e-92d7-7829e22984dc",
            "type": "object_occurrence_relation"
          },
          "links": {
            "related": "/object_occurrence_relations/d46165c9-0977-4c8e-92d7-7829e22984dc"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "2bfe764e06ac8a7c2b7cafc5055474f25fd7e09b9e9f1ac49e6847bbf7298173",
      "type": "oor_chain_element",
      "attributes": {
        "steps": [
          2
        ]
      },
      "relationships": {
        "object_occurrence_relation": {
          "data": {
            "id": "7ba338a4-aae6-4d07-af98-57d1daa473b7",
            "type": "object_occurrence_relation"
          },
          "links": {
            "related": "/object_occurrence_relations/7ba338a4-aae6-4d07-af98-57d1daa473b7"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "947aec84e320f5caa6d4d45ec7f55e7a863370b20ef75df42275c0a20e19ed56",
      "type": "oor_chain_element",
      "attributes": {
        "steps": [
          2
        ]
      },
      "relationships": {
        "object_occurrence_relation": {
          "data": {
            "id": "144a8cb1-9306-4272-852e-ab815456bacc",
            "type": "object_occurrence_relation"
          },
          "links": {
            "related": "/object_occurrence_relations/144a8cb1-9306-4272-852e-ab815456bacc"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "d46165c9-0977-4c8e-92d7-7829e22984dc",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "oor1",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=d46165c9-0977-4c8e-92d7-7829e22984dc",
            "self": "/object_occurrence_relations/d46165c9-0977-4c8e-92d7-7829e22984dc/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=d46165c9-0977-4c8e-92d7-7829e22984dc&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/d46165c9-0977-4c8e-92d7-7829e22984dc/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "classification_entry": {
          "data": {
            "id": "694e98cb-2088-4f8f-9284-68dc23618fcc",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/694e98cb-2088-4f8f-9284-68dc23618fcc",
            "self": "/object_occurrence_relations/d46165c9-0977-4c8e-92d7-7829e22984dc/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "6bbf60e7-97d3-454c-aa53-2c72dbf56153",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6bbf60e7-97d3-454c-aa53-2c72dbf56153",
            "self": "/object_occurrence_relations/d46165c9-0977-4c8e-92d7-7829e22984dc/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "e590b3c6-4aec-4b33-89e9-4e9b3a7aac65",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/e590b3c6-4aec-4b33-89e9-4e9b3a7aac65",
            "self": "/object_occurrence_relations/d46165c9-0977-4c8e-92d7-7829e22984dc/relationships/source"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "694e98cb-2088-4f8f-9284-68dc23618fcc",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal A",
        "name": "Alarm a408e80fb566",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=694e98cb-2088-4f8f-9284-68dc23618fcc",
            "self": "/classification_entries/694e98cb-2088-4f8f-9284-68dc23618fcc/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "1613475f-a759-4f3a-aa05-22ece7a95e0b",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/1613475f-a759-4f3a-aa05-22ece7a95e0b"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=694e98cb-2088-4f8f-9284-68dc23618fcc",
            "self": "/classification_entries/694e98cb-2088-4f8f-9284-68dc23618fcc/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "7ba338a4-aae6-4d07-af98-57d1daa473b7",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "oor3",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=7ba338a4-aae6-4d07-af98-57d1daa473b7",
            "self": "/object_occurrence_relations/7ba338a4-aae6-4d07-af98-57d1daa473b7/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=7ba338a4-aae6-4d07-af98-57d1daa473b7&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/7ba338a4-aae6-4d07-af98-57d1daa473b7/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "classification_entry": {
          "data": {
            "id": "895952f3-8499-48f3-8a9a-8cf4b0f7741c",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/895952f3-8499-48f3-8a9a-8cf4b0f7741c",
            "self": "/object_occurrence_relations/7ba338a4-aae6-4d07-af98-57d1daa473b7/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "3efd1fe1-ae97-44b0-b07b-cf5eaf9af6ee",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/3efd1fe1-ae97-44b0-b07b-cf5eaf9af6ee",
            "self": "/object_occurrence_relations/7ba338a4-aae6-4d07-af98-57d1daa473b7/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "6bbf60e7-97d3-454c-aa53-2c72dbf56153",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6bbf60e7-97d3-454c-aa53-2c72dbf56153",
            "self": "/object_occurrence_relations/7ba338a4-aae6-4d07-af98-57d1daa473b7/relationships/source"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "895952f3-8499-48f3-8a9a-8cf4b0f7741c",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal B",
        "name": "Alarm 951c214b6d00",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=895952f3-8499-48f3-8a9a-8cf4b0f7741c",
            "self": "/classification_entries/895952f3-8499-48f3-8a9a-8cf4b0f7741c/relationships/tags"
          }
        },
        "classification_table": {
          "data": {
            "id": "1613475f-a759-4f3a-aa05-22ece7a95e0b",
            "type": "classification_table"
          },
          "links": {
            "self": "/classification_tables/1613475f-a759-4f3a-aa05-22ece7a95e0b"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=895952f3-8499-48f3-8a9a-8cf4b0f7741c",
            "self": "/classification_entries/895952f3-8499-48f3-8a9a-8cf4b0f7741c/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      },
      "meta": {
        "locales": [
          "en"
        ],
        "current_locale": "en",
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "144a8cb1-9306-4272-852e-ab815456bacc",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "oor2",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=144a8cb1-9306-4272-852e-ab815456bacc",
            "self": "/object_occurrence_relations/144a8cb1-9306-4272-852e-ab815456bacc/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=144a8cb1-9306-4272-852e-ab815456bacc&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/144a8cb1-9306-4272-852e-ab815456bacc/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ]
        },
        "classification_entry": {
          "data": {
            "id": "694e98cb-2088-4f8f-9284-68dc23618fcc",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/694e98cb-2088-4f8f-9284-68dc23618fcc",
            "self": "/object_occurrence_relations/144a8cb1-9306-4272-852e-ab815456bacc/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "ac67ad46-8ff0-492e-904c-62ed4f834cad",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/ac67ad46-8ff0-492e-904c-62ed4f834cad",
            "self": "/object_occurrence_relations/144a8cb1-9306-4272-852e-ab815456bacc/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "6bbf60e7-97d3-454c-aa53-2c72dbf56153",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6bbf60e7-97d3-454c-aa53-2c72dbf56153",
            "self": "/object_occurrence_relations/144a8cb1-9306-4272-852e-ab815456bacc/relationships/source"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/chain_analysis/e590b3c6-4aec-4b33-89e9-4e9b3a7aac65/object_occurrence_relations?steps_forward=2&steps_backward=2",
    "current": "http://example.org/chain_analysis/e590b3c6-4aec-4b33-89e9-4e9b3a7aac65/object_occurrence_relations?include=object_occurrence_relation,object_occurrence_relation.classification_entry,object_occurrence_relation.tags,object_occurrence_relation.owners,object_occurrence_relation.progress_step_checked&page[number]=1&steps_backward=2&steps_forward=2"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[steps_forward] | n steps forward to look out |
| data[steps_backward] | n steps backward to look out |
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
| data[steps_forward] | n steps forward to look out |
| data[steps_backward] | n steps backward to look out |
| data[id] | Object Occurrence resource ID |
| data[links] | JSON:API links data |
| data[attributes][steps] | chain steps for given OOR |
| data[relationships][object_occurrence_relation] | OOR |


# File import

It's possible to mass import some types of resources through Excell files.


## List

List all your imports

### Request

#### Endpoint

```plaintext
GET /imports
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /imports`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8ed4cd2d-318f-4ba1-b2ed-e143e4955f54
200 OK
```


```json
{
  "data": [
    {
      "id": "b4a87fd3-366f-4551-9269-f223cc97d154",
      "type": "import",
      "attributes": {
        "identifier": "rds",
        "processed": false,
        "processing": false
      },
      "relationships": {
        "target": {
          "links": {
            "related": "/"
          }
        },
        "user": {
          "links": {
            "related": "/users/auth0%7C3280ab072428ed79fe686599f27c59d9977fa47ec8c58091"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "792e0191-83d8-4d2f-b157-670151af0a2e",
      "type": "import",
      "attributes": {
        "identifier": "rds",
        "processed": false,
        "processing": false
      },
      "relationships": {
        "target": {
          "links": {
            "related": "/contexts/d8aa419c-001c-48f1-8412-a2ae311f9b1a"
          }
        },
        "user": {
          "links": {
            "related": "/users/auth0%7C3280ab072428ed79fe686599f27c59d9977fa47ec8c58091"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/imports",
    "current": "http://example.org/imports?page[number]=1"
  }
}
```



## Show

Show the current state of a specific Import process

### Request

#### Endpoint

```plaintext
GET /imports/03e49da3-7a7c-4d62-923c-6a8f19b25196
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /imports/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 6ac22c37-abfc-4db2-9511-2201910c834a
200 OK
```


```json
{
  "data": {
    "id": "03e49da3-7a7c-4d62-923c-6a8f19b25196",
    "type": "import",
    "attributes": {
      "identifier": "rds",
      "processed": false,
      "processing": false
    },
    "relationships": {
      "target": {
        "links": {
          "related": "/contexts/1e8d471e-d6df-48c4-b083-0edf2ee01b6e"
        }
      },
      "user": {
        "links": {
          "related": "/users/auth0%7C4a3c0a4e2e72e0e94a434e22b582a656d70da652eb832a82"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/imports/03e49da3-7a7c-4d62-923c-6a8f19b25196"
  }
}
```



## Create

          Create an import flow, into which the client can later upload a file.


### Request

#### Endpoint

```plaintext
POST /imports
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /imports`

#### Parameters


```json
{
  "data": {
    "type": "import",
    "relationships": {
      "target": {
        "type": "context",
        "id": "959da55e-5033-499c-8f9f-30f700b54b9d"
      }
    },
    "attributes": {
      "identifier": "rds"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][identifier]  | Indicates the type of primary identifier in the file. This can be either <code>rds</code> or <code>classification</code>. |
| data[relationships][target][type]  | Indicates the target type to import the data into |
| data[relationships][target][id]  | Indicates the target ID to import the data into |



### Response

```plaintext
Location: http://example.org/polling/80941391bd9471fbc5d7f867
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 639806b2-d589-4176-bf62-94730e2b53f3
202 Accepted
```


```json
{
  "data": {
    "id": "76dd23c8-0716-49e3-93fc-1bb735d32a80",
    "type": "import",
    "attributes": {
      "identifier": "rds",
      "processed": false,
      "processing": false
    },
    "relationships": {
      "target": {
        "links": {
          "related": "/contexts/959da55e-5033-499c-8f9f-30f700b54b9d"
        }
      },
      "user": {
        "links": {
          "related": "/users/auth0%7Cdb3ce1a51cabecd8a47bca2c05c519487b1a151a17189c27"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/imports"
  }
}
```



# Users

User is managed from external service. In scope of this documentation is only listing all users allowed to login into application.


## List


### Request

#### Endpoint

```plaintext
GET /users
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /users`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fd8871de-cb9b-4f54-adc1-8e4fcd7c3e8c
200 OK
```


```json
{
  "data": [
    {
      "id": "auth0|5e4bb9be8b614d114f00caa7",
      "type": "user",
      "attributes": {
        "id": "auth0|5e4bb9be8b614d114f00caa7",
        "name": "test@syseng.dk",
        "updated_at": "2020-07-09T08:44:25.723Z"
      },
      "relationships": {
        "user_permissions": {
          "data": [

          ],
          "links": {
            "self": "/user_permissions?user_id_eq=auth0%7C5e4bb9be8b614d114f00caa7"
          }
        },
        "settings": {
          "data": null,
          "links": {
            "related": "/user_settings"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "auth0|5ee759003d86c10019162f5a",
      "type": "user",
      "attributes": {
        "id": "auth0|5ee759003d86c10019162f5a",
        "name": "appstoretest@syseng.dk",
        "updated_at": "2020-06-17T20:39:57.855Z"
      },
      "relationships": {
        "user_permissions": {
          "data": [

          ],
          "links": {
            "self": "/user_permissions?user_id_eq=auth0%7C5ee759003d86c10019162f5a"
          }
        },
        "settings": {
          "data": null,
          "links": {
            "related": "/user_settings"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "auth0|5eecb4e752afaa0015de8a45",
      "type": "user",
      "attributes": {
        "id": "auth0|5eecb4e752afaa0015de8a45",
        "name": "emk@syseng.dk",
        "updated_at": "2020-07-09T08:49:04.279Z"
      },
      "relationships": {
        "user_permissions": {
          "data": [

          ],
          "links": {
            "self": "/user_permissions?user_id_eq=auth0%7C5eecb4e752afaa0015de8a45"
          }
        },
        "settings": {
          "data": null,
          "links": {
            "related": "/user_settings"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [

  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/users",
    "current": "http://example.org/users?include=user_permissions&page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][id] | User id from external provider |
| data[attributes][name] | User name |
| data[attributes][email] | User email |
| data[attributes][account_id] | Account ID |


# Trade Studies

A Trade Study (TS) is when a user spins off a copy of a Context
with the goal of removing or adding OORs for later comparison against
the original Context.


## List


### Request

#### Endpoint

```plaintext
GET /trade_studies
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /trade_studies`

#### Parameters



| Name | Description |
|:-----|:------------|
| sort  | available sort fields: name |
| query  | search query |
| filter[upstream_context_id_eq]  | filter by upstream context |
| filter[closed]  | return closed trade studies (false by default) |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2671134f-7094-4b61-84c6-621a4edd1eec
200 OK
```


```json
{
  "data": [
    {
      "id": "891ca864-bed9-4a94-87a9-04e3a4bcf20c",
      "type": "trade_study",
      "attributes": {
        "name": "[TS] Context 1",
        "closed_at": null,
        "copy_oors": true,
        "copy_permissions": true,
        "created_at": "2020-11-20T12:51:22.168+00:00"
      },
      "relationships": {
        "upstream_context": {
          "data": {
            "id": "43f6c64f-e12a-4da7-831c-2f5df86eb3ec",
            "type": "context"
          },
          "links": {
            "related": "/contexts/43f6c64f-e12a-4da7-831c-2f5df86eb3ec"
          }
        },
        "downstream_context": {
          "data": {
            "id": "2083564b-6cc8-403c-b446-9477fa2e391f",
            "type": "context"
          },
          "links": {
            "related": "/contexts/2083564b-6cc8-403c-b446-9477fa2e391f"
          }
        },
        "creator": {
          "data": {
            "id": "auth0|0a512306b32db2146d15251fb5d295996c7365433eae2370",
            "type": "user"
          },
          "links": {
            "related": "/users/auth0%7C0a512306b32db2146d15251fb5d295996c7365433eae2370"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    },
    {
      "id": "f0ed50e1-d914-48a0-9046-47272f9981d0",
      "type": "trade_study",
      "attributes": {
        "name": "[TS] Context 1",
        "closed_at": null,
        "copy_oors": true,
        "copy_permissions": true,
        "created_at": "2020-11-20T12:51:22.325+00:00"
      },
      "relationships": {
        "upstream_context": {
          "data": {
            "id": "43f6c64f-e12a-4da7-831c-2f5df86eb3ec",
            "type": "context"
          },
          "links": {
            "related": "/contexts/43f6c64f-e12a-4da7-831c-2f5df86eb3ec"
          }
        },
        "downstream_context": {
          "data": {
            "id": "03f8c56a-68c0-42d8-bad8-721881961e9d",
            "type": "context"
          },
          "links": {
            "related": "/contexts/03f8c56a-68c0-42d8-bad8-721881961e9d"
          }
        },
        "creator": {
          "data": {
            "id": "auth0|0a512306b32db2146d15251fb5d295996c7365433eae2370",
            "type": "user"
          },
          "links": {
            "related": "/users/auth0%7C0a512306b32db2146d15251fb5d295996c7365433eae2370"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "included": [
    {
      "id": "auth0|0a512306b32db2146d15251fb5d295996c7365433eae2370",
      "type": "user",
      "attributes": {
        "id": "auth0|0a512306b32db2146d15251fb5d295996c7365433eae2370",
        "name": "emk@syseng.dk",
        "updated_at": "2020-02-12T12:07:35.980Z"
      },
      "relationships": {
        "user_permissions": {
          "data": [
            {
              "id": "33bee81f-e8b8-441d-9065-9896d5ca9804",
              "type": "user_permission"
            }
          ],
          "links": {
            "self": "/user_permissions?user_id_eq=auth0%7C0a512306b32db2146d15251fb5d295996c7365433eae2370"
          }
        },
        "settings": {
          "data": null,
          "links": {
            "related": "/user_settings"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        }
      },
      "meta": {
        "missing_required_fields": [

        ]
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/trade_studies",
    "current": "http://example.org/trade_studies?include=creator&page[number]=1&sort=name"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | TradeStudy name |
| data[attributes][copy_oors] | Copy object occurrence relations to trade study |
| data[attributes][copy_permissions] | Copy permissions to trade study |
| data[attributes][closed_at] | Closing date |


## Show


### Request

#### Endpoint

```plaintext
GET /trade_studies/caceae4f-3f42-4dae-9ff1-b5e82565d8e2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /trade_studies/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 32f5ecec-fc99-42ae-9cf1-25b30335c1d2
200 OK
```


```json
{
  "data": {
    "id": "caceae4f-3f42-4dae-9ff1-b5e82565d8e2",
    "type": "trade_study",
    "attributes": {
      "name": "[TS] Context 1",
      "closed_at": null,
      "copy_oors": true,
      "copy_permissions": true,
      "created_at": "2020-11-20T12:51:24.701+00:00"
    },
    "relationships": {
      "upstream_context": {
        "data": {
          "id": "1df3720f-7566-48d3-b9ae-3cd29bc9fccf",
          "type": "context"
        },
        "links": {
          "related": "/contexts/1df3720f-7566-48d3-b9ae-3cd29bc9fccf"
        }
      },
      "downstream_context": {
        "data": {
          "id": "ec03b7c6-1103-4a81-9923-e12da1435f1f",
          "type": "context"
        },
        "links": {
          "related": "/contexts/ec03b7c6-1103-4a81-9923-e12da1435f1f"
        }
      },
      "creator": {
        "data": {
          "id": "auth0|3fd9aea84f2074636100f397ee872e10867da9f3d443820d",
          "type": "user"
        },
        "links": {
          "related": "/users/auth0%7C3fd9aea84f2074636100f397ee872e10867da9f3d443820d"
        }
      }
    },
    "meta": {
      "missing_required_fields": [

      ]
    }
  },
  "links": {
    "self": "http://example.org/trade_studies/caceae4f-3f42-4dae-9ff1-b5e82565d8e2"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | TradeStudy name |
| data[attributes][copy_oors] | Copy object occurrence relations to trade study |
| data[attributes][copy_permissions] | Copy permissions to trade study |
| data[attributes][closed_at] | Closing date |


## Create


### Request

#### Endpoint

```plaintext
POST /contexts/504c9b20-bea6-4f36-b853-e9402ff94dcf/relationships/trade_studies
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:context_id/relationships/trade_studies`

#### Parameters


```json
{
  "data": {
    "type": "trade_study",
    "attributes": {
      "name": "Trade Study #1",
      "copy_oors": "true",
      "copy_permissions": "true"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json
X-Request-Id: 8cc3ee78-bc75-47f2-9b45-1a9855d971b1
202 Accepted
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | TradeStudy name |
| data[attributes][copy_oors] | Copy object occurrence relations to trade study |
| data[attributes][copy_permissions] | Copy permissions to trade study |
| data[attributes][closed_at] | Closing date |


## Compare

During the lifecycle of a Trade Study, it's possible to make several
comparisons against the main Context. Comparisons will always happen
against the latest version of the main Context, not against the main
Context at the point in time when someone created the Trade Study.

Making changes to the SIMO grid in the Trade Study Content will generate
several Deltas and Delta Groups. This collection of Deltas and Delta Groups
is the main component of a Discrepancy Analysis.

A Delta represents a single change, deletion, or creation of a single
Object Occurrence Relation in the Trade Study's Context.

It's possible to accept a single Delta. Doing so immediately copies
the change which the Delta represents into the main Context and deletes
the Delta.

Deltas come in two flavors: Simple and complex. Complex deltas have
related Deltas, which much be simultaneously accepted or rejected.
A Delta Group is a group of Deltas related to a specific pair of
Object Occurrence Relations.


### Request

#### Endpoint

```plaintext
GET /contexts/6e052aa1-4720-48f1-a66f-a2e949a37287/relationships/trade_studies/f2412983-21b1-46a7-bfca-a624e886e79f/comparison
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:context_id/relationships/trade_studies/:id/comparison`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 71af897e-1e79-4dcf-9e3c-b242a3bba220
200 OK
```


```json
{
  "data": [
    {
      "id": "<Context 1>=A1|<Context 1>=A1=A2",
      "type": "delta_group",
      "attributes": {
        "id": "<Context 1>=A1|<Context 1>=A1=A2"
      },
      "relationships": {
        "deltas": {
          "data": [
            {
              "id": "0fecff6f-51e9-443f-a7ac-c3452a3122a0",
              "type": "delta"
            },
            {
              "id": "4f239fc3-0f1c-499f-b2ca-1997e19c661c",
              "type": "delta"
            }
          ]
        },
        "ts_object_occurrences": {
          "data": [
            {
              "id": "94da60a6-ede0-4c6e-afa3-08298fb2622d",
              "type": "object_occurrence"
            },
            {
              "id": "c8d6be15-9032-44c1-bb79-49bd2263f6a4",
              "type": "object_occurrence"
            }
          ]
        },
        "ctx_object_occurrences": {
          "data": [
            {
              "id": "5a6535a7-1466-4f70-805a-fe1f6f6a2c10",
              "type": "object_occurrence"
            },
            {
              "id": "c76839ed-ff40-4cde-a8f7-e02b36a9a82d",
              "type": "object_occurrence"
            }
          ]
        }
      },
      "meta": {
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/contexts/6e052aa1-4720-48f1-a66f-a2e949a37287/relationships/trade_studies/f2412983-21b1-46a7-bfca-a624e886e79f/comparison",
    "current": "http://example.org/contexts/6e052aa1-4720-48f1-a66f-a2e949a37287/relationships/trade_studies/f2412983-21b1-46a7-bfca-a624e886e79f/comparison?page[number]=1"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | TradeStudy name |
| data[attributes][copy_oors] | Copy object occurrence relations to trade study |
| data[attributes][copy_permissions] | Copy permissions to trade study |
| data[attributes][closed_at] | Closing date |
| data[attributes][name] | TradeStudy name |
| data[attributes][copy_oors] | Copy object occurrence relations to trade study |
| data[attributes][copy_permissions] | Copy permissions to trade study |
| data[attributes][closed_at] | Closing date |


## Close

Closing the trade study doesn't remove the trade study from the database.
It's record is persisted and not returned by default by the API
(see "closed" filter). Only the downstream context is removed from the DB.


### Request

#### Endpoint

```plaintext
DELETE /trade_studies/1fe91676-4c48-4d89-bfdc-78ca97371821
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /trade_studies/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5a4bc314-3215-416a-8e84-43985655ef80
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | TradeStudy name |
| data[attributes][copy_oors] | Copy object occurrence relations to trade study |
| data[attributes][copy_permissions] | Copy permissions to trade study |
| data[attributes][closed_at] | Closing date |


# Deltas

When comparing the trade study to the main Context, this is done using deltas.
Endpoints listed in this section are created for manipulating those deltas. We
can accept particular delta and provide changes to main context, reject delta and
ignore changes or revert this action by unrejecting.


## Accept


### Request

#### Endpoint

```plaintext
POST /contexts/57dafd3a-7a61-4cfd-aeec-a22610ba663e/relationships/trade_studies/df24f1bd-e3a8-467d-9b11-f2ba957d2bc8/relationships/deltas/362435b4-a501-4fb3-9b7a-1889fa763983/accept
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:context_id/relationships/trade_studies/:trade_study_id/relationships/deltas/:delta_id/accept`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7d608fa5-af34-49a0-8199-c749b87f7f38
200 OK
```


```json
{
  "data": {
    "id": "362435b4-a501-4fb3-9b7a-1889fa763983",
    "type": "delta",
    "attributes": {
      "id": "362435b4-a501-4fb3-9b7a-1889fa763983",
      "changes_type": "addition",
      "changes_hash": {
        "relation": {
          "code": "RA1"
        }
      },
      "created_at": "2020-11-20T12:51:45.225+00:00",
      "updated_at": "2020-11-20T12:51:46.146+00:00"
    },
    "relationships": {
      "ts_object_occurrence_relation": {
        "data": {
          "id": "d8fca78a-2aa0-467c-9c4b-0dfe65050241",
          "type": "object_occurrence_relation"
        },
        "links": {
          "related": "/object_occurrence_relations/d8fca78a-2aa0-467c-9c4b-0dfe65050241"
        }
      }
    },
    "meta": {
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][changes_type] | Might be `addition`, `deletion` or `change` |
| data[attributes][changes_hash] | Hash containing all changes related to particular delta |
| data[attributes][changes_hash][relation] | Details of change in scope of particular relation |
| data[attributes][changes_hash][relation][name] | Changed name of relation |
| data[attributes][changes_hash][relation][code] | Changed code of relation |
| data[attributes][changes_hash][relation][number] | Changed number of relation |
| data[attributes][changes_hash][progress][progress] | Changes in scope of progress for particular relation |


## Reject


### Request

#### Endpoint

```plaintext
POST /contexts/884f0dec-186e-41ae-bd4d-50914f33ad63/relationships/trade_studies/60d426cf-3e64-4504-ac8f-71393f85e99c/relationships/deltas/e04ae5c4-0ad4-4a75-829c-16555d91b3de/reject
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:context_id/relationships/trade_studies/:trade_study_id/relationships/deltas/:delta_id/reject`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 85666c3c-085f-4cda-a48c-8a1c8fe72971
200 OK
```


```json
{
  "data": {
    "id": "e04ae5c4-0ad4-4a75-829c-16555d91b3de",
    "type": "delta",
    "attributes": {
      "id": "e04ae5c4-0ad4-4a75-829c-16555d91b3de",
      "changes_type": "addition",
      "changes_hash": {
        "relation": {
          "code": "RA1"
        }
      },
      "created_at": "2020-11-20T12:51:53.480+00:00",
      "updated_at": "2020-11-20T12:51:54.116+00:00"
    },
    "relationships": {
      "ts_object_occurrence_relation": {
        "data": {
          "id": "97ad06a1-f983-4b1d-9978-0ff19b9780bd",
          "type": "object_occurrence_relation"
        },
        "links": {
          "related": "/object_occurrence_relations/97ad06a1-f983-4b1d-9978-0ff19b9780bd"
        }
      }
    },
    "meta": {
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][changes_type] | Might be `addition`, `deletion` or `change` |
| data[attributes][changes_hash] | Hash containing all changes related to particular delta |
| data[attributes][changes_hash][relation] | Details of change in scope of particular relation |
| data[attributes][changes_hash][relation][name] | Changed name of relation |
| data[attributes][changes_hash][relation][code] | Changed code of relation |
| data[attributes][changes_hash][relation][number] | Changed number of relation |
| data[attributes][changes_hash][progress][progress] | Changes in scope of progress for particular relation |


## Restore


### Request

#### Endpoint

```plaintext
POST /contexts/7e6216eb-0324-44ec-80dd-589ce4fbc36e/relationships/trade_studies/6757288b-c6c8-4c38-98e8-80e9e999a484/relationships/deltas/de29afbc-d522-42a2-b67b-c5b3b16de9ad/restore
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:context_id/relationships/trade_studies/:trade_study_id/relationships/deltas/:delta_id/restore`

#### Parameters


None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2fc4c779-6dbe-467d-9639-ad46feecc2da
200 OK
```


```json
{
  "data": {
    "id": "de29afbc-d522-42a2-b67b-c5b3b16de9ad",
    "type": "delta",
    "attributes": {
      "id": "de29afbc-d522-42a2-b67b-c5b3b16de9ad",
      "changes_type": "addition",
      "changes_hash": {
        "relation": {
          "code": "RA1"
        }
      },
      "created_at": "2020-11-20T12:52:01.261+00:00",
      "updated_at": "2020-11-20T12:52:01.598+00:00"
    },
    "relationships": {
      "ts_object_occurrence_relation": {
        "data": {
          "id": "f30ec903-b6b2-40e7-a84a-34ad4cb16dab",
          "type": "object_occurrence_relation"
        },
        "links": {
          "related": "/object_occurrence_relations/f30ec903-b6b2-40e7-a84a-34ad4cb16dab"
        }
      }
    },
    "meta": {
    }
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][changes_type] | Might be `addition`, `deletion` or `change` |
| data[attributes][changes_hash] | Hash containing all changes related to particular delta |
| data[attributes][changes_hash][relation] | Details of change in scope of particular relation |
| data[attributes][changes_hash][relation][name] | Changed name of relation |
| data[attributes][changes_hash][relation][code] | Changed code of relation |
| data[attributes][changes_hash][relation][number] | Changed number of relation |
| data[attributes][changes_hash][progress][progress] | Changes in scope of progress for particular relation |


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
X-Request-Id: 0572ef7d-e414-4501-a4bf-b055a00d9e62
200 OK
```


```json
{
  "data": [
    {
      "id": "86881aa9-d4f3-4ac3-acdb-ce29112a8756",
      "type": "tag",
      "attributes": {
        "value": "Tag value 47"
      },
      "relationships": {
      },
      "meta": {
      }
    },
    {
      "id": "dfcf7305-e418-484e-88e7-433dc5f25bc3",
      "type": "tag",
      "attributes": {
        "value": "Tag value 48"
      },
      "relationships": {
      },
      "meta": {
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
X-Request-Id: 9373ef6a-34ee-46bd-8ed8-1b59acf2750f
200 OK
```


```json
{
  "data": [
    {
      "id": "8eeab0e2-89ac-47e0-9db6-1c6d7e551d4f",
      "type": "permission",
      "attributes": {
        "name": "account:write",
        "description": "MyText"
      },
      "meta": {
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/permissions",
    "current": "http://example.org/permissions?page[number]=1&sort=name"
  }
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
GET /permissions/d8a521e2-0085-4418-8e29-c625fce5d231
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
X-Request-Id: 4c408b7d-a3af-4e12-a3c3-71dbb7bd2916
200 OK
```


```json
{
  "data": {
    "id": "d8a521e2-0085-4418-8e29-c625fce5d231",
    "type": "permission",
    "attributes": {
      "name": "account:write",
      "description": "MyText"
    },
    "meta": {
    }
  },
  "links": {
    "self": "http://example.org/permissions/d8a521e2-0085-4418-8e29-c625fce5d231"
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
GET /utils/path/from/object_occurrence/e812eeb9-0e7e-466b-9d89-183727abbf6e/to/object_occurrence/71a01a2c-d281-490d-82a5-ba1a4bca73f1
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
X-Request-Id: c37c6e8c-6e39-46f1-a923-351cbfebd0f1
200 OK
```


```json
[
  {
    "id": "e812eeb9-0e7e-466b-9d89-183727abbf6e",
    "type": "object_occurrence"
  },
  {
    "id": "545e64eb-31dc-493e-b1e4-1c6c3eafbdf9",
    "type": "object_occurrence"
  },
  {
    "id": "176380fe-e4f9-4f6f-8726-a29e27e36107",
    "type": "object_occurrence"
  },
  {
    "id": "f33c7b79-9b2f-487b-9110-4dfbaff795d7",
    "type": "object_occurrence"
  },
  {
    "id": "ef372944-1f05-48f8-b19c-b4c157dda24a",
    "type": "object_occurrence"
  },
  {
    "id": "8d64f98e-6a30-4cf4-9933-569e8c94c4ff",
    "type": "object_occurrence"
  },
  {
    "id": "71a01a2c-d281-490d-82a5-ba1a4bca73f1",
    "type": "object_occurrence"
  }
]
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
X-Request-Id: 31dda1ac-43e9-4c0e-92c6-d7092d9de2e6
200 OK
```


```json
default: PASSED Application is running (0.000s)
```
