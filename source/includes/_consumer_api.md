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
X-Request-Id: deadb535-9755-4e27-bb12-11fa89a4b82f
200 OK
```


```json
{
  "data": {
    "id": "9d6caeea-1447-4233-b0f1-58cc077eb666",
    "type": "account",
    "attributes": {
      "name": "Account 0b4d8c64c578"
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
X-Request-Id: dc3e3b83-2217-425a-a361-1822465df389
200 OK
```


```json
{
  "data": {
    "id": "6e6d012a-324a-4628-b01d-ac5578b42d0b",
    "type": "account",
    "attributes": {
      "name": "Account 80d36703f519"
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
    "id": "4f4f3e54-9617-4e18-ac52-dcb3a30e90e5",
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
X-Request-Id: 37092659-5688-44ea-ad1a-51ba0126e07b
200 OK
```


```json
{
  "data": {
    "id": "4f4f3e54-9617-4e18-ac52-dcb3a30e90e5",
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
X-Request-Id: 54181b46-7c68-487f-b461-83d31b5a3931
200 OK
```


```json
{
  "data": [
    {
      "id": "8bbd7dc7-b0ad-46af-acbe-a86e9b3ad20a",
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
              "id": "0e00b3de-63c8-4059-85c9-a5626b6f49c5",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=8bbd7dc7-b0ad-46af-acbe-a86e9b3ad20a"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=8bbd7dc7-b0ad-46af-acbe-a86e9b3ad20a",
            "self": "/projects/8bbd7dc7-b0ad-46af-acbe-a86e9b3ad20a/relationships/contexts"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "0e00b3de-63c8-4059-85c9-a5626b6f49c5",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "c93d1ded-be5c-4598-8529-a9f17a764a0f",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/c93d1ded-be5c-4598-8529-a9f17a764a0f"
          }
        },
        "target": {
          "links": {
            "related": "/projects/8bbd7dc7-b0ad-46af-acbe-a86e9b3ad20a"
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
GET /projects/278a50ea-5dd9-4526-8d0a-4cdf24d07d5b
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
X-Request-Id: 24bb7d3a-288e-4a9c-a4c4-09be52d9cf18
200 OK
```


```json
{
  "data": {
    "id": "278a50ea-5dd9-4526-8d0a-4cdf24d07d5b",
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
            "id": "a00eaa43-daaa-40db-bb60-b72f904b19ed",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=278a50ea-5dd9-4526-8d0a-4cdf24d07d5b"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=278a50ea-5dd9-4526-8d0a-4cdf24d07d5b",
          "self": "/projects/278a50ea-5dd9-4526-8d0a-4cdf24d07d5b/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/278a50ea-5dd9-4526-8d0a-4cdf24d07d5b"
  },
  "included": [
    {
      "id": "a00eaa43-daaa-40db-bb60-b72f904b19ed",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "32537a63-fa13-435c-8462-58397b7f37c3",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/32537a63-fa13-435c-8462-58397b7f37c3"
          }
        },
        "target": {
          "links": {
            "related": "/projects/278a50ea-5dd9-4526-8d0a-4cdf24d07d5b"
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
PATCH /projects/97c1de7f-c682-460f-bf4a-8b0f47aea31c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "97c1de7f-c682-460f-bf4a-8b0f47aea31c",
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
X-Request-Id: 37e62981-d3b3-4485-8c62-c9826f8696db
200 OK
```


```json
{
  "data": {
    "id": "97c1de7f-c682-460f-bf4a-8b0f47aea31c",
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
            "id": "a4068280-03c0-4b92-ad02-bcf4e4d1b8d8",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=97c1de7f-c682-460f-bf4a-8b0f47aea31c"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=97c1de7f-c682-460f-bf4a-8b0f47aea31c",
          "self": "/projects/97c1de7f-c682-460f-bf4a-8b0f47aea31c/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/97c1de7f-c682-460f-bf4a-8b0f47aea31c"
  },
  "included": [
    {
      "id": "a4068280-03c0-4b92-ad02-bcf4e4d1b8d8",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "5342c002-94da-4403-803b-3b36df588ff4",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/5342c002-94da-4403-803b-3b36df588ff4"
          }
        },
        "target": {
          "links": {
            "related": "/projects/97c1de7f-c682-460f-bf4a-8b0f47aea31c"
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
POST /projects/49515347-e624-415e-b5fd-8f35c1db3258/archive
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
X-Request-Id: f11ee92d-34dd-4210-9f33-dba7cb06097e
200 OK
```


```json
{
  "data": {
    "id": "49515347-e624-415e-b5fd-8f35c1db3258",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-01T17:28:58.854Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "progress_step_checked": {
        "data": [
          {
            "id": "87a3736c-6d04-40f7-8242-35598d5a5a7a",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=49515347-e624-415e-b5fd-8f35c1db3258"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=49515347-e624-415e-b5fd-8f35c1db3258",
          "self": "/projects/49515347-e624-415e-b5fd-8f35c1db3258/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/49515347-e624-415e-b5fd-8f35c1db3258/archive"
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
DELETE /projects/ac3c57a7-e53e-45e6-b80e-dbed73d768cf
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 34c195cd-3bc0-489b-a4df-23db0dade708
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
X-Request-Id: 43a1f960-d067-4c66-9730-6c7fb652d960
200 OK
```


```json
{
  "data": [
    {
      "id": "f44458dc-8e65-4997-9109-94d219a1292f",
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
              "id": "f1670f7b-697e-4905-932c-3ddfec23c71d",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=f44458dc-8e65-4997-9109-94d219a1292f"
          }
        },
        "project": {
          "links": {
            "related": "/projects/3cb62227-bcc8-47b7-9646-c40a17c69e28"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/8175b4fb-9e3b-4e12-83e6-cd774fb3818c"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/e03d9247-aa74-4933-8826-80c969be8f6c"
          }
        }
      }
    },
    {
      "id": "2d45bd51-02ca-4d49-89a3-7c5da4a2a2de",
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
            "related": "/progress?filter[target_id_eq]=2d45bd51-02ca-4d49-89a3-7c5da4a2a2de"
          }
        },
        "project": {
          "links": {
            "related": "/projects/3cb62227-bcc8-47b7-9646-c40a17c69e28"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/d2f24262-3290-498c-88e2-c879dd31cc42"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/e03d9247-aa74-4933-8826-80c969be8f6c"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "f1670f7b-697e-4905-932c-3ddfec23c71d",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "b3743989-c2f1-4968-ae2b-29671f7dece2",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/b3743989-c2f1-4968-ae2b-29671f7dece2"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/f44458dc-8e65-4997-9109-94d219a1292f"
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
GET /contexts/88affd84-9d49-4b81-b03c-c4063a76409f
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
X-Request-Id: eb1a0f30-ef69-4683-86ba-2c73733afac8
200 OK
```


```json
{
  "data": {
    "id": "88affd84-9d49-4b81-b03c-c4063a76409f",
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
            "id": "b6f9dfb8-8e5d-4d0e-9c3a-6f3d17745424",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=88affd84-9d49-4b81-b03c-c4063a76409f"
        }
      },
      "project": {
        "links": {
          "related": "/projects/702f27d9-db9e-4f01-8d39-4147e26830ef"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/f2ca12e4-f369-4f6f-9401-d8eae9050554"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/66c51ce7-76f7-4a75-b40a-5f63584f4560"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/88affd84-9d49-4b81-b03c-c4063a76409f"
  },
  "included": [
    {
      "id": "b6f9dfb8-8e5d-4d0e-9c3a-6f3d17745424",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "6a7f588f-d1f0-4194-a53d-cd2e4f893ab0",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/6a7f588f-d1f0-4194-a53d-cd2e4f893ab0"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/88affd84-9d49-4b81-b03c-c4063a76409f"
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
PATCH /contexts/af939130-8b29-46e8-9b8f-799a0e1cb43d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "af939130-8b29-46e8-9b8f-799a0e1cb43d",
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
X-Request-Id: 2d1a91b5-5224-44bd-9909-1716f5f05400
200 OK
```


```json
{
  "data": {
    "id": "af939130-8b29-46e8-9b8f-799a0e1cb43d",
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
            "id": "52e443f5-08f5-4260-9284-c487738ea748",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=af939130-8b29-46e8-9b8f-799a0e1cb43d"
        }
      },
      "project": {
        "links": {
          "related": "/projects/4cc7604f-c354-4f9f-a040-dab936b64990"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/9504437e-5d02-4c63-81e6-a4fac3d9ba58"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/09e5601e-bfad-43c2-bae1-57904ad9f14f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/af939130-8b29-46e8-9b8f-799a0e1cb43d"
  },
  "included": [
    {
      "id": "52e443f5-08f5-4260-9284-c487738ea748",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "2c00b6fb-3145-43fb-abea-1bdef673221b",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/2c00b6fb-3145-43fb-abea-1bdef673221b"
          }
        },
        "target": {
          "links": {
            "related": "/contexts/af939130-8b29-46e8-9b8f-799a0e1cb43d"
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
POST /projects/7af88ba5-2473-472e-876c-3fd9ccd28b84/relationships/contexts
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
          "id": "abaa144e-9c60-45ba-82dc-6be78dd6204c"
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
X-Request-Id: c8fe05a5-64b5-4b0d-ba3e-13b30cf347ad
201 Created
```


```json
{
  "data": {
    "id": "4115f492-4680-4b68-87bc-e39a6ad89f89",
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
          "related": "/progress?filter[target_id_eq]=4115f492-4680-4b68-87bc-e39a6ad89f89"
        }
      },
      "project": {
        "links": {
          "related": "/projects/7af88ba5-2473-472e-876c-3fd9ccd28b84"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/6e450596-fbb5-40a8-bdec-d191e88249d4"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/abaa144e-9c60-45ba-82dc-6be78dd6204c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7af88ba5-2473-472e-876c-3fd9ccd28b84/relationships/contexts"
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
POST /contexts/85980e47-9cdb-47cb-b3e7-024360eef4dd/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/8fae765cb4ae14faae9968e6
Content-Type: text/html; charset=utf-8
X-Request-Id: 0fca912f-5007-4ea7-8253-fd4fba95985d
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/8fae765cb4ae14faae9968e6">redirected</a>.</body></html>
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
DELETE /contexts/99bf3a85-b676-4ad7-b3e0-c685247054b0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b4837f3e-926e-44f8-bcdc-605c2f5d6ab5
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
POST /object_occurrences/b6976717-6091-47c4-a516-b7cf9838f0e1/relationships/tags
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
X-Request-Id: 3a3f18fc-3015-48c4-a17a-454d8e821b10
201 Created
```


```json
{
  "data": {
    "id": "8a9bca3b-9115-4605-9c41-6d954b4a017f",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b6976717-6091-47c4-a516-b7cf9838f0e1/relationships/tags"
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
POST /object_occurrences/89813e9e-8388-43fa-9ebb-04c0a6eff60e/relationships/tags
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
    "id": "55124787-609b-4420-a131-b7ad1cc873bd"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3c8c2563-7581-47ae-8a1e-db102a4d07dc
201 Created
```


```json
{
  "data": {
    "id": "55124787-609b-4420-a131-b7ad1cc873bd",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/89813e9e-8388-43fa-9ebb-04c0a6eff60e/relationships/tags"
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
DELETE /object_occurrences/6240ca3c-154c-4ebd-b741-a7e93ee2f92d/relationships/tags/352bf202-8545-45fe-a3e2-0360440b2484
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5a73ed50-0bfc-41fa-8784-77ff460b8ff1
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/05cdf183-1594-4b14-a34d-1b4ea9e7a7d7/relationships/owners
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
X-Request-Id: 6cbe50a5-18a0-41b3-b814-175cb7ee61f0
201 Created
```


```json
{
  "data": {
    "id": "f52489f1-82dc-42d9-8a40-e3c09c89c4f4",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/05cdf183-1594-4b14-a34d-1b4ea9e7a7d7/relationships/owners"
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
POST /object_occurrences/736dfa28-352d-4e2d-847e-dfc491432f22/relationships/owners
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
X-Request-Id: 6fdfd807-3d1a-4bd6-bfa4-0d7c41b4db6d
201 Created
```


```json
{
  "data": {
    "id": "0569ca3f-8ff3-4f99-b6cd-b0121383579e",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/736dfa28-352d-4e2d-847e-dfc491432f22/relationships/owners"
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
POST /object_occurrences/c542bb27-3d7d-4d00-baa4-77c35199c821/relationships/owners
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
    "id": "84f56ce2-481b-43db-a128-803876e81c64"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 37681059-dcd4-4672-9b23-9a41db41c9ee
201 Created
```


```json
{
  "data": {
    "id": "84f56ce2-481b-43db-a128-803876e81c64",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 7",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c542bb27-3d7d-4d00-baa4-77c35199c821/relationships/owners"
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
DELETE /object_occurrences/59683494-e0b4-4d5c-b210-a1b67aba9dcb/relationships/owners/bec0ea6b-f067-46df-b922-08dad3f54834
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: bf917fa8-eb5b-41f0-b775-62c6641a5ca2
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
X-Request-Id: cee37c01-2fba-42d6-8ff0-e725ffc724ea
200 OK
```


```json
{
  "data": [
    {
      "id": "714b58e0-c8dd-42f5-af9d-be1d87115ce9",
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
              "id": "0f38f668-f2b8-4c79-8704-56adf784a75a",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=714b58e0-c8dd-42f5-af9d-be1d87115ce9",
            "self": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "ee2cffc2-549b-48d4-bdbd-dae71ecbe416",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=714b58e0-c8dd-42f5-af9d-be1d87115ce9&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "0b06af6d-1364-4eb4-a150-723f0fb8f123",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=714b58e0-c8dd-42f5-af9d-be1d87115ce9"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffe75854-e689-4606-9193-d1c4b8d32274"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737",
            "self": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "e1573a2f-f2b6-47d4-93db-f458f3f26c60",
              "type": "object_occurrence"
            },
            {
              "id": "01c3d393-6bbb-4194-910d-9dbcb7306962",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "530b7de8-2486-4ad9-86da-85db64507e65",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=714b58e0-c8dd-42f5-af9d-be1d87115ce9"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "ebf293b6-b82c-4015-99ec-d63d457f639b",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=714b58e0-c8dd-42f5-af9d-be1d87115ce9"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "343811d3-44e5-431f-b504-1e9684af2313",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=714b58e0-c8dd-42f5-af9d-be1d87115ce9"
          }
        }
      }
    },
    {
      "id": "01c3d393-6bbb-4194-910d-9dbcb7306962",
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
            "related": "/tags?filter[target_id_eq]=01c3d393-6bbb-4194-910d-9dbcb7306962",
            "self": "/object_occurrences/01c3d393-6bbb-4194-910d-9dbcb7306962/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=01c3d393-6bbb-4194-910d-9dbcb7306962&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/01c3d393-6bbb-4194-910d-9dbcb7306962/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=01c3d393-6bbb-4194-910d-9dbcb7306962"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffe75854-e689-4606-9193-d1c4b8d32274"
          }
        },
        "classification_table": {
          "data": {
            "id": "343811d3-44e5-431f-b504-1e9684af2313",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/343811d3-44e5-431f-b504-1e9684af2313"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9",
            "self": "/object_occurrences/01c3d393-6bbb-4194-910d-9dbcb7306962/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/01c3d393-6bbb-4194-910d-9dbcb7306962/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "530b7de8-2486-4ad9-86da-85db64507e65",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=01c3d393-6bbb-4194-910d-9dbcb7306962"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "ebf293b6-b82c-4015-99ec-d63d457f639b",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=01c3d393-6bbb-4194-910d-9dbcb7306962"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "343811d3-44e5-431f-b504-1e9684af2313",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=01c3d393-6bbb-4194-910d-9dbcb7306962"
          }
        }
      }
    },
    {
      "id": "e1573a2f-f2b6-47d4-93db-f458f3f26c60",
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
            "related": "/tags?filter[target_id_eq]=e1573a2f-f2b6-47d4-93db-f458f3f26c60",
            "self": "/object_occurrences/e1573a2f-f2b6-47d4-93db-f458f3f26c60/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e1573a2f-f2b6-47d4-93db-f458f3f26c60&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e1573a2f-f2b6-47d4-93db-f458f3f26c60/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=e1573a2f-f2b6-47d4-93db-f458f3f26c60"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffe75854-e689-4606-9193-d1c4b8d32274"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9",
            "self": "/object_occurrences/e1573a2f-f2b6-47d4-93db-f458f3f26c60/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/e1573a2f-f2b6-47d4-93db-f458f3f26c60/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "530b7de8-2486-4ad9-86da-85db64507e65",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e1573a2f-f2b6-47d4-93db-f458f3f26c60"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "ebf293b6-b82c-4015-99ec-d63d457f639b",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e1573a2f-f2b6-47d4-93db-f458f3f26c60"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "343811d3-44e5-431f-b504-1e9684af2313",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e1573a2f-f2b6-47d4-93db-f458f3f26c60"
          }
        }
      }
    },
    {
      "id": "61397a65-96c5-49cc-bf05-fef436e408af",
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
            "related": "/tags?filter[target_id_eq]=61397a65-96c5-49cc-bf05-fef436e408af",
            "self": "/object_occurrences/61397a65-96c5-49cc-bf05-fef436e408af/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=61397a65-96c5-49cc-bf05-fef436e408af&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/61397a65-96c5-49cc-bf05-fef436e408af/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=61397a65-96c5-49cc-bf05-fef436e408af"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/d97c7da1-17a4-4470-89ce-d6d2d7994ad1"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/026e3e8a-da89-480a-85dc-770d2d5951ab",
            "self": "/object_occurrences/61397a65-96c5-49cc-bf05-fef436e408af/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/61397a65-96c5-49cc-bf05-fef436e408af/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "530b7de8-2486-4ad9-86da-85db64507e65",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=61397a65-96c5-49cc-bf05-fef436e408af"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "ebf293b6-b82c-4015-99ec-d63d457f639b",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=61397a65-96c5-49cc-bf05-fef436e408af"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "343811d3-44e5-431f-b504-1e9684af2313",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=61397a65-96c5-49cc-bf05-fef436e408af"
          }
        }
      }
    },
    {
      "id": "ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
        "name": "ObjectOccurrence abcd0ac2a902",
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
            "related": "/tags?filter[target_id_eq]=ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737",
            "self": "/object_occurrences/ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffe75854-e689-4606-9193-d1c4b8d32274"
          }
        },
        "components": {
          "data": [
            {
              "id": "714b58e0-c8dd-42f5-af9d-be1d87115ce9",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "530b7de8-2486-4ad9-86da-85db64507e65",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "ebf293b6-b82c-4015-99ec-d63d457f639b",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "343811d3-44e5-431f-b504-1e9684af2313",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=ebdfa3fa-38ae-4a7f-9a51-0fbcf2806737"
          }
        }
      }
    },
    {
      "id": "026e3e8a-da89-480a-85dc-770d2d5951ab",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "image_key": null,
        "name": "ObjectOccurrence f84e76537272",
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
            "related": "/tags?filter[target_id_eq]=026e3e8a-da89-480a-85dc-770d2d5951ab",
            "self": "/object_occurrences/026e3e8a-da89-480a-85dc-770d2d5951ab/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=026e3e8a-da89-480a-85dc-770d2d5951ab&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/026e3e8a-da89-480a-85dc-770d2d5951ab/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=026e3e8a-da89-480a-85dc-770d2d5951ab"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/d97c7da1-17a4-4470-89ce-d6d2d7994ad1"
          }
        },
        "components": {
          "data": [
            {
              "id": "61397a65-96c5-49cc-bf05-fef436e408af",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/026e3e8a-da89-480a-85dc-770d2d5951ab/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [
            {
              "id": "530b7de8-2486-4ad9-86da-85db64507e65",
              "type": "allowed_children_syntax_node"
            }
          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=026e3e8a-da89-480a-85dc-770d2d5951ab"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [
            {
              "id": "ebf293b6-b82c-4015-99ec-d63d457f639b",
              "type": "allowed_children_syntax_element"
            }
          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=026e3e8a-da89-480a-85dc-770d2d5951ab"
          }
        },
        "allowed_children_classification_tables": {
          "data": [
            {
              "id": "343811d3-44e5-431f-b504-1e9684af2313",
              "type": "allowed_children_classification_table"
            }
          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=026e3e8a-da89-480a-85dc-770d2d5951ab"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "ee2cffc2-549b-48d4-bdbd-dae71ecbe416",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 10",
        "title": null
      }
    },
    {
      "id": "0b06af6d-1364-4eb4-a150-723f0fb8f123",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "ad42ded5-6ff1-4681-a4ab-13b65f31f5fc",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/ad42ded5-6ff1-4681-a4ab-13b65f31f5fc"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/714b58e0-c8dd-42f5-af9d-be1d87115ce9"
          }
        }
      }
    },
    {
      "id": "0f38f668-f2b8-4c79-8704-56adf784a75a",
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



## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d
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
X-Request-Id: b7a4e872-5f4a-4f48-8f0b-d1d83e42042b
200 OK
```


```json
{
  "data": {
    "id": "65dfaeba-32ff-4749-a829-5f58c4c42d8d",
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
            "id": "df4a3839-61a7-4fd8-93da-9a42ca898d53",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=65dfaeba-32ff-4749-a829-5f58c4c42d8d",
          "self": "/object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "6f0f4808-ec93-45e9-a38e-199f337e3f9f",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=65dfaeba-32ff-4749-a829-5f58c4c42d8d&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "858d029a-8041-42c0-9e74-e535b3f9e918",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=65dfaeba-32ff-4749-a829-5f58c4c42d8d"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/b9298272-c3d4-4f35-b335-7b5899241042"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/4bb48bc8-6076-4aa8-abe0-a6b0095de510",
          "self": "/object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "f86e8633-ce3d-4f21-9aef-516edbee213b",
            "type": "object_occurrence"
          },
          {
            "id": "e693d635-e646-448c-b1e7-5f3e1e8f0de4",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "879b1ca5-799d-403b-8160-7bae8399eff9",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=65dfaeba-32ff-4749-a829-5f58c4c42d8d"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "1c26a4a5-0519-4809-9d0b-d629085b27bb",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=65dfaeba-32ff-4749-a829-5f58c4c42d8d"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "1e30dcd3-61d7-426b-9e0e-24e81e6a11e9",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=65dfaeba-32ff-4749-a829-5f58c4c42d8d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d"
  },
  "included": [
    {
      "id": "6f0f4808-ec93-45e9-a38e-199f337e3f9f",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 11",
        "title": null
      }
    },
    {
      "id": "858d029a-8041-42c0-9e74-e535b3f9e918",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "3e4c08e5-a374-4cc9-bbb7-cc80c5e61cda",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/3e4c08e5-a374-4cc9-bbb7-cc80c5e61cda"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/65dfaeba-32ff-4749-a829-5f58c4c42d8d"
          }
        }
      }
    },
    {
      "id": "df4a3839-61a7-4fd8-93da-9a42ca898d53",
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
POST /object_occurrences/c9b32aee-7c3e-4f45-bb40-b6d543ca8a65/relationships/components
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
X-Request-Id: 57b7fb83-3f2b-4cc9-8259-16765f3e1712
201 Created
```


```json
{
  "data": {
    "id": "0d48ab03-fc7e-4dbc-93df-43bc1808e58a",
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
          "related": "/tags?filter[target_id_eq]=0d48ab03-fc7e-4dbc-93df-43bc1808e58a",
          "self": "/object_occurrences/0d48ab03-fc7e-4dbc-93df-43bc1808e58a/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=0d48ab03-fc7e-4dbc-93df-43bc1808e58a&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/0d48ab03-fc7e-4dbc-93df-43bc1808e58a/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=0d48ab03-fc7e-4dbc-93df-43bc1808e58a"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/7b4edbc7-8e24-4139-ae48-826eb43b0bc7"
        }
      },
      "classification_table": {
        "data": {
          "id": "104ba367-48eb-4377-8abb-906d443ecf19",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/104ba367-48eb-4377-8abb-906d443ecf19"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/c9b32aee-7c3e-4f45-bb40-b6d543ca8a65",
          "self": "/object_occurrences/0d48ab03-fc7e-4dbc-93df-43bc1808e58a/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/0d48ab03-fc7e-4dbc-93df-43bc1808e58a/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "e945f987-f449-4c0c-938f-074c5741c708",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=0d48ab03-fc7e-4dbc-93df-43bc1808e58a"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "1967bfa2-d64f-4124-a25a-c081bdcd8c62",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=0d48ab03-fc7e-4dbc-93df-43bc1808e58a"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "104ba367-48eb-4377-8abb-906d443ecf19",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=0d48ab03-fc7e-4dbc-93df-43bc1808e58a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c9b32aee-7c3e-4f45-bb40-b6d543ca8a65/relationships/components"
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


## Create external

Create a single, external Object Occurrence.

External Object Occurrences represent external systems which this design depends on,
such as GPS or the power grid.


### Request

#### Endpoint

```plaintext
POST /object_occurrences/8c2bb3b1-fb43-4819-bb43-e140522ec7bb/relationships/components
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
X-Request-Id: 303bba13-34b8-4af3-86fc-73b87ed27942
201 Created
```


```json
{
  "data": {
    "id": "dcd39ecf-e557-4635-9fab-73444c44ef96",
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
          "related": "/tags?filter[target_id_eq]=dcd39ecf-e557-4635-9fab-73444c44ef96",
          "self": "/object_occurrences/dcd39ecf-e557-4635-9fab-73444c44ef96/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=dcd39ecf-e557-4635-9fab-73444c44ef96&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/dcd39ecf-e557-4635-9fab-73444c44ef96/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=dcd39ecf-e557-4635-9fab-73444c44ef96"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/8ab968f4-fa49-48a9-bde5-cfda91ad59d7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/8c2bb3b1-fb43-4819-bb43-e140522ec7bb/relationships/components"
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
PATCH /object_occurrences/188301b1-731f-42f7-8983-ca5e05fe71f8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "188301b1-731f-42f7-8983-ca5e05fe71f8",
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
          "id": "13a64dee-0ad4-4cbe-a030-261c916926be"
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
X-Request-Id: 3272f587-53f3-452f-8ba2-b7a38be89328
200 OK
```


```json
{
  "data": {
    "id": "188301b1-731f-42f7-8983-ca5e05fe71f8",
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
          "related": "/tags?filter[target_id_eq]=188301b1-731f-42f7-8983-ca5e05fe71f8",
          "self": "/object_occurrences/188301b1-731f-42f7-8983-ca5e05fe71f8/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=188301b1-731f-42f7-8983-ca5e05fe71f8&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/188301b1-731f-42f7-8983-ca5e05fe71f8/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=188301b1-731f-42f7-8983-ca5e05fe71f8"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/fa30c84e-8006-4023-bca4-65e01b7fbe98"
        }
      },
      "classification_table": {
        "data": {
          "id": "2cf077ba-d4d6-4af7-8281-50e4f6aa51ce",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/2cf077ba-d4d6-4af7-8281-50e4f6aa51ce"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/13a64dee-0ad4-4cbe-a030-261c916926be",
          "self": "/object_occurrences/188301b1-731f-42f7-8983-ca5e05fe71f8/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/188301b1-731f-42f7-8983-ca5e05fe71f8/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "62226b08-8145-4f12-aa52-510fc126fe5b",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=188301b1-731f-42f7-8983-ca5e05fe71f8"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "0231f229-a777-4ded-bb8e-dde9e83943de",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=188301b1-731f-42f7-8983-ca5e05fe71f8"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "2cf077ba-d4d6-4af7-8281-50e4f6aa51ce",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=188301b1-731f-42f7-8983-ca5e05fe71f8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/188301b1-731f-42f7-8983-ca5e05fe71f8"
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
POST /object_occurrences/442cdf11-76d4-4746-9c17-f60b50998bc6/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "8b558793-2723-42df-b31e-685015bff64f",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/8fe4391457620f81d365136d
Content-Type: text/html; charset=utf-8
X-Request-Id: daf719a2-af21-4cfc-82bc-e300ae7adfcf
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/8fe4391457620f81d365136d">redirected</a>.</body></html>
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
DELETE /object_occurrences/bbaba505-1719-4c3c-8bdd-3b62f5b34215
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 74a7fac9-ba4d-4ea4-8dae-768059fc281e
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/2cc53dfa-1bcd-44fb-bc9d-396f046058d6/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "7117f49c-8997-42dd-8bd2-84d48b7cfcb7",
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
X-Request-Id: 487bcc0f-2024-4c59-8956-6bfe3867cebb
200 OK
```


```json
{
  "data": {
    "id": "2cc53dfa-1bcd-44fb-bc9d-396f046058d6",
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
          "related": "/tags?filter[target_id_eq]=2cc53dfa-1bcd-44fb-bc9d-396f046058d6",
          "self": "/object_occurrences/2cc53dfa-1bcd-44fb-bc9d-396f046058d6/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=2cc53dfa-1bcd-44fb-bc9d-396f046058d6&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/2cc53dfa-1bcd-44fb-bc9d-396f046058d6/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=2cc53dfa-1bcd-44fb-bc9d-396f046058d6"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/6562e07d-db76-43f4-89cd-2a61fdf64a03"
        }
      },
      "classification_table": {
        "data": {
          "id": "5adb0f4d-0af0-475c-aa58-c1f7a50a036c",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/5adb0f4d-0af0-475c-aa58-c1f7a50a036c"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/7117f49c-8997-42dd-8bd2-84d48b7cfcb7",
          "self": "/object_occurrences/2cc53dfa-1bcd-44fb-bc9d-396f046058d6/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/2cc53dfa-1bcd-44fb-bc9d-396f046058d6/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "b1de2839-620a-41f5-ad11-567944f7622e",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=2cc53dfa-1bcd-44fb-bc9d-396f046058d6"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "70e61c4d-b3cb-48b8-b884-43d88ba5091e",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=2cc53dfa-1bcd-44fb-bc9d-396f046058d6"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "5adb0f4d-0af0-475c-aa58-c1f7a50a036c",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=2cc53dfa-1bcd-44fb-bc9d-396f046058d6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/2cc53dfa-1bcd-44fb-bc9d-396f046058d6/relationships/part_of"
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
X-Request-Id: d9f02329-da19-4373-bd61-13d65e4daa01
200 OK
```


```json
{
  "data": [
    {
      "id": "0390ebf96ffd9534890515d2e71b95eac0bda8f18eee550966ddfc9f5a4af4ec",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "dc599fc0-8eaa-440e-aa69-2f365c44e71c",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/dc599fc0-8eaa-440e-aa69-2f365c44e71c"
          }
        }
      }
    },
    {
      "id": "88d61eeeb34ba2e7b36dc736d6912d766bbc182f54c0c691a4a617ed0928e2fc",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "bde11416-2417-48e8-bab3-5c819f15f5d3",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/bde11416-2417-48e8-bab3-5c819f15f5d3"
          }
        }
      }
    },
    {
      "id": "f278839613b2898cdf0f6e182489cc68a143022b746a37be8a2aea6fe14ce150",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "90797676-6467-4c02-846e-2ebf226cd899",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/90797676-6467-4c02-846e-2ebf226cd899"
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
GET /object_occurrences/ff72bfeb-ee36-4a9a-8962-99b1e1d3273c/relationships/image/upload_url?extension=jpg
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
X-Request-Id: 73db5ba5-852c-4e72-b960-0427a0309822
200 OK
```


```json
{
  "data": {
    "id": "ooc/ff72bfeb-ee36-4a9a-8962-99b1e1d3273c/1234abcde.jpg",
    "type": "url_struct",
    "attributes": {
      "id": "ooc/ff72bfeb-ee36-4a9a-8962-99b1e1d3273c/1234abcde.jpg",
      "url": "https://qa-sec-hub-document-bucket.s3.eu-west-1.amazonaws.com/ooc/ff72bfeb-ee36-4a9a-8962-99b1e1d3273c/1234abcde.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20200501%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20200501T173051Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=2115c104c309e9e66cf08f9d7cf48c126b7147fac9e46f1a25e1dad450a97751",
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
PATCH /object_occurrences/865481e3-2e45-4cbb-b9a4-cfdb63d426e7/relationships/image
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
X-Request-Id: f05f0aef-6229-4598-9336-10c88dd83506
200 OK
```


```json
{
  "data": {
    "id": "865481e3-2e45-4cbb-b9a4-cfdb63d426e7",
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
          "related": "/tags?filter[target_id_eq]=865481e3-2e45-4cbb-b9a4-cfdb63d426e7",
          "self": "/object_occurrences/865481e3-2e45-4cbb-b9a4-cfdb63d426e7/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=865481e3-2e45-4cbb-b9a4-cfdb63d426e7&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/865481e3-2e45-4cbb-b9a4-cfdb63d426e7/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=865481e3-2e45-4cbb-b9a4-cfdb63d426e7"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/e88d9b4b-233c-4ad8-9a0f-a7e2cd5d1ca3"
        }
      },
      "classification_table": {
        "data": {
          "id": "90bca330-49c0-46f2-8ca3-81c5ceccc7e6",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/90bca330-49c0-46f2-8ca3-81c5ceccc7e6"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/46b030e2-0723-4e99-8f00-dee54bdec806",
          "self": "/object_occurrences/865481e3-2e45-4cbb-b9a4-cfdb63d426e7/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/865481e3-2e45-4cbb-b9a4-cfdb63d426e7/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "data": [
          {
            "id": "b6a634eb-9945-4ef8-b297-13c95d061444",
            "type": "allowed_children_syntax_node"
          }
        ],
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=865481e3-2e45-4cbb-b9a4-cfdb63d426e7"
        }
      },
      "allowed_children_syntax_elements": {
        "data": [
          {
            "id": "e1459956-6a2a-4331-a5c4-f97d322f9bed",
            "type": "allowed_children_syntax_element"
          }
        ],
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=865481e3-2e45-4cbb-b9a4-cfdb63d426e7"
        }
      },
      "allowed_children_classification_tables": {
        "data": [
          {
            "id": "90bca330-49c0-46f2-8ca3-81c5ceccc7e6",
            "type": "allowed_children_classification_table"
          }
        ],
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=865481e3-2e45-4cbb-b9a4-cfdb63d426e7"
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
DELETE /object_occurrences/5c412b9b-6f2a-42ca-8099-2482d17c0310/relationships/image
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/image`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 208c6eb0-fb49-4c03-8f56-0fb47adbcd63
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
POST /classification_tables/109ed83e-f02f-4a59-b479-05d07c3a06e2/relationships/tags
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
X-Request-Id: bc1f441c-1519-4ffb-b887-b453ba3ff182
201 Created
```


```json
{
  "data": {
    "id": "17c7f47e-c2c0-47df-ad67-0141751660d9",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/109ed83e-f02f-4a59-b479-05d07c3a06e2/relationships/tags"
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
POST /classification_tables/f33dcb4b-42b0-4103-9701-255c994184d4/relationships/tags
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
    "id": "2dc375d6-a679-4e8a-b0b8-1da9910714dd"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8b46a009-4c1b-46c6-b4a5-df56be1642cf
201 Created
```


```json
{
  "data": {
    "id": "2dc375d6-a679-4e8a-b0b8-1da9910714dd",
    "type": "tag",
    "attributes": {
      "value": "tag value 18"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/f33dcb4b-42b0-4103-9701-255c994184d4/relationships/tags"
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
DELETE /classification_tables/e5f54f96-0d2b-4ec5-851d-58f0c73b00b9/relationships/tags/6133dcc0-aba8-4fe5-94a5-e546ea42b79a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cf5ffe31-4ea5-40c7-bb9f-4faf37459210
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
X-Request-Id: 87b8a87b-4ddc-49a5-aa68-ec4c4ed742f1
200 OK
```


```json
{
  "data": [
    {
      "id": "6fb0eba0-8d55-4ad8-bc3a-1105d023db84",
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
            "related": "/tags?filter[target_id_eq]=6fb0eba0-8d55-4ad8-bc3a-1105d023db84",
            "self": "/classification_tables/6fb0eba0-8d55-4ad8-bc3a-1105d023db84/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=6fb0eba0-8d55-4ad8-bc3a-1105d023db84",
            "self": "/classification_tables/6fb0eba0-8d55-4ad8-bc3a-1105d023db84/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "b03a7c43-4c0c-4b31-bafd-b6e0adbce266",
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
            "related": "/tags?filter[target_id_eq]=b03a7c43-4c0c-4b31-bafd-b6e0adbce266",
            "self": "/classification_tables/b03a7c43-4c0c-4b31-bafd-b6e0adbce266/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=b03a7c43-4c0c-4b31-bafd-b6e0adbce266",
            "self": "/classification_tables/b03a7c43-4c0c-4b31-bafd-b6e0adbce266/relationships/classification_entries",
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
GET /classification_tables/79590443-7604-4184-96af-f6833048b386
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
X-Request-Id: dbba394d-c794-4c8b-b30b-a187ca8996d7
200 OK
```


```json
{
  "data": {
    "id": "79590443-7604-4184-96af-f6833048b386",
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
          "related": "/tags?filter[target_id_eq]=79590443-7604-4184-96af-f6833048b386",
          "self": "/classification_tables/79590443-7604-4184-96af-f6833048b386/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=79590443-7604-4184-96af-f6833048b386",
          "self": "/classification_tables/79590443-7604-4184-96af-f6833048b386/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/79590443-7604-4184-96af-f6833048b386"
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
PATCH /classification_tables/9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6",
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
X-Request-Id: 8147d3b3-0746-4f9c-b9e9-c397bcc8a232
200 OK
```


```json
{
  "data": {
    "id": "9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6",
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
          "related": "/tags?filter[target_id_eq]=9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6",
          "self": "/classification_tables/9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6",
          "self": "/classification_tables/9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/9cbd8b05-42df-48a6-b0ec-06a5ebb6e6a6"
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
DELETE /classification_tables/388751c8-15b1-45f9-a5a8-121e9d515d06
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: abea4366-8afc-4407-918e-21b749459a97
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
POST /classification_tables/7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84/publish
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
X-Request-Id: 217e3528-7b75-4313-8a79-13cd87a73c6e
200 OK
```


```json
{
  "data": {
    "id": "7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-05-01T17:29:41.426Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84",
          "self": "/classification_tables/7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84",
          "self": "/classification_tables/7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/7eb5bf2f-4ef4-4890-b8b4-a47bc741bb84/publish"
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
POST /classification_tables/b1d19a1f-2e9e-49df-811b-452720f85ecc/archive
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
X-Request-Id: 11cd40ec-5038-4966-bcd3-af2cb819e292
200 OK
```


```json
{
  "data": {
    "id": "b1d19a1f-2e9e-49df-811b-452720f85ecc",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-01T17:29:42.263Z",
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
          "related": "/tags?filter[target_id_eq]=b1d19a1f-2e9e-49df-811b-452720f85ecc",
          "self": "/classification_tables/b1d19a1f-2e9e-49df-811b-452720f85ecc/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=b1d19a1f-2e9e-49df-811b-452720f85ecc",
          "self": "/classification_tables/b1d19a1f-2e9e-49df-811b-452720f85ecc/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/b1d19a1f-2e9e-49df-811b-452720f85ecc/archive"
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
X-Request-Id: 8751d908-1ee8-4f1d-b7e0-2ea31652aec6
201 Created
```


```json
{
  "data": {
    "id": "300d5fdb-d1ff-4b81-b8c6-0df23e0cccbe",
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
          "related": "/tags?filter[target_id_eq]=300d5fdb-d1ff-4b81-b8c6-0df23e0cccbe",
          "self": "/classification_tables/300d5fdb-d1ff-4b81-b8c6-0df23e0cccbe/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=300d5fdb-d1ff-4b81-b8c6-0df23e0cccbe",
          "self": "/classification_tables/300d5fdb-d1ff-4b81-b8c6-0df23e0cccbe/relationships/classification_entries",
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
POST /classification_entries/23fdba9b-bcc1-4739-822f-fa1bcbaabe6d/relationships/tags
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
X-Request-Id: 2a2513b8-ceef-48e2-b082-ee0e4fc064c6
201 Created
```


```json
{
  "data": {
    "id": "8705757a-8fed-44e7-8403-7427670c6f8f",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/23fdba9b-bcc1-4739-822f-fa1bcbaabe6d/relationships/tags"
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
POST /classification_entries/95059383-1918-4b1f-a43b-7c4184e6c263/relationships/tags
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
    "id": "3dcfea56-6ca5-4716-8ef0-7240216afd78"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 28602e38-49e2-4a89-8dfc-e037f6b91d9d
201 Created
```


```json
{
  "data": {
    "id": "3dcfea56-6ca5-4716-8ef0-7240216afd78",
    "type": "tag",
    "attributes": {
      "value": "tag value 20"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/95059383-1918-4b1f-a43b-7c4184e6c263/relationships/tags"
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
DELETE /classification_entries/b5491280-8a19-4eeb-bedb-456d7d329eb7/relationships/tags/f7d5d732-6211-4225-bde4-40a3b3d500a3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6d28f707-5934-4d9e-ba29-e9d6167ffe0e
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
X-Request-Id: 5aaaab61-128c-4932-8b28-7eeb4396f705
200 OK
```


```json
{
  "data": [
    {
      "id": "48fcb52a-11fb-4491-a011-5f52e2a2b5b2",
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
            "related": "/tags?filter[target_id_eq]=48fcb52a-11fb-4491-a011-5f52e2a2b5b2",
            "self": "/classification_entries/48fcb52a-11fb-4491-a011-5f52e2a2b5b2/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=48fcb52a-11fb-4491-a011-5f52e2a2b5b2",
            "self": "/classification_entries/48fcb52a-11fb-4491-a011-5f52e2a2b5b2/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "bcd0c359-5c13-4a81-a188-aa0d8ddb9d2d",
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
            "related": "/tags?filter[target_id_eq]=bcd0c359-5c13-4a81-a188-aa0d8ddb9d2d",
            "self": "/classification_entries/bcd0c359-5c13-4a81-a188-aa0d8ddb9d2d/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "48fcb52a-11fb-4491-a011-5f52e2a2b5b2",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/bcd0c359-5c13-4a81-a188-aa0d8ddb9d2d"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=bcd0c359-5c13-4a81-a188-aa0d8ddb9d2d",
            "self": "/classification_entries/bcd0c359-5c13-4a81-a188-aa0d8ddb9d2d/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "03df100f-6a1b-41b9-9c8f-093e1b27a1a1",
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
            "related": "/tags?filter[target_id_eq]=03df100f-6a1b-41b9-9c8f-093e1b27a1a1",
            "self": "/classification_entries/03df100f-6a1b-41b9-9c8f-093e1b27a1a1/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=03df100f-6a1b-41b9-9c8f-093e1b27a1a1",
            "self": "/classification_entries/03df100f-6a1b-41b9-9c8f-093e1b27a1a1/relationships/classification_entries",
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
GET /classification_entries/84d2dcb4-eb59-4a14-9040-dce8130089e9
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
X-Request-Id: aaa69b15-24db-493b-a00a-50fff8e8fb87
200 OK
```


```json
{
  "data": {
    "id": "84d2dcb4-eb59-4a14-9040-dce8130089e9",
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
          "related": "/tags?filter[target_id_eq]=84d2dcb4-eb59-4a14-9040-dce8130089e9",
          "self": "/classification_entries/84d2dcb4-eb59-4a14-9040-dce8130089e9/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=84d2dcb4-eb59-4a14-9040-dce8130089e9",
          "self": "/classification_entries/84d2dcb4-eb59-4a14-9040-dce8130089e9/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/84d2dcb4-eb59-4a14-9040-dce8130089e9"
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
PATCH /classification_entries/47a34744-baa7-4996-9e05-c8ad777532dc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "47a34744-baa7-4996-9e05-c8ad777532dc",
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
X-Request-Id: 4a7489d0-3b32-4ca8-a75a-ea5718e0ef94
200 OK
```


```json
{
  "data": {
    "id": "47a34744-baa7-4996-9e05-c8ad777532dc",
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
          "related": "/tags?filter[target_id_eq]=47a34744-baa7-4996-9e05-c8ad777532dc",
          "self": "/classification_entries/47a34744-baa7-4996-9e05-c8ad777532dc/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "901483e8-2575-4d2a-a996-3d71f39a5819",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/47a34744-baa7-4996-9e05-c8ad777532dc"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=47a34744-baa7-4996-9e05-c8ad777532dc",
          "self": "/classification_entries/47a34744-baa7-4996-9e05-c8ad777532dc/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/47a34744-baa7-4996-9e05-c8ad777532dc"
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
DELETE /classification_entries/f1456010-3f8d-420d-93f6-b54ba6393cd0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b6e8b48e-7498-4a25-920a-956e2d1d3d16
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
POST /classification_tables/be904b4f-0bb2-4e8f-a325-67141b4032b6/relationships/classification_entries
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
X-Request-Id: 66fd8c73-a18c-43bb-a34c-2c6dcf540387
201 Created
```


```json
{
  "data": {
    "id": "1a0fb422-f4df-432b-af6d-ffcb5864d77d",
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
          "related": "/tags?filter[target_id_eq]=1a0fb422-f4df-432b-af6d-ffcb5864d77d",
          "self": "/classification_entries/1a0fb422-f4df-432b-af6d-ffcb5864d77d/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=1a0fb422-f4df-432b-af6d-ffcb5864d77d",
          "self": "/classification_entries/1a0fb422-f4df-432b-af6d-ffcb5864d77d/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/be904b4f-0bb2-4e8f-a325-67141b4032b6/relationships/classification_entries"
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
X-Request-Id: 6510df64-13fa-4244-9774-86e4ca02c93f
200 OK
```


```json
{
  "data": [
    {
      "id": "9370f208-ff4b-428f-92d9-b11ae5f4f85b",
      "type": "syntax",
      "attributes": {
        "account_id": "c20d2e57-9c96-4736-878e-b5f0893d75b1",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax b7541ee341f0",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=9370f208-ff4b-428f-92d9-b11ae5f4f85b",
            "self": "/syntaxes/9370f208-ff4b-428f-92d9-b11ae5f4f85b/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/15f26191-975c-4826-8a70-537bccb9bcfe",
            "self": "/syntax_nodes/15f26191-975c-4826-8a70-537bccb9bcfe/relationships/components"
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
GET /syntaxes/49cf644c-d823-40c2-b9ff-718c107c4bd4
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
X-Request-Id: b818f90c-c607-44a2-a228-a4820b4904fc
200 OK
```


```json
{
  "data": {
    "id": "49cf644c-d823-40c2-b9ff-718c107c4bd4",
    "type": "syntax",
    "attributes": {
      "account_id": "41e66496-0b36-4ca8-8f6c-fd99342c0c6f",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 4354094a23cb",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=49cf644c-d823-40c2-b9ff-718c107c4bd4",
          "self": "/syntaxes/49cf644c-d823-40c2-b9ff-718c107c4bd4/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/1bcf943a-100e-4258-ba98-43fc077a18ec",
          "self": "/syntax_nodes/1bcf943a-100e-4258-ba98-43fc077a18ec/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/49cf644c-d823-40c2-b9ff-718c107c4bd4"
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
X-Request-Id: 28ed996c-cf70-4628-91e3-06df6e1f967f
201 Created
```


```json
{
  "data": {
    "id": "f68eb587-3c33-4e18-8216-15a99db2a37e",
    "type": "syntax",
    "attributes": {
      "account_id": "2d6b8efc-7f86-4d7e-8efa-60007def69c7",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=f68eb587-3c33-4e18-8216-15a99db2a37e",
          "self": "/syntaxes/f68eb587-3c33-4e18-8216-15a99db2a37e/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/cabc25db-a024-4879-a346-ba06853c4fe5",
          "self": "/syntax_nodes/cabc25db-a024-4879-a346-ba06853c4fe5/relationships/components"
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
PATCH /syntaxes/73fb52e4-4073-4aa2-bd39-1d7ed5ea08d4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "73fb52e4-4073-4aa2-bd39-1d7ed5ea08d4",
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
X-Request-Id: 2432d039-9e81-40b5-a386-88e640df27e3
200 OK
```


```json
{
  "data": {
    "id": "73fb52e4-4073-4aa2-bd39-1d7ed5ea08d4",
    "type": "syntax",
    "attributes": {
      "account_id": "1533e29d-e606-459b-8afb-9a0d063537d5",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=73fb52e4-4073-4aa2-bd39-1d7ed5ea08d4",
          "self": "/syntaxes/73fb52e4-4073-4aa2-bd39-1d7ed5ea08d4/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/6de0ed6d-1bad-47ab-89f3-4fe7a1945312",
          "self": "/syntax_nodes/6de0ed6d-1bad-47ab-89f3-4fe7a1945312/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/73fb52e4-4073-4aa2-bd39-1d7ed5ea08d4"
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
DELETE /syntaxes/752a5cfc-4e28-44e4-bc68-f68c942031a9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7165e775-08c8-4274-94bd-a7e45057b1cd
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
POST /syntaxes/8a3349cf-19eb-4db5-8541-078a8232e62c/publish
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
X-Request-Id: 9a96b3e9-3a15-4f42-9dea-35f13ed74dea
200 OK
```


```json
{
  "data": {
    "id": "8a3349cf-19eb-4db5-8541-078a8232e62c",
    "type": "syntax",
    "attributes": {
      "account_id": "2884b44b-eaf9-49ed-a595-4018c7dfc075",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 971b81a42660",
      "published": true,
      "published_at": "2020-05-01T17:29:54.394Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=8a3349cf-19eb-4db5-8541-078a8232e62c",
          "self": "/syntaxes/8a3349cf-19eb-4db5-8541-078a8232e62c/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/ede77940-9d8a-4b67-9df7-84c64a8f7266",
          "self": "/syntax_nodes/ede77940-9d8a-4b67-9df7-84c64a8f7266/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/8a3349cf-19eb-4db5-8541-078a8232e62c/publish"
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
POST /syntaxes/6643a06c-3897-4e68-b39c-591c5cd0f234/archive
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
X-Request-Id: 7482e79f-78c5-491a-88fc-15c6bd399e61
200 OK
```


```json
{
  "data": {
    "id": "6643a06c-3897-4e68-b39c-591c5cd0f234",
    "type": "syntax",
    "attributes": {
      "account_id": "86c5e5c8-d98b-4019-ae2f-958eb74b2dbf",
      "archived": true,
      "archived_at": "2020-05-01T17:29:55.025Z",
      "description": "Description",
      "name": "Syntax 8361ae94d5bf",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=6643a06c-3897-4e68-b39c-591c5cd0f234",
          "self": "/syntaxes/6643a06c-3897-4e68-b39c-591c5cd0f234/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/8e189f60-8bca-437d-92b6-8c8bae021f76",
          "self": "/syntax_nodes/8e189f60-8bca-437d-92b6-8c8bae021f76/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/6643a06c-3897-4e68-b39c-591c5cd0f234/archive"
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
X-Request-Id: de6d972c-eb8e-41f0-8592-36079b1672f5
200 OK
```


```json
{
  "data": [
    {
      "id": "270d62e0-9479-4dd0-91ce-50addcc4f956",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 18",
        "hex_color": "102ecb"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/c5167b33-c85a-44ff-a558-432d9a3a7f13"
          }
        },
        "classification_table": {
          "data": {
            "id": "b968671b-5b3e-43a8-a592-6dd6bb961531",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/b968671b-5b3e-43a8-a592-6dd6bb961531",
            "self": "/syntax_elements/270d62e0-9479-4dd0-91ce-50addcc4f956/relationships/classification_table"
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
GET /syntax_elements/c892b019-4d84-47b2-90fe-02a95570f4cd
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
X-Request-Id: 9dc0b3e3-32c1-4228-a2d0-9810e1dd908b
200 OK
```


```json
{
  "data": {
    "id": "c892b019-4d84-47b2-90fe-02a95570f4cd",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 19",
      "hex_color": "a72db3"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/153640ba-3990-4388-999f-8d0af39a3c57"
        }
      },
      "classification_table": {
        "data": {
          "id": "3957261f-ca16-429f-b3f5-9547d15326c6",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/3957261f-ca16-429f-b3f5-9547d15326c6",
          "self": "/syntax_elements/c892b019-4d84-47b2-90fe-02a95570f4cd/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/c892b019-4d84-47b2-90fe-02a95570f4cd"
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
POST /syntaxes/9ea9585a-1a7b-46ae-b620-0e1211823586/relationships/syntax_elements
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
          "id": "57cb0a25-ff6f-4e06-9a0b-a9a37e117558"
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
X-Request-Id: 5e95a0e6-edba-4d34-8ada-dc6de572da0c
201 Created
```


```json
{
  "data": {
    "id": "c5d50bc3-8a6a-42ba-9cf1-6fe32289bd9b",
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
          "related": "/syntaxes/9ea9585a-1a7b-46ae-b620-0e1211823586"
        }
      },
      "classification_table": {
        "data": {
          "id": "57cb0a25-ff6f-4e06-9a0b-a9a37e117558",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/57cb0a25-ff6f-4e06-9a0b-a9a37e117558",
          "self": "/syntax_elements/c5d50bc3-8a6a-42ba-9cf1-6fe32289bd9b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/9ea9585a-1a7b-46ae-b620-0e1211823586/relationships/syntax_elements"
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
PATCH /syntax_elements/375d6f78-5570-4219-b142-7b49ab462859
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "375d6f78-5570-4219-b142-7b49ab462859",
    "type": "syntax_element",
    "attributes": {
      "name": "New element",
      "hex_color": "ffffff"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "6e2af9ab-f830-4fb5-bff3-d7bd124920fb"
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
X-Request-Id: 31693d23-9a34-40c7-a1e5-019fcc47bcd4
200 OK
```


```json
{
  "data": {
    "id": "375d6f78-5570-4219-b142-7b49ab462859",
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
          "related": "/syntaxes/4fdff759-f3a8-4c8d-a14e-705958f65a63"
        }
      },
      "classification_table": {
        "data": {
          "id": "6e2af9ab-f830-4fb5-bff3-d7bd124920fb",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/6e2af9ab-f830-4fb5-bff3-d7bd124920fb",
          "self": "/syntax_elements/375d6f78-5570-4219-b142-7b49ab462859/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/375d6f78-5570-4219-b142-7b49ab462859"
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
DELETE /syntax_elements/f5343190-06f3-4b7f-9e39-9c43534969a8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a8e3875d-a283-42e9-9806-d2e9706e01f6
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
PATCH /syntax_elements/71a599bb-9dcd-4803-88b0-f41776534719/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "0a67085b-8b72-4770-9359-e83c5ac4f7af",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e7bb9ba9-a65b-40cd-9181-068c9e1c68b1
200 OK
```


```json
{
  "data": {
    "id": "71a599bb-9dcd-4803-88b0-f41776534719",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 23",
      "hex_color": "d4658a"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/3f0bb0a4-36b2-4507-a8bb-dc4ccc3ee567"
        }
      },
      "classification_table": {
        "data": {
          "id": "0a67085b-8b72-4770-9359-e83c5ac4f7af",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/0a67085b-8b72-4770-9359-e83c5ac4f7af",
          "self": "/syntax_elements/71a599bb-9dcd-4803-88b0-f41776534719/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/71a599bb-9dcd-4803-88b0-f41776534719/relationships/classification_table"
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
DELETE /syntax_elements/e54e2b0d-31c7-4076-a7b6-3e5c16070671/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 494d1d10-2023-474d-aa81-4c684817cd0b
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
X-Request-Id: 4f8c8a05-b5e9-4868-8398-e7efada0a1c2
200 OK
```


```json
{
  "data": [
    {
      "id": "70a99dc6-deac-43b4-b6a4-4222b625f96f",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/db48cea0-64a5-43ac-b410-e97231d0e593"
          }
        },
        "components": {
          "data": [
            {
              "id": "3d30a853-a91e-430c-a5e6-5e60f5809962",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/70a99dc6-deac-43b4-b6a4-4222b625f96f/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/70a99dc6-deac-43b4-b6a4-4222b625f96f/relationships/parent",
            "related": "/syntax_nodes/70a99dc6-deac-43b4-b6a4-4222b625f96f"
          }
        }
      }
    },
    {
      "id": "7b41b3d7-95cc-423b-aa32-e5aff0ab914f",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/db48cea0-64a5-43ac-b410-e97231d0e593"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/7b41b3d7-95cc-423b-aa32-e5aff0ab914f/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/7b41b3d7-95cc-423b-aa32-e5aff0ab914f/relationships/parent",
            "related": "/syntax_nodes/7b41b3d7-95cc-423b-aa32-e5aff0ab914f"
          }
        }
      }
    },
    {
      "id": "27deea45-649e-49d7-859c-1670a13bd4fa",
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
              "id": "d559a2df-2daf-4436-b920-3fff627e2dce",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/27deea45-649e-49d7-859c-1670a13bd4fa/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/27deea45-649e-49d7-859c-1670a13bd4fa/relationships/parent",
            "related": "/syntax_nodes/27deea45-649e-49d7-859c-1670a13bd4fa"
          }
        }
      }
    },
    {
      "id": "3d30a853-a91e-430c-a5e6-5e60f5809962",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/db48cea0-64a5-43ac-b410-e97231d0e593"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/3d30a853-a91e-430c-a5e6-5e60f5809962/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/3d30a853-a91e-430c-a5e6-5e60f5809962/relationships/parent",
            "related": "/syntax_nodes/3d30a853-a91e-430c-a5e6-5e60f5809962"
          }
        }
      }
    },
    {
      "id": "d559a2df-2daf-4436-b920-3fff627e2dce",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/db48cea0-64a5-43ac-b410-e97231d0e593"
          }
        },
        "components": {
          "data": [
            {
              "id": "70a99dc6-deac-43b4-b6a4-4222b625f96f",
              "type": "syntax_node"
            },
            {
              "id": "7b41b3d7-95cc-423b-aa32-e5aff0ab914f",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/d559a2df-2daf-4436-b920-3fff627e2dce/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/d559a2df-2daf-4436-b920-3fff627e2dce/relationships/parent",
            "related": "/syntax_nodes/d559a2df-2daf-4436-b920-3fff627e2dce"
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
GET /syntax_nodes/3c0a9d20-c7f0-418d-995b-7f896f413e93?depth=2
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
X-Request-Id: acad426b-52f6-409f-8bc9-ef59ada38441
200 OK
```


```json
{
  "data": {
    "id": "3c0a9d20-c7f0-418d-995b-7f896f413e93",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/fffeeeeb-7121-4aee-a322-a64374f492cf"
        }
      },
      "components": {
        "data": [
          {
            "id": "92359f61-6c1b-483a-9296-e9887350af96",
            "type": "syntax_node"
          },
          {
            "id": "b723a871-368d-4bfb-9674-318709f9bf6d",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/3c0a9d20-c7f0-418d-995b-7f896f413e93/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/3c0a9d20-c7f0-418d-995b-7f896f413e93/relationships/parent",
          "related": "/syntax_nodes/3c0a9d20-c7f0-418d-995b-7f896f413e93"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/3c0a9d20-c7f0-418d-995b-7f896f413e93?depth=2"
  },
  "included": [
    {
      "id": "b723a871-368d-4bfb-9674-318709f9bf6d",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fffeeeeb-7121-4aee-a322-a64374f492cf"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/b723a871-368d-4bfb-9674-318709f9bf6d/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/b723a871-368d-4bfb-9674-318709f9bf6d/relationships/parent",
            "related": "/syntax_nodes/b723a871-368d-4bfb-9674-318709f9bf6d"
          }
        }
      }
    },
    {
      "id": "92359f61-6c1b-483a-9296-e9887350af96",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fffeeeeb-7121-4aee-a322-a64374f492cf"
          }
        },
        "components": {
          "data": [
            {
              "id": "a121f0ee-67a8-4728-9e99-edae58c95de0",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/92359f61-6c1b-483a-9296-e9887350af96/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/92359f61-6c1b-483a-9296-e9887350af96/relationships/parent",
            "related": "/syntax_nodes/92359f61-6c1b-483a-9296-e9887350af96"
          }
        }
      }
    },
    {
      "id": "a121f0ee-67a8-4728-9e99-edae58c95de0",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fffeeeeb-7121-4aee-a322-a64374f492cf"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/a121f0ee-67a8-4728-9e99-edae58c95de0/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/a121f0ee-67a8-4728-9e99-edae58c95de0/relationships/parent",
            "related": "/syntax_nodes/a121f0ee-67a8-4728-9e99-edae58c95de0"
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
POST /syntax_nodes/cf809019-8cb1-4061-9c3f-8c6d656ceabe/relationships/components
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
          "id": "8255f9fa-0fe4-4742-96a5-cad7aad5514b"
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
X-Request-Id: 5ed2d848-131d-4714-8b2b-3eb8226191de
201 Created
```


```json
{
  "data": {
    "id": "13a3db63-dcfb-4368-acf2-489232e6b4f2",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/8255f9fa-0fe4-4742-96a5-cad7aad5514b"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/13a3db63-dcfb-4368-acf2-489232e6b4f2/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/13a3db63-dcfb-4368-acf2-489232e6b4f2/relationships/parent",
          "related": "/syntax_nodes/13a3db63-dcfb-4368-acf2-489232e6b4f2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/cf809019-8cb1-4061-9c3f-8c6d656ceabe/relationships/components"
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
PATCH /syntax_nodes/30b756a3-5bb9-420f-aa0e-64e456322206/relationships/parent
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
    "id": "c197a840-9228-4a10-98fc-dc2d18352b40"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4a715a26-a2c5-4543-9898-4476e4371c69
200 OK
```


```json
{
  "data": {
    "id": "30b756a3-5bb9-420f-aa0e-64e456322206",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 2
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/c25903df-bc9a-483b-8a9e-22fb42781730"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/30b756a3-5bb9-420f-aa0e-64e456322206/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/30b756a3-5bb9-420f-aa0e-64e456322206/relationships/parent",
          "related": "/syntax_nodes/30b756a3-5bb9-420f-aa0e-64e456322206"
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
PATCH /syntax_nodes/cd1c9b70-707c-4b76-9576-476ed7c20239
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "cd1c9b70-707c-4b76-9576-476ed7c20239",
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
X-Request-Id: 4489d6fa-f258-41e4-97b9-c627d6a8b330
200 OK
```


```json
{
  "data": {
    "id": "cd1c9b70-707c-4b76-9576-476ed7c20239",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/04865e6e-bf6c-4d65-b5ca-7a7d247f0bd3"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/cd1c9b70-707c-4b76-9576-476ed7c20239/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/cd1c9b70-707c-4b76-9576-476ed7c20239/relationships/parent",
          "related": "/syntax_nodes/cd1c9b70-707c-4b76-9576-476ed7c20239"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/cd1c9b70-707c-4b76-9576-476ed7c20239"
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
DELETE /syntax_nodes/d8651c2b-3a46-41c7-8034-51a4ebdb0d07
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 95222c99-c037-4e2b-971a-f7379f0edb15
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
X-Request-Id: 44b875f4-7a0f-4512-9212-7dc79b8796d5
200 OK
```


```json
{
  "data": [
    {
      "id": "a98f8def-015f-4e3d-8392-7cbba59f82f6",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 105,
        "published": true,
        "published_at": "2020-05-01T17:30:08.094Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a98f8def-015f-4e3d-8392-7cbba59f82f6",
            "self": "/progress_models/a98f8def-015f-4e3d-8392-7cbba59f82f6/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "c321ddb9-0d4c-4958-8d0e-2b67633a4f92",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=c321ddb9-0d4c-4958-8d0e-2b67633a4f92",
            "self": "/progress_models/c321ddb9-0d4c-4958-8d0e-2b67633a4f92/relationships/progress_steps"
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
GET /progress_models/3888cfa1-2a69-463e-a950-afb2d6dfe146
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
X-Request-Id: 65a2ab41-efeb-444c-8029-255c3e5c3d5a
200 OK
```


```json
{
  "data": {
    "id": "3888cfa1-2a69-463e-a950-afb2d6dfe146",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 107,
      "published": true,
      "published_at": "2020-05-01T17:30:09.196Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=3888cfa1-2a69-463e-a950-afb2d6dfe146",
          "self": "/progress_models/3888cfa1-2a69-463e-a950-afb2d6dfe146/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/3888cfa1-2a69-463e-a950-afb2d6dfe146"
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
PATCH /progress_models/766c7dca-3ec0-423d-9995-ae2625350c51
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "766c7dca-3ec0-423d-9995-ae2625350c51",
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
X-Request-Id: 32eeb687-3039-48f6-abf3-55de9ebb8cd1
200 OK
```


```json
{
  "data": {
    "id": "766c7dca-3ec0-423d-9995-ae2625350c51",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=766c7dca-3ec0-423d-9995-ae2625350c51",
          "self": "/progress_models/766c7dca-3ec0-423d-9995-ae2625350c51/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/766c7dca-3ec0-423d-9995-ae2625350c51"
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
DELETE /progress_models/6dc58409-00f7-4ae0-80dd-8e27da5f508d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: bf829b16-976e-4505-8066-5c36f6db1a31
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
POST /progress_models/8841fb15-dde5-4b95-b02d-1cdb1bd75251/publish
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
X-Request-Id: 14f8eae9-09bd-4912-91f5-c9580b259593
200 OK
```


```json
{
  "data": {
    "id": "8841fb15-dde5-4b95-b02d-1cdb1bd75251",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 114,
      "published": true,
      "published_at": "2020-05-01T17:30:11.698Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=8841fb15-dde5-4b95-b02d-1cdb1bd75251",
          "self": "/progress_models/8841fb15-dde5-4b95-b02d-1cdb1bd75251/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/8841fb15-dde5-4b95-b02d-1cdb1bd75251/publish"
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
POST /progress_models/c5da4261-e4fb-40c4-97ad-7310ea8f97de/archive
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
X-Request-Id: b2354acf-29f0-4e01-8c10-5ccd13443f17
200 OK
```


```json
{
  "data": {
    "id": "c5da4261-e4fb-40c4-97ad-7310ea8f97de",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-05-01T17:30:12.219Z",
      "name": "pm 2",
      "order": 116,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=c5da4261-e4fb-40c4-97ad-7310ea8f97de",
          "self": "/progress_models/c5da4261-e4fb-40c4-97ad-7310ea8f97de/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/c5da4261-e4fb-40c4-97ad-7310ea8f97de/archive"
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
X-Request-Id: 9a168b24-71b8-404e-a930-7ec570851cbd
201 Created
```


```json
{
  "data": {
    "id": "a5278455-4df2-41a0-a083-b87aac26f9ee",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a5278455-4df2-41a0-a083-b87aac26f9ee",
          "self": "/progress_models/a5278455-4df2-41a0-a083-b87aac26f9ee/relationships/progress_steps"
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
X-Request-Id: 129204c4-2268-4095-a49c-fea3256e75b1
200 OK
```


```json
{
  "data": [
    {
      "id": "ab05d0eb-6062-453a-b0b9-755f135f4e80",
      "type": "progress_step",
      "attributes": {
        "name": "ps context",
        "order": 1,
        "hex_color": "247d0f"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/158781af-f6a2-4c5f-8fd8-ddfc79717f65"
          }
        }
      }
    },
    {
      "id": "3c25caef-769a-4a53-a619-7cb3ea2ed917",
      "type": "progress_step",
      "attributes": {
        "name": "ps ooc",
        "order": 1,
        "hex_color": "079715"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/f37f32be-f5e4-4a6a-9b37-81a6aa9f1ab9"
          }
        }
      }
    },
    {
      "id": "770f3243-00e4-4ebb-b6ee-ffe6b999c7c1",
      "type": "progress_step",
      "attributes": {
        "name": "ps oor",
        "order": 1,
        "hex_color": "edac8f"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/b5571270-facd-4e6e-a3e2-b0555f951b56"
          }
        }
      }
    },
    {
      "id": "c96289ce-779c-4a4a-9e29-28983dcd8b9a",
      "type": "progress_step",
      "attributes": {
        "name": "ps project",
        "order": 1,
        "hex_color": "5ec761"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/2e937598-cd2f-4b23-bc96-40eef28fd533"
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
GET /progress_steps/93c7cbc8-a1e1-4e03-8329-34dc5fafc7f2
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
X-Request-Id: a2b3dcc7-dd33-46ab-aab3-c97c2574808c
200 OK
```


```json
{
  "data": {
    "id": "93c7cbc8-a1e1-4e03-8329-34dc5fafc7f2",
    "type": "progress_step",
    "attributes": {
      "name": "ps oor",
      "order": 1,
      "hex_color": "c603f7"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/3899b012-a094-4b11-94be-fd808161458e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/93c7cbc8-a1e1-4e03-8329-34dc5fafc7f2"
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
PATCH /progress_steps/7a8e4374-c714-4617-ae1d-70d831f427c9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "7a8e4374-c714-4617-ae1d-70d831f427c9",
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
X-Request-Id: 9ec9f04e-d10e-41f9-b2bf-9ada2f054ebf
200 OK
```


```json
{
  "data": {
    "id": "7a8e4374-c714-4617-ae1d-70d831f427c9",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 1,
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/e1576b75-c860-4916-9db7-a9f11bc224f3"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/7a8e4374-c714-4617-ae1d-70d831f427c9"
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
DELETE /progress_steps/7db8df3e-ef1d-47d6-a493-7d3c0116c916
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4277b434-5db0-4d10-b86c-4cc7630862f7
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
POST /progress_models/56525632-7066-440d-908e-590ff6d7017a/relationships/progress_steps
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
X-Request-Id: fcd9e5f2-9080-4a09-afb5-49cc7a289344
201 Created
```


```json
{
  "data": {
    "id": "b8aa425b-b169-4a7e-96bb-2f5ff8f304bd",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/56525632-7066-440d-908e-590ff6d7017a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/56525632-7066-440d-908e-590ff6d7017a/relationships/progress_steps"
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
X-Request-Id: 9327eb2f-e081-4a14-970e-974e9421f504
200 OK
```


```json
{
  "data": [
    {
      "id": "e37d4458-3c15-4923-95bc-f3c2ebe4e7ea",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "234d31d1-7a5d-4fe3-9683-1cfe8833ea68",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/234d31d1-7a5d-4fe3-9683-1cfe8833ea68"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/5279de3c-0750-4a51-a0ff-9e644efce125"
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
GET /progress/be8da214-790e-4898-a6be-8d37886c480b
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
X-Request-Id: 0b5f81d4-2a6f-4604-969d-97fb3adc8d3a
200 OK
```


```json
{
  "data": {
    "id": "be8da214-790e-4898-a6be-8d37886c480b",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "8c30e3b7-ad70-4718-a87e-6e927e273d7f",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/8c30e3b7-ad70-4718-a87e-6e927e273d7f"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/d5080706-3587-42c2-a2c9-fe35fac69542"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/be8da214-790e-4898-a6be-8d37886c480b"
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
DELETE /progress/e466a3eb-9eb5-405f-a4cf-6bbe5db18df7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 19db93c2-91db-408f-9220-b298a0ae65e4
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
          "id": "8fe8bda0-9afb-4d2d-a8d0-d57443a2ffda"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "ac8ee850-98fa-4a82-a102-f03ae84291e2"
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
X-Request-Id: 2d3b482a-ca3a-48bf-99fd-54a756506ab5
201 Created
```


```json
{
  "data": {
    "id": "15558f9d-50a8-43c7-89d4-92871208cbe1",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "data": {
          "id": "8fe8bda0-9afb-4d2d-a8d0-d57443a2ffda",
          "type": "progress_step"
        },
        "links": {
          "related": "/progress_steps/8fe8bda0-9afb-4d2d-a8d0-d57443a2ffda"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/ac8ee850-98fa-4a82-a102-f03ae84291e2"
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
X-Request-Id: a213e5cd-02c8-47ec-a2ee-bcd289d5a31b
200 OK
```


```json
{
  "data": [
    {
      "id": "11ec5fcd-0244-4551-9fc2-fe0091fce2c2",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "b46f54b4-abc1-4b5f-a95f-bbbac0e8d954"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/b46f54b4-abc1-4b5f-a95f-bbbac0e8d954"
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
GET /projects/fe5c6f0c-0340-43b7-be78-11d67579750c/relationships/project_setting
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
X-Request-Id: d0e1286f-8849-457b-b2c2-a18f270e7227
200 OK
```


```json
{
  "data": {
    "id": "d3e70cfd-ee4d-41aa-915f-240db058d7ae",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "fe5c6f0c-0340-43b7-be78-11d67579750c"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/fe5c6f0c-0340-43b7-be78-11d67579750c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/fe5c6f0c-0340-43b7-be78-11d67579750c/relationships/project_setting"
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
PATCH /projects/767c8552-b940-4447-9094-fe5b3833b0f2/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "767c8552-b940-4447-9094-fe5b3833b0f2",
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
X-Request-Id: 9c3e3371-c337-40bf-9d36-dd2672ff6f84
200 OK
```


```json
{
  "data": {
    "id": "8a8b115a-3167-433d-87ee-8b8e35f3926b",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "767c8552-b940-4447-9094-fe5b3833b0f2"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/767c8552-b940-4447-9094-fe5b3833b0f2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/767c8552-b940-4447-9094-fe5b3833b0f2/relationships/project_setting"
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
X-Request-Id: 389f07ef-6994-4429-aa05-47bc6c4c9ee0
200 OK
```


```json
{
  "data": [
    {
      "id": "9aec0d61-d807-46e1-b0d6-7943d39a5bcd",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/9aec0d61-d807-46e1-b0d6-7943d39a5bcd"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/9aec0d61-d807-46e1-b0d6-7943d39a5bcd"
          }
        }
      }
    },
    {
      "id": "02fd73c3-b9be-4cea-a655-dcb991e6876a",
      "type": "system_element",
      "attributes": {
        "name": "ObjectOccurrence b44dcc937030-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/02fd73c3-b9be-4cea-a655-dcb991e6876a"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/02fd73c3-b9be-4cea-a655-dcb991e6876a"
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
GET /system_elements/96ec9342-b59e-4bef-b992-bafebd7046c8
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
X-Request-Id: 93cf5628-9f96-440d-8477-15ba2e83a616
200 OK
```


```json
{
  "data": {
    "id": "96ec9342-b59e-4bef-b992-bafebd7046c8",
    "type": "system_element",
    "attributes": {
      "name": "ObjectOccurrence 0460732aa938-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/96ec9342-b59e-4bef-b992-bafebd7046c8"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/96ec9342-b59e-4bef-b992-bafebd7046c8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/96ec9342-b59e-4bef-b992-bafebd7046c8"
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
POST /object_occurrences/a9ef79a5-7887-4ea9-b625-774dffac2afd/relationships/system_elements
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
      "target_id": "48cf4d66-0a65-44ba-b5b1-ba3abe821edd"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c1ddd14c-7bf6-4225-a5a2-b9b5bc9b1e13
201 Created
```


```json
{
  "data": {
    "id": "bf5139b8-3988-4988-8b4e-a79b71e959a2",
    "type": "system_element",
    "attributes": {
      "name": "ObjectOccurrence 7c530dc9dade-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/bf5139b8-3988-4988-8b4e-a79b71e959a2"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/bf5139b8-3988-4988-8b4e-a79b71e959a2"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/a9ef79a5-7887-4ea9-b625-774dffac2afd/relationships/system_elements"
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
DELETE /object_occurrences/6e9d802a-70a5-4b16-beba-a2a9cd65850f/relationships/system_elements/7b167bff-6f28-45aa-a844-cd5ee25da233
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 08c0287a-7af0-4c51-8497-164b1d18d63d
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
POST /object_occurrence_relations/8d4c0c43-5530-4e1d-994a-b86172fced66/relationships/owners
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
X-Request-Id: 05ffc74c-1e41-4e71-a1fc-2aadde401343
201 Created
```


```json
{
  "data": {
    "id": "56d5fdc6-20ea-456f-b2b8-1b00e68aa3c0",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/8d4c0c43-5530-4e1d-994a-b86172fced66/relationships/owners"
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
POST /object_occurrence_relations/df9c58bc-d74a-4a3d-816c-2df51ab4dfdc/relationships/owners
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
X-Request-Id: 72f5565c-0900-493a-b054-3d1697f2f3fe
201 Created
```


```json
{
  "data": {
    "id": "0f2018e1-5ea3-4113-9580-d07f660f1015",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/df9c58bc-d74a-4a3d-816c-2df51ab4dfdc/relationships/owners"
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
POST /object_occurrence_relations/f6f73f31-7c6e-42a4-896c-c24175a99a3f/relationships/owners
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
    "id": "00b55583-8e43-4036-8b9c-4734592c9057"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0916fd1f-8136-4bd4-a047-1598820ac4ac
201 Created
```


```json
{
  "data": {
    "id": "00b55583-8e43-4036-8b9c-4734592c9057",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 21",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/f6f73f31-7c6e-42a4-896c-c24175a99a3f/relationships/owners"
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
DELETE /object_occurrence_relations/f210b7c0-ef1a-4ed1-8eed-bea7d0f9c6da/relationships/owners/43861cfd-09b4-40f3-b2cc-061abd306cf4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3cb071c4-fcf5-418c-adee-4cc23772c318
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
X-Request-Id: f648694b-e85e-4c1f-a11a-74918d91f3a1
200 OK
```


```json
{
  "data": [
    {
      "id": "552f0d93-13bd-48ea-855b-190a05f8d4db",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation 803e2b623219",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "e1cbf262-86ed-4160-b625-4570e53654dc",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=552f0d93-13bd-48ea-855b-190a05f8d4db",
            "self": "/object_occurrence_relations/552f0d93-13bd-48ea-855b-190a05f8d4db/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "1eb86680-6da4-47c5-b87e-077e72130cb3",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=552f0d93-13bd-48ea-855b-190a05f8d4db&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/552f0d93-13bd-48ea-855b-190a05f8d4db/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "6739fb7d-7141-4c92-a93e-b822812d1ed3",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=552f0d93-13bd-48ea-855b-190a05f8d4db"
          }
        },
        "classification_entry": {
          "data": {
            "id": "688e7ae1-0370-4137-889c-54a80a4fb960",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/688e7ae1-0370-4137-889c-54a80a4fb960",
            "self": "/object_occurrence_relations/552f0d93-13bd-48ea-855b-190a05f8d4db/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "df90993d-3e6a-4c73-bc66-1e2426e444b5",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/df90993d-3e6a-4c73-bc66-1e2426e444b5",
            "self": "/object_occurrence_relations/552f0d93-13bd-48ea-855b-190a05f8d4db/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "1ce25915-4225-4ce4-94b9-40022923287f",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/1ce25915-4225-4ce4-94b9-40022923287f",
            "self": "/object_occurrence_relations/552f0d93-13bd-48ea-855b-190a05f8d4db/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "688e7ae1-0370-4137-889c-54a80a4fb960",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 6a54a0a9f837",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=688e7ae1-0370-4137-889c-54a80a4fb960",
            "self": "/classification_entries/688e7ae1-0370-4137-889c-54a80a4fb960/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=688e7ae1-0370-4137-889c-54a80a4fb960",
            "self": "/classification_entries/688e7ae1-0370-4137-889c-54a80a4fb960/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "1eb86680-6da4-47c5-b87e-077e72130cb3",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 24",
        "title": null
      }
    },
    {
      "id": "6739fb7d-7141-4c92-a93e-b822812d1ed3",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "de2c33e5-eb5e-49af-864e-c5838338128c",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/de2c33e5-eb5e-49af-864e-c5838338128c"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/552f0d93-13bd-48ea-855b-190a05f8d4db"
          }
        }
      }
    },
    {
      "id": "e1cbf262-86ed-4160-b625-4570e53654dc",
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
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=931f4c60-28ad-4d8b-8b4b-a9b681229358&amp;filter[object_occurrence_source_ids_cont][]=07146a1e-3c88-4eb1-9226-5ca83ab02d3c&amp;filter[object_occurrence_target_ids_cont][]=ec8621f1-1197-49b7-b406-03c96298db0a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;931f4c60-28ad-4d8b-8b4b-a9b681229358&quot;, &quot;07146a1e-3c88-4eb1-9226-5ca83ab02d3c&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;ec8621f1-1197-49b7-b406-03c96298db0a&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 52f539eb-a587-469f-923b-7b15d5fd8496
200 OK
```


```json
{
  "data": [
    {
      "id": "e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "ObjectOccurrenceRelation 16ff3e01eecf",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [
            {
              "id": "0b02c477-f9aa-4db1-90db-d5d67872bf56",
              "type": "tag"
            }
          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a",
            "self": "/object_occurrence_relations/e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a/relationships/tags"
          }
        },
        "owners": {
          "data": [
            {
              "id": "66186890-a54e-4b6c-9aaa-ea1893f79f20",
              "type": "owner"
            }
          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [
            {
              "id": "ea4758a9-62ae-4e14-b8c4-696c6659434c",
              "type": "progress_step_checked"
            }
          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a"
          }
        },
        "classification_entry": {
          "data": {
            "id": "7c0bd67b-0309-4ee9-8faf-049a1df8a456",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/7c0bd67b-0309-4ee9-8faf-049a1df8a456",
            "self": "/object_occurrence_relations/e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "ec8621f1-1197-49b7-b406-03c96298db0a",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/ec8621f1-1197-49b7-b406-03c96298db0a",
            "self": "/object_occurrence_relations/e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "931f4c60-28ad-4d8b-8b4b-a9b681229358",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/931f4c60-28ad-4d8b-8b4b-a9b681229358",
            "self": "/object_occurrence_relations/e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "7c0bd67b-0309-4ee9-8faf-049a1df8a456",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 2aa855c76ad1",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=7c0bd67b-0309-4ee9-8faf-049a1df8a456",
            "self": "/classification_entries/7c0bd67b-0309-4ee9-8faf-049a1df8a456/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=7c0bd67b-0309-4ee9-8faf-049a1df8a456",
            "self": "/classification_entries/7c0bd67b-0309-4ee9-8faf-049a1df8a456/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "66186890-a54e-4b6c-9aaa-ea1893f79f20",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 25",
        "title": null
      }
    },
    {
      "id": "ea4758a9-62ae-4e14-b8c4-696c6659434c",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "703e304e-5e13-4071-b67b-f5abb382a11e",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/703e304e-5e13-4071-b67b-f5abb382a11e"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/e7e4b6c6-6de4-4834-bea1-669f5fa5fd8a"
          }
        }
      }
    },
    {
      "id": "0b02c477-f9aa-4db1-90db-d5d67872bf56",
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
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=931f4c60-28ad-4d8b-8b4b-a9b681229358&filter[object_occurrence_source_ids_cont][]=07146a1e-3c88-4eb1-9226-5ca83ab02d3c&filter[object_occurrence_target_ids_cont][]=ec8621f1-1197-49b7-b406-03c96298db0a",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=931f4c60-28ad-4d8b-8b4b-a9b681229358&filter[object_occurrence_source_ids_cont][]=07146a1e-3c88-4eb1-9226-5ca83ab02d3c&filter[object_occurrence_target_ids_cont][]=ec8621f1-1197-49b7-b406-03c96298db0a&include=tags,owners,progress_step_checked,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f
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
X-Request-Id: 557f3000-92e9-42f8-8946-677acff62141
200 OK
```


```json
{
  "data": {
    "id": "fad17e52-6f33-4ce5-8e9d-7fca3919355f",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "ObjectOccurrenceRelation 33b7135fd5c0",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [
          {
            "id": "2511c1fa-51f2-4fa0-a052-84db13d84e24",
            "type": "tag"
          }
        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=fad17e52-6f33-4ce5-8e9d-7fca3919355f",
          "self": "/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f/relationships/tags"
        }
      },
      "owners": {
        "data": [
          {
            "id": "6a893db5-ff21-4663-aad1-c4588f95632a",
            "type": "owner"
          }
        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=fad17e52-6f33-4ce5-8e9d-7fca3919355f&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f/relationships/owners"
        }
      },
      "progress_step_checked": {
        "data": [
          {
            "id": "0ea5e412-54c2-44c6-bcfb-c4993f80afbf",
            "type": "progress_step_checked"
          }
        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=fad17e52-6f33-4ce5-8e9d-7fca3919355f"
        }
      },
      "classification_entry": {
        "data": {
          "id": "16f1597f-2b41-4f3e-bd1e-0bcf383ea88f",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/16f1597f-2b41-4f3e-bd1e-0bcf383ea88f",
          "self": "/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "b7e46782-4d2b-4e13-9aaf-2ea5c1561245",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/b7e46782-4d2b-4e13-9aaf-2ea5c1561245",
          "self": "/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "a2a8ff1e-976d-4695-b401-daea6e8ddca5",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/a2a8ff1e-976d-4695-b401-daea6e8ddca5",
          "self": "/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f"
  },
  "included": [
    {
      "id": "16f1597f-2b41-4f3e-bd1e-0bcf383ea88f",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal R",
        "name": "Alarm 41a87302dd59",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=16f1597f-2b41-4f3e-bd1e-0bcf383ea88f",
            "self": "/classification_entries/16f1597f-2b41-4f3e-bd1e-0bcf383ea88f/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=16f1597f-2b41-4f3e-bd1e-0bcf383ea88f",
            "self": "/classification_entries/16f1597f-2b41-4f3e-bd1e-0bcf383ea88f/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "6a893db5-ff21-4663-aad1-c4588f95632a",
      "type": "owner",
      "attributes": {
        "company": null,
        "name": "Owner 26",
        "title": null
      }
    },
    {
      "id": "0ea5e412-54c2-44c6-bcfb-c4993f80afbf",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "data": {
            "id": "9a796b74-f27e-4c67-9291-4a56a1d027fc",
            "type": "progress_step"
          },
          "links": {
            "related": "/progress_steps/9a796b74-f27e-4c67-9291-4a56a1d027fc"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrence_relations/fad17e52-6f33-4ce5-8e9d-7fca3919355f"
          }
        }
      }
    },
    {
      "id": "2511c1fa-51f2-4fa0-a052-84db13d84e24",
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
X-Request-Id: dda3b170-2726-4149-a20b-312b33265e32
200 OK
```


```json
{
  "data": [
    {
      "id": "17b161db73901676f9985954e043eb7e4e65375c863ca79601d5f5d9772b134c",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "118cdacf-c5fc-4e85-b044-d48adc41406d",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/118cdacf-c5fc-4e85-b044-d48adc41406d"
          }
        }
      }
    },
    {
      "id": "61b7fd0023dd8f69213f86bc5cb6c84045544a45e4f2e1082a3159b59b59bec1",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "394fa222-a3ae-4dd6-8519-ad76c21d81be",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/394fa222-a3ae-4dd6-8519-ad76c21d81be"
          }
        }
      }
    },
    {
      "id": "060172c30539b6c2c611a4d66fa825fb6ec69b2f7a7f750bbde5815a1af2d798",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "0a9b08c5-b2f7-402d-be74-e9cbe91ef3b1",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/0a9b08c5-b2f7-402d-be74-e9cbe91ef3b1"
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
X-Request-Id: 6e23e49a-1dac-4958-a6af-44cd72c995be
200 OK
```


```json
{
  "data": [
    {
      "id": "735311bd-3935-4168-8502-bd944e8b59c3",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "9eb53270-b3e2-43be-a557-da954eed3938",
            "type": "project"
          },
          "links": {
            "related": "/projects/9eb53270-b3e2-43be-a557-da954eed3938"
          }
        },
        "user": {
          "data": {
            "id": "05ba9a36-787b-4fde-adfc-a6bfa837d406",
            "type": "user"
          },
          "links": {
            "related": "/users/05ba9a36-787b-4fde-adfc-a6bfa837d406"
          }
        },
        "permission": {
          "data": {
            "id": "251ca653-3858-4334-9db9-65eb0ff6fd6e",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/251ca653-3858-4334-9db9-65eb0ff6fd6e"
          }
        }
      }
    },
    {
      "id": "02f112ed-520f-4941-bb65-e74f3600df74",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "e1858c7b-7b53-4d56-9e6b-f806d462f14e",
            "type": "context"
          },
          "links": {
            "related": "/contexts/e1858c7b-7b53-4d56-9e6b-f806d462f14e"
          }
        },
        "user": {
          "data": {
            "id": "05ba9a36-787b-4fde-adfc-a6bfa837d406",
            "type": "user"
          },
          "links": {
            "related": "/users/05ba9a36-787b-4fde-adfc-a6bfa837d406"
          }
        },
        "permission": {
          "data": {
            "id": "9f8428fc-9ba2-4a2b-873b-e697cd1aba0b",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/9f8428fc-9ba2-4a2b-873b-e697cd1aba0b"
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
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=3e128e32-6f01-41ea-b60c-65530cb12d72&amp;filter[user_id_eq]=ccbacbf4-193e-4497-a617-9de975d68a38&amp;filter[permission_id_eq]=620fe197-d951-482e-b82d-7c40b4cd3a96
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;3e128e32-6f01-41ea-b60c-65530cb12d72&quot;, &quot;user_id_eq&quot;=&gt;&quot;ccbacbf4-193e-4497-a617-9de975d68a38&quot;, &quot;permission_id_eq&quot;=&gt;&quot;620fe197-d951-482e-b82d-7c40b4cd3a96&quot;}
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
X-Request-Id: 098078aa-788f-44b1-82b4-e8e4b3d288e0
200 OK
```


```json
{
  "data": [
    {
      "id": "f897ea69-39d9-4e15-9039-f9010f6d193b",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "3e128e32-6f01-41ea-b60c-65530cb12d72",
            "type": "project"
          },
          "links": {
            "related": "/projects/3e128e32-6f01-41ea-b60c-65530cb12d72"
          }
        },
        "user": {
          "data": {
            "id": "ccbacbf4-193e-4497-a617-9de975d68a38",
            "type": "user"
          },
          "links": {
            "related": "/users/ccbacbf4-193e-4497-a617-9de975d68a38"
          }
        },
        "permission": {
          "data": {
            "id": "620fe197-d951-482e-b82d-7c40b4cd3a96",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/620fe197-d951-482e-b82d-7c40b4cd3a96"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/user_permissions?filter[target_type_eq]=project&filter[target_id_eq]=3e128e32-6f01-41ea-b60c-65530cb12d72&filter[user_id_eq]=ccbacbf4-193e-4497-a617-9de975d68a38&filter[permission_id_eq]=620fe197-d951-482e-b82d-7c40b4cd3a96",
    "current": "http://example.org/user_permissions?filter[permission_id_eq]=620fe197-d951-482e-b82d-7c40b4cd3a96&filter[target_id_eq]=3e128e32-6f01-41ea-b60c-65530cb12d72&filter[target_type_eq]=project&filter[user_id_eq]=ccbacbf4-193e-4497-a617-9de975d68a38&page[number]=1"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /user_permissions/93a52b00-9409-47df-b09f-43f282544bc3
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
X-Request-Id: 5b0d1c90-d45e-40cf-a636-20451ae988b3
200 OK
```


```json
{
  "data": {
    "id": "93a52b00-9409-47df-b09f-43f282544bc3",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "d384b22d-a5bd-4454-8987-930ada6ad252",
          "type": "project"
        },
        "links": {
          "related": "/projects/d384b22d-a5bd-4454-8987-930ada6ad252"
        }
      },
      "user": {
        "data": {
          "id": "d283dbd7-6792-4209-868a-6c9cbcb79e7a",
          "type": "user"
        },
        "links": {
          "related": "/users/d283dbd7-6792-4209-868a-6c9cbcb79e7a"
        }
      },
      "permission": {
        "data": {
          "id": "61ef0926-6378-4c0b-9961-b04dc0b949c6",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/61ef0926-6378-4c0b-9961-b04dc0b949c6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions/93a52b00-9409-47df-b09f-43f282544bc3"
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
          "id": "19836e1f-e65a-40f7-91d4-c10c4072aaf2"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "cb859a51-95d0-4f79-b4d7-30b20c902a93"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "8e31d9e9-e9ae-4fda-9721-441173769223"
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
X-Request-Id: bf89e24d-f684-44c6-aa76-6b5df3736a60
201 Created
```


```json
{
  "data": {
    "id": "aaab72ba-ed5b-4ff3-9a55-bf8db3830307",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "19836e1f-e65a-40f7-91d4-c10c4072aaf2",
          "type": "project"
        },
        "links": {
          "related": "/projects/19836e1f-e65a-40f7-91d4-c10c4072aaf2"
        }
      },
      "user": {
        "data": {
          "id": "8e31d9e9-e9ae-4fda-9721-441173769223",
          "type": "user"
        },
        "links": {
          "related": "/users/8e31d9e9-e9ae-4fda-9721-441173769223"
        }
      },
      "permission": {
        "data": {
          "id": "cb859a51-95d0-4f79-b4d7-30b20c902a93",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/cb859a51-95d0-4f79-b4d7-30b20c902a93"
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
DELETE /user_permissions/93028237-06eb-4416-8b3c-e06334823362
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e9720829-7a79-4196-a5b0-65fb14382a94
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
X-Request-Id: 00d99947-072e-4384-99e8-35f0a7ca69d3
200 OK
```


```json
{
  "data": {
    "id": "b0764ef7-cdd4-49f7-ae79-4322bf5194d1",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "da810bd6-9f22-4689-b1ef-dc1093bc9c61"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/da810bd6-9f22-4689-b1ef-dc1093bc9c61"
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
X-Request-Id: f471cf13-21e7-459a-871e-c338991cbdae
200 OK
```


```json
{
  "data": {
    "id": "0a4b1c03-ddae-4714-a9cd-0cb3110e1540",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "0de54a37-7ca4-498f-8e42-644ffe65be62"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/0de54a37-7ca4-498f-8e42-644ffe65be62"
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
GET /chain_analysis/b8c5db71-9428-43c9-af39-c87c777792c9?steps=2
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
X-Request-Id: b7024921-a569-4baf-9fd1-85a3678d054c
200 OK
```


```json
{
  "data": [
    {
      "id": "7535ab6f-6b5d-4173-ac0f-22ee483eb688",
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
            "related": "/tags?filter[target_id_eq]=7535ab6f-6b5d-4173-ac0f-22ee483eb688",
            "self": "/object_occurrences/7535ab6f-6b5d-4173-ac0f-22ee483eb688/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=7535ab6f-6b5d-4173-ac0f-22ee483eb688&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/7535ab6f-6b5d-4173-ac0f-22ee483eb688/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=7535ab6f-6b5d-4173-ac0f-22ee483eb688"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/d9ba3d4c-2d89-426b-a7af-a57e802b289b"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/34cac3a7-9d9e-4b50-b74b-11fcfb6f8b9c",
            "self": "/object_occurrences/7535ab6f-6b5d-4173-ac0f-22ee483eb688/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/7535ab6f-6b5d-4173-ac0f-22ee483eb688/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7535ab6f-6b5d-4173-ac0f-22ee483eb688"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7535ab6f-6b5d-4173-ac0f-22ee483eb688"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=7535ab6f-6b5d-4173-ac0f-22ee483eb688"
          }
        }
      }
    },
    {
      "id": "2af69956-4053-42c5-bfba-7733098bcefd",
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
            "related": "/tags?filter[target_id_eq]=2af69956-4053-42c5-bfba-7733098bcefd",
            "self": "/object_occurrences/2af69956-4053-42c5-bfba-7733098bcefd/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=2af69956-4053-42c5-bfba-7733098bcefd&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/2af69956-4053-42c5-bfba-7733098bcefd/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=2af69956-4053-42c5-bfba-7733098bcefd"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/d9ba3d4c-2d89-426b-a7af-a57e802b289b"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/34cac3a7-9d9e-4b50-b74b-11fcfb6f8b9c",
            "self": "/object_occurrences/2af69956-4053-42c5-bfba-7733098bcefd/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/2af69956-4053-42c5-bfba-7733098bcefd/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=2af69956-4053-42c5-bfba-7733098bcefd"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=2af69956-4053-42c5-bfba-7733098bcefd"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=2af69956-4053-42c5-bfba-7733098bcefd"
          }
        }
      }
    },
    {
      "id": "aad4de0d-d4ee-41f8-b688-96b0e580d714",
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
            "related": "/tags?filter[target_id_eq]=aad4de0d-d4ee-41f8-b688-96b0e580d714",
            "self": "/object_occurrences/aad4de0d-d4ee-41f8-b688-96b0e580d714/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=aad4de0d-d4ee-41f8-b688-96b0e580d714&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/aad4de0d-d4ee-41f8-b688-96b0e580d714/relationships/owners"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=aad4de0d-d4ee-41f8-b688-96b0e580d714"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/d9ba3d4c-2d89-426b-a7af-a57e802b289b"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/34cac3a7-9d9e-4b50-b74b-11fcfb6f8b9c",
            "self": "/object_occurrences/aad4de0d-d4ee-41f8-b688-96b0e580d714/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/aad4de0d-d4ee-41f8-b688-96b0e580d714/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "data": [

          ],
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=aad4de0d-d4ee-41f8-b688-96b0e580d714"
          }
        },
        "allowed_children_syntax_elements": {
          "data": [

          ],
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=aad4de0d-d4ee-41f8-b688-96b0e580d714"
          }
        },
        "allowed_children_classification_tables": {
          "data": [

          ],
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=aad4de0d-d4ee-41f8-b688-96b0e580d714"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/chain_analysis/b8c5db71-9428-43c9-af39-c87c777792c9?steps=2",
    "current": "http://example.org/chain_analysis/b8c5db71-9428-43c9-af39-c87c777792c9?page[number]=1&steps=2"
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
X-Request-Id: cddfcdd8-1a7b-41ef-9e47-52db958c3ad6
200 OK
```


```json
{
  "data": {
    "id": "directory/1234abcde.png",
    "type": "url_struct",
    "attributes": {
      "id": "directory/1234abcde.png",
      "url": "https://qa-sec-hub-document-bucket.s3.eu-west-1.amazonaws.com/directory/1234abcde.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=stubbed-akid%2F20200501%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Date=20200501T173054Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=b54e3da8028acea560dbd03cd3fd52c5a55e061ff943a7f110c06c74a6dfd198",
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
X-Request-Id: 46faa103-a0f2-4602-9c43-83ee1c2a7dc5
200 OK
```


```json
{
  "data": [
    {
      "id": "37d6acaf-a48c-4f82-bdeb-cbd017092f89",
      "type": "tag",
      "attributes": {
        "value": "tag value 29"
      },
      "relationships": {
      }
    },
    {
      "id": "924367d6-bebe-4de3-8371-d3d78c966de7",
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
X-Request-Id: 42b12c50-f035-4e45-a8f3-d21fd13cd08a
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
GET /permissions/0b154ffb-1b69-4e93-9e20-5ecbd4e79707
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
X-Request-Id: 4896a057-7804-4351-8ccf-7fef4eda6853
200 OK
```


```json
{
  "data": {
    "id": "0b154ffb-1b69-4e93-9e20-5ecbd4e79707",
    "type": "permission",
    "attributes": {
      "name": "account:write",
      "description": "MyText"
    }
  },
  "links": {
    "self": "http://example.org/permissions/0b154ffb-1b69-4e93-9e20-5ecbd4e79707"
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
GET /utils/path/from/object_occurrence/d20885d6-61ec-4b55-b217-3ad1f26802f6/to/object_occurrence/0d1f5afc-90a8-4910-92dc-8273465e2d24
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
X-Request-Id: 74ff6ffc-2521-4189-81af-f983071d711e
200 OK
```


```json
[
  {
    "id": "d20885d6-61ec-4b55-b217-3ad1f26802f6",
    "type": "object_occurrence"
  },
  {
    "id": "d5553324-88bf-40e8-9fff-c70550bee3b7",
    "type": "object_occurrence"
  },
  {
    "id": "3c1ce9cf-ddc8-451a-a9d7-01bc0d9c8de1",
    "type": "object_occurrence"
  },
  {
    "id": "d1d8c1b3-97b1-486e-934a-8908af1286c4",
    "type": "object_occurrence"
  },
  {
    "id": "caede079-8a00-475c-9936-55d909bd8b6a",
    "type": "object_occurrence"
  },
  {
    "id": "7ff5f3e1-91de-4ea3-b33f-a36c69f8abab",
    "type": "object_occurrence"
  },
  {
    "id": "0d1f5afc-90a8-4910-92dc-8273465e2d24",
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
X-Request-Id: ccc1e361-bead-40aa-a873-816ac881fd14
200 OK
```


```json
{
  "data": [
    {
      "id": "4f68b8d8-06aa-439d-9842-d742be1ae3c6",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/59d43bcf-7535-4e83-93ea-1397da43b6eb"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/5e2c3bee-2165-4c84-8561-bb6fafb8be2e"
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
X-Request-Id: 58e7a371-ab99-45e0-9006-28d7c85c59a9
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



