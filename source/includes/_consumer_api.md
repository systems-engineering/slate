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
X-Request-Id: de40327b-00f8-4410-b11b-5fb14a4a9bf5
200 OK
```


```json
{
  "data": {
    "id": "9d981ab5-ef6b-4da7-9fb5-4bbddedc36bb",
    "type": "account",
    "attributes": {
      "name": "Account e1d3fa83d895"
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



## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 564b170d-ef25-4c79-9619-45c30911b642
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 08e39991-2758-4bea-b417-67c64b7f57d5
200 OK
```


```json
{
  "data": {
    "id": "23aa3260-d0df-4c66-9445-bf3c815eace1",
    "type": "account",
    "attributes": {
      "name": "Account 05d536205cd1"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 26595cc6-45f6-4d4a-acc7-6dd8739d1bdb
429 Too Many Requests
```


```json
This action has been rate limited
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
    "id": "ec31136f-975e-43e9-b3a2-11e7301c9db6",
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
X-Request-Id: 2adf41eb-3d58-4069-8a74-e527115a8c5b
200 OK
```


```json
{
  "data": {
    "id": "ec31136f-975e-43e9-b3a2-11e7301c9db6",
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


## blocks too many calls


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
    "id": "7b781e48-d215-43d6-b01f-31c4f9a68816",
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
Content-Type: text/plain
X-Request-Id: 62cd934f-c05b-4598-8fbd-3bfe4ec6fcca
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 1c5b85d1-b06b-4ea5-b9ca-5b0e699df86e
200 OK
```


```json
{
  "data": [
    {
      "id": "232c1ee3-b493-4659-b272-f58d55626ecc",
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
              "id": "088ccf0c-8707-4dfa-8790-154738766882",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=232c1ee3-b493-4659-b272-f58d55626ecc"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=232c1ee3-b493-4659-b272-f58d55626ecc",
            "self": "/projects/232c1ee3-b493-4659-b272-f58d55626ecc/relationships/contexts"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "088ccf0c-8707-4dfa-8790-154738766882",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "95e5e9bb-9b15-4f0f-80a9-9c4248ef989e",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/95e5e9bb-9b15-4f0f-80a9-9c4248ef989e"
          }
        },
        "target": {
          "links": {
            "related": "/projects/232c1ee3-b493-4659-b272-f58d55626ecc"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 4cb8629e-01f8-4565-8128-1e8053254cab
429 Too Many Requests
```


```json
This action has been rate limited
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Show


### Request

#### Endpoint

```plaintext
GET /projects/31ae12e9-3fad-44de-b32f-5ba0bc4d24f9
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
X-Request-Id: f36af3ab-34dc-4923-b23e-ae11d7368851
200 OK
```


```json
{
  "data": {
    "id": "31ae12e9-3fad-44de-b32f-5ba0bc4d24f9",
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
            "id": "8b5d3028-4fc3-4053-9165-756965d4a2ec",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=31ae12e9-3fad-44de-b32f-5ba0bc4d24f9"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=31ae12e9-3fad-44de-b32f-5ba0bc4d24f9",
          "self": "/projects/31ae12e9-3fad-44de-b32f-5ba0bc4d24f9/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/31ae12e9-3fad-44de-b32f-5ba0bc4d24f9"
  },
  "included": [
    {
      "id": "8b5d3028-4fc3-4053-9165-756965d4a2ec",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "0f8ba1bc-a702-41d9-b0c8-777ab6662fa2",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/0f8ba1bc-a702-41d9-b0c8-777ab6662fa2"
          }
        },
        "target": {
          "links": {
            "related": "/projects/31ae12e9-3fad-44de-b32f-5ba0bc4d24f9"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /projects/a05c3c9e-ac7a-4ce0-a412-46ba8bd4e0e1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: a1d04207-16cf-42d2-821a-a4a1dd50a2b6
429 Too Many Requests
```


```json
This action has been rate limited
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Update


### Request

#### Endpoint

```plaintext
PATCH /projects/94954f2c-34b8-4e8d-abd4-1ad178903716
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "94954f2c-34b8-4e8d-abd4-1ad178903716",
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
X-Request-Id: 107eb427-b507-4bd6-80d0-6e2c21ddc809
200 OK
```


```json
{
  "data": {
    "id": "94954f2c-34b8-4e8d-abd4-1ad178903716",
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
            "id": "66bc1e2b-7849-49fc-ab2c-5628b27feda3",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=94954f2c-34b8-4e8d-abd4-1ad178903716"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=94954f2c-34b8-4e8d-abd4-1ad178903716",
          "self": "/projects/94954f2c-34b8-4e8d-abd4-1ad178903716/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/94954f2c-34b8-4e8d-abd4-1ad178903716"
  },
  "included": [
    {
      "id": "66bc1e2b-7849-49fc-ab2c-5628b27feda3",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "b774cf21-5204-4112-ab7c-7e816dbfb353",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/b774cf21-5204-4112-ab7c-7e816dbfb353"
          }
        },
        "target": {
          "links": {
            "related": "/projects/94954f2c-34b8-4e8d-abd4-1ad178903716"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /projects/94d67846-bbfe-4e78-b357-913c88e74153
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "94d67846-bbfe-4e78-b357-913c88e74153",
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
Content-Type: text/plain
X-Request-Id: 44f0f333-f8f6-45e1-b0d3-01dd00387475
429 Too Many Requests
```


```json
This action has been rate limited
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Archive


### Request

#### Endpoint

```plaintext
POST /projects/4749399f-f6cd-4b36-a43c-25a59b6e8848/archive
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
X-Request-Id: 3868ad45-a72b-480b-b766-79c0d084fba9
200 OK
```


```json
{
  "data": {
    "id": "4749399f-f6cd-4b36-a43c-25a59b6e8848",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-10T12:41:39.358Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "eb916057-ad59-4cb0-972e-039db5838540",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=4749399f-f6cd-4b36-a43c-25a59b6e8848"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=4749399f-f6cd-4b36-a43c-25a59b6e8848",
          "self": "/projects/4749399f-f6cd-4b36-a43c-25a59b6e8848/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/4749399f-f6cd-4b36-a43c-25a59b6e8848/archive"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /projects/c8473e09-ec9f-4820-a639-e69edb0d27a4/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 8ce993f7-b970-4f8c-a844-b4f6c8ddfe14
429 Too Many Requests
```


```json
This action has been rate limited
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## Destroy


### Request

#### Endpoint

```plaintext
DELETE /projects/a5873b79-7186-4d87-bcad-42cd555864fd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0d51a80f-daa8-4e9a-a79b-2bccf9f12565
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /projects/a3be18f0-9b69-4683-96bd-1f84e043390a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 60e9af52-ec9b-45b5-b758-8e6aef3d0dbe
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: a40fb605-f549-499e-8d7a-95f8e35758d0
200 OK
```


```json
{
  "data": [
    {
      "id": "343b47c2-fdae-4553-856e-486177ef32e1",
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
              "id": "dc1e7e15-8755-4aab-ba38-d78bcb4d98c2",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=343b47c2-fdae-4553-856e-486177ef32e1"
          }
        },
        "project": {
          "links": {
            "related": "/projects/4f2adc80-9bfc-4074-871b-61604c267c41"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/e6d239b9-e2f6-4015-8b81-0e5617a17d9b"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/5b5090ad-4537-4605-906d-fdecab099b4d"
          }
        }
      }
    },
    {
      "id": "b1ecb7d3-7c17-4cf8-8cd1-530cca028c97",
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
            "related": "/progress?filter[target_id_eq]=b1ecb7d3-7c17-4cf8-8cd1-530cca028c97"
          }
        },
        "project": {
          "links": {
            "related": "/projects/4f2adc80-9bfc-4074-871b-61604c267c41"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/2519c2e3-1a79-4e8a-b5d4-911540993b8f"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/5b5090ad-4537-4605-906d-fdecab099b4d"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "dc1e7e15-8755-4aab-ba38-d78bcb4d98c2",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "42698c0c-6968-4d21-8a89-9792d946d004",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/42698c0c-6968-4d21-8a89-9792d946d004"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/343b47c2-fdae-4553-856e-486177ef32e1"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 0a87e72c-0d57-4d34-9377-1ad801308d3a
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /contexts/65846256-56db-41b2-a260-7d03c7ff164b
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
X-Request-Id: c2c6fe32-6ee8-450d-9cc8-a090d8cc06bb
200 OK
```


```json
{
  "data": {
    "id": "65846256-56db-41b2-a260-7d03c7ff164b",
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
            "id": "c421cbde-5de0-409f-993a-ac2e5eb610e7",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=65846256-56db-41b2-a260-7d03c7ff164b"
        }
      },
      "project": {
        "links": {
          "related": "/projects/63fdc97e-2cff-440e-80e2-8960ac1f694b"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/6ef530cc-c2f8-4a11-8424-2123725888e2"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/7de5de6f-f1fa-4f08-bedb-6ede0c923b00"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/65846256-56db-41b2-a260-7d03c7ff164b"
  },
  "included": [
    {
      "id": "c421cbde-5de0-409f-993a-ac2e5eb610e7",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "172885e7-44d0-4da5-b75d-f87a0128c581",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/172885e7-44d0-4da5-b75d-f87a0128c581"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/65846256-56db-41b2-a260-7d03c7ff164b"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /contexts/838c9e1f-63fa-457f-9bc6-d7e6e02802e3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: a1d49cef-3efa-487b-8ac8-387f8d09d2c7
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /contexts/adbdf882-94d7-4064-8275-5093a554529c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "adbdf882-94d7-4064-8275-5093a554529c",
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
X-Request-Id: ceca9a3d-e750-46f3-833e-c993f02e7a11
200 OK
```


```json
{
  "data": {
    "id": "adbdf882-94d7-4064-8275-5093a554529c",
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
            "id": "c9cba4d0-501a-4c4e-a1bd-f2ecffa14ebc",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=adbdf882-94d7-4064-8275-5093a554529c"
        }
      },
      "project": {
        "links": {
          "related": "/projects/29d77de1-070d-4871-9fe8-cce3c9a59864"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/828b1f53-7315-4765-8268-9ab0c90dd4a8"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/4a1cda11-28a7-41c4-879f-7511fb89e93f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/adbdf882-94d7-4064-8275-5093a554529c"
  },
  "included": [
    {
      "id": "c9cba4d0-501a-4c4e-a1bd-f2ecffa14ebc",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "8d7282e6-e71d-47ba-ae10-f71338457be6",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/8d7282e6-e71d-47ba-ae10-f71338457be6"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/adbdf882-94d7-4064-8275-5093a554529c"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /contexts/60915428-5c8b-4605-8b66-cb7966987cd4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "60915428-5c8b-4605-8b66-cb7966987cd4",
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
Content-Type: text/plain
X-Request-Id: d4feb0cf-0a01-4931-bfbc-f8abc1bffb7b
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /projects/a13380bb-09d1-4644-8966-e66674aef398/relationships/contexts
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
          "id": "68786946-6fcc-46b7-b84e-be3d4aac37fc"
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
X-Request-Id: 5882cddc-259a-41df-9d6a-fb5971e4acfe
201 Created
```


```json
{
  "data": {
    "id": "d7324a1f-0cdb-4e20-904e-f4c53662254d",
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
          "related": "/progress?filter[target_id_eq]=d7324a1f-0cdb-4e20-904e-f4c53662254d"
        }
      },
      "project": {
        "links": {
          "related": "/projects/a13380bb-09d1-4644-8966-e66674aef398"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/ff66d0cb-939d-454d-9b38-6f10d6cdddc2"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/68786946-6fcc-46b7-b84e-be3d4aac37fc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a13380bb-09d1-4644-8966-e66674aef398/relationships/contexts"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /projects/b8071f37-f72f-4b66-a1d6-b257969c13f7/relationships/contexts
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
          "id": "51898598-e36e-4f29-b347-fc375e350e83"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 8fa80d91-5463-4993-a87c-42b1e7cafb6a
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /contexts/b3d18c6b-f677-4034-ac42-70ad749a9b0f/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/d288a52f6ce89bc834513376
Content-Type: text/html; charset=utf-8
X-Request-Id: 97836974-2397-4758-9e28-084009bb10c8
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/d288a52f6ce89bc834513376">redirected</a>.</body></html>
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /contexts/1abbc418-a010-44ad-adee-ddddb442f641/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: d34052a3-6380-4fbd-9ca3-72d0c1ff600a
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /contexts/e5d5435b-b821-4ad1-9021-5a3239aa7ab0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9d1dc7fb-68ff-42de-a921-e70b69f96e0d
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /contexts/a9397f2b-e2b1-455b-a494-b3d86fa4e749
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: cc902f83-6a33-4c7a-bcf4-60ccf18d3229
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /object_occurrences/83e6e23b-d049-4fc2-a49a-ca26774fae66/relationships/tags
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
X-Request-Id: 3a281608-3f0c-4295-8c02-c76bc52a88ec
201 Created
```


```json
{
  "data": {
    "id": "4b21794b-a6e9-46a8-b8af-deb2deb14468",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/83e6e23b-d049-4fc2-a49a-ca26774fae66/relationships/tags"
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
POST /object_occurrences/da5c26c5-c06b-4a8b-b855-3497f0774391/relationships/tags
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
    "id": "90f2d47c-c1f5-4646-a963-35a9eee04272"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fc503124-ea96-4a90-8fad-0d0f3c748443
201 Created
```


```json
{
  "data": {
    "id": "90f2d47c-c1f5-4646-a963-35a9eee04272",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/da5c26c5-c06b-4a8b-b855-3497f0774391/relationships/tags"
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
DELETE /object_occurrences/54d419e3-ef2f-4d04-9031-ef9073d391b6/relationships/tags/5f93c7d2-094f-42ec-8484-19ebd782aff4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6ac55c18-a37a-4de5-ade5-0aae57bda857
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/8858e65d-1fb1-42da-bec4-3670193a701f/relationships/owners
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
X-Request-Id: 9ee84151-99c0-4ef3-9c19-b9bd215d1b3a
201 Created
```


```json
{
  "data": {
    "id": "d4e1ade8-a8e9-4bd5-9f4a-ea7060501aee",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/8858e65d-1fb1-42da-bec4-3670193a701f/relationships/owners"
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
POST /object_occurrences/dd687b24-6787-4999-a0d0-e8f7731c9552/relationships/owners
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
X-Request-Id: 0b22d7b8-3927-4138-b9e7-5838fcfd4153
201 Created
```


```json
{
  "data": {
    "id": "183e5a89-a03d-4fe6-a560-fdf2b2eca122",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/dd687b24-6787-4999-a0d0-e8f7731c9552/relationships/owners"
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
POST /object_occurrences/6fc894e3-861b-46bb-8256-58c339269896/relationships/owners
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
    "id": "314c11e8-8ab8-47ce-8ab5-538e44f14dc2"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 45003847-859c-4b7a-b44e-13db763ce153
201 Created
```


```json
{
  "data": {
    "id": "314c11e8-8ab8-47ce-8ab5-538e44f14dc2",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 7",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/6fc894e3-861b-46bb-8256-58c339269896/relationships/owners"
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
DELETE /object_occurrences/cac8839c-cc31-48ca-a8b5-91cea8d30101/relationships/owners/f504b5fe-c9d8-4c24-a251-996e886a5799
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7bc5eca6-3b38-4b6d-83a7-31f350f8703b
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
X-Request-Id: 294342b1-593c-4ca6-8a7b-09aff24598ae
200 OK
```


```json
{
  "data": [
    {
      "id": "0a53340f-4726-46f4-ab0d-109d8875774c",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
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
              "id": "8eaf1ebe-7d4e-40d5-8244-cbdf9e6ecdd7",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=0a53340f-4726-46f4-ab0d-109d8875774c",
            "self": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "67b9214d-b3a6-4aa4-a01c-c8df44f45099",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=0a53340f-4726-46f4-ab0d-109d8875774c&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "9514d45c-ec38-4435-968a-12db98299eec",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=0a53340f-4726-46f4-ab0d-109d8875774c"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ac45540b-c505-41db-a35d-a5367db9e9b4"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/917219f0-421f-4378-8e39-e6a0bc3af234",
            "self": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "97ad84f9-de9d-461e-9acf-e8f3ed4bc9db",
              "type": "object_occurrence"
            },
            {
              "id": "a9ebbb97-0435-443e-adc4-b4710b389a70",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "ac68e930-a161-45be-b4af-76e32e254661",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a53340f-4726-46f4-ab0d-109d8875774c"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "510fb11d-542e-476d-aec5-e38d6cd416b7",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a53340f-4726-46f4-ab0d-109d8875774c"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a53340f-4726-46f4-ab0d-109d8875774c"
          }
        }
      }
    },
    {
      "id": "a9ebbb97-0435-443e-adc4-b4710b389a70",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "XYZ",
        "description": null,
        "image_key": null,
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
            "related": "/tags?filter[target_id_eq]=a9ebbb97-0435-443e-adc4-b4710b389a70",
            "self": "/object_occurrences/a9ebbb97-0435-443e-adc4-b4710b389a70/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=a9ebbb97-0435-443e-adc4-b4710b389a70&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/a9ebbb97-0435-443e-adc4-b4710b389a70/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=a9ebbb97-0435-443e-adc4-b4710b389a70"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ac45540b-c505-41db-a35d-a5367db9e9b4"
          }
        },
        "classification_table": {
          "data": {
            "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/e8b68f89-22fe-48f9-8041-b67e22a0acbb"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c",
            "self": "/object_occurrences/a9ebbb97-0435-443e-adc4-b4710b389a70/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/a9ebbb97-0435-443e-adc4-b4710b389a70/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "ac68e930-a161-45be-b4af-76e32e254661",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=a9ebbb97-0435-443e-adc4-b4710b389a70"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "510fb11d-542e-476d-aec5-e38d6cd416b7",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=a9ebbb97-0435-443e-adc4-b4710b389a70"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=a9ebbb97-0435-443e-adc4-b4710b389a70"
          }
        }
      }
    },
    {
      "id": "97ad84f9-de9d-461e-9acf-e8f3ed4bc9db",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
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
            "related": "/tags?filter[target_id_eq]=97ad84f9-de9d-461e-9acf-e8f3ed4bc9db",
            "self": "/object_occurrences/97ad84f9-de9d-461e-9acf-e8f3ed4bc9db/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=97ad84f9-de9d-461e-9acf-e8f3ed4bc9db&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/97ad84f9-de9d-461e-9acf-e8f3ed4bc9db/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=97ad84f9-de9d-461e-9acf-e8f3ed4bc9db"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ac45540b-c505-41db-a35d-a5367db9e9b4"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c",
            "self": "/object_occurrences/97ad84f9-de9d-461e-9acf-e8f3ed4bc9db/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/97ad84f9-de9d-461e-9acf-e8f3ed4bc9db/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "ac68e930-a161-45be-b4af-76e32e254661",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=97ad84f9-de9d-461e-9acf-e8f3ed4bc9db"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "510fb11d-542e-476d-aec5-e38d6cd416b7",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=97ad84f9-de9d-461e-9acf-e8f3ed4bc9db"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=97ad84f9-de9d-461e-9acf-e8f3ed4bc9db"
          }
        }
      }
    },
    {
      "id": "1ab8c877-3f89-4daf-b9c8-ca00f06c59f5",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
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
            "related": "/tags?filter[target_id_eq]=1ab8c877-3f89-4daf-b9c8-ca00f06c59f5",
            "self": "/object_occurrences/1ab8c877-3f89-4daf-b9c8-ca00f06c59f5/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=1ab8c877-3f89-4daf-b9c8-ca00f06c59f5&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/1ab8c877-3f89-4daf-b9c8-ca00f06c59f5/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=1ab8c877-3f89-4daf-b9c8-ca00f06c59f5"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/4bfc670a-6535-46ed-8040-bfff525730dc"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ae919239-6738-44d8-aa4e-2bb298fb209e",
            "self": "/object_occurrences/1ab8c877-3f89-4daf-b9c8-ca00f06c59f5/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/1ab8c877-3f89-4daf-b9c8-ca00f06c59f5/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "ac68e930-a161-45be-b4af-76e32e254661",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=1ab8c877-3f89-4daf-b9c8-ca00f06c59f5"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "510fb11d-542e-476d-aec5-e38d6cd416b7",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=1ab8c877-3f89-4daf-b9c8-ca00f06c59f5"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=1ab8c877-3f89-4daf-b9c8-ca00f06c59f5"
          }
        }
      }
    },
    {
      "id": "ae919239-6738-44d8-aa4e-2bb298fb209e",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
        "name": "ObjectOccurrence 0b898450b50b",
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
            "related": "/tags?filter[target_id_eq]=ae919239-6738-44d8-aa4e-2bb298fb209e",
            "self": "/object_occurrences/ae919239-6738-44d8-aa4e-2bb298fb209e/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=ae919239-6738-44d8-aa4e-2bb298fb209e&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/ae919239-6738-44d8-aa4e-2bb298fb209e/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=ae919239-6738-44d8-aa4e-2bb298fb209e"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/4bfc670a-6535-46ed-8040-bfff525730dc"
          }
        },
        "components": {
          "data": [
            {
              "id": "1ab8c877-3f89-4daf-b9c8-ca00f06c59f5",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/ae919239-6738-44d8-aa4e-2bb298fb209e/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "ac68e930-a161-45be-b4af-76e32e254661",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=ae919239-6738-44d8-aa4e-2bb298fb209e"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "510fb11d-542e-476d-aec5-e38d6cd416b7",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=ae919239-6738-44d8-aa4e-2bb298fb209e"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=ae919239-6738-44d8-aa4e-2bb298fb209e"
          }
        }
      }
    },
    {
      "id": "917219f0-421f-4378-8e39-e6a0bc3af234",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
        "name": "ObjectOccurrence fb1dceec75b7",
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
            "related": "/tags?filter[target_id_eq]=917219f0-421f-4378-8e39-e6a0bc3af234",
            "self": "/object_occurrences/917219f0-421f-4378-8e39-e6a0bc3af234/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=917219f0-421f-4378-8e39-e6a0bc3af234&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/917219f0-421f-4378-8e39-e6a0bc3af234/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=917219f0-421f-4378-8e39-e6a0bc3af234"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ac45540b-c505-41db-a35d-a5367db9e9b4"
          }
        },
        "components": {
          "data": [
            {
              "id": "0a53340f-4726-46f4-ab0d-109d8875774c",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/917219f0-421f-4378-8e39-e6a0bc3af234/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "ac68e930-a161-45be-b4af-76e32e254661",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=917219f0-421f-4378-8e39-e6a0bc3af234"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "510fb11d-542e-476d-aec5-e38d6cd416b7",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=917219f0-421f-4378-8e39-e6a0bc3af234"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "e8b68f89-22fe-48f9-8041-b67e22a0acbb",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=917219f0-421f-4378-8e39-e6a0bc3af234"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "67b9214d-b3a6-4aa4-a01c-c8df44f45099",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 10",
        "title": null
      }
    },
    {
      "id": "9514d45c-ec38-4435-968a-12db98299eec",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "de788f89-e068-4d89-b0ad-c0fcbdb67356",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/de788f89-e068-4d89-b0ad-c0fcbdb67356"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/0a53340f-4726-46f4-ab0d-109d8875774c"
          }
        }
      }
    },
    {
      "id": "8eaf1ebe-7d4e-40d5-8244-cbdf9e6ecdd7",
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
    "current": "http://example.org/object_occurrences?include=tags,owners,progress_step_checked&page[number]=1&sort=name,number"
  }
}
```



## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: ab1a3bc5-67e2-4281-bc4a-628b40ffd451
429 Too Many Requests
```


```json
This action has been rate limited
```



## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086
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
X-Request-Id: 9dcfa5ec-0769-45bb-b633-7742facd40d2
200 OK
```


```json
{
  "data": {
    "id": "4048e8d0-eb8b-43d9-8cc3-acd9de1fe086",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "image_key": null,
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
            "id": "a8245cc1-18f0-42fa-ab48-9e0f9592b317",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=4048e8d0-eb8b-43d9-8cc3-acd9de1fe086",
          "self": "/object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "2a8cf1b6-143d-4d69-919f-d777b464a4b6",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=4048e8d0-eb8b-43d9-8cc3-acd9de1fe086&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "104afd7f-9042-4f7d-ad0c-9c3f97a375cd",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=4048e8d0-eb8b-43d9-8cc3-acd9de1fe086"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/239bac6f-c512-45f2-bd25-aeb2506fa176"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/7d41f301-fe3f-412e-9a1c-e2c1367ef39c",
          "self": "/object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "920729c5-df01-4693-a1c0-72a2ba148eec",
            "type": "object_occurrence"
          },
          {
            "id": "f6e6ce7d-12a5-4696-a4c1-5256f887ae3b",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "6fff1b71-78b6-435a-867d-667146d3fd9f",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=4048e8d0-eb8b-43d9-8cc3-acd9de1fe086"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "d5716a92-69d0-405e-80eb-bbf9f76c6d08",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=4048e8d0-eb8b-43d9-8cc3-acd9de1fe086"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "abb3bef2-ee53-4004-9565-d595af2a6218",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=4048e8d0-eb8b-43d9-8cc3-acd9de1fe086"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086"
  },
  "included": [
    {
      "id": "2a8cf1b6-143d-4d69-919f-d777b464a4b6",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 12",
        "title": null
      }
    },
    {
      "id": "104afd7f-9042-4f7d-ad0c-9c3f97a375cd",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "614d8906-1402-4e9f-a530-982ccb7c1ec7",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/614d8906-1402-4e9f-a530-982ccb7c1ec7"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/4048e8d0-eb8b-43d9-8cc3-acd9de1fe086"
          }
        }
      }
    },
    {
      "id": "a8245cc1-18f0-42fa-ab48-9e0f9592b317",
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /object_occurrences/5f1a0d2a-1778-4b91-bdb8-cabb3f357e58
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
Content-Type: text/plain
X-Request-Id: 96afaf94-95af-4f4f-b705-487afcddbc49
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /object_occurrences/e2fbf05d-a4c6-4ca1-b55e-c9eb34b9fa8e/relationships/components
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
X-Request-Id: d4a619fc-5604-42d0-b2a5-a6fd7a12b039
201 Created
```


```json
{
  "data": {
    "id": "4cb0bc1f-5ba2-46ae-be6d-60feecf50276",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
      "description": null,
      "image_key": null,
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
          "related": "/tags?filter[target_id_eq]=4cb0bc1f-5ba2-46ae-be6d-60feecf50276",
          "self": "/object_occurrences/4cb0bc1f-5ba2-46ae-be6d-60feecf50276/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=4cb0bc1f-5ba2-46ae-be6d-60feecf50276&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/4cb0bc1f-5ba2-46ae-be6d-60feecf50276/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=4cb0bc1f-5ba2-46ae-be6d-60feecf50276"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/aaf533ac-6224-492b-82d4-87fa963113e6"
        }
      },
      "classification_table": {
        "data": {
          "id": "2cc311d7-8567-4898-92cf-d38a0887e8c6",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/2cc311d7-8567-4898-92cf-d38a0887e8c6"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/e2fbf05d-a4c6-4ca1-b55e-c9eb34b9fa8e",
          "self": "/object_occurrences/4cb0bc1f-5ba2-46ae-be6d-60feecf50276/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/4cb0bc1f-5ba2-46ae-be6d-60feecf50276/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "06002560-a143-48d1-9623-955654dde9f6",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=4cb0bc1f-5ba2-46ae-be6d-60feecf50276"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "bf2e5d21-cfad-4720-aa7e-24fb4df059cd",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=4cb0bc1f-5ba2-46ae-be6d-60feecf50276"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "2cc311d7-8567-4898-92cf-d38a0887e8c6",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=4cb0bc1f-5ba2-46ae-be6d-60feecf50276"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/e2fbf05d-a4c6-4ca1-b55e-c9eb34b9fa8e/relationships/components"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /object_occurrences/cf4c404e-86f6-4e85-b6e9-d563e86df16d/relationships/components
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
Content-Type: text/plain
X-Request-Id: 11208a67-3ee1-453e-9d00-ad999cab71ba
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /object_occurrences/2b0b55c6-1d88-4236-a9d7-c831b2f128b2/relationships/components
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
X-Request-Id: c1d0ce96-7b55-4060-bae8-693e6a000dde
201 Created
```


```json
{
  "data": {
    "id": "ddfc5709-d5a7-4e4e-834d-c650dbf43ac8",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
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

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=ddfc5709-d5a7-4e4e-834d-c650dbf43ac8",
          "self": "/object_occurrences/ddfc5709-d5a7-4e4e-834d-c650dbf43ac8/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=ddfc5709-d5a7-4e4e-834d-c650dbf43ac8&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/ddfc5709-d5a7-4e4e-834d-c650dbf43ac8/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=ddfc5709-d5a7-4e4e-834d-c650dbf43ac8"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/8f1a75c4-15d9-43a4-8ed0-bbe961eab3d0"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/2b0b55c6-1d88-4236-a9d7-c831b2f128b2/relationships/components"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /object_occurrences/dd2a2d62-b4c8-489b-844c-3cd0631d704c/relationships/components
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
Content-Type: text/plain
X-Request-Id: f72ac0b3-4e31-4f76-97b4-6d339fbd09ea
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /object_occurrences/751ec0ea-39df-4310-980e-97bca18f8c28
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "751ec0ea-39df-4310-980e-97bca18f8c28",
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
          "id": "88ae3bba-88cd-4c67-8796-4c940779597d"
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
X-Request-Id: 49f1691b-6581-4891-9995-fa6ff796d662
200 OK
```


```json
{
  "data": {
    "id": "751ec0ea-39df-4310-980e-97bca18f8c28",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
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

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=751ec0ea-39df-4310-980e-97bca18f8c28",
          "self": "/object_occurrences/751ec0ea-39df-4310-980e-97bca18f8c28/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=751ec0ea-39df-4310-980e-97bca18f8c28&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/751ec0ea-39df-4310-980e-97bca18f8c28/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=751ec0ea-39df-4310-980e-97bca18f8c28"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/c8c591e0-aeb2-4a56-9098-4cfb03815e01"
        }
      },
      "classification_table": {
        "data": {
          "id": "5de8e80f-45d4-46ad-992a-ee1b3302a2bd",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/5de8e80f-45d4-46ad-992a-ee1b3302a2bd"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/88ae3bba-88cd-4c67-8796-4c940779597d",
          "self": "/object_occurrences/751ec0ea-39df-4310-980e-97bca18f8c28/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/751ec0ea-39df-4310-980e-97bca18f8c28/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "ad2bc6b8-3cfa-44e1-9e8d-279d23906ac4",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=751ec0ea-39df-4310-980e-97bca18f8c28"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "33060838-4c28-42ce-bf43-f19c8e70c05c",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=751ec0ea-39df-4310-980e-97bca18f8c28"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "5de8e80f-45d4-46ad-992a-ee1b3302a2bd",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=751ec0ea-39df-4310-980e-97bca18f8c28"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/751ec0ea-39df-4310-980e-97bca18f8c28"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/962e0be8-2357-46d4-a623-ff2196dcb563
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "962e0be8-2357-46d4-a623-ff2196dcb563",
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
          "id": "9d656669-a844-4c3c-905f-c151f481c5b2"
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
Content-Type: text/plain
X-Request-Id: a2cb8603-540d-4ad1-ba28-c946114eb82c
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /object_occurrences/2da88dae-f94c-428e-82c4-e28260e2a1b0/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "cd4fe0b7-6828-40c1-a8a3-51dbb8357fdb",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/1e1d29142cda76de577a3d16
Content-Type: text/html; charset=utf-8
X-Request-Id: dea6bbfa-2bcb-49bc-9136-ac7ef84df387
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/1e1d29142cda76de577a3d16">redirected</a>.</body></html>
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /object_occurrences/1250ac3c-5ba4-4d19-bbf6-8e78c06bbe60/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "9cd5c30d-a063-4163-849a-249c5a872a1a",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Content-Type: text/plain
X-Request-Id: bc163de6-abd9-4974-ab5e-60e5c75e47da
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /object_occurrences/fdc5aedc-e6d8-4f92-8267-1b2372f46c7b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f55803e6-8c0c-4c26-bc56-96a4d307f7cc
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/d5a0ae25-16cb-463e-9679-f8c716b1bde7/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "004779af-5421-49b2-803c-873b8ca85218",
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
X-Request-Id: bf3e98e4-3836-4cc5-879a-6b639575b9fe
200 OK
```


```json
{
  "data": {
    "id": "d5a0ae25-16cb-463e-9679-f8c716b1bde7",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
      "description": null,
      "image_key": null,
      "name": "OOC 2",
      "position": 2,
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
          "related": "/tags?filter[target_id_eq]=d5a0ae25-16cb-463e-9679-f8c716b1bde7",
          "self": "/object_occurrences/d5a0ae25-16cb-463e-9679-f8c716b1bde7/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=d5a0ae25-16cb-463e-9679-f8c716b1bde7&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/d5a0ae25-16cb-463e-9679-f8c716b1bde7/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=d5a0ae25-16cb-463e-9679-f8c716b1bde7"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/e611b0d0-efa2-4876-adb6-ad0e99e6651e"
        }
      },
      "classification_table": {
        "data": {
          "id": "6fc9cafb-7e1b-49e1-a46e-079e96551718",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/6fc9cafb-7e1b-49e1-a46e-079e96551718"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/004779af-5421-49b2-803c-873b8ca85218",
          "self": "/object_occurrences/d5a0ae25-16cb-463e-9679-f8c716b1bde7/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/d5a0ae25-16cb-463e-9679-f8c716b1bde7/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "dc936184-d402-44e8-9dc1-8493a157cd3d",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=d5a0ae25-16cb-463e-9679-f8c716b1bde7"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "9ba014a0-ae86-42a9-a5a5-7eb4e438eeec",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=d5a0ae25-16cb-463e-9679-f8c716b1bde7"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "6fc9cafb-7e1b-49e1-a46e-079e96551718",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=d5a0ae25-16cb-463e-9679-f8c716b1bde7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d5a0ae25-16cb-463e-9679-f8c716b1bde7/relationships/part_of"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/c324e7d4-a8eb-4005-ad9a-9032d89c0f7b/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "41d848fb-5be9-4086-8126-5832e5c13aba",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID of the new parent of the current Object Occurrence |



### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 2bcb70d3-6f73-410d-865d-7f3d5cd68ad8
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 92670d73-0c5f-4b5f-b170-8e3541070ce0
200 OK
```


```json
{
  "data": [
    {
      "id": "ca86ae5131b9f43d9871c639f8ff9163b58c12f6b112c0e79e1fda8f47e02fbd",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "83009ec8-b6e9-43d4-b12b-a16172445285",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/83009ec8-b6e9-43d4-b12b-a16172445285"
          }
        }
      }
    },
    {
      "id": "d81aba5093b21f116dbc8d4331ce23573ad17f2e7932c81481fd446d5fa7bc74",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "cd2d25de-9be6-46de-9e22-532a9d1ab026",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/cd2d25de-9be6-46de-9e22-532a9d1ab026"
          }
        }
      }
    },
    {
      "id": "15be2d9a3cd3414b1ca96908024db83eb8280804c3cf378261b02b91799cb340",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "dd770253-4577-4fa2-a90d-b4cd3ccc11d7",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/dd770253-4577-4fa2-a90d-b4cd3ccc11d7"
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



## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: edda615d-3109-4e7b-8c76-0f282b941a62
429 Too Many Requests
```


```json
This action has been rate limited
```



## Generate URL for direct upload


### Request

#### Endpoint

```plaintext
GET /object_occurrences/665e4c1a-b212-45da-9818-cf96305b7da0/relationships/image/upload_url?extension=jpg
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
X-Request-Id: 9b79aa9d-0aef-4beb-bd58-0feb07fb6cb9
200 OK
```


```json
{
  "data": {
    "id": "ooc/665e4c1a-b212-45da-9818-cf96305b7da0/1234abcde.jpg",
    "type": "url_struct",
    "attributes": {
      "id": "ooc/665e4c1a-b212-45da-9818-cf96305b7da0/1234abcde.jpg",
      "url": "https://qa-sec-hub-document-bucket.s3.eu-west-1.amazonaws.com/ooc/665e4c1a-b212-45da-9818-cf96305b7da0/1234abcde.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20200510%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20200510T124329Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=3ce3ff58247ece62786dd82a7ba8e39404b86080ad477ae1c30bcd93a5f857d7",
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /object_occurrences/083ff246-7fe6-4f99-b54e-c37ab28d6423/relationships/image/upload_url?extension=jpg
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
Content-Type: text/plain
X-Request-Id: 0a51d45a-bf38-4e59-b732-ad09e8980c10
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /object_occurrences/0a7f9e3b-ed03-49b5-88cd-643e65d41280/relationships/image
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
X-Request-Id: 93271e88-2402-4ae6-bd66-51b5748b1318
200 OK
```


```json
{
  "data": {
    "id": "0a7f9e3b-ed03-49b5-88cd-643e65d41280",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "image_key": "ooc/1234abcde.jpg",
      "name": "ooc 1",
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
          "related": "/tags?filter[target_id_eq]=0a7f9e3b-ed03-49b5-88cd-643e65d41280",
          "self": "/object_occurrences/0a7f9e3b-ed03-49b5-88cd-643e65d41280/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=0a7f9e3b-ed03-49b5-88cd-643e65d41280&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/0a7f9e3b-ed03-49b5-88cd-643e65d41280/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=0a7f9e3b-ed03-49b5-88cd-643e65d41280"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/7e9713c9-93e7-4f1e-9839-831b509abfd8"
        }
      },
      "classification_table": {
        "data": {
          "id": "ae115b85-ecf1-4066-bc98-bae6376aaf45",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/ae115b85-ecf1-4066-bc98-bae6376aaf45"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/2f85d491-469e-49a3-87a6-69d77dd58f10",
          "self": "/object_occurrences/0a7f9e3b-ed03-49b5-88cd-643e65d41280/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/0a7f9e3b-ed03-49b5-88cd-643e65d41280/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "9c1be9a7-f732-4c1a-82a7-1b498563c031",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a7f9e3b-ed03-49b5-88cd-643e65d41280"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "b151603b-66fb-4984-b857-079f2bd18d21",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a7f9e3b-ed03-49b5-88cd-643e65d41280"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "ae115b85-ecf1-4066-bc98-bae6376aaf45",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=0a7f9e3b-ed03-49b5-88cd-643e65d41280"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/2a1960c6-abec-4e27-80d7-4f20b6d28d9f/relationships/image
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
Content-Type: text/plain
X-Request-Id: 2683e7ba-2c6d-435d-b40b-54dc9dfa68de
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /object_occurrences/2516bdb3-b560-496e-ab67-7fe7d888b7ca/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 779741b2-ec43-4b96-a447-36a354e05d9c
204 No Content
```




## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/2fb371aa-de1c-491d-8ea0-9ba504e94086/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 49fbc668-f8af-4c8b-828f-1f2fd140a16c
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /classification_tables/cb0a9d75-1bf0-4678-8c96-c51e64de0069/relationships/tags
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
X-Request-Id: cd7e676e-7e65-470e-8c6e-994fd1342f3b
201 Created
```


```json
{
  "data": {
    "id": "c918e995-10e5-4f3f-92fc-9ffe12b9a36c",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/cb0a9d75-1bf0-4678-8c96-c51e64de0069/relationships/tags"
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
POST /classification_tables/fc111aec-ca23-4506-9927-db87ed9a8f01/relationships/tags
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
    "id": "bdbda83f-49ab-4bce-be6b-2f1912194373"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: dc2f5bc0-581d-4237-b183-3b58cbad7a42
201 Created
```


```json
{
  "data": {
    "id": "bdbda83f-49ab-4bce-be6b-2f1912194373",
    "type": "tag",
    "attributes": {
      "value": "tag value 25"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/fc111aec-ca23-4506-9927-db87ed9a8f01/relationships/tags"
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
DELETE /classification_tables/88b2807a-e349-4b10-9b03-e6867c706d8e/relationships/tags/9781512c-e072-41a7-8a4e-78b0ae5f879f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3b724213-75f6-4676-aad5-1c91b126a7db
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
X-Request-Id: f2550727-7e88-45a9-acea-1a1be6deccd6
200 OK
```


```json
{
  "data": [
    {
      "id": "425485a2-8888-408e-9971-a196ef3700d2",
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
            "related": "/tags?filter[target_id_eq]=425485a2-8888-408e-9971-a196ef3700d2",
            "self": "/classification_tables/425485a2-8888-408e-9971-a196ef3700d2/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=425485a2-8888-408e-9971-a196ef3700d2",
            "self": "/classification_tables/425485a2-8888-408e-9971-a196ef3700d2/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "513ed80c-37a8-4018-b3d8-e678bb732c99",
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
            "related": "/tags?filter[target_id_eq]=513ed80c-37a8-4018-b3d8-e678bb732c99",
            "self": "/classification_tables/513ed80c-37a8-4018-b3d8-e678bb732c99/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=513ed80c-37a8-4018-b3d8-e678bb732c99",
            "self": "/classification_tables/513ed80c-37a8-4018-b3d8-e678bb732c99/relationships/classification_entries",
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 9478c9fd-59e8-41c5-9f0c-bc185fd47933
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /classification_tables/907560c7-781a-4523-a7f2-a5916d93e765
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
X-Request-Id: 3ef24ff1-fbc7-42ad-bfa1-1dce26618ca9
200 OK
```


```json
{
  "data": {
    "id": "907560c7-781a-4523-a7f2-a5916d93e765",
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
          "related": "/tags?filter[target_id_eq]=907560c7-781a-4523-a7f2-a5916d93e765",
          "self": "/classification_tables/907560c7-781a-4523-a7f2-a5916d93e765/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=907560c7-781a-4523-a7f2-a5916d93e765",
          "self": "/classification_tables/907560c7-781a-4523-a7f2-a5916d93e765/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/907560c7-781a-4523-a7f2-a5916d93e765"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /classification_tables/2b4bcbdd-883f-4840-8da1-96fa31b7ef06
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: be077f9c-0573-4728-bca9-81d962339161
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /classification_tables/87309a63-cd9e-4036-a9f4-01f4721a36ed
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "87309a63-cd9e-4036-a9f4-01f4721a36ed",
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
X-Request-Id: ae1265e0-2353-480b-9b9e-24b3c6acf23f
200 OK
```


```json
{
  "data": {
    "id": "87309a63-cd9e-4036-a9f4-01f4721a36ed",
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
          "related": "/tags?filter[target_id_eq]=87309a63-cd9e-4036-a9f4-01f4721a36ed",
          "self": "/classification_tables/87309a63-cd9e-4036-a9f4-01f4721a36ed/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=87309a63-cd9e-4036-a9f4-01f4721a36ed",
          "self": "/classification_tables/87309a63-cd9e-4036-a9f4-01f4721a36ed/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/87309a63-cd9e-4036-a9f4-01f4721a36ed"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /classification_tables/54a10e74-0021-4125-b962-92bf5f8e660f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "54a10e74-0021-4125-b962-92bf5f8e660f",
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
Content-Type: text/plain
X-Request-Id: 298489bc-363b-4e09-a8d4-bca0175da6ff
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /classification_tables/59216d13-d587-474b-8638-4793fd7ad8be
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3e404219-0329-49d2-aed1-ca154a009dcc
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /classification_tables/9843683f-5689-400a-8abd-7081fd79c3b6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: f9e2362f-9f4b-43af-8710-04fe1e28d552
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /classification_tables/233e3800-fcf5-470c-b085-a26ec273f2bd/publish
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
X-Request-Id: 3314283d-ab33-462d-b689-324d42aad624
200 OK
```


```json
{
  "data": {
    "id": "233e3800-fcf5-470c-b085-a26ec273f2bd",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-05-10T12:42:19.781Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=233e3800-fcf5-470c-b085-a26ec273f2bd",
          "self": "/classification_tables/233e3800-fcf5-470c-b085-a26ec273f2bd/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=233e3800-fcf5-470c-b085-a26ec273f2bd",
          "self": "/classification_tables/233e3800-fcf5-470c-b085-a26ec273f2bd/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/233e3800-fcf5-470c-b085-a26ec273f2bd/publish"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /classification_tables/3ea7ec1a-da7a-4c9d-9505-bcc3e104282d/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 859bacf5-32a5-4554-8360-de784bc50d50
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /classification_tables/d64ea6e4-758d-4768-b62c-65028f191662/archive
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
X-Request-Id: 7a810478-7314-43c0-93bd-4acfd896f791
200 OK
```


```json
{
  "data": {
    "id": "d64ea6e4-758d-4768-b62c-65028f191662",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-10T12:42:20.778Z",
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
          "related": "/tags?filter[target_id_eq]=d64ea6e4-758d-4768-b62c-65028f191662",
          "self": "/classification_tables/d64ea6e4-758d-4768-b62c-65028f191662/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=d64ea6e4-758d-4768-b62c-65028f191662",
          "self": "/classification_tables/d64ea6e4-758d-4768-b62c-65028f191662/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d64ea6e4-758d-4768-b62c-65028f191662/archive"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /classification_tables/a477372b-0c81-4ea1-bb08-ee443b737196/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 5c2e7637-43d1-4d9b-8776-7b6920239f17
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: b4686641-a76d-4727-a11e-ca51f793d884
201 Created
```


```json
{
  "data": {
    "id": "5f39cc3d-7952-4618-afbd-cde9fc01a7c6",
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
          "related": "/tags?filter[target_id_eq]=5f39cc3d-7952-4618-afbd-cde9fc01a7c6",
          "self": "/classification_tables/5f39cc3d-7952-4618-afbd-cde9fc01a7c6/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=5f39cc3d-7952-4618-afbd-cde9fc01a7c6",
          "self": "/classification_tables/5f39cc3d-7952-4618-afbd-cde9fc01a7c6/relationships/classification_entries",
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: c5b8c93f-ff86-4c69-8e48-1a9eb152e0bd
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /classification_entries/ed647a7e-b4d0-4aac-a8bd-6b6eca4efb1e/relationships/tags
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
X-Request-Id: fa759193-a50c-41f9-a152-f77e86910c3e
201 Created
```


```json
{
  "data": {
    "id": "5f715459-6d79-4b32-b40c-84ea0a701629",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/ed647a7e-b4d0-4aac-a8bd-6b6eca4efb1e/relationships/tags"
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
POST /classification_entries/b9a90cf9-3c10-4df3-b080-07d7a76bc9ab/relationships/tags
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
    "id": "1b26fcf1-c24b-4eba-b09e-772091584c63"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 27b8acfb-d4ff-4ad7-a4a6-abb55dd2dbba
201 Created
```


```json
{
  "data": {
    "id": "1b26fcf1-c24b-4eba-b09e-772091584c63",
    "type": "tag",
    "attributes": {
      "value": "tag value 27"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/b9a90cf9-3c10-4df3-b080-07d7a76bc9ab/relationships/tags"
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
DELETE /classification_entries/0ff923fa-bfcc-4966-9780-0ace8b3f9bc2/relationships/tags/6ec69d59-d818-4ce6-ba5d-6f53e5d67dc0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: afac039b-38a1-4add-8507-0f745259f527
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
X-Request-Id: ed65f158-4831-45d7-9eb5-32e8bdf51bf0
200 OK
```


```json
{
  "data": [
    {
      "id": "1e72bec7-5911-42f1-b467-851a9d9dfc3d",
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
            "related": "/tags?filter[target_id_eq]=1e72bec7-5911-42f1-b467-851a9d9dfc3d",
            "self": "/classification_entries/1e72bec7-5911-42f1-b467-851a9d9dfc3d/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=1e72bec7-5911-42f1-b467-851a9d9dfc3d",
            "self": "/classification_entries/1e72bec7-5911-42f1-b467-851a9d9dfc3d/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "be03c97b-c349-4211-a76f-187a7e75a180",
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
            "related": "/tags?filter[target_id_eq]=be03c97b-c349-4211-a76f-187a7e75a180",
            "self": "/classification_entries/be03c97b-c349-4211-a76f-187a7e75a180/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "1e72bec7-5911-42f1-b467-851a9d9dfc3d",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/be03c97b-c349-4211-a76f-187a7e75a180"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=be03c97b-c349-4211-a76f-187a7e75a180",
            "self": "/classification_entries/be03c97b-c349-4211-a76f-187a7e75a180/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "53c30a34-1c97-422d-ad37-d8cda72d1efd",
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
            "related": "/tags?filter[target_id_eq]=53c30a34-1c97-422d-ad37-d8cda72d1efd",
            "self": "/classification_entries/53c30a34-1c97-422d-ad37-d8cda72d1efd/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=53c30a34-1c97-422d-ad37-d8cda72d1efd",
            "self": "/classification_entries/53c30a34-1c97-422d-ad37-d8cda72d1efd/relationships/classification_entries",
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: d9a6da4f-8841-4df3-bf57-2e3874dc38ff
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /classification_entries/50b3cf43-4c08-453a-a7de-3be33eadb199
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
X-Request-Id: cd1981c9-1786-4b71-96c3-c36a871822be
200 OK
```


```json
{
  "data": {
    "id": "50b3cf43-4c08-453a-a7de-3be33eadb199",
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
          "related": "/tags?filter[target_id_eq]=50b3cf43-4c08-453a-a7de-3be33eadb199",
          "self": "/classification_entries/50b3cf43-4c08-453a-a7de-3be33eadb199/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=50b3cf43-4c08-453a-a7de-3be33eadb199",
          "self": "/classification_entries/50b3cf43-4c08-453a-a7de-3be33eadb199/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/50b3cf43-4c08-453a-a7de-3be33eadb199"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /classification_entries/a0573ffd-b69a-4de8-857d-77b9f8d239a4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 79430333-0fe8-4d27-9b0f-1b1388814672
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /classification_entries/a5ce135d-ec2b-4a0c-8f67-0504d0a08591
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "a5ce135d-ec2b-4a0c-8f67-0504d0a08591",
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
X-Request-Id: 89024f30-f698-4bb3-bc88-e3cadb393ae8
200 OK
```


```json
{
  "data": {
    "id": "a5ce135d-ec2b-4a0c-8f67-0504d0a08591",
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
          "related": "/tags?filter[target_id_eq]=a5ce135d-ec2b-4a0c-8f67-0504d0a08591",
          "self": "/classification_entries/a5ce135d-ec2b-4a0c-8f67-0504d0a08591/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "652a9dc1-31fc-4cad-a457-a70b600a16ce",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/a5ce135d-ec2b-4a0c-8f67-0504d0a08591"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=a5ce135d-ec2b-4a0c-8f67-0504d0a08591",
          "self": "/classification_entries/a5ce135d-ec2b-4a0c-8f67-0504d0a08591/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/a5ce135d-ec2b-4a0c-8f67-0504d0a08591"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /classification_entries/2824fc61-c72e-4287-ae2b-398b705a4bd0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "2824fc61-c72e-4287-ae2b-398b705a4bd0",
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
Content-Type: text/plain
X-Request-Id: 70cff84a-5561-41f4-9a3c-a3edfca7d007
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /classification_entries/833ad813-adde-4e14-99c5-417c53317fa0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 195963ce-ce69-4ced-9ce1-3a5f86369954
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][code] | Classification code |
| data[attributes][definition] | Definition |
| data[attributes][name] | Common name |
| data[attributes][reciprocal_name] | Reciprocal name |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /classification_entries/eccfe148-3b05-4c81-b2ab-571986f1f49b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 76f25c30-e548-4193-be01-22fc11d31468
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /classification_tables/23276a73-e8ac-4dd5-b562-47b7e22bd309/relationships/classification_entries
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
X-Request-Id: 2f600402-a4e8-4204-bb80-406a08005b01
201 Created
```


```json
{
  "data": {
    "id": "42ecd7ae-a1f8-4283-a952-796d928e2ebd",
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
          "related": "/tags?filter[target_id_eq]=42ecd7ae-a1f8-4283-a952-796d928e2ebd",
          "self": "/classification_entries/42ecd7ae-a1f8-4283-a952-796d928e2ebd/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=42ecd7ae-a1f8-4283-a952-796d928e2ebd",
          "self": "/classification_entries/42ecd7ae-a1f8-4283-a952-796d928e2ebd/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/23276a73-e8ac-4dd5-b562-47b7e22bd309/relationships/classification_entries"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /classification_tables/d4907fbb-cace-4aeb-8a69-0e193260b725/relationships/classification_entries
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
Content-Type: text/plain
X-Request-Id: d67e0680-60a4-4622-be01-8ac5ddc97b41
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 00f89133-f7a6-49eb-a24d-ab3c03161441
200 OK
```


```json
{
  "data": [
    {
      "id": "6b959403-c80a-4568-96cd-c8486f9e87f8",
      "type": "syntax",
      "attributes": {
        "account_id": "86a2598a-4f9a-48c2-b2de-8e5f6c57310f",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 3add432c51df",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=6b959403-c80a-4568-96cd-c8486f9e87f8",
            "self": "/syntaxes/6b959403-c80a-4568-96cd-c8486f9e87f8/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/c0b64867-34de-45a2-8870-4df262326fce",
            "self": "/syntax_nodes/c0b64867-34de-45a2-8870-4df262326fce/relationships/components"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 207e6373-08af-4f74-a739-afab7cee5722
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /syntaxes/e05700e0-d743-4553-b2cf-a1d4ed9b1cff
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
X-Request-Id: d3003084-6593-418d-9f9f-3ac803abab51
200 OK
```


```json
{
  "data": {
    "id": "e05700e0-d743-4553-b2cf-a1d4ed9b1cff",
    "type": "syntax",
    "attributes": {
      "account_id": "b968e1a4-b37f-4c95-9ac3-5bc082f230a2",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 2ace1e22330d",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=e05700e0-d743-4553-b2cf-a1d4ed9b1cff",
          "self": "/syntaxes/e05700e0-d743-4553-b2cf-a1d4ed9b1cff/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/0b5b167d-8f30-4d6a-8949-607f05003b90",
          "self": "/syntax_nodes/0b5b167d-8f30-4d6a-8949-607f05003b90/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/e05700e0-d743-4553-b2cf-a1d4ed9b1cff"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /syntaxes/0106ba1f-b778-48c9-9270-9e9dbdb5ec13
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 4f799973-0b77-400a-beaa-1f4d72555bf9
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: df9bede2-ddbc-4473-883a-97b2fc99644f
201 Created
```


```json
{
  "data": {
    "id": "60e02baf-7a3f-4e4d-8967-227f72dff242",
    "type": "syntax",
    "attributes": {
      "account_id": "935a30ed-0a64-4b9c-aea5-20a6d68a9bb4",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=60e02baf-7a3f-4e4d-8967-227f72dff242",
          "self": "/syntaxes/60e02baf-7a3f-4e4d-8967-227f72dff242/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/7adde4f2-3081-4ab5-94dd-050d0b640387",
          "self": "/syntax_nodes/7adde4f2-3081-4ab5-94dd-050d0b640387/relationships/components"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 1097d9e7-1829-4315-ac16-789b0d332e69
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /syntaxes/54d34f87-c9c5-44d6-8bc6-19a6e5c0cb69
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "54d34f87-c9c5-44d6-8bc6-19a6e5c0cb69",
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
X-Request-Id: fde886a7-40b9-48ef-a121-2e0638f98f67
200 OK
```


```json
{
  "data": {
    "id": "54d34f87-c9c5-44d6-8bc6-19a6e5c0cb69",
    "type": "syntax",
    "attributes": {
      "account_id": "da300dcd-d107-4425-ae43-ff2c2b394e50",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=54d34f87-c9c5-44d6-8bc6-19a6e5c0cb69",
          "self": "/syntaxes/54d34f87-c9c5-44d6-8bc6-19a6e5c0cb69/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/619f0513-060c-431f-bc14-6b5c88fcda73",
          "self": "/syntax_nodes/619f0513-060c-431f-bc14-6b5c88fcda73/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/54d34f87-c9c5-44d6-8bc6-19a6e5c0cb69"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /syntaxes/263b841b-7b33-4672-b10e-9661b0ca5f9a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "263b841b-7b33-4672-b10e-9661b0ca5f9a",
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
Content-Type: text/plain
X-Request-Id: bc8d1b3c-8194-4edc-870e-291ce1f8d7aa
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /syntaxes/4de756b8-e0b9-4a4f-82f9-aad93baeccd2
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8998cede-1fd5-4d43-9223-4b87d65d6914
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /syntaxes/ef6ec06d-48c1-4e1e-9833-62d572655480
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 7e28bb75-28ab-4fbd-a142-2866334dd7c6
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /syntaxes/bf68d782-0840-47a9-8774-e66d288f524e/publish
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
X-Request-Id: a6a0528d-767d-4b30-a036-8258afe04e89
200 OK
```


```json
{
  "data": {
    "id": "bf68d782-0840-47a9-8774-e66d288f524e",
    "type": "syntax",
    "attributes": {
      "account_id": "ba030a5e-1271-49b5-a723-d6166dd72a21",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax d5273baf8570",
      "published": true,
      "published_at": "2020-05-10T12:42:34.228Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=bf68d782-0840-47a9-8774-e66d288f524e",
          "self": "/syntaxes/bf68d782-0840-47a9-8774-e66d288f524e/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/554fcad8-f0f0-4b32-aad3-a9e419890ccd",
          "self": "/syntax_nodes/554fcad8-f0f0-4b32-aad3-a9e419890ccd/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/bf68d782-0840-47a9-8774-e66d288f524e/publish"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /syntaxes/f54ba0a5-7f30-4410-899c-8f05ffd223ad/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 56f19388-ea1e-41da-8365-2e6cbf23ed8c
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /syntaxes/33f8e6b6-f2a3-47ac-aa80-389359c2cb03/archive
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
X-Request-Id: 08870fb1-a2a0-43fb-9967-852d667e77d2
200 OK
```


```json
{
  "data": {
    "id": "33f8e6b6-f2a3-47ac-aa80-389359c2cb03",
    "type": "syntax",
    "attributes": {
      "account_id": "32026120-810e-4a2d-91a3-5de434012c78",
      "archived": true,
      "archived_at": "2020-05-10T12:42:34.922Z",
      "description": "Description",
      "name": "Syntax 6d2c1d081e43",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=33f8e6b6-f2a3-47ac-aa80-389359c2cb03",
          "self": "/syntaxes/33f8e6b6-f2a3-47ac-aa80-389359c2cb03/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/81f2e0a3-dd99-4ace-9c68-bed2a7b35567",
          "self": "/syntax_nodes/81f2e0a3-dd99-4ace-9c68-bed2a7b35567/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/33f8e6b6-f2a3-47ac-aa80-389359c2cb03/archive"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /syntaxes/677517c8-a8d2-4208-9e07-a08d5ae0d1e0/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: cf666a06-f892-4757-ae71-9c1605632aa5
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 2566c681-176f-4d0b-8bd3-c4b088f13775
200 OK
```


```json
{
  "data": [
    {
      "id": "571d7668-5dc3-486c-93f8-6602f54debe8",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 27",
        "hex_color": "4771c2"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/8840ce62-3434-4ab0-a3c1-b85640551cd5"
          }
        },
        "classification_table": {
          "data": {
            "id": "08dee191-908d-46cd-a5f8-7a5803d2cc23",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/08dee191-908d-46cd-a5f8-7a5803d2cc23",
            "self": "/syntax_elements/571d7668-5dc3-486c-93f8-6602f54debe8/relationships/classification_table"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: c64505d4-e1b3-48dc-8d70-7a1810baf639
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /syntax_elements/086217b8-78f9-4802-866d-f882dc2d743a
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
X-Request-Id: f50f78a3-29f0-4727-92e4-0b6f4a448821
200 OK
```


```json
{
  "data": {
    "id": "086217b8-78f9-4802-866d-f882dc2d743a",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 29",
      "hex_color": "f6421f"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/53b46cf2-a7cc-4ec6-8a6d-60e2d27b9955"
        }
      },
      "classification_table": {
        "data": {
          "id": "759f0b45-5787-4f14-9dd2-783188bc4c5b",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/759f0b45-5787-4f14-9dd2-783188bc4c5b",
          "self": "/syntax_elements/086217b8-78f9-4802-866d-f882dc2d743a/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/086217b8-78f9-4802-866d-f882dc2d743a"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /syntax_elements/fe398369-7bd1-4a00-841d-0af0b26e857f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 4d7a8f0f-b8a9-49d7-9bc3-b97c361ad3f3
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /syntaxes/83928066-1eb8-4614-8019-33bd3436bb1e/relationships/syntax_elements
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
          "id": "87e648d8-fe72-4e29-bb77-ef86b6dd79e8"
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
X-Request-Id: 6fdebba8-698c-483a-b4a7-18467f6151ba
201 Created
```


```json
{
  "data": {
    "id": "23bff6c2-8263-443c-9723-1f0ae20a2f97",
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
          "related": "/syntaxes/83928066-1eb8-4614-8019-33bd3436bb1e"
        }
      },
      "classification_table": {
        "data": {
          "id": "87e648d8-fe72-4e29-bb77-ef86b6dd79e8",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/87e648d8-fe72-4e29-bb77-ef86b6dd79e8",
          "self": "/syntax_elements/23bff6c2-8263-443c-9723-1f0ae20a2f97/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/83928066-1eb8-4614-8019-33bd3436bb1e/relationships/syntax_elements"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /syntaxes/6326460c-5049-4f8e-b8c3-2dd1bd97d12f/relationships/syntax_elements
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
          "id": "071e230e-6725-4ef0-bd67-8c2db81b9abb"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 49eeec44-5f99-4645-aa8a-f7f79f90d0de
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /syntax_elements/3bc8c0d6-37cf-4a5c-9ba2-d2ca247805d9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "3bc8c0d6-37cf-4a5c-9ba2-d2ca247805d9",
    "type": "syntax_element",
    "attributes": {
      "name": "New element",
      "hex_color": "ffffff"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "e68fd6d3-5d63-438a-ac00-c189f11695f7"
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
X-Request-Id: 3efdaf5c-0ed9-4e1c-9082-bd6670dce5b1
200 OK
```


```json
{
  "data": {
    "id": "3bc8c0d6-37cf-4a5c-9ba2-d2ca247805d9",
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
          "related": "/syntaxes/305212c8-2111-46ec-97b3-28bf5390608e"
        }
      },
      "classification_table": {
        "data": {
          "id": "e68fd6d3-5d63-438a-ac00-c189f11695f7",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/e68fd6d3-5d63-438a-ac00-c189f11695f7",
          "self": "/syntax_elements/3bc8c0d6-37cf-4a5c-9ba2-d2ca247805d9/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/3bc8c0d6-37cf-4a5c-9ba2-d2ca247805d9"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /syntax_elements/3126c38f-2dd9-48ee-b0cc-27aec485232e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "3126c38f-2dd9-48ee-b0cc-27aec485232e",
    "type": "syntax_element",
    "attributes": {
      "name": "New element",
      "hex_color": "ffffff"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "93ea7cc9-4130-4d75-a505-69bcaba7d3ee"
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
Content-Type: text/plain
X-Request-Id: 9ce22f02-c36e-4b63-b220-6832ea23ddd2
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /syntax_elements/6582247e-9ea4-4048-975e-47cce66001bd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 960793ff-619f-4a9e-9934-d6ca0c139c16
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /syntax_elements/20e5b5e4-1948-4571-9494-375198bb62ca
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 747100b8-da2b-48df-987e-4d2001fd4180
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /syntax_elements/77685440-1eeb-49d6-ae53-a8da0a4c8262/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "a1ec93b5-58cf-48c5-a71c-c93e10dae991",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7ec1d318-4471-449d-8e5f-5b4ea2cdaf2b
200 OK
```


```json
{
  "data": {
    "id": "77685440-1eeb-49d6-ae53-a8da0a4c8262",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 37",
      "hex_color": "b63083"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/a737ceeb-2593-4a4c-b461-91cc63540eac"
        }
      },
      "classification_table": {
        "data": {
          "id": "a1ec93b5-58cf-48c5-a71c-c93e10dae991",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/a1ec93b5-58cf-48c5-a71c-c93e10dae991",
          "self": "/syntax_elements/77685440-1eeb-49d6-ae53-a8da0a4c8262/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/77685440-1eeb-49d6-ae53-a8da0a4c8262/relationships/classification_table"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /syntax_elements/6f8845d7-3b5c-4ed8-888c-f4a7188132ed/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "5ee532a6-4fc4-43f9-bb14-bcd445d1231a",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: e044ddd0-36e8-4bcd-96c6-e6314ea4cb5b
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /syntax_elements/e183d6ce-dc38-49f5-876c-e53ae6398e5a/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e19a2f0e-968e-4dac-b5db-1ea9f5bf36a4
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /syntax_elements/125c60b8-5701-407c-a794-9d8c891288b8/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 6d69cf81-7877-4962-9dec-69ddeab5bef5
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 437194c7-e63b-4607-b8cf-6231bba1cea5
200 OK
```


```json
{
  "data": [
    {
      "id": "abb51d7c-e832-43b5-bbe8-b8cf953f456d",
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
              "id": "ae4abe3d-905e-46d5-bc35-87aede8e66ec",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/abb51d7c-e832-43b5-bbe8-b8cf953f456d/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/abb51d7c-e832-43b5-bbe8-b8cf953f456d/relationships/parent",
            "related": "/syntax_nodes/abb51d7c-e832-43b5-bbe8-b8cf953f456d"
          }
        }
      }
    },
    {
      "id": "827c6e74-da5c-4dbc-aeb9-6b1772e49ccf",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/f648d309-b2fd-4fb3-a7ed-580104037a4c"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/827c6e74-da5c-4dbc-aeb9-6b1772e49ccf/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/827c6e74-da5c-4dbc-aeb9-6b1772e49ccf/relationships/parent",
            "related": "/syntax_nodes/827c6e74-da5c-4dbc-aeb9-6b1772e49ccf"
          }
        }
      }
    },
    {
      "id": "d9c66d0c-9af5-4738-bb3e-ee525ed394fa",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/f648d309-b2fd-4fb3-a7ed-580104037a4c"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/d9c66d0c-9af5-4738-bb3e-ee525ed394fa/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/d9c66d0c-9af5-4738-bb3e-ee525ed394fa/relationships/parent",
            "related": "/syntax_nodes/d9c66d0c-9af5-4738-bb3e-ee525ed394fa"
          }
        }
      }
    },
    {
      "id": "e7bb13b8-89b5-4188-a92f-d7552dcfca33",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/f648d309-b2fd-4fb3-a7ed-580104037a4c"
          }
        },
        "components": {
          "data": [
            {
              "id": "827c6e74-da5c-4dbc-aeb9-6b1772e49ccf",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/e7bb13b8-89b5-4188-a92f-d7552dcfca33/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e7bb13b8-89b5-4188-a92f-d7552dcfca33/relationships/parent",
            "related": "/syntax_nodes/e7bb13b8-89b5-4188-a92f-d7552dcfca33"
          }
        }
      }
    },
    {
      "id": "ae4abe3d-905e-46d5-bc35-87aede8e66ec",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/f648d309-b2fd-4fb3-a7ed-580104037a4c"
          }
        },
        "components": {
          "data": [
            {
              "id": "e7bb13b8-89b5-4188-a92f-d7552dcfca33",
              "type": "syntax_node"
            },
            {
              "id": "d9c66d0c-9af5-4738-bb3e-ee525ed394fa",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/ae4abe3d-905e-46d5-bc35-87aede8e66ec/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/ae4abe3d-905e-46d5-bc35-87aede8e66ec/relationships/parent",
            "related": "/syntax_nodes/ae4abe3d-905e-46d5-bc35-87aede8e66ec"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 6eead412-905d-44a5-9e5d-0bb8ea64c8e8
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /syntax_nodes/7f987b12-f383-4a46-b8d7-1f28858bfe23?depth=2
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
X-Request-Id: df54fbac-aafe-479a-9825-47ad8b496ef4
200 OK
```


```json
{
  "data": {
    "id": "7f987b12-f383-4a46-b8d7-1f28858bfe23",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/7ebf7dfd-20a4-4158-a673-0cabf3054184"
        }
      },
      "components": {
        "data": [
          {
            "id": "c7de3828-a121-422b-a8eb-fde1e3f98e05",
            "type": "syntax_node"
          },
          {
            "id": "5f627d67-7e8b-4283-b451-15291bf6e150",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/7f987b12-f383-4a46-b8d7-1f28858bfe23/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/7f987b12-f383-4a46-b8d7-1f28858bfe23/relationships/parent",
          "related": "/syntax_nodes/7f987b12-f383-4a46-b8d7-1f28858bfe23"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/7f987b12-f383-4a46-b8d7-1f28858bfe23?depth=2"
  },
  "included": [
    {
      "id": "5f627d67-7e8b-4283-b451-15291bf6e150",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/7ebf7dfd-20a4-4158-a673-0cabf3054184"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/5f627d67-7e8b-4283-b451-15291bf6e150/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/5f627d67-7e8b-4283-b451-15291bf6e150/relationships/parent",
            "related": "/syntax_nodes/5f627d67-7e8b-4283-b451-15291bf6e150"
          }
        }
      }
    },
    {
      "id": "c7de3828-a121-422b-a8eb-fde1e3f98e05",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/7ebf7dfd-20a4-4158-a673-0cabf3054184"
          }
        },
        "components": {
          "data": [
            {
              "id": "1f50eeb9-415a-40ac-a53b-6765405f1241",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/c7de3828-a121-422b-a8eb-fde1e3f98e05/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/c7de3828-a121-422b-a8eb-fde1e3f98e05/relationships/parent",
            "related": "/syntax_nodes/c7de3828-a121-422b-a8eb-fde1e3f98e05"
          }
        }
      }
    },
    {
      "id": "1f50eeb9-415a-40ac-a53b-6765405f1241",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/7ebf7dfd-20a4-4158-a673-0cabf3054184"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/1f50eeb9-415a-40ac-a53b-6765405f1241/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/1f50eeb9-415a-40ac-a53b-6765405f1241/relationships/parent",
            "related": "/syntax_nodes/1f50eeb9-415a-40ac-a53b-6765405f1241"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /syntax_nodes/b6c17841-b721-4cfc-81a7-2c0a85017f75?depth=2
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
Content-Type: text/plain
X-Request-Id: e69e6395-deaf-4ab0-adc4-e10cd00782e8
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /syntax_nodes/219e874b-525c-4a97-b812-403a7ab99342/relationships/components
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
          "id": "6644c7c1-ce34-40a0-b490-583b008f0b67"
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
X-Request-Id: cafbbce0-9c20-4709-84cb-ad79aff39ce9
201 Created
```


```json
{
  "data": {
    "id": "9a0fbdfc-1fb2-4f31-900b-1e8750c74e4c",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/6644c7c1-ce34-40a0-b490-583b008f0b67"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/9a0fbdfc-1fb2-4f31-900b-1e8750c74e4c/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/9a0fbdfc-1fb2-4f31-900b-1e8750c74e4c/relationships/parent",
          "related": "/syntax_nodes/9a0fbdfc-1fb2-4f31-900b-1e8750c74e4c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/219e874b-525c-4a97-b812-403a7ab99342/relationships/components"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /syntax_nodes/426a138e-2bae-4c65-a611-13d939228f94/relationships/components
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
          "id": "fa8689cd-269c-4f30-8d81-5bffbf15083d"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: dbff9dac-c35e-462a-aa6a-e91071d41c9c
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /syntax_nodes/937517ac-b5ce-4813-92ce-98917087c9df/relationships/parent
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
    "id": "3e34cfff-8ec6-4ff1-b58c-bfc8fc871ffb"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2f3bed96-0258-4868-a63c-2d963da95f98
200 OK
```


```json
{
  "data": {
    "id": "937517ac-b5ce-4813-92ce-98917087c9df",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 2
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/cbfeda84-55cd-4ce7-adb3-5c82e06f5800"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/937517ac-b5ce-4813-92ce-98917087c9df/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/937517ac-b5ce-4813-92ce-98917087c9df/relationships/parent",
          "related": "/syntax_nodes/937517ac-b5ce-4813-92ce-98917087c9df"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /syntax_nodes/a72c29c0-171d-4758-b276-3cd76e7cad71/relationships/parent
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
    "id": "315dab92-1d40-47b6-ab64-f933b17df1ef"
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 625070db-1656-478c-bb0b-377e6b3dd8ed
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /syntax_nodes/72fbd6dd-b094-40e5-84c0-4f2c293d6579
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "72fbd6dd-b094-40e5-84c0-4f2c293d6579",
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
X-Request-Id: 5eb168f2-c6fb-4178-9cd5-c3d3ac1245f6
200 OK
```


```json
{
  "data": {
    "id": "72fbd6dd-b094-40e5-84c0-4f2c293d6579",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/69e6f808-14b3-4a60-b98f-f15d54b135b1"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/72fbd6dd-b094-40e5-84c0-4f2c293d6579/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/72fbd6dd-b094-40e5-84c0-4f2c293d6579/relationships/parent",
          "related": "/syntax_nodes/72fbd6dd-b094-40e5-84c0-4f2c293d6579"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/72fbd6dd-b094-40e5-84c0-4f2c293d6579"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /syntax_nodes/22244b7e-d177-4907-b7e0-3158217b114a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "22244b7e-d177-4907-b7e0-3158217b114a",
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
Content-Type: text/plain
X-Request-Id: da598746-f762-4989-b6d3-7ac6e8f52d55
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /syntax_nodes/eb434a96-492e-47c5-b8e7-f20a4fdf8e98
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e807713b-060f-44fe-b470-b1c5d2a47bf6
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /syntax_nodes/615a5c2d-71db-46c1-81fb-af93baa04c12
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: d0288bd2-060d-48c4-8e54-3d6f696c8839
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: ff3dc787-b19c-4702-a5e2-d8b42c8d553b
200 OK
```


```json
{
  "data": [
    {
      "id": "24647145-4921-4767-b21b-062f177a1844",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 177,
        "published": true,
        "published_at": "2020-05-10T12:42:48.108Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=24647145-4921-4767-b21b-062f177a1844",
            "self": "/progress_models/24647145-4921-4767-b21b-062f177a1844/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "6f1117f3-b9c7-4e64-8cd2-9887a28b3938",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=6f1117f3-b9c7-4e64-8cd2-9887a28b3938",
            "self": "/progress_models/6f1117f3-b9c7-4e64-8cd2-9887a28b3938/relationships/progress_steps"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 8cc38917-a3d5-4dc3-953a-0489d4c4f17b
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /progress_models/b98e7fb5-b499-4186-9c6c-6d414aaf8a15
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
X-Request-Id: 9360d745-e55c-4de5-8bde-edc7a293a757
200 OK
```


```json
{
  "data": {
    "id": "b98e7fb5-b499-4186-9c6c-6d414aaf8a15",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 181,
      "published": true,
      "published_at": "2020-05-10T12:42:48.835Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b98e7fb5-b499-4186-9c6c-6d414aaf8a15",
          "self": "/progress_models/b98e7fb5-b499-4186-9c6c-6d414aaf8a15/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/b98e7fb5-b499-4186-9c6c-6d414aaf8a15"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /progress_models/18262180-8fd6-4b6a-bded-918fb0bfa25b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 26e86444-e848-4c5e-8a65-38285b51a223
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /progress_models/1b7cfc6d-fe58-49c0-b1db-1a5e48396eee
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "1b7cfc6d-fe58-49c0-b1db-1a5e48396eee",
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
X-Request-Id: 954a7c27-6919-48b8-8a43-fa71d4f7496a
200 OK
```


```json
{
  "data": {
    "id": "1b7cfc6d-fe58-49c0-b1db-1a5e48396eee",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=1b7cfc6d-fe58-49c0-b1db-1a5e48396eee",
          "self": "/progress_models/1b7cfc6d-fe58-49c0-b1db-1a5e48396eee/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/1b7cfc6d-fe58-49c0-b1db-1a5e48396eee"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /progress_models/9a30239e-b35d-44cd-a488-9f4583f4f41e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "9a30239e-b35d-44cd-a488-9f4583f4f41e",
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
Content-Type: text/plain
X-Request-Id: 9393f14f-d3b7-425d-ad53-a7f4f5635da5
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /progress_models/b16f774b-8845-49c2-a05e-222c75c33267
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6f2374d1-7e2f-4e90-813f-76210bae4943
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][published_at] | Publication date |
| data[attributes][published] | Published |
| data[attributes][order] | Order |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /progress_models/f4871ad9-b2c1-47b3-9dd8-b69b604cfe9a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: bbd1b9c7-14ba-4056-98e7-171f374e9220
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /progress_models/76a7c294-10e1-460a-ab73-3449f3a802a6/publish
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
X-Request-Id: f014160b-8b3a-4af4-9496-f1dcd28a0475
200 OK
```


```json
{
  "data": {
    "id": "76a7c294-10e1-460a-ab73-3449f3a802a6",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 194,
      "published": true,
      "published_at": "2020-05-10T12:42:51.744Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=76a7c294-10e1-460a-ab73-3449f3a802a6",
          "self": "/progress_models/76a7c294-10e1-460a-ab73-3449f3a802a6/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/76a7c294-10e1-460a-ab73-3449f3a802a6/publish"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /progress_models/f30997b9-d5f4-4d94-ab68-35665daaa04b/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models/:id/publish`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 0eb7093c-2f70-4884-9b7a-d45ab87f9d21
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /progress_models/0632fca2-c2df-4c95-92f8-7b83f7aaeaf2/archive
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
X-Request-Id: 7d704a97-9143-40b0-9d24-3a984956f7c1
200 OK
```


```json
{
  "data": {
    "id": "0632fca2-c2df-4c95-92f8-7b83f7aaeaf2",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-10T12:42:52.303Z",
      "name": "pm 2",
      "order": 198,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=0632fca2-c2df-4c95-92f8-7b83f7aaeaf2",
          "self": "/progress_models/0632fca2-c2df-4c95-92f8-7b83f7aaeaf2/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0632fca2-c2df-4c95-92f8-7b83f7aaeaf2/archive"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /progress_models/69d839bc-b06b-4435-b9a7-d22c0b75849c/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /progress_models/:id/archive`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: e852bc98-9eec-415e-9486-adb7154aeb05
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: fd7460a7-fbc1-4580-b412-f6e816a05c96
201 Created
```


```json
{
  "data": {
    "id": "dd832c0f-37e5-4d38-86a8-1de226a7906a",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=dd832c0f-37e5-4d38-86a8-1de226a7906a",
          "self": "/progress_models/dd832c0f-37e5-4d38-86a8-1de226a7906a/relationships/progress_steps"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: f484fbec-35d2-4310-a5f1-83cffbc40ef0
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 858ed27c-eaaf-4b2e-a3b1-c8b91fc74fec
200 OK
```


```json
{
  "data": [
    {
      "id": "1d2a2272-c49b-4376-b413-9d08a6ccb585",
      "type": "progress_step",
      "attributes": {
        "name": "ps context",
        "order": 1,
        "hex_color": "581409"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/b909423c-1a2c-44cb-bcb6-57478604eecf"
          }
        }
      }
    },
    {
      "id": "0dc89013-9495-4566-9b9f-509a512c0ce0",
      "type": "progress_step",
      "attributes": {
        "name": "ps ooc",
        "order": 1,
        "hex_color": "ecd7c8"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/773c1cd3-c381-414a-8635-f77cd12fcc2f"
          }
        }
      }
    },
    {
      "id": "74c36b71-48da-4a1c-8459-46f9fa540e62",
      "type": "progress_step",
      "attributes": {
        "name": "ps oor",
        "order": 1,
        "hex_color": "bdb99a"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/0105b0d4-16e7-42ec-a219-8e4222b23296"
          }
        }
      }
    },
    {
      "id": "092bc0c0-2ee7-400b-ab8a-125b8bd0e4a1",
      "type": "progress_step",
      "attributes": {
        "name": "ps project",
        "order": 1,
        "hex_color": "5e6342"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/a6f19bb0-466b-481d-b1b5-2af1440c3d3d"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: c83b359b-c318-4ac8-a963-471426628c7f
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /progress_steps/33ebcd23-8995-47cb-98af-00557814bab3
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
X-Request-Id: f9b30a2f-5d69-4c81-b490-eefd48c1dac7
200 OK
```


```json
{
  "data": {
    "id": "33ebcd23-8995-47cb-98af-00557814bab3",
    "type": "progress_step",
    "attributes": {
      "name": "ps oor",
      "order": 1,
      "hex_color": "b093c9"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/9f7e185e-9b19-4fcf-ab02-f5a1e0c972c3"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/33ebcd23-8995-47cb-98af-00557814bab3"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /progress_steps/d0e392b3-2c8f-4086-a2c7-b50c10ef9985
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 26dc363a-b667-44b1-8ca0-8ef913ea8d8d
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /progress_steps/b9b3a38f-2048-4c77-8f44-4fb3d6c0489c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "b9b3a38f-2048-4c77-8f44-4fb3d6c0489c",
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
X-Request-Id: d2d063e5-9e6e-4bf5-8954-f003fc88cc75
200 OK
```


```json
{
  "data": {
    "id": "b9b3a38f-2048-4c77-8f44-4fb3d6c0489c",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 1,
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/957003dd-be19-4811-90e3-6356bea031e7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/b9b3a38f-2048-4c77-8f44-4fb3d6c0489c"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /progress_steps/516ca584-4aba-460c-991c-bba11b3a310c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "516ca584-4aba-460c-991c-bba11b3a310c",
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
Content-Type: text/plain
X-Request-Id: 32285c6f-3f89-47c3-9491-8d3808b71a2f
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /progress_steps/6672069b-470b-4f03-b71b-bb32710bf665
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 20f34db1-5a93-44c1-b262-fa5c111dd9dd
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /progress_steps/3bf42fe9-f0d5-4fcb-906f-39fc1d042df6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: b838faf2-d081-44f2-a9da-3c9238a81c05
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /progress_models/1b914d2a-4dea-4787-ab28-26438b5ed01d/relationships/progress_steps
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
X-Request-Id: ec35c6c4-abea-4f2e-aebf-8042aac59875
201 Created
```


```json
{
  "data": {
    "id": "00769499-e661-4041-89a2-54061a83d31e",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/1b914d2a-4dea-4787-ab28-26438b5ed01d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/1b914d2a-4dea-4787-ab28-26438b5ed01d/relationships/progress_steps"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Name |
| data[attributes][order] | Order |


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /progress_models/12e9949b-7dca-4ead-a69e-dd8b1f306d27/relationships/progress_steps
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
Content-Type: text/plain
X-Request-Id: fcae6e05-7ecf-4fb9-9daa-d93547c10148
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: c28f77b8-392f-471d-bf0e-2ef5fd505244
200 OK
```


```json
{
  "data": [
    {
      "id": "18eb6d1e-9fff-48e3-a4d8-100821258b4e",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "b03dcff6-e268-4ff2-be0e-259ebb195d06",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/b03dcff6-e268-4ff2-be0e-259ebb195d06"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/81142aad-daf1-47c6-997d-d2f6818d5399"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: f0e24db7-e9e3-422a-a3f6-5deb3f0280eb
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /progress/ece4beb9-504e-4d78-8b53-743cbcaeea48
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
X-Request-Id: 61c18cb1-66e4-44ea-abb7-4a60289b77b1
200 OK
```


```json
{
  "data": {
    "id": "ece4beb9-504e-4d78-8b53-743cbcaeea48",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "ec2f9f5f-cec0-4e66-a85b-7ebc0e4b3732",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/ec2f9f5f-cec0-4e66-a85b-7ebc0e4b3732"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/c1e169f8-ee55-4c65-a671-e18c232b00f1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/ece4beb9-504e-4d78-8b53-743cbcaeea48"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][progress_step] | Progress step |
| data[attributes][target] | Target |


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /progress/dd9de062-6539-4252-8341-595baaa185bd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /progress/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 189c122d-8bc7-44f6-bee6-d8857c89e185
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /progress/977bc75e-f654-4600-ad1c-698050676a00
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0c562a3c-2f19-425b-9d99-be2fc4d86ba9
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][progress_step] | Progress step |
| data[attributes][target] | Target |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /progress/0dd4fb56-2039-49ef-b049-1a83e26471c3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 78cd7a2e-0115-4709-928d-7eca85774f4b
429 Too Many Requests
```


```json
This action has been rate limited
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
          "id": "0b388e5c-5ad5-46de-b9e1-ca8902f1f93a"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "3664ea6a-7512-4e68-9a3c-428e81254b19"
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
X-Request-Id: 40da2799-df1d-4608-bdff-3ec7eea42c6d
201 Created
```


```json
{
  "data": {
    "id": "c0783425-a709-48bf-ac9c-50b4c7ed296a",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "0b388e5c-5ad5-46de-b9e1-ca8902f1f93a",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/0b388e5c-5ad5-46de-b9e1-ca8902f1f93a"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/3664ea6a-7512-4e68-9a3c-428e81254b19"
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


## blocks too many calls


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
          "id": "b107cd17-7425-413a-a7c1-31e7ef85b4d7"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "87f47383-2a9e-4c11-9556-de3b306e92fb"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: b8d7aa69-1874-4d49-8b21-d953061bf8f7
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: b7e76299-b34d-4e38-9cc3-8e897ae75be1
200 OK
```


```json
{
  "data": [
    {
      "id": "54e8b159-f050-49e6-a4fb-e0c2d35a3160",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "e41f61cb-369e-4cad-9944-0db915a86b27"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/e41f61cb-369e-4cad-9944-0db915a86b27"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: c61da6a3-6fd5-4438-8414-ebafbf0037e8
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /projects/171f00e2-c59c-4429-b8e3-c1d736cb04e3/relationships/project_setting
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
X-Request-Id: 74888363-fb5f-49fb-a762-90ce661954d4
200 OK
```


```json
{
  "data": {
    "id": "f4047cf1-f217-4d5e-ac7b-c3668a49c71b",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "171f00e2-c59c-4429-b8e3-c1d736cb04e3"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/171f00e2-c59c-4429-b8e3-c1d736cb04e3"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/171f00e2-c59c-4429-b8e3-c1d736cb04e3/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /projects/28f0b601-bada-4e7d-a272-a6ecb2b5605d/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:project_id/relationships/project_setting`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 6b204274-bde2-46f6-b053-33f00499a76c
429 Too Many Requests
```


```json
This action has been rate limited
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
PATCH /projects/71ca1496-e2f0-4a88-b583-20d3189658d8/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "71ca1496-e2f0-4a88-b583-20d3189658d8",
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
X-Request-Id: 7edd2ca1-9fe7-4a3b-affd-214fa97cac09
200 OK
```


```json
{
  "data": {
    "id": "b31e17c1-2ce5-4a8a-9f88-7007bedd5437",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "71ca1496-e2f0-4a88-b583-20d3189658d8"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/71ca1496-e2f0-4a88-b583-20d3189658d8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/71ca1496-e2f0-4a88-b583-20d3189658d8/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


## blocks too many calls


### Request

#### Endpoint

```plaintext
PATCH /projects/4fe62e35-4f35-49b4-b64d-d31839f04759/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "4fe62e35-4f35-49b4-b64d-d31839f04759",
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
Content-Type: text/plain
X-Request-Id: 023f9cea-49b7-4bb9-b686-cd2a9181f60c
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: cfe910f0-0c72-4e25-94de-8340af8b2f89
200 OK
```


```json
{
  "data": [
    {
      "id": "c9ce63f7-4e79-439d-9e92-f6a0f73d9674",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/c9ce63f7-4e79-439d-9e92-f6a0f73d9674"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/c9ce63f7-4e79-439d-9e92-f6a0f73d9674"
          }
        }
      }
    },
    {
      "id": "0af7f327-852e-44c7-9c50-07b728b0007a",
      "type": "system_element",
      "attributes": {
        "name": "ObjectOccurrence d7c7236c9c0f-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/0af7f327-852e-44c7-9c50-07b728b0007a"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/0af7f327-852e-44c7-9c50-07b728b0007a"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: c0bd97d7-a4cc-4785-ac70-3ed478ecf368
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /system_elements/bd477645-bcb4-4885-9fb6-d91ba91dff52
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
X-Request-Id: 6534b4ee-3168-4084-8cf2-585973d1dfa5
200 OK
```


```json
{
  "data": {
    "id": "bd477645-bcb4-4885-9fb6-d91ba91dff52",
    "type": "system_element",
    "attributes": {
      "name": "ObjectOccurrence a6603857a32d-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/bd477645-bcb4-4885-9fb6-d91ba91dff52"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/bd477645-bcb4-4885-9fb6-d91ba91dff52"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/bd477645-bcb4-4885-9fb6-d91ba91dff52"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /system_elements/ed9f4f3b-b7d9-4ada-a1ca-54fffba8e424
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 04b01040-a860-4896-85fe-22c6ebb8a1b4
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /object_occurrences/167be623-7982-4042-9029-1c4f3455a859/relationships/system_elements
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
      "target_id": "38464265-3b92-450e-a464-bd6ea6c1f66d"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8accc964-a4ec-4f1b-aa70-e5c146ec6dda
201 Created
```


```json
{
  "data": {
    "id": "f1b1ff2c-8aa4-4503-bd0f-36a2b5ad0663",
    "type": "system_element",
    "attributes": {
      "name": "ObjectOccurrence 4a8c319af6da-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/f1b1ff2c-8aa4-4503-bd0f-36a2b5ad0663"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/f1b1ff2c-8aa4-4503-bd0f-36a2b5ad0663"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/167be623-7982-4042-9029-1c4f3455a859/relationships/system_elements"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


## blocks too many calls


### Request

#### Endpoint

```plaintext
POST /object_occurrences/7cd884b4-2c13-4075-96f2-ff8ee0be27e0/relationships/system_elements
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
      "target_id": "fca6a7d4-66bc-4f17-98ac-2942a5880fae"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 9765146f-2e40-48ad-9fcc-63649855a1b6
429 Too Many Requests
```


```json
This action has been rate limited
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
DELETE /object_occurrences/90a1adac-5cf4-4d41-ac39-42ddbf739550/relationships/system_elements/48cd889c-4cf7-4790-ae27-e767dde909d9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f12fe659-4e69-4e5f-a386-3328964a6c30
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/2ae194bb-de90-4592-bca8-72b9d2d642cb/relationships/system_elements/656e4261-9ed0-4d40-b488-3379c52643e1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: b598ee29-4244-43ec-9ed5-6489bd0cee9b
429 Too Many Requests
```


```json
This action has been rate limited
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
POST /object_occurrence_relations/e98d209a-31b5-463c-a2c0-34d97448e78e/relationships/owners
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
X-Request-Id: 3ba741e8-5eff-4a60-8c1b-0f6d2dedb060
201 Created
```


```json
{
  "data": {
    "id": "952c17d0-9d16-4d57-aa4b-75e52b785854",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/e98d209a-31b5-463c-a2c0-34d97448e78e/relationships/owners"
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
POST /object_occurrence_relations/aa1ea7fa-8808-4b9a-b355-820006e74f0a/relationships/owners
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
X-Request-Id: 7c496fe0-bd26-43ca-a154-3524f1748679
201 Created
```


```json
{
  "data": {
    "id": "72aa50d2-aa33-49e2-bf3a-7a3cb732ae9b",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/aa1ea7fa-8808-4b9a-b355-820006e74f0a/relationships/owners"
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
POST /object_occurrence_relations/b7cab31a-03ff-4b63-bc7d-acb7303ae259/relationships/owners
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
    "id": "2c9a4829-e1bc-4aeb-ae33-27d95290c633"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c43fb021-1291-4486-a28f-cddc0502d216
201 Created
```


```json
{
  "data": {
    "id": "2c9a4829-e1bc-4aeb-ae33-27d95290c633",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 28",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/b7cab31a-03ff-4b63-bc7d-acb7303ae259/relationships/owners"
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
DELETE /object_occurrence_relations/f894901b-96fe-4779-9cdc-5a6e8c9e51b8/relationships/owners/4a44fc4b-f179-42e1-bfed-94d947350954
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6e6905a3-aaf0-4756-afe0-6ef34395a4ca
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
X-Request-Id: af9b7626-c95e-4f82-b30c-fdddf6f4577d
200 OK
```


```json
{
  "data": [
    {
      "id": "a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation ccc750fa6b5f",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "d965fffb-aeb3-4741-8c92-0c93152aa859",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64",
            "self": "/object_occurrence_relations/a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "c1085c16-a434-4f4b-84e6-6109dc7ef3d6",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "14bd6bd9-21a3-454c-bd4d-c35fb38b36c6",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64"
          }
        },
        "classification_entry": {
          "data": {
            "id": "b269f613-101b-4ed6-8765-a70750920eef",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b269f613-101b-4ed6-8765-a70750920eef",
            "self": "/object_occurrence_relations/a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "4c8042f9-5f44-40db-97b5-48cf37f5e55b",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/4c8042f9-5f44-40db-97b5-48cf37f5e55b",
            "self": "/object_occurrence_relations/a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "63b6a48f-57a9-4c74-9057-cc1dcd233ef7",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/63b6a48f-57a9-4c74-9057-cc1dcd233ef7",
            "self": "/object_occurrence_relations/a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "b269f613-101b-4ed6-8765-a70750920eef",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 3f84f9d61b38",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=b269f613-101b-4ed6-8765-a70750920eef",
            "self": "/classification_entries/b269f613-101b-4ed6-8765-a70750920eef/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=b269f613-101b-4ed6-8765-a70750920eef",
            "self": "/classification_entries/b269f613-101b-4ed6-8765-a70750920eef/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "c1085c16-a434-4f4b-84e6-6109dc7ef3d6",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 31",
        "title": null
      }
    },
    {
      "id": "14bd6bd9-21a3-454c-bd4d-c35fb38b36c6",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "c9fe791c-3fb0-4320-9643-a8a4ecd149ad",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/c9fe791c-3fb0-4320-9643-a8a4ecd149ad"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/a74b5fc2-a9f8-4bec-81c4-f6ff21c8ab64"
          }
        }
      }
    },
    {
      "id": "d965fffb-aeb3-4741-8c92-0c93152aa859",
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



## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 88b851b6-eb7f-40b9-a023-37c349a57b42
429 Too Many Requests
```


```json
This action has been rate limited
```



## Filter by object_occurrence_source_ids_cont and object_occurrence_target_ids_cont


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=6d173e27-4e45-43f3-905a-6119a7d44a28&amp;filter[object_occurrence_source_ids_cont][]=3f001f93-cf46-44c8-9e07-a12a22da0909&amp;filter[object_occurrence_target_ids_cont][]=733e8f08-99fe-4861-8a72-028d9040b355
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;6d173e27-4e45-43f3-905a-6119a7d44a28&quot;, &quot;3f001f93-cf46-44c8-9e07-a12a22da0909&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;733e8f08-99fe-4861-8a72-028d9040b355&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 82a64f8b-a1a0-42cf-9f87-24b5dc4a34d4
200 OK
```


```json
{
  "data": [
    {
      "id": "bdb9931a-29c0-432c-a47f-07cedf517423",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation 28af05b9c23b",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "79e2d7d8-e7a2-402a-a21c-0a20377a9f76",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=bdb9931a-29c0-432c-a47f-07cedf517423",
            "self": "/object_occurrence_relations/bdb9931a-29c0-432c-a47f-07cedf517423/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "f4a3473a-55c1-4807-b0e1-f48b8685f125",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=bdb9931a-29c0-432c-a47f-07cedf517423&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/bdb9931a-29c0-432c-a47f-07cedf517423/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "a4c6f12e-1e80-42d6-a184-12be1af9a30e",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=bdb9931a-29c0-432c-a47f-07cedf517423"
          }
        },
        "classification_entry": {
          "data": {
            "id": "31dd448c-c14a-481c-9cbd-219e63099562",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/31dd448c-c14a-481c-9cbd-219e63099562",
            "self": "/object_occurrence_relations/bdb9931a-29c0-432c-a47f-07cedf517423/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "733e8f08-99fe-4861-8a72-028d9040b355",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/733e8f08-99fe-4861-8a72-028d9040b355",
            "self": "/object_occurrence_relations/bdb9931a-29c0-432c-a47f-07cedf517423/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "6d173e27-4e45-43f3-905a-6119a7d44a28",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6d173e27-4e45-43f3-905a-6119a7d44a28",
            "self": "/object_occurrence_relations/bdb9931a-29c0-432c-a47f-07cedf517423/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "31dd448c-c14a-481c-9cbd-219e63099562",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm dedc92e860f8",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=31dd448c-c14a-481c-9cbd-219e63099562",
            "self": "/classification_entries/31dd448c-c14a-481c-9cbd-219e63099562/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=31dd448c-c14a-481c-9cbd-219e63099562",
            "self": "/classification_entries/31dd448c-c14a-481c-9cbd-219e63099562/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "f4a3473a-55c1-4807-b0e1-f48b8685f125",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 33",
        "title": null
      }
    },
    {
      "id": "a4c6f12e-1e80-42d6-a184-12be1af9a30e",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "547ca405-a800-4525-9022-87342719829a",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/547ca405-a800-4525-9022-87342719829a"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/bdb9931a-29c0-432c-a47f-07cedf517423"
          }
        }
      }
    },
    {
      "id": "79e2d7d8-e7a2-402a-a21c-0a20377a9f76",
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
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=6d173e27-4e45-43f3-905a-6119a7d44a28&filter[object_occurrence_source_ids_cont][]=3f001f93-cf46-44c8-9e07-a12a22da0909&filter[object_occurrence_target_ids_cont][]=733e8f08-99fe-4861-8a72-028d9040b355",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=6d173e27-4e45-43f3-905a-6119a7d44a28&filter[object_occurrence_source_ids_cont][]=3f001f93-cf46-44c8-9e07-a12a22da0909&filter[object_occurrence_target_ids_cont][]=733e8f08-99fe-4861-8a72-028d9040b355&include=tags,owners,progress_step_checked,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=69d82b39-ac55-4894-9e15-f20bdc53ec27&amp;filter[object_occurrence_source_ids_cont][]=f7d9909f-19f6-4937-9313-19695ae1484d&amp;filter[object_occurrence_target_ids_cont][]=ac6e0a2f-b259-4fc8-91ea-1d7335fe875a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;69d82b39-ac55-4894-9e15-f20bdc53ec27&quot;, &quot;f7d9909f-19f6-4937-9313-19695ae1484d&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;ac6e0a2f-b259-4fc8-91ea-1d7335fe875a&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: text/plain
X-Request-Id: ab82568e-69df-4438-97b6-f7e2fdb70f6a
429 Too Many Requests
```


```json
This action has been rate limited
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6
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
X-Request-Id: 87c837d1-99b3-4352-af86-7caae3350650
200 OK
```


```json
{
  "data": {
    "id": "bda55ccd-e96e-4128-b715-b1d58976bca6",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "ObjectOccurrenceRelation 22c0514a58ef",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "b104b027-1eff-47f9-8f96-0bb46bf1fcb5",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=bda55ccd-e96e-4128-b715-b1d58976bca6",
          "self": "/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "e4333f2c-c04a-4475-8909-ccf599e855ea",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=bda55ccd-e96e-4128-b715-b1d58976bca6&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "ffb9c317-7225-4ed8-aa41-64b8dee08504",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=bda55ccd-e96e-4128-b715-b1d58976bca6"
        }
      },
      "classification_entry": {
        "data": {
          "id": "eda862d5-ab9b-4a28-a6f8-25ee66bbc40c",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/eda862d5-ab9b-4a28-a6f8-25ee66bbc40c",
          "self": "/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "36743b0a-e58b-4f05-b9e0-eeac201bd9e1",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/36743b0a-e58b-4f05-b9e0-eeac201bd9e1",
          "self": "/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "713d7f95-c468-4314-a413-1d6cb06b6e85",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/713d7f95-c468-4314-a413-1d6cb06b6e85",
          "self": "/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6"
  },
  "included": [
    {
      "id": "eda862d5-ab9b-4a28-a6f8-25ee66bbc40c",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 8352d78f5885",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=eda862d5-ab9b-4a28-a6f8-25ee66bbc40c",
            "self": "/classification_entries/eda862d5-ab9b-4a28-a6f8-25ee66bbc40c/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=eda862d5-ab9b-4a28-a6f8-25ee66bbc40c",
            "self": "/classification_entries/eda862d5-ab9b-4a28-a6f8-25ee66bbc40c/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "e4333f2c-c04a-4475-8909-ccf599e855ea",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 35",
        "title": null
      }
    },
    {
      "id": "ffb9c317-7225-4ed8-aa41-64b8dee08504",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "cd841635-451e-4718-815d-7e6731b6791d",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/cd841635-451e-4718-815d-7e6731b6791d"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/bda55ccd-e96e-4128-b715-b1d58976bca6"
          }
        }
      }
    },
    {
      "id": "b104b027-1eff-47f9-8f96-0bb46bf1fcb5",
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



## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/ab1518ef-a45c-4df4-a7ad-14265961e0b0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 7ea5858f-770d-446a-abf2-d0360d82c13e
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 5d7ade25-dd69-4c8d-a31e-5550bb5331d2
200 OK
```


```json
{
  "data": [
    {
      "id": "65464765f7e8f2135c43b5e517af01ad63cf3db1619e9ebf6046101b0d01283c",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "cae7aa5a-b471-4fd1-a35d-25c6380ba071",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/cae7aa5a-b471-4fd1-a35d-25c6380ba071"
          }
        }
      }
    },
    {
      "id": "4c7069b2e8f1cb33bf8ba7b58270b4c04b32f203f99df5157d109dba5d12da54",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "1ce1dbfb-c284-471e-95d0-1af9f0b47e03",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/1ce1dbfb-c284-471e-95d0-1af9f0b47e03"
          }
        }
      }
    },
    {
      "id": "f97bb0c62978a88096aa4d8461737ea01e0e3827cdae135e34772cf5129b7373",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "afb34443-3190-4b80-97e1-fffa495ca632",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/afb34443-3190-4b80-97e1-fffa495ca632"
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



## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: d302e78c-9261-4602-95f6-5db58d66e9f9
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 403cf7d8-a1ac-4c54-ba01-c851f66bfb80
200 OK
```


```json
{
  "data": [
    {
      "id": "52a1485f-5dd8-49b6-ad9f-5b576106b405",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "bad26209-0a84-4126-b0d6-25a16ed84223",
            "type": "project"
          },
          "links": {
            "related": "/projects/bad26209-0a84-4126-b0d6-25a16ed84223"
          }
        },
        "user": {
          "data": {
            "id": "d9f77614-f4c1-4d70-b32a-1d7a9fb2cb0d",
            "type": "user"
          },
          "links": {
            "related": "/users/d9f77614-f4c1-4d70-b32a-1d7a9fb2cb0d"
          }
        },
        "permission": {
          "data": {
            "id": "11c4dfc2-9ce4-4f4f-889d-4630dd6aa079",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/11c4dfc2-9ce4-4f4f-889d-4630dd6aa079"
          }
        }
      }
    },
    {
      "id": "d34a2036-4d8d-4d4c-ad88-9d23602b8ab0",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "e1147ada-ffa1-402e-80af-86473351ae6e",
            "type": "context"
          },
          "links": {
            "related": "/contexts/e1147ada-ffa1-402e-80af-86473351ae6e"
          }
        },
        "user": {
          "data": {
            "id": "d9f77614-f4c1-4d70-b32a-1d7a9fb2cb0d",
            "type": "user"
          },
          "links": {
            "related": "/users/d9f77614-f4c1-4d70-b32a-1d7a9fb2cb0d"
          }
        },
        "permission": {
          "data": {
            "id": "6451c451-81a4-48ad-83ba-c7f523a0bb45",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/6451c451-81a4-48ad-83ba-c7f523a0bb45"
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



## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 9f0d8a99-1402-471d-a45d-377b0e4ec501
429 Too Many Requests
```


```json
This action has been rate limited
```



## Filter


### Request

#### Endpoint

```plaintext
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=f860d6ee-cd4f-4e0b-b3b5-242b2f5b9162&amp;filter[user_id_eq]=f2399c79-edde-449b-aa18-b0ff93fec84b&amp;filter[permission_id_eq]=4ced49b4-b595-43ee-9378-18be2290f1de
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;f860d6ee-cd4f-4e0b-b3b5-242b2f5b9162&quot;, &quot;user_id_eq&quot;=&gt;&quot;f2399c79-edde-449b-aa18-b0ff93fec84b&quot;, &quot;permission_id_eq&quot;=&gt;&quot;4ced49b4-b595-43ee-9378-18be2290f1de&quot;}
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
X-Request-Id: 226af4a9-b056-4aa7-90bf-93b53be2d23b
200 OK
```


```json
{
  "data": [
    {
      "id": "1988cf70-afb0-4ca6-85ad-9249543d0111",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "f860d6ee-cd4f-4e0b-b3b5-242b2f5b9162",
            "type": "project"
          },
          "links": {
            "related": "/projects/f860d6ee-cd4f-4e0b-b3b5-242b2f5b9162"
          }
        },
        "user": {
          "data": {
            "id": "f2399c79-edde-449b-aa18-b0ff93fec84b",
            "type": "user"
          },
          "links": {
            "related": "/users/f2399c79-edde-449b-aa18-b0ff93fec84b"
          }
        },
        "permission": {
          "data": {
            "id": "4ced49b4-b595-43ee-9378-18be2290f1de",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/4ced49b4-b595-43ee-9378-18be2290f1de"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/user_permissions?filter[target_type_eq]=project&filter[target_id_eq]=f860d6ee-cd4f-4e0b-b3b5-242b2f5b9162&filter[user_id_eq]=f2399c79-edde-449b-aa18-b0ff93fec84b&filter[permission_id_eq]=4ced49b4-b595-43ee-9378-18be2290f1de",
    "current": "http://example.org/user_permissions?filter[permission_id_eq]=4ced49b4-b595-43ee-9378-18be2290f1de&filter[target_id_eq]=f860d6ee-cd4f-4e0b-b3b5-242b2f5b9162&filter[target_type_eq]=project&filter[user_id_eq]=f2399c79-edde-449b-aa18-b0ff93fec84b&page[number]=1"
  }
}
```



## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=26fe0d00-62be-48de-b752-43be50821b6e&amp;filter[user_id_eq]=7e4fd9cb-c57f-4deb-bbc1-65b232716b69&amp;filter[permission_id_eq]=e56570c6-f22f-4d37-9487-f36e12f6004c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;26fe0d00-62be-48de-b752-43be50821b6e&quot;, &quot;user_id_eq&quot;=&gt;&quot;7e4fd9cb-c57f-4deb-bbc1-65b232716b69&quot;, &quot;permission_id_eq&quot;=&gt;&quot;e56570c6-f22f-4d37-9487-f36e12f6004c&quot;}
```


| Name | Description |
|:-----|:------------|
| filter[target_type_eq]  | Filter target type eq |
| filter[target_id_eq]  | Filter target id eq |
| filter[user_id_eq]  | Filter user id eq |
| filter[permission_id_eq]  | Filter permission id eq |



### Response

```plaintext
Content-Type: text/plain
X-Request-Id: bc0896a0-f79e-4eda-83b6-f784dfe738b5
429 Too Many Requests
```


```json
This action has been rate limited
```



## Show


### Request

#### Endpoint

```plaintext
GET /user_permissions/192c4b3f-da92-4df7-9279-7d78356d6e59
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
X-Request-Id: 59154f46-9262-4477-a95e-3dc26e329d56
200 OK
```


```json
{
  "data": {
    "id": "192c4b3f-da92-4df7-9279-7d78356d6e59",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "7fcb44c5-5578-413e-87a6-dd86ad9635ee",
          "type": "project"
        },
        "links": {
          "related": "/projects/7fcb44c5-5578-413e-87a6-dd86ad9635ee"
        }
      },
      "user": {
        "data": {
          "id": "15acb578-5e5e-4e0e-817c-2aac6b12dbd1",
          "type": "user"
        },
        "links": {
          "related": "/users/15acb578-5e5e-4e0e-817c-2aac6b12dbd1"
        }
      },
      "permission": {
        "data": {
          "id": "4c20c76e-a74d-4251-96a1-3821c1cdd11e",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/4c20c76e-a74d-4251-96a1-3821c1cdd11e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions/192c4b3f-da92-4df7-9279-7d78356d6e59"
  }
}
```



## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /user_permissions/89dc030b-bb5b-48f1-866e-32bca1effe43
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: e1949db7-f10f-41e1-86f1-e6bf48738b17
429 Too Many Requests
```


```json
This action has been rate limited
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
          "id": "4f67e5ca-cb59-4e2a-941d-2c5611bf36e5"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "0c6e468c-949b-4a3b-96e8-8d7f8780ad08"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "0b0d37d2-3f75-41ce-9a9c-c462f907f572"
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
X-Request-Id: 36a76e15-fb83-4872-816a-af10fdcb3af2
201 Created
```


```json
{
  "data": {
    "id": "ec6f0053-a70c-442d-a2fa-8f96e3cf624d",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "4f67e5ca-cb59-4e2a-941d-2c5611bf36e5",
          "type": "project"
        },
        "links": {
          "related": "/projects/4f67e5ca-cb59-4e2a-941d-2c5611bf36e5"
        }
      },
      "user": {
        "data": {
          "id": "0b0d37d2-3f75-41ce-9a9c-c462f907f572",
          "type": "user"
        },
        "links": {
          "related": "/users/0b0d37d2-3f75-41ce-9a9c-c462f907f572"
        }
      },
      "permission": {
        "data": {
          "id": "0c6e468c-949b-4a3b-96e8-8d7f8780ad08",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/0c6e468c-949b-4a3b-96e8-8d7f8780ad08"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions"
  }
}
```



## blocks too many calls


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
          "id": "2ae9c77b-480d-401e-b619-cc34239554c8"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "cf24651b-7671-4453-a503-a9bf63ea2f4b"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "5d0671f5-a14a-4847-bacf-b1973820572e"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 6f88d308-68ee-42c3-b67a-b43910ff7265
429 Too Many Requests
```


```json
This action has been rate limited
```



## Remove permission


### Request

#### Endpoint

```plaintext
DELETE /user_permissions/841a6fc4-75cd-413c-8645-e36a8b77bcd8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d227c3f8-bec0-4e3c-9017-2805f9bd7563
204 No Content
```




## blocks too many calls


### Request

#### Endpoint

```plaintext
DELETE /user_permissions/98001522-e93b-4177-b5d0-24d5108a0821
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: 376aeea4-399b-4d80-affb-97adc54bee9d
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 3a2c69de-6268-4e7a-81ee-ac761fe3718d
200 OK
```


```json
{
  "data": {
    "id": "67fb81c2-2cb7-4d53-8fdc-48c0383e87e7",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "b2416186-0ccb-43f9-8233-c4e731e62440"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/b2416186-0ccb-43f9-8233-c4e731e62440"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: a26d1499-ec8d-478a-95a4-68e0abf5d553
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 2cdfa9e9-9135-48dc-ab16-b17e6c71fd8f
200 OK
```


```json
{
  "data": {
    "id": "b0a00c75-e453-4e44-88c0-191d48b15d67",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "cb32dca2-aca8-451e-98c0-6084dee0f3e4"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/cb32dca2-aca8-451e-98c0-6084dee0f3e4"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 6a351de8-fa79-468a-aebe-71f73714f123
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /chain_analysis/ea09bff1-114a-4049-866e-1bec6ddf754b?steps=2
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
X-Request-Id: 14ffa779-8e54-46c3-841e-981648c2f652
200 OK
```


```json
{
  "data": [
    {
      "id": "6435506d-a374-47f6-b71d-bc7dfa54b9f2",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
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

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=6435506d-a374-47f6-b71d-bc7dfa54b9f2",
            "self": "/object_occurrences/6435506d-a374-47f6-b71d-bc7dfa54b9f2/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=6435506d-a374-47f6-b71d-bc7dfa54b9f2&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/6435506d-a374-47f6-b71d-bc7dfa54b9f2/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=6435506d-a374-47f6-b71d-bc7dfa54b9f2"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e15c373f-67ef-4558-a114-b9e920ec2d54"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/302a31fe-adb3-4a6f-bb47-394f5f4c11c0",
            "self": "/object_occurrences/6435506d-a374-47f6-b71d-bc7dfa54b9f2/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/6435506d-a374-47f6-b71d-bc7dfa54b9f2/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=6435506d-a374-47f6-b71d-bc7dfa54b9f2"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=6435506d-a374-47f6-b71d-bc7dfa54b9f2"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=6435506d-a374-47f6-b71d-bc7dfa54b9f2"
          }
        }
      }
    },
    {
      "id": "b08ca78b-e15f-4e91-bbe2-8e93a923569a",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
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

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=b08ca78b-e15f-4e91-bbe2-8e93a923569a",
            "self": "/object_occurrences/b08ca78b-e15f-4e91-bbe2-8e93a923569a/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=b08ca78b-e15f-4e91-bbe2-8e93a923569a&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/b08ca78b-e15f-4e91-bbe2-8e93a923569a/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=b08ca78b-e15f-4e91-bbe2-8e93a923569a"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e15c373f-67ef-4558-a114-b9e920ec2d54"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/302a31fe-adb3-4a6f-bb47-394f5f4c11c0",
            "self": "/object_occurrences/b08ca78b-e15f-4e91-bbe2-8e93a923569a/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/b08ca78b-e15f-4e91-bbe2-8e93a923569a/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b08ca78b-e15f-4e91-bbe2-8e93a923569a"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b08ca78b-e15f-4e91-bbe2-8e93a923569a"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b08ca78b-e15f-4e91-bbe2-8e93a923569a"
          }
        }
      }
    },
    {
      "id": "78b3a8fc-79b0-41aa-9807-17533862d8a0",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
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

        ]
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=78b3a8fc-79b0-41aa-9807-17533862d8a0",
            "self": "/object_occurrences/78b3a8fc-79b0-41aa-9807-17533862d8a0/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=78b3a8fc-79b0-41aa-9807-17533862d8a0&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/78b3a8fc-79b0-41aa-9807-17533862d8a0/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=78b3a8fc-79b0-41aa-9807-17533862d8a0"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e15c373f-67ef-4558-a114-b9e920ec2d54"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/302a31fe-adb3-4a6f-bb47-394f5f4c11c0",
            "self": "/object_occurrences/78b3a8fc-79b0-41aa-9807-17533862d8a0/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/78b3a8fc-79b0-41aa-9807-17533862d8a0/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=78b3a8fc-79b0-41aa-9807-17533862d8a0"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=78b3a8fc-79b0-41aa-9807-17533862d8a0"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=78b3a8fc-79b0-41aa-9807-17533862d8a0"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/chain_analysis/ea09bff1-114a-4049-866e-1bec6ddf754b?steps=2",
    "current": "http://example.org/chain_analysis/ea09bff1-114a-4049-866e-1bec6ddf754b?page[number]=1&steps=2"
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


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /chain_analysis/4f80f1b4-9d8a-4e62-8afe-f20ec01b1151?steps=2
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
Content-Type: text/plain
X-Request-Id: 87f8a201-25d2-46cf-a8a6-10a716f2709b
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: d25bc682-ba30-4d48-9bfc-c22a59a4f3de
200 OK
```


```json
{
  "data": {
    "id": "directory/1234abcde.png",
    "type": "url_struct",
    "attributes": {
      "id": "directory/1234abcde.png",
      "url": "https://qa-sec-hub-document-bucket.s3.eu-west-1.amazonaws.com/directory/1234abcde.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20200510%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20200510T124332Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=a7697a6cfd4c2dd1eb45095c522a7acf313001b09c253c7ab3d112874d2dca40",
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 2dedfb9f-27b0-4a6e-9945-b2ae7a69d65d
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 39187ef0-f0a9-4dba-bbd9-2766d40195ef
200 OK
```


```json
{
  "data": [
    {
      "id": "6549e6bf-18a8-41de-bcea-8981b1072f31",
      "type": "tag",
      "attributes": {
        "value": "tag value 39"
      },
      "relationships": {
      }
    },
    {
      "id": "cc57118a-65f8-4215-8506-7ab0518a3c99",
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 1368f44d-18a8-41fb-a41c-9c1345b2b5e8
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 576e7e23-912c-4d3e-8025-3b85584ef313
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 08385e5e-8d74-494b-8556-8595396dac08
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /permissions/aae656d1-ccb6-4d3f-a7d3-4d1e623311f9
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
X-Request-Id: ba7cf698-ce1a-4261-9e10-3aed35c35223
200 OK
```


```json
{
  "data": {
    "id": "aae656d1-ccb6-4d3f-a7d3-4d1e623311f9",
    "type": "permission",
    "attributes": {
      "name": "account:write",
      "description": "MyText"
    }
  },
  "links": {
    "self": "http://example.org/permissions/aae656d1-ccb6-4d3f-a7d3-4d1e623311f9"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Permission name |
| data[attributes][description] | Permission description |


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /permissions/4438a9d9-72aa-499b-af92-04279fe96b81
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /permissions/:id`

#### Parameters


None known.


### Response

```plaintext
Content-Type: text/plain
X-Request-Id: f5ad12ba-6e54-468d-9873-82fbcbfd84de
429 Too Many Requests
```


```json
This action has been rate limited
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
GET /utils/path/from/object_occurrence/a5a4581b-4541-4ad0-acf9-f0bdc23898b6/to/object_occurrence/0a9fe140-6cf9-4c70-9222-7fbf5da83779
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
X-Request-Id: e46604ad-d4e5-455e-938b-b4e52c68471b
200 OK
```


```json
[
  {
    "id": "a5a4581b-4541-4ad0-acf9-f0bdc23898b6",
    "type": "object_occurrence"
  },
  {
    "id": "d8d4bcc4-7109-47a1-a222-9543cf75afe8",
    "type": "object_occurrence"
  },
  {
    "id": "eaba7d69-657f-41eb-a44c-0933bb1cb2b1",
    "type": "object_occurrence"
  },
  {
    "id": "13c49a45-abdf-4265-ad5a-eb88d25987e1",
    "type": "object_occurrence"
  },
  {
    "id": "365f7253-3b87-4edc-a1f2-0444f8e7599e",
    "type": "object_occurrence"
  },
  {
    "id": "374d1641-f4c5-4a81-aeea-cce703a751cd",
    "type": "object_occurrence"
  },
  {
    "id": "0a9fe140-6cf9-4c70-9222-7fbf5da83779",
    "type": "object_occurrence"
  }
]
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][event] | Event name |


## blocks too many calls


### Request

#### Endpoint

```plaintext
GET /utils/path/from/object_occurrence/33824e15-7ee1-4576-b270-6fa5e40fd7ea/to/object_occurrence/40e603bf-e600-4f5d-b41a-a0cad04dd483
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
Content-Type: text/plain
X-Request-Id: d89288fa-2262-43db-8ded-215878ac126f
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 8b87923a-572b-40ee-b785-684d2dd1d511
200 OK
```


```json
{
  "data": [
    {
      "id": "a325aa3e-de7b-4ef4-beaa-2e8a9a40161f",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/081290e2-cb14-4876-af11-58d1fda373f1"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/4f81c190-ff81-457e-aa25-a65dbbb45474"
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


## blocks too many calls


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
Content-Type: text/plain
X-Request-Id: 2615a6d7-1745-461c-994c-4fc33668a816
429 Too Many Requests
```


```json
This action has been rate limited
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
X-Request-Id: 59fafc8d-8c69-40a2-87d3-18b9ffc14f6e
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



