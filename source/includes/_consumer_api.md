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
X-Request-Id: f8c7be53-9f25-483f-ac6b-9443c8acd0e1
200 OK
```


```json
{
  "data": {
    "id": "45fc2e59-fe76-44f5-89ac-b29d4ff6f5c4",
    "type": "account",
    "attributes": {
      "name": "Account 167637e6c52b"
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
X-Request-Id: de89e9d1-4011-4ad5-b6f9-c1936a7fafeb
200 OK
```


```json
{
  "data": {
    "id": "9fed33b7-86af-4715-94b1-abb648400c7b",
    "type": "account",
    "attributes": {
      "name": "Account 7067fae62fd9"
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
    "id": "32df90ea-5ee7-4100-9bf0-5414dfcb58ed",
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
X-Request-Id: ea78f609-decb-422a-9ed9-d58b40e177fc
200 OK
```


```json
{
  "data": {
    "id": "32df90ea-5ee7-4100-9bf0-5414dfcb58ed",
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
X-Request-Id: cc8c4846-b37e-4beb-8227-85e4855d4667
200 OK
```


```json
{
  "data": [
    {
      "id": "fd86fb56-d35b-4f85-a72a-ce248afae8cf",
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
            "related": "/contexts?filter[project_id_eq]=fd86fb56-d35b-4f85-a72a-ce248afae8cf",
            "self": "/projects/fd86fb56-d35b-4f85-a72a-ce248afae8cf/relationships/contexts"
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
GET /projects/bccc702c-b26b-478a-a613-4a4b0d12ab2a
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
X-Request-Id: fe2c0d27-af6c-4e8c-8286-05ed4d4feff4
200 OK
```


```json
{
  "data": {
    "id": "bccc702c-b26b-478a-a613-4a4b0d12ab2a",
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
          "related": "/contexts?filter[project_id_eq]=bccc702c-b26b-478a-a613-4a4b0d12ab2a",
          "self": "/projects/bccc702c-b26b-478a-a613-4a4b0d12ab2a/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/bccc702c-b26b-478a-a613-4a4b0d12ab2a"
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
PATCH /projects/f10e5d36-c9fb-4c72-be92-d6f020610735
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "f10e5d36-c9fb-4c72-be92-d6f020610735",
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
X-Request-Id: f76bda4e-fe68-49bd-aa69-b861733cde66
200 OK
```


```json
{
  "data": {
    "id": "f10e5d36-c9fb-4c72-be92-d6f020610735",
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
          "related": "/contexts?filter[project_id_eq]=f10e5d36-c9fb-4c72-be92-d6f020610735",
          "self": "/projects/f10e5d36-c9fb-4c72-be92-d6f020610735/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/f10e5d36-c9fb-4c72-be92-d6f020610735"
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
POST /projects/a796089e-70af-4d9c-bc34-4540cae8fe8a/archive
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
X-Request-Id: 29230256-96f4-46d5-affe-9d952e47d0f9
200 OK
```


```json
{
  "data": {
    "id": "a796089e-70af-4d9c-bc34-4540cae8fe8a",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-20T12:15:46.687Z",
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
          "related": "/contexts?filter[project_id_eq]=a796089e-70af-4d9c-bc34-4540cae8fe8a",
          "self": "/projects/a796089e-70af-4d9c-bc34-4540cae8fe8a/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a796089e-70af-4d9c-bc34-4540cae8fe8a/archive"
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
DELETE /projects/52a9539d-35fd-420e-b7a0-0452bbba1f29
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 061c1433-06b1-442f-857c-e20f81b1cd7e
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
X-Request-Id: ac5a8cc5-8c70-4b47-a95f-263daa0c12fe
200 OK
```


```json
{
  "data": [
    {
      "id": "114d43bc-e742-4b37-9101-63a7cf471b8e",
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
            "related": "/projects/5c820392-947f-4780-872d-c9170cf03e2b"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/325fb202-2dd0-4d34-b53b-aae52b1c0eb7"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/01923b59-35f0-4ac9-8f29-a7b67d58d055"
          }
        }
      }
    },
    {
      "id": "7b9a0988-dcc2-4017-9607-f032d4dea40a",
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
            "related": "/projects/5c820392-947f-4780-872d-c9170cf03e2b"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/a0e6250f-b063-4359-824c-88428af444ce"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/01923b59-35f0-4ac9-8f29-a7b67d58d055"
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
GET /contexts/fc720912-9d5c-4aed-8d02-8b5a067b4f79
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
X-Request-Id: 1851b474-07b9-4fe2-8916-5b8a245040fa
200 OK
```


```json
{
  "data": {
    "id": "fc720912-9d5c-4aed-8d02-8b5a067b4f79",
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
          "related": "/projects/a488e387-b55d-452d-9f3c-78da5442f72b"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/ba8ea9e2-6a34-4de8-8ef2-cb861e0171be"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/0fd86904-8b3f-4dd2-b312-96059baf950e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/fc720912-9d5c-4aed-8d02-8b5a067b4f79"
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
PATCH /contexts/710f979b-037c-4a6c-9de7-4d97c4cd1f2c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "710f979b-037c-4a6c-9de7-4d97c4cd1f2c",
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
X-Request-Id: ea164966-3350-41dc-b84b-b08445191f29
200 OK
```


```json
{
  "data": {
    "id": "710f979b-037c-4a6c-9de7-4d97c4cd1f2c",
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
          "related": "/projects/1069df90-6791-4a4c-87d9-0cd118adc2f8"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/f141b4a2-d8e0-45c5-b80d-3c3d5a7969da"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/951e3b6e-ec59-49d5-afd6-58bb50f05654"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/710f979b-037c-4a6c-9de7-4d97c4cd1f2c"
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
POST /projects/68ced95a-0786-4ea8-a78c-3bc5a592cf88/relationships/contexts
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
          "id": "cb28750c-c298-4aee-92da-1e75f8a0bc38"
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
X-Request-Id: b5d39c91-99a8-41a2-b8fd-e0362e0713cf
201 Created
```


```json
{
  "data": {
    "id": "ce2a37f6-6994-4add-a4c7-1c49e990255c",
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
          "related": "/projects/68ced95a-0786-4ea8-a78c-3bc5a592cf88"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/45289ec9-fbf2-40c8-b40b-a78ee85af19a"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/cb28750c-c298-4aee-92da-1e75f8a0bc38"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/68ced95a-0786-4ea8-a78c-3bc5a592cf88/relationships/contexts"
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
POST /contexts/fbf42b1b-1c1a-4bf7-9656-cb3a4e4665be/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/0b7ebddf416ef1e79efb0821
Content-Type: text/html; charset=utf-8
X-Request-Id: d84d0dd3-cf76-4c12-8d6c-402edda3d26d
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/0b7ebddf416ef1e79efb0821">redirected</a>.</body></html>
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
DELETE /contexts/50468a05-0805-46a3-bb70-cebf8f41920b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1c5bc793-c8dc-414b-8b2c-a1764ba0a9af
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
POST /object_occurrences/f479a14e-3291-4db4-ad4e-033de2167761/relationships/tags
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
X-Request-Id: 259ed073-b8a4-4930-b790-9292a2cc54a0
201 Created
```


```json
{
  "data": {
    "id": "00a0ec05-b700-46e5-a219-b5377bc35549",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f479a14e-3291-4db4-ad4e-033de2167761/relationships/tags"
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
POST /object_occurrences/e299459c-c0c3-4d8d-93fb-07c2a04c8b69/relationships/tags
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
    "id": "045fe6c6-08ad-4ea8-bcbf-7439c231b033"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 24836b04-5f8e-4ab1-bd46-4c9d391a4d6d
201 Created
```


```json
{
  "data": {
    "id": "045fe6c6-08ad-4ea8-bcbf-7439c231b033",
    "type": "tag",
    "attributes": {
      "value": "tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/e299459c-c0c3-4d8d-93fb-07c2a04c8b69/relationships/tags"
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
DELETE /object_occurrences/f884d89f-393e-42ac-86a8-793a717dd621/relationships/tags/53f59638-1339-4d58-8fad-5f9ae30a8c89
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3eca8ef9-7682-4d67-9aa8-21d0f5c38374
204 No Content
```




## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrences/66dd8625-ccb6-4c9c-987d-5bd76b9fc7d0/relationships/owners
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
X-Request-Id: 6e473136-1ab0-4526-8e12-16b98815caaf
201 Created
```


```json
{
  "data": {
    "id": "97f0c219-8cdf-471f-8de5-504cf80ac53a",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/66dd8625-ccb6-4c9c-987d-5bd76b9fc7d0/relationships/owners"
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
POST /object_occurrences/7aeee9a8-64b6-403c-bb91-bb5856433926/relationships/owners
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
X-Request-Id: 547922b6-d015-4301-86bf-c8513eeeca11
201 Created
```


```json
{
  "data": {
    "id": "ab7fa2ee-3332-4e6a-a59e-86552aed279c",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/7aeee9a8-64b6-403c-bb91-bb5856433926/relationships/owners"
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
POST /object_occurrences/d53b688c-1913-46db-99fc-3c9dc95fb16a/relationships/owners
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
    "id": "63b9ea0c-7df2-420d-ae55-66357c42a5b3"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 90eec9bc-1487-4ab5-bad3-6c6a6330e8be
201 Created
```


```json
{
  "data": {
    "id": "63b9ea0c-7df2-420d-ae55-66357c42a5b3",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 1",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d53b688c-1913-46db-99fc-3c9dc95fb16a/relationships/owners"
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
DELETE /object_occurrences/8a37a65a-8d6d-48a6-b435-e16ae0d231d9/relationships/owners/d1e45d31-1af5-4d90-bfff-9cdd3707d57e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: a3461d22-5447-4dd6-a213-7b192725c7f4
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
X-Request-Id: e70e8b67-fc96-4f9a-83a1-9b9b9d44c7ed
200 OK
```


```json
{
  "data": [
    {
      "id": "4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f",
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
            "related": "/tags?filter[target_id_eq]=4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f",
            "self": "/object_occurrences/4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e2fcc0ad-8767-4817-b583-02efd57a6d67"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/cf8f254f-1fe1-4ab9-a569-30ba5e081f38",
            "self": "/object_occurrences/4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f"
          }
        }
      }
    },
    {
      "id": "534d48c7-d124-4fd3-832e-d1c0c61453f4",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC de4fa0815eca",
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
            "related": "/tags?filter[target_id_eq]=534d48c7-d124-4fd3-832e-d1c0c61453f4",
            "self": "/object_occurrences/534d48c7-d124-4fd3-832e-d1c0c61453f4/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=534d48c7-d124-4fd3-832e-d1c0c61453f4&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/534d48c7-d124-4fd3-832e-d1c0c61453f4/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e2fcc0ad-8767-4817-b583-02efd57a6d67"
          }
        },
        "components": {
          "data": [
            {
              "id": "cf8f254f-1fe1-4ab9-a569-30ba5e081f38",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/534d48c7-d124-4fd3-832e-d1c0c61453f4/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=534d48c7-d124-4fd3-832e-d1c0c61453f4"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=534d48c7-d124-4fd3-832e-d1c0c61453f4"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=534d48c7-d124-4fd3-832e-d1c0c61453f4"
          }
        }
      }
    },
    {
      "id": "aa0c44cc-9912-4fc3-b9b0-864091216a95",
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
            "related": "/tags?filter[target_id_eq]=aa0c44cc-9912-4fc3-b9b0-864091216a95",
            "self": "/object_occurrences/aa0c44cc-9912-4fc3-b9b0-864091216a95/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=aa0c44cc-9912-4fc3-b9b0-864091216a95&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/aa0c44cc-9912-4fc3-b9b0-864091216a95/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e2fcc0ad-8767-4817-b583-02efd57a6d67"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/cf8f254f-1fe1-4ab9-a569-30ba5e081f38",
            "self": "/object_occurrences/aa0c44cc-9912-4fc3-b9b0-864091216a95/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/aa0c44cc-9912-4fc3-b9b0-864091216a95/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=aa0c44cc-9912-4fc3-b9b0-864091216a95"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=aa0c44cc-9912-4fc3-b9b0-864091216a95"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=aa0c44cc-9912-4fc3-b9b0-864091216a95"
          }
        }
      }
    },
    {
      "id": "cf8f254f-1fe1-4ab9-a569-30ba5e081f38",
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
            "related": "/tags?filter[target_id_eq]=cf8f254f-1fe1-4ab9-a569-30ba5e081f38",
            "self": "/object_occurrences/cf8f254f-1fe1-4ab9-a569-30ba5e081f38/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=cf8f254f-1fe1-4ab9-a569-30ba5e081f38&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/cf8f254f-1fe1-4ab9-a569-30ba5e081f38/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/e2fcc0ad-8767-4817-b583-02efd57a6d67"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/534d48c7-d124-4fd3-832e-d1c0c61453f4",
            "self": "/object_occurrences/cf8f254f-1fe1-4ab9-a569-30ba5e081f38/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "4d57c3ad-4fa1-446a-a9e1-ff71f4e9b76f",
              "type": "object_occurrence"
            },
            {
              "id": "aa0c44cc-9912-4fc3-b9b0-864091216a95",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/cf8f254f-1fe1-4ab9-a569-30ba5e081f38/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=cf8f254f-1fe1-4ab9-a569-30ba5e081f38"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=cf8f254f-1fe1-4ab9-a569-30ba5e081f38"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=cf8f254f-1fe1-4ab9-a569-30ba5e081f38"
          }
        }
      }
    },
    {
      "id": "080b9e29-0deb-4e26-9292-55e4d366549b",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC b402f160e33f",
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
            "related": "/tags?filter[target_id_eq]=080b9e29-0deb-4e26-9292-55e4d366549b",
            "self": "/object_occurrences/080b9e29-0deb-4e26-9292-55e4d366549b/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=080b9e29-0deb-4e26-9292-55e4d366549b&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/080b9e29-0deb-4e26-9292-55e4d366549b/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffbea951-1d59-4bd2-b4f8-9ceb8447a9d4"
          }
        },
        "components": {
          "data": [
            {
              "id": "980e1936-b357-4723-b380-5e8e67fef0fb",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/080b9e29-0deb-4e26-9292-55e4d366549b/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=080b9e29-0deb-4e26-9292-55e4d366549b"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=080b9e29-0deb-4e26-9292-55e4d366549b"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=080b9e29-0deb-4e26-9292-55e4d366549b"
          }
        }
      }
    },
    {
      "id": "980e1936-b357-4723-b380-5e8e67fef0fb",
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
            "related": "/tags?filter[target_id_eq]=980e1936-b357-4723-b380-5e8e67fef0fb",
            "self": "/object_occurrences/980e1936-b357-4723-b380-5e8e67fef0fb/relationships/tags"
          }
        },
        "owners": {
          "data": [

          ],
          "links": {
            "related": "/owners?filter[target_id_eq]=980e1936-b357-4723-b380-5e8e67fef0fb&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/980e1936-b357-4723-b380-5e8e67fef0fb/relationships/owners"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/ffbea951-1d59-4bd2-b4f8-9ceb8447a9d4"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/080b9e29-0deb-4e26-9292-55e4d366549b",
            "self": "/object_occurrences/980e1936-b357-4723-b380-5e8e67fef0fb/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/980e1936-b357-4723-b380-5e8e67fef0fb/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=980e1936-b357-4723-b380-5e8e67fef0fb"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=980e1936-b357-4723-b380-5e8e67fef0fb"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=980e1936-b357-4723-b380-5e8e67fef0fb"
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
GET /object_occurrences/0d09fa66-be3c-4e08-bf76-a8f6328e30e1
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
X-Request-Id: 1825d7f8-7a7a-4e50-a6d1-d5a6e0432e90
200 OK
```


```json
{
  "data": {
    "id": "0d09fa66-be3c-4e08-bf76-a8f6328e30e1",
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
          "related": "/tags?filter[target_id_eq]=0d09fa66-be3c-4e08-bf76-a8f6328e30e1",
          "self": "/object_occurrences/0d09fa66-be3c-4e08-bf76-a8f6328e30e1/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=0d09fa66-be3c-4e08-bf76-a8f6328e30e1&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/0d09fa66-be3c-4e08-bf76-a8f6328e30e1/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/c7dd6aee-0641-418a-9b94-8d59f571c8e7"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/8ab01e91-daa3-460f-8a2e-abfdf29cd35a",
          "self": "/object_occurrences/0d09fa66-be3c-4e08-bf76-a8f6328e30e1/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "121e2b4c-5950-431d-8a48-bf3caa7e9796",
            "type": "object_occurrence"
          },
          {
            "id": "d6f3e809-13c0-4fe9-8e39-18ed70f965e8",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/0d09fa66-be3c-4e08-bf76-a8f6328e30e1/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=0d09fa66-be3c-4e08-bf76-a8f6328e30e1"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=0d09fa66-be3c-4e08-bf76-a8f6328e30e1"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=0d09fa66-be3c-4e08-bf76-a8f6328e30e1"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/0d09fa66-be3c-4e08-bf76-a8f6328e30e1"
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
POST /object_occurrences/03870862-d661-4b8b-b834-435591f8db34/relationships/components
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
X-Request-Id: e58573ad-94e4-43bd-ae9f-9caae91a185d
201 Created
```


```json
{
  "data": {
    "id": "770eb591-965d-4858-b8c3-634482f444e0",
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
          "related": "/tags?filter[target_id_eq]=770eb591-965d-4858-b8c3-634482f444e0",
          "self": "/object_occurrences/770eb591-965d-4858-b8c3-634482f444e0/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=770eb591-965d-4858-b8c3-634482f444e0&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/770eb591-965d-4858-b8c3-634482f444e0/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/8c5665cc-42a2-41ab-bdbf-1c411b279900"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/03870862-d661-4b8b-b834-435591f8db34",
          "self": "/object_occurrences/770eb591-965d-4858-b8c3-634482f444e0/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/770eb591-965d-4858-b8c3-634482f444e0/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=770eb591-965d-4858-b8c3-634482f444e0"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=770eb591-965d-4858-b8c3-634482f444e0"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=770eb591-965d-4858-b8c3-634482f444e0"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/03870862-d661-4b8b-b834-435591f8db34/relationships/components"
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
POST /object_occurrences/004539c7-a63b-48ea-acc5-d38f1a75a2f4/relationships/components
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
X-Request-Id: f32f0279-f451-4012-bf1c-37397bd62760
201 Created
```


```json
{
  "data": {
    "id": "8911017c-bd30-4078-b213-ea950376e383",
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
          "related": "/tags?filter[target_id_eq]=8911017c-bd30-4078-b213-ea950376e383",
          "self": "/object_occurrences/8911017c-bd30-4078-b213-ea950376e383/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=8911017c-bd30-4078-b213-ea950376e383&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/8911017c-bd30-4078-b213-ea950376e383/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/0fdf3ef1-e40b-40fb-8efa-10aac35ae89e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/004539c7-a63b-48ea-acc5-d38f1a75a2f4/relationships/components"
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
PATCH /object_occurrences/8f28d972-4b06-49c2-b251-74019386254b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "8f28d972-4b06-49c2-b251-74019386254b",
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
          "id": "6f9f2073-ed4c-4b31-9e9c-8f4096be171d"
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
X-Request-Id: 60bb09cc-834c-4834-8613-93636105dd57
200 OK
```


```json
{
  "data": {
    "id": "8f28d972-4b06-49c2-b251-74019386254b",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=8f28d972-4b06-49c2-b251-74019386254b",
          "self": "/object_occurrences/8f28d972-4b06-49c2-b251-74019386254b/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=8f28d972-4b06-49c2-b251-74019386254b&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/8f28d972-4b06-49c2-b251-74019386254b/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/29ec0e70-72bf-421a-a557-abb4de885ea6"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6f9f2073-ed4c-4b31-9e9c-8f4096be171d",
          "self": "/object_occurrences/8f28d972-4b06-49c2-b251-74019386254b/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/8f28d972-4b06-49c2-b251-74019386254b/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=8f28d972-4b06-49c2-b251-74019386254b"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=8f28d972-4b06-49c2-b251-74019386254b"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=8f28d972-4b06-49c2-b251-74019386254b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/8f28d972-4b06-49c2-b251-74019386254b"
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
POST /object_occurrences/086fc537-9fb3-43dc-9a3c-b26de974f8ae/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "7aa768f1-7eef-4505-ae1d-12ba97472fcf",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/96a17f64436111d623bcf868
Content-Type: text/html; charset=utf-8
X-Request-Id: 0579be96-d159-441c-99de-851b0d85516c
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/96a17f64436111d623bcf868">redirected</a>.</body></html>
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
DELETE /object_occurrences/e28e9eb9-5078-439f-b40f-364c7c44e856
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: adade061-d6eb-4004-bbe7-72a98183b079
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/7593b3c7-4613-46af-8b0f-91ae1b81628a/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "aa9e54ff-b71d-45bb-9a86-103cb15d28d4",
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
X-Request-Id: 3fa94049-ad9c-4e0a-8b20-c60e6e64f426
200 OK
```


```json
{
  "data": {
    "id": "7593b3c7-4613-46af-8b0f-91ae1b81628a",
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
          "related": "/tags?filter[target_id_eq]=7593b3c7-4613-46af-8b0f-91ae1b81628a",
          "self": "/object_occurrences/7593b3c7-4613-46af-8b0f-91ae1b81628a/relationships/tags"
        }
      },
      "owners": {
        "data": [

        ],
        "links": {
          "related": "/owners?filter[target_id_eq]=7593b3c7-4613-46af-8b0f-91ae1b81628a&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/7593b3c7-4613-46af-8b0f-91ae1b81628a/relationships/owners"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/f316fdc7-26ca-41d9-971f-469756f0a9c6"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/aa9e54ff-b71d-45bb-9a86-103cb15d28d4",
          "self": "/object_occurrences/7593b3c7-4613-46af-8b0f-91ae1b81628a/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/7593b3c7-4613-46af-8b0f-91ae1b81628a/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7593b3c7-4613-46af-8b0f-91ae1b81628a"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7593b3c7-4613-46af-8b0f-91ae1b81628a"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=7593b3c7-4613-46af-8b0f-91ae1b81628a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/7593b3c7-4613-46af-8b0f-91ae1b81628a/relationships/part_of"
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
POST /classification_tables/a69bce79-4dab-44e6-b13f-52e84146cc5d/relationships/tags
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
X-Request-Id: 1fefee10-be9c-4e84-bd35-94571494ba69
201 Created
```


```json
{
  "data": {
    "id": "28449131-8827-4208-aec9-34ad1916d3bf",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a69bce79-4dab-44e6-b13f-52e84146cc5d/relationships/tags"
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
POST /classification_tables/02164b0a-0fa6-4ab1-b611-58640df31d8a/relationships/tags
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
    "id": "1b0ae476-46ac-4a49-97c8-483d5839d7eb"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b6f4acd8-61a3-48d0-9cbc-5b285770612e
201 Created
```


```json
{
  "data": {
    "id": "1b0ae476-46ac-4a49-97c8-483d5839d7eb",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/02164b0a-0fa6-4ab1-b611-58640df31d8a/relationships/tags"
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
DELETE /classification_tables/fe21e1bb-e3ad-4a8b-b51e-ff1b701da615/relationships/tags/62f052d8-d27f-401c-8fc5-80807607bd56
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 02e8ddf7-9a5e-41f5-b621-7e8d835946c2
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
X-Request-Id: 6c8191c4-9c34-4154-92a3-bb5d3bba15dd
200 OK
```


```json
{
  "data": [
    {
      "id": "658e46db-6cb1-4f28-a05a-ccce94e1a3af",
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
            "related": "/tags?filter[target_id_eq]=658e46db-6cb1-4f28-a05a-ccce94e1a3af",
            "self": "/classification_tables/658e46db-6cb1-4f28-a05a-ccce94e1a3af/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=658e46db-6cb1-4f28-a05a-ccce94e1a3af",
            "self": "/classification_tables/658e46db-6cb1-4f28-a05a-ccce94e1a3af/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "de37ed76-54c8-4883-8929-279ed5045d10",
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
            "related": "/tags?filter[target_id_eq]=de37ed76-54c8-4883-8929-279ed5045d10",
            "self": "/classification_tables/de37ed76-54c8-4883-8929-279ed5045d10/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=de37ed76-54c8-4883-8929-279ed5045d10",
            "self": "/classification_tables/de37ed76-54c8-4883-8929-279ed5045d10/relationships/classification_entries",
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
GET /classification_tables/d9ea8c4d-b905-49b4-af68-d129629158ac
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
X-Request-Id: 9fd4accc-3344-44cc-81a0-12eed5dc1e87
200 OK
```


```json
{
  "data": {
    "id": "d9ea8c4d-b905-49b4-af68-d129629158ac",
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
          "related": "/tags?filter[target_id_eq]=d9ea8c4d-b905-49b4-af68-d129629158ac",
          "self": "/classification_tables/d9ea8c4d-b905-49b4-af68-d129629158ac/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=d9ea8c4d-b905-49b4-af68-d129629158ac",
          "self": "/classification_tables/d9ea8c4d-b905-49b4-af68-d129629158ac/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d9ea8c4d-b905-49b4-af68-d129629158ac"
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
PATCH /classification_tables/96de532a-7c92-4b76-a415-24a5119410e7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "96de532a-7c92-4b76-a415-24a5119410e7",
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
X-Request-Id: 4cedaf08-19c6-4aa9-a36e-a00aba23a1a3
200 OK
```


```json
{
  "data": {
    "id": "96de532a-7c92-4b76-a415-24a5119410e7",
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
          "related": "/tags?filter[target_id_eq]=96de532a-7c92-4b76-a415-24a5119410e7",
          "self": "/classification_tables/96de532a-7c92-4b76-a415-24a5119410e7/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=96de532a-7c92-4b76-a415-24a5119410e7",
          "self": "/classification_tables/96de532a-7c92-4b76-a415-24a5119410e7/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/96de532a-7c92-4b76-a415-24a5119410e7"
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
DELETE /classification_tables/00df65f0-41de-40c1-b732-091bf05bbe36
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 44434eed-bb31-4f49-8ba1-e8eaf08b7d3d
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
POST /classification_tables/88385204-315d-443a-8308-64045dda3612/publish
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
X-Request-Id: c33af89b-4a6b-4c60-9d73-e75096e25320
200 OK
```


```json
{
  "data": {
    "id": "88385204-315d-443a-8308-64045dda3612",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-04-20T12:16:25.513Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=88385204-315d-443a-8308-64045dda3612",
          "self": "/classification_tables/88385204-315d-443a-8308-64045dda3612/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=88385204-315d-443a-8308-64045dda3612",
          "self": "/classification_tables/88385204-315d-443a-8308-64045dda3612/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/88385204-315d-443a-8308-64045dda3612/publish"
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
POST /classification_tables/97f94c86-b780-4a73-8565-cdebc69e0a90/archive
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
X-Request-Id: e4c18acd-8d3f-46dd-8387-8a67a33387d7
200 OK
```


```json
{
  "data": {
    "id": "97f94c86-b780-4a73-8565-cdebc69e0a90",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-20T12:16:26.349Z",
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
          "related": "/tags?filter[target_id_eq]=97f94c86-b780-4a73-8565-cdebc69e0a90",
          "self": "/classification_tables/97f94c86-b780-4a73-8565-cdebc69e0a90/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=97f94c86-b780-4a73-8565-cdebc69e0a90",
          "self": "/classification_tables/97f94c86-b780-4a73-8565-cdebc69e0a90/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/97f94c86-b780-4a73-8565-cdebc69e0a90/archive"
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
X-Request-Id: 9c0177d0-7a2e-4849-a3ee-fa7190feb0c3
201 Created
```


```json
{
  "data": {
    "id": "f5194d7f-b98c-4a57-9de5-c94802100c05",
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
          "related": "/tags?filter[target_id_eq]=f5194d7f-b98c-4a57-9de5-c94802100c05",
          "self": "/classification_tables/f5194d7f-b98c-4a57-9de5-c94802100c05/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=f5194d7f-b98c-4a57-9de5-c94802100c05",
          "self": "/classification_tables/f5194d7f-b98c-4a57-9de5-c94802100c05/relationships/classification_entries",
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
POST /classification_entries/14cfa8ae-51f9-47ac-8908-8adbcee5beb7/relationships/tags
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
X-Request-Id: aeecd8d5-92b2-4bd6-b2fe-20f681468769
201 Created
```


```json
{
  "data": {
    "id": "e45f970b-9b87-46c9-836c-af0813dc5e2d",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/14cfa8ae-51f9-47ac-8908-8adbcee5beb7/relationships/tags"
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
POST /classification_entries/e553c8ab-ceb0-455c-a804-e71fea6cf8ea/relationships/tags
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
    "id": "a2617082-16db-46ff-afb9-baf4ae960031"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 08eda3a8-53a2-4cc2-8c19-cbce96edfa7e
201 Created
```


```json
{
  "data": {
    "id": "a2617082-16db-46ff-afb9-baf4ae960031",
    "type": "tag",
    "attributes": {
      "value": "tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/e553c8ab-ceb0-455c-a804-e71fea6cf8ea/relationships/tags"
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
DELETE /classification_entries/f7a6cd08-1674-4476-a882-d63af367122a/relationships/tags/0ed14705-4bb6-41ca-940d-f05909f18cc5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3f1696e6-fd48-4b4e-b489-97225965fa40
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
X-Request-Id: f068fb82-607b-4b6f-875e-c680667d488b
200 OK
```


```json
{
  "data": [
    {
      "id": "46249b02-f512-4752-9bcd-a60dcb638c9a",
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
            "related": "/tags?filter[target_id_eq]=46249b02-f512-4752-9bcd-a60dcb638c9a",
            "self": "/classification_entries/46249b02-f512-4752-9bcd-a60dcb638c9a/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=46249b02-f512-4752-9bcd-a60dcb638c9a",
            "self": "/classification_entries/46249b02-f512-4752-9bcd-a60dcb638c9a/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "0f044e83-961d-48b0-a504-6a2874a26579",
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
            "related": "/tags?filter[target_id_eq]=0f044e83-961d-48b0-a504-6a2874a26579",
            "self": "/classification_entries/0f044e83-961d-48b0-a504-6a2874a26579/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "46249b02-f512-4752-9bcd-a60dcb638c9a",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/0f044e83-961d-48b0-a504-6a2874a26579"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=0f044e83-961d-48b0-a504-6a2874a26579",
            "self": "/classification_entries/0f044e83-961d-48b0-a504-6a2874a26579/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "70b27329-fb2a-4dc7-bc77-0cce2272beec",
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
            "related": "/tags?filter[target_id_eq]=70b27329-fb2a-4dc7-bc77-0cce2272beec",
            "self": "/classification_entries/70b27329-fb2a-4dc7-bc77-0cce2272beec/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=70b27329-fb2a-4dc7-bc77-0cce2272beec",
            "self": "/classification_entries/70b27329-fb2a-4dc7-bc77-0cce2272beec/relationships/classification_entries",
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
GET /classification_entries/b7734552-73e6-4d03-ad7a-7bfc6c06f36d
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
X-Request-Id: a888e6a1-e073-4b4f-b365-fc6c03352900
200 OK
```


```json
{
  "data": {
    "id": "b7734552-73e6-4d03-ad7a-7bfc6c06f36d",
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
          "related": "/tags?filter[target_id_eq]=b7734552-73e6-4d03-ad7a-7bfc6c06f36d",
          "self": "/classification_entries/b7734552-73e6-4d03-ad7a-7bfc6c06f36d/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=b7734552-73e6-4d03-ad7a-7bfc6c06f36d",
          "self": "/classification_entries/b7734552-73e6-4d03-ad7a-7bfc6c06f36d/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/b7734552-73e6-4d03-ad7a-7bfc6c06f36d"
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
PATCH /classification_entries/c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7",
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
X-Request-Id: c5862a02-bb00-40be-8451-7b5c3aeb4465
200 OK
```


```json
{
  "data": {
    "id": "c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7",
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
          "related": "/tags?filter[target_id_eq]=c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7",
          "self": "/classification_entries/c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "437a0c48-e6c1-46f5-8f43-8965e4dd3d8e",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7",
          "self": "/classification_entries/c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/c0f72da9-a6f0-4593-8b88-c1acb4dfc1c7"
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
DELETE /classification_entries/d9550d62-6d2c-4b59-8843-7d4c81b05015
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 63b1473a-7ba0-49a5-92b3-518e9d7bf3db
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
POST /classification_tables/95a5038c-8fe5-4a59-b762-d6a1da0b9cf0/relationships/classification_entries
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
X-Request-Id: d94c1cf6-fe18-479a-bf0b-dbeda86d0416
201 Created
```


```json
{
  "data": {
    "id": "86a979bb-6f89-40cb-a141-b5225ec81532",
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
          "related": "/tags?filter[target_id_eq]=86a979bb-6f89-40cb-a141-b5225ec81532",
          "self": "/classification_entries/86a979bb-6f89-40cb-a141-b5225ec81532/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=86a979bb-6f89-40cb-a141-b5225ec81532",
          "self": "/classification_entries/86a979bb-6f89-40cb-a141-b5225ec81532/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/95a5038c-8fe5-4a59-b762-d6a1da0b9cf0/relationships/classification_entries"
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
X-Request-Id: 61eeb815-1927-40c2-8323-696021c17061
200 OK
```


```json
{
  "data": [
    {
      "id": "85609e20-726b-430d-ade5-806577143d9f",
      "type": "syntax",
      "attributes": {
        "account_id": "a2b377e5-da6d-4939-8c61-b18a552bf03a",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 3d6adb76d0ff",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=85609e20-726b-430d-ade5-806577143d9f",
            "self": "/syntaxes/85609e20-726b-430d-ade5-806577143d9f/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/229df54a-7bef-49aa-955f-69583fc8e729",
            "self": "/syntax_nodes/229df54a-7bef-49aa-955f-69583fc8e729/relationships/components"
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
GET /syntaxes/9eb2314e-6fd6-466a-b16c-8ae21ebdca44
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
X-Request-Id: f1d7d98d-4053-4857-bdf3-481602c48ef8
200 OK
```


```json
{
  "data": {
    "id": "9eb2314e-6fd6-466a-b16c-8ae21ebdca44",
    "type": "syntax",
    "attributes": {
      "account_id": "7ff5cd18-0e6a-498e-a2a5-e67b18f1eecf",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 30837c74c908",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=9eb2314e-6fd6-466a-b16c-8ae21ebdca44",
          "self": "/syntaxes/9eb2314e-6fd6-466a-b16c-8ae21ebdca44/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/8b16a2a7-444e-4750-a626-3b50e463b722",
          "self": "/syntax_nodes/8b16a2a7-444e-4750-a626-3b50e463b722/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/9eb2314e-6fd6-466a-b16c-8ae21ebdca44"
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
X-Request-Id: 14f98df1-7219-46ee-a450-284b0c869622
201 Created
```


```json
{
  "data": {
    "id": "541abb40-8836-4711-aae5-23889e3d9c09",
    "type": "syntax",
    "attributes": {
      "account_id": "c2d3b8a2-501e-416b-83e6-a88e31710ceb",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=541abb40-8836-4711-aae5-23889e3d9c09",
          "self": "/syntaxes/541abb40-8836-4711-aae5-23889e3d9c09/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/15a9227c-1a11-4043-b40f-ecc1472195f8",
          "self": "/syntax_nodes/15a9227c-1a11-4043-b40f-ecc1472195f8/relationships/components"
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
PATCH /syntaxes/81cc7279-7e7e-4546-ac62-fce11bd3834a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "81cc7279-7e7e-4546-ac62-fce11bd3834a",
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
X-Request-Id: 3a9a5341-6c2d-4c7c-ab88-05399a188504
200 OK
```


```json
{
  "data": {
    "id": "81cc7279-7e7e-4546-ac62-fce11bd3834a",
    "type": "syntax",
    "attributes": {
      "account_id": "9661313d-4527-4eaf-9049-fb587950c9c7",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=81cc7279-7e7e-4546-ac62-fce11bd3834a",
          "self": "/syntaxes/81cc7279-7e7e-4546-ac62-fce11bd3834a/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/1f614680-fa49-45fd-9bdc-df8676f1830c",
          "self": "/syntax_nodes/1f614680-fa49-45fd-9bdc-df8676f1830c/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/81cc7279-7e7e-4546-ac62-fce11bd3834a"
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
DELETE /syntaxes/eb56dee9-3db4-4ce7-9bc0-0f2506f565a6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cac8afbb-3cc4-4820-8072-892657290ab2
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
POST /syntaxes/3e6bbc50-8a2e-48f7-890d-aff7cdd77769/publish
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
X-Request-Id: 5b3b68c8-2ce3-4519-8695-0a4146a5b011
200 OK
```


```json
{
  "data": {
    "id": "3e6bbc50-8a2e-48f7-890d-aff7cdd77769",
    "type": "syntax",
    "attributes": {
      "account_id": "926d73d1-e9bf-4b05-a492-f869f8026359",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 05a372928d02",
      "published": true,
      "published_at": "2020-04-20T12:16:37.489Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=3e6bbc50-8a2e-48f7-890d-aff7cdd77769",
          "self": "/syntaxes/3e6bbc50-8a2e-48f7-890d-aff7cdd77769/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/6f9cd5ba-ce6c-4891-8d80-fab8848aabe9",
          "self": "/syntax_nodes/6f9cd5ba-ce6c-4891-8d80-fab8848aabe9/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/3e6bbc50-8a2e-48f7-890d-aff7cdd77769/publish"
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
POST /syntaxes/a2f7b445-c44e-4d21-a9ed-7ab77e82ed4d/archive
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
X-Request-Id: 37a39e7f-45dc-420b-a8f3-1e3fa96f4678
200 OK
```


```json
{
  "data": {
    "id": "a2f7b445-c44e-4d21-a9ed-7ab77e82ed4d",
    "type": "syntax",
    "attributes": {
      "account_id": "3f6de8f5-7804-49c0-82c5-9838d4ff48fa",
      "archived": true,
      "archived_at": "2020-04-20T12:16:38.169Z",
      "description": "Description",
      "name": "Syntax 3ceb6e33cf04",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=a2f7b445-c44e-4d21-a9ed-7ab77e82ed4d",
          "self": "/syntaxes/a2f7b445-c44e-4d21-a9ed-7ab77e82ed4d/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/7a22c6f4-39f0-46a3-ad89-fbcc349d74e1",
          "self": "/syntax_nodes/7a22c6f4-39f0-46a3-ad89-fbcc349d74e1/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/a2f7b445-c44e-4d21-a9ed-7ab77e82ed4d/archive"
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
X-Request-Id: 5ce56992-4a4a-42b2-9253-a2e7d773208f
200 OK
```


```json
{
  "data": [
    {
      "id": "e3c11458-e3a7-4455-8e6c-40796a5b1c32",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 18",
        "hex_color": "67ae9f"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/c586ae3d-80f5-4773-b2b4-1e8c54a8614a"
          }
        },
        "classification_table": {
          "data": {
            "id": "741842ca-165e-4221-88f4-00fa77ff240a",
            "type": "classification_table"
          },
          "links": {
            "related": "/classification_tables/741842ca-165e-4221-88f4-00fa77ff240a",
            "self": "/syntax_elements/e3c11458-e3a7-4455-8e6c-40796a5b1c32/relationships/classification_table"
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
GET /syntax_elements/241a1918-0524-4c0d-8fee-f6866791ace1
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
X-Request-Id: 85e5992c-43f3-4b3f-b58b-daeaddd8d0ab
200 OK
```


```json
{
  "data": {
    "id": "241a1918-0524-4c0d-8fee-f6866791ace1",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 19",
      "hex_color": "464e80"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/4a03950d-9e1f-4119-8d3f-38222603b371"
        }
      },
      "classification_table": {
        "data": {
          "id": "e838b184-36dc-4c28-a49d-85f191d4d87e",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/e838b184-36dc-4c28-a49d-85f191d4d87e",
          "self": "/syntax_elements/241a1918-0524-4c0d-8fee-f6866791ace1/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/241a1918-0524-4c0d-8fee-f6866791ace1"
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
POST /syntaxes/794d26c0-55bf-490f-b29f-7ac202ac18da/relationships/syntax_elements
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
          "id": "71f7b2b3-0310-4d7e-9010-d0655bdfef4d"
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
X-Request-Id: dc792450-36d5-42b3-aca0-a8e84849247f
201 Created
```


```json
{
  "data": {
    "id": "4ee6156b-5676-40d1-8da7-3852bc99b3d0",
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
          "related": "/syntaxes/794d26c0-55bf-490f-b29f-7ac202ac18da"
        }
      },
      "classification_table": {
        "data": {
          "id": "71f7b2b3-0310-4d7e-9010-d0655bdfef4d",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/71f7b2b3-0310-4d7e-9010-d0655bdfef4d",
          "self": "/syntax_elements/4ee6156b-5676-40d1-8da7-3852bc99b3d0/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/794d26c0-55bf-490f-b29f-7ac202ac18da/relationships/syntax_elements"
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
PATCH /syntax_elements/15ecc06b-f8a8-4d8d-a04c-0e30c71cc74a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "15ecc06b-f8a8-4d8d-a04c-0e30c71cc74a",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "4f20ac27-9c76-42bc-8695-411afead560b"
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
X-Request-Id: bb423fa1-8f27-43d6-84ba-155092c98ce8
200 OK
```


```json
{
  "data": {
    "id": "15ecc06b-f8a8-4d8d-a04c-0e30c71cc74a",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "hex_color": "df8f0e"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/658982f8-8e96-4c2a-8c08-d62abfb2d077"
        }
      },
      "classification_table": {
        "data": {
          "id": "4f20ac27-9c76-42bc-8695-411afead560b",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/4f20ac27-9c76-42bc-8695-411afead560b",
          "self": "/syntax_elements/15ecc06b-f8a8-4d8d-a04c-0e30c71cc74a/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/15ecc06b-f8a8-4d8d-a04c-0e30c71cc74a"
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
DELETE /syntax_elements/ba6901a1-2367-4356-96f4-1fce3a94bea4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 989f8734-65d2-4956-90f6-184700bcb480
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
PATCH /syntax_elements/164500fb-f183-4496-aaf8-b76c43a53d60/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "1c5263bd-3518-4bb5-8ec6-dc255937d937",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8cd11520-9c38-4611-bf38-cb56bc4a0536
200 OK
```


```json
{
  "data": {
    "id": "164500fb-f183-4496-aaf8-b76c43a53d60",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 23",
      "hex_color": "0fa255"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/89c723a6-668a-4656-a01d-ec0175b48dc4"
        }
      },
      "classification_table": {
        "data": {
          "id": "1c5263bd-3518-4bb5-8ec6-dc255937d937",
          "type": "classification_table"
        },
        "links": {
          "related": "/classification_tables/1c5263bd-3518-4bb5-8ec6-dc255937d937",
          "self": "/syntax_elements/164500fb-f183-4496-aaf8-b76c43a53d60/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/164500fb-f183-4496-aaf8-b76c43a53d60/relationships/classification_table"
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
DELETE /syntax_elements/6f77e789-ebb0-4fd7-90d0-be70b3eff189/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2a533c55-2cb1-4f43-b8dd-068a18e206d2
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
X-Request-Id: d28348e6-510a-4df9-8551-e2b4864ac68c
200 OK
```


```json
{
  "data": [
    {
      "id": "2e2b0bb8-0895-457b-a036-0911d3bff388",
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
              "id": "e9cfc532-ff45-4188-9ffa-770cf43bf0ef",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/2e2b0bb8-0895-457b-a036-0911d3bff388/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/2e2b0bb8-0895-457b-a036-0911d3bff388/relationships/parent",
            "related": "/syntax_nodes/2e2b0bb8-0895-457b-a036-0911d3bff388"
          }
        }
      }
    },
    {
      "id": "e9cfc532-ff45-4188-9ffa-770cf43bf0ef",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/1e22943b-76d8-4c5d-ab4e-48c16804fd3c"
          }
        },
        "components": {
          "data": [
            {
              "id": "d34a7050-5f9d-40a2-bc24-3d30d093aca8",
              "type": "syntax_node"
            },
            {
              "id": "6cce2519-5895-4262-a4b1-5effc608669b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/e9cfc532-ff45-4188-9ffa-770cf43bf0ef/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e9cfc532-ff45-4188-9ffa-770cf43bf0ef/relationships/parent",
            "related": "/syntax_nodes/e9cfc532-ff45-4188-9ffa-770cf43bf0ef"
          }
        }
      }
    },
    {
      "id": "d34a7050-5f9d-40a2-bc24-3d30d093aca8",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/1e22943b-76d8-4c5d-ab4e-48c16804fd3c"
          }
        },
        "components": {
          "data": [
            {
              "id": "88ddf0ed-581c-4bd0-8afa-a0fcabeac26d",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/d34a7050-5f9d-40a2-bc24-3d30d093aca8/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/d34a7050-5f9d-40a2-bc24-3d30d093aca8/relationships/parent",
            "related": "/syntax_nodes/d34a7050-5f9d-40a2-bc24-3d30d093aca8"
          }
        }
      }
    },
    {
      "id": "6cce2519-5895-4262-a4b1-5effc608669b",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/1e22943b-76d8-4c5d-ab4e-48c16804fd3c"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/6cce2519-5895-4262-a4b1-5effc608669b/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/6cce2519-5895-4262-a4b1-5effc608669b/relationships/parent",
            "related": "/syntax_nodes/6cce2519-5895-4262-a4b1-5effc608669b"
          }
        }
      }
    },
    {
      "id": "88ddf0ed-581c-4bd0-8afa-a0fcabeac26d",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/1e22943b-76d8-4c5d-ab4e-48c16804fd3c"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/88ddf0ed-581c-4bd0-8afa-a0fcabeac26d/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/88ddf0ed-581c-4bd0-8afa-a0fcabeac26d/relationships/parent",
            "related": "/syntax_nodes/88ddf0ed-581c-4bd0-8afa-a0fcabeac26d"
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
GET /syntax_nodes/25980706-6d36-4896-86c4-8e8dee017c8a?depth=2
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
X-Request-Id: 82e86807-3e09-47e9-baa0-6bc471461cc2
200 OK
```


```json
{
  "data": {
    "id": "25980706-6d36-4896-86c4-8e8dee017c8a",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/86cfb6f9-cde9-46bb-91ee-697b22c03e56"
        }
      },
      "components": {
        "data": [
          {
            "id": "56f3f001-caa5-4445-839d-58ca6bff1e9f",
            "type": "syntax_node"
          },
          {
            "id": "c2c1dde4-95b7-43da-9f57-f61a6698f231",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/25980706-6d36-4896-86c4-8e8dee017c8a/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/25980706-6d36-4896-86c4-8e8dee017c8a/relationships/parent",
          "related": "/syntax_nodes/25980706-6d36-4896-86c4-8e8dee017c8a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/25980706-6d36-4896-86c4-8e8dee017c8a?depth=2"
  },
  "included": [
    {
      "id": "c2c1dde4-95b7-43da-9f57-f61a6698f231",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/86cfb6f9-cde9-46bb-91ee-697b22c03e56"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/c2c1dde4-95b7-43da-9f57-f61a6698f231/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/c2c1dde4-95b7-43da-9f57-f61a6698f231/relationships/parent",
            "related": "/syntax_nodes/c2c1dde4-95b7-43da-9f57-f61a6698f231"
          }
        }
      }
    },
    {
      "id": "56f3f001-caa5-4445-839d-58ca6bff1e9f",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/86cfb6f9-cde9-46bb-91ee-697b22c03e56"
          }
        },
        "components": {
          "data": [
            {
              "id": "d3c27cb6-d4f5-466e-8ece-305dbf944815",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/56f3f001-caa5-4445-839d-58ca6bff1e9f/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/56f3f001-caa5-4445-839d-58ca6bff1e9f/relationships/parent",
            "related": "/syntax_nodes/56f3f001-caa5-4445-839d-58ca6bff1e9f"
          }
        }
      }
    },
    {
      "id": "d3c27cb6-d4f5-466e-8ece-305dbf944815",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/86cfb6f9-cde9-46bb-91ee-697b22c03e56"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/d3c27cb6-d4f5-466e-8ece-305dbf944815/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/d3c27cb6-d4f5-466e-8ece-305dbf944815/relationships/parent",
            "related": "/syntax_nodes/d3c27cb6-d4f5-466e-8ece-305dbf944815"
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
POST /syntax_nodes/9f4ed0d8-2b82-492d-a1f4-db7bd10479f1/relationships/components
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
          "id": "3644015f-25a0-4b06-a339-965c26c5546b"
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
X-Request-Id: 10951a4f-3879-4088-b97c-351c645f2911
201 Created
```


```json
{
  "data": {
    "id": "54e4fbbd-832a-4121-9907-4ba5c8a068f4",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/3644015f-25a0-4b06-a339-965c26c5546b"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/54e4fbbd-832a-4121-9907-4ba5c8a068f4/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/54e4fbbd-832a-4121-9907-4ba5c8a068f4/relationships/parent",
          "related": "/syntax_nodes/54e4fbbd-832a-4121-9907-4ba5c8a068f4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/9f4ed0d8-2b82-492d-a1f4-db7bd10479f1/relationships/components"
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
PATCH /syntax_nodes/42dac2d8-9b27-4e91-ac35-4b981def4f16/relationships/parent
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
    "id": "d5f97d23-1772-4510-930e-eaaf9f9a89b3"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 24ee2e11-30a1-474f-ac6b-7bfc9ebb1f8a
200 OK
```


```json
{
  "data": {
    "id": "42dac2d8-9b27-4e91-ac35-4b981def4f16",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/f191eebd-9533-49be-8224-0a15d001e679"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/42dac2d8-9b27-4e91-ac35-4b981def4f16/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/42dac2d8-9b27-4e91-ac35-4b981def4f16/relationships/parent",
          "related": "/syntax_nodes/42dac2d8-9b27-4e91-ac35-4b981def4f16"
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
PATCH /syntax_nodes/1feea637-2307-488a-a692-e18209065877
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "1feea637-2307-488a-a692-e18209065877",
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
X-Request-Id: 34351832-7c2d-461b-a96a-506b32087ec3
200 OK
```


```json
{
  "data": {
    "id": "1feea637-2307-488a-a692-e18209065877",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/5913ce84-ba0a-4774-86a2-b751234a2b6c"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/1feea637-2307-488a-a692-e18209065877/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/1feea637-2307-488a-a692-e18209065877/relationships/parent",
          "related": "/syntax_nodes/1feea637-2307-488a-a692-e18209065877"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/1feea637-2307-488a-a692-e18209065877"
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
DELETE /syntax_nodes/5f0c4a6f-f342-400d-95b3-d13918aae6f9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 1883f50d-b41a-4ce2-a7b0-0da4aa01c133
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
X-Request-Id: 5dcd9abf-1310-42fa-aa16-02a82f76d841
200 OK
```


```json
{
  "data": [
    {
      "id": "33bb0447-3cf4-4c99-aaad-0e60d8e0de82",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-04-20T12:16:49.679Z",
        "type": "object_occurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=33bb0447-3cf4-4c99-aaad-0e60d8e0de82",
            "self": "/progress_models/33bb0447-3cf4-4c99-aaad-0e60d8e0de82/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "c51dd575-f14a-4e11-adad-bf4c36050b7f",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=c51dd575-f14a-4e11-adad-bf4c36050b7f",
            "self": "/progress_models/c51dd575-f14a-4e11-adad-bf4c36050b7f/relationships/progress_steps"
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
GET /progress_models/83266ff7-dfc4-4caf-a5b0-b137d450a4b6
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
X-Request-Id: 6ac9ec6d-f2de-423f-a167-9a3bfb067a5c
200 OK
```


```json
{
  "data": {
    "id": "83266ff7-dfc4-4caf-a5b0-b137d450a4b6",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-04-20T12:16:50.432Z",
      "type": "object_occurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=83266ff7-dfc4-4caf-a5b0-b137d450a4b6",
          "self": "/progress_models/83266ff7-dfc4-4caf-a5b0-b137d450a4b6/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/83266ff7-dfc4-4caf-a5b0-b137d450a4b6"
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
PATCH /progress_models/25f060d9-4484-426f-b971-89f57e0c908f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "25f060d9-4484-426f-b971-89f57e0c908f",
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
X-Request-Id: c4037f9a-a571-43a4-b579-d3a3e7ea08d3
200 OK
```


```json
{
  "data": {
    "id": "25f060d9-4484-426f-b971-89f57e0c908f",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=25f060d9-4484-426f-b971-89f57e0c908f",
          "self": "/progress_models/25f060d9-4484-426f-b971-89f57e0c908f/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/25f060d9-4484-426f-b971-89f57e0c908f"
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
DELETE /progress_models/61a7d472-0c81-48c5-a3cc-0598bfc04de8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cdc9494a-a4cc-45d4-a7af-8f7987370928
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
POST /progress_models/501cd235-47e3-4825-980d-15e3854529f4/publish
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
X-Request-Id: 086f20ba-8e75-4ac3-9d3b-4132b98dd229
200 OK
```


```json
{
  "data": {
    "id": "501cd235-47e3-4825-980d-15e3854529f4",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-04-20T12:16:52.886Z",
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=501cd235-47e3-4825-980d-15e3854529f4",
          "self": "/progress_models/501cd235-47e3-4825-980d-15e3854529f4/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/501cd235-47e3-4825-980d-15e3854529f4/publish"
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
POST /progress_models/b5469df4-f93e-4860-8891-65e83e5f9ab7/archive
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
X-Request-Id: 8047cc52-0f7a-4f0b-9ef6-609ff31670c7
200 OK
```


```json
{
  "data": {
    "id": "b5469df4-f93e-4860-8891-65e83e5f9ab7",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-04-20T12:16:53.516Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "object_occurrence_relation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b5469df4-f93e-4860-8891-65e83e5f9ab7",
          "self": "/progress_models/b5469df4-f93e-4860-8891-65e83e5f9ab7/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/b5469df4-f93e-4860-8891-65e83e5f9ab7/archive"
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
X-Request-Id: ba06a7e9-b42e-4cf2-ae63-ecfde3b035e2
201 Created
```


```json
{
  "data": {
    "id": "7ab0ca41-66ae-490b-ade1-bc91b8a3d193",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=7ab0ca41-66ae-490b-ade1-bc91b8a3d193",
          "self": "/progress_models/7ab0ca41-66ae-490b-ade1-bc91b8a3d193/relationships/progress_steps"
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
X-Request-Id: 97857214-a7b7-41f8-9529-68bf3114ce12
200 OK
```


```json
{
  "data": [
    {
      "id": "613f3382-cabb-44e3-8887-b0e6fe1df4b0",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1,
        "hex_color": "f32de8"
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/3623f98b-8b69-4721-b8e4-8df669e11759"
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
GET /progress_steps/28065c8a-d518-4075-bba6-967ea42f2d13
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
X-Request-Id: 8553a199-b6ad-4b26-8299-ffeed2278d9d
200 OK
```


```json
{
  "data": {
    "id": "28065c8a-d518-4075-bba6-967ea42f2d13",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2,
      "hex_color": "17e886"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/4de9f042-e68b-4be2-8bba-2e2030a9f451"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/28065c8a-d518-4075-bba6-967ea42f2d13"
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
PATCH /progress_steps/4cf9f279-380a-461c-8019-1523199174e6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "4cf9f279-380a-461c-8019-1523199174e6",
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
X-Request-Id: dc32647e-0bc0-4206-a1a3-ff4bbee66aa8
200 OK
```


```json
{
  "data": {
    "id": "4cf9f279-380a-461c-8019-1523199174e6",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3,
      "hex_color": "444444"
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/1aea4579-1181-4660-bd33-8596b9fe3840"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/4cf9f279-380a-461c-8019-1523199174e6"
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
DELETE /progress_steps/ced2b187-b006-40cb-a2af-f21c2644f4d1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6c2deb0a-014a-4c74-a0ec-2fd1f0588275
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
POST /progress_models/139c5280-c7a9-465e-984f-8c8a0aa29238/relationships/progress_steps
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
X-Request-Id: bb3592b7-e36c-4635-ada5-c578cca1c6ec
201 Created
```


```json
{
  "data": {
    "id": "3b9c9cd7-ddda-48ad-aafe-5edf4a3c70d2",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999,
      "hex_color": null
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/139c5280-c7a9-465e-984f-8c8a0aa29238"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/139c5280-c7a9-465e-984f-8c8a0aa29238/relationships/progress_steps"
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
X-Request-Id: b76f246d-e69b-44d8-b9ed-2800a82a9008
200 OK
```


```json
{
  "data": [
    {
      "id": "129a2f33-2544-4005-b8b9-fbcbbc536e8c",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/779aab1f-1276-476e-9045-305e005cfc4e"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/f503276e-2912-48e3-aae5-a1fa75292517"
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
GET /progress/53d9ccd7-1de3-48e6-af96-cc5e9c85bf0d
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
X-Request-Id: fa3e9174-aa71-45c8-abe3-d4a1ad63a3e6
200 OK
```


```json
{
  "data": {
    "id": "53d9ccd7-1de3-48e6-af96-cc5e9c85bf0d",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/06d37753-99af-418f-8625-d471805b3581"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/2ce27adf-54e3-4ec0-a04d-b57a06918fba"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/53d9ccd7-1de3-48e6-af96-cc5e9c85bf0d"
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
DELETE /progress/cd999838-9664-4e35-b6fb-f89202329fa5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3284ad63-8b0e-4baa-932c-7c0a811b0379
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
          "id": "d11a6af9-62c1-4dd6-a5af-0fc9ee4f7238"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "39761fb6-dbe3-4eb9-98e1-0b5f158457a2"
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
X-Request-Id: babdbd57-d64d-437b-ac50-5b120d2d5915
201 Created
```


```json
{
  "data": {
    "id": "347e91e9-37f4-43b1-819a-346e116a723f",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/d11a6af9-62c1-4dd6-a5af-0fc9ee4f7238"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/39761fb6-dbe3-4eb9-98e1-0b5f158457a2"
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
X-Request-Id: af4cce07-76c1-4485-b21d-29ea126d153a
200 OK
```


```json
{
  "data": [
    {
      "id": "e075c3c8-6c0d-4e88-b0e2-dcf43d0478be",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "1fd6b9bb-ae01-4521-9d02-1ee2b2ea7982"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/1fd6b9bb-ae01-4521-9d02-1ee2b2ea7982"
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
GET /projects/f020b280-f62b-412f-84a1-369e807f797d/relationships/project_setting
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
X-Request-Id: ffd4635d-2934-4362-b6ad-963e39ecffa2
200 OK
```


```json
{
  "data": {
    "id": "62b713bf-8bcf-4560-b969-37d680ff8414",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "f020b280-f62b-412f-84a1-369e807f797d"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/f020b280-f62b-412f-84a1-369e807f797d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/f020b280-f62b-412f-84a1-369e807f797d/relationships/project_setting"
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
PATCH /projects/a8894c44-9eac-41c9-9bc5-fd9366450ed7/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "a8894c44-9eac-41c9-9bc5-fd9366450ed7",
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
X-Request-Id: 927f9687-6594-441b-b33d-726d3752e8ba
200 OK
```


```json
{
  "data": {
    "id": "0967ff3a-96a4-42c5-bab9-73998df0ebb9",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "a8894c44-9eac-41c9-9bc5-fd9366450ed7"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/a8894c44-9eac-41c9-9bc5-fd9366450ed7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/a8894c44-9eac-41c9-9bc5-fd9366450ed7/relationships/project_setting"
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
X-Request-Id: 758d4fc0-ab78-4f5b-b7b0-c40d21ac112b
200 OK
```


```json
{
  "data": [
    {
      "id": "c6ff6016-3348-4c69-b460-67417e920416",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/c6ff6016-3348-4c69-b460-67417e920416"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/c6ff6016-3348-4c69-b460-67417e920416"
          }
        }
      }
    },
    {
      "id": "aeeb7e99-2f0e-4f0b-b732-29ccaa2fce3e",
      "type": "system_element",
      "attributes": {
        "name": "OOC 7ce1b4bed116-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/aeeb7e99-2f0e-4f0b-b732-29ccaa2fce3e"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/aeeb7e99-2f0e-4f0b-b732-29ccaa2fce3e"
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
GET /system_elements/accf315b-95c6-40c3-9c9c-a1ac2627f005
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
X-Request-Id: 85477dac-9062-47a7-9e70-6a766958ec7d
200 OK
```


```json
{
  "data": {
    "id": "accf315b-95c6-40c3-9c9c-a1ac2627f005",
    "type": "system_element",
    "attributes": {
      "name": "OOC fee521a63f1d-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/accf315b-95c6-40c3-9c9c-a1ac2627f005"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/accf315b-95c6-40c3-9c9c-a1ac2627f005"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/accf315b-95c6-40c3-9c9c-a1ac2627f005"
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
POST /object_occurrences/b2330204-98ea-4af9-a0a6-5442b36231c3/relationships/system_elements
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
      "target_id": "75094c51-75f4-4804-92b1-568ec6f21a55"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c32530cc-2155-4860-9dbe-37affefb21be
201 Created
```


```json
{
  "data": {
    "id": "656bd403-ed44-4e0e-ade1-8eca7cf506b9",
    "type": "system_element",
    "attributes": {
      "name": "OOC accc69c8e6d3-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/656bd403-ed44-4e0e-ade1-8eca7cf506b9"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/656bd403-ed44-4e0e-ade1-8eca7cf506b9"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/b2330204-98ea-4af9-a0a6-5442b36231c3/relationships/system_elements"
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
DELETE /object_occurrences/82f86862-3917-45df-b19c-349bc6671b4e/relationships/system_elements/9693432c-5698-46ab-9bfc-0ea1e32c5ad9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 92b80cbb-90a4-400c-af24-57fa065e5f6f
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | System Element name |
| data[attributes][description] | System Element description |


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
X-Request-Id: 879454dd-58a5-4e5c-86a3-eb09c8b861e7
200 OK
```


```json
{
  "data": {
    "id": "f78e7b2e-65ac-49ce-9076-feb59c6d0175",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "71720c3c-62cd-47da-818e-9749c4f830fb"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/71720c3c-62cd-47da-818e-9749c4f830fb"
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
X-Request-Id: ca48c2d1-8796-45e1-9800-e9c4ebb7c9fe
200 OK
```


```json
{
  "data": {
    "id": "e488ce76-60e5-4c13-aa3a-fd21770a5f7c",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "21810634-743b-454a-a99b-dcee227ac7bf"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/21810634-743b-454a-a99b-dcee227ac7bf"
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


# Object Occurrence Relations

Object Occurrence Relations between Object Occurrences.


## Add new owner

Adds a new owner to the resource


### Request

#### Endpoint

```plaintext
POST /object_occurrence_relations/1f529ea5-8042-411e-ac66-ff43c529bcad/relationships/owners
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
X-Request-Id: 5d6c093a-a820-4106-b540-779b6931950c
201 Created
```


```json
{
  "data": {
    "id": "9815b8eb-cc10-44c2-b277-52b8959c439b",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/1f529ea5-8042-411e-ac66-ff43c529bcad/relationships/owners"
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
POST /object_occurrence_relations/127b21de-774a-4ca1-9798-a8f1a1738e69/relationships/owners
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
X-Request-Id: 50d89dfa-b9b7-4d05-a5ac-467dc3df4505
201 Created
```


```json
{
  "data": {
    "id": "9cc4c39d-82e3-456c-a740-ab44906fb936",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "New owner name",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/127b21de-774a-4ca1-9798-a8f1a1738e69/relationships/owners"
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
POST /object_occurrence_relations/b674cde6-e886-4cbc-920c-d36ae3367fd9/relationships/owners
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
    "id": "16b972e0-8a99-4778-9b0a-32a71de9ced4"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing owner ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 33e4eabf-7af6-42c4-8d22-7028b72fa74d
201 Created
```


```json
{
  "data": {
    "id": "16b972e0-8a99-4778-9b0a-32a71de9ced4",
    "type": "owner",
    "attributes": {
      "company": null,
      "name": "Owner 3",
      "title": null
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/b674cde6-e886-4cbc-920c-d36ae3367fd9/relationships/owners"
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
DELETE /object_occurrence_relations/142d6f18-4a14-4f92-9055-f86c4aac229c/relationships/owners/9a0c5eaf-0b02-4637-a1d4-c94fb549c05f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrence_relations/:id/relationships/owners/:owner_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2c8996d0-ab7e-489c-9c7e-29a36cc81948
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
X-Request-Id: 723f10fa-e8c5-49ea-bcb7-a4da89497198
200 OK
```


```json
{
  "data": [
    {
      "id": "10c366ea-0951-4fb6-a77d-59e37884fe1f",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 47f4da45067b",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=10c366ea-0951-4fb6-a77d-59e37884fe1f",
            "self": "/object_occurrence_relations/10c366ea-0951-4fb6-a77d-59e37884fe1f/relationships/tags"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=10c366ea-0951-4fb6-a77d-59e37884fe1f"
          }
        },
        "classification_entry": {
          "data": {
            "id": "cb668fea-e954-44d1-8241-8e2da847295e",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/cb668fea-e954-44d1-8241-8e2da847295e",
            "self": "/object_occurrence_relations/10c366ea-0951-4fb6-a77d-59e37884fe1f/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "5b579af4-3222-4326-af3f-e0afdaaf7d2e",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/5b579af4-3222-4326-af3f-e0afdaaf7d2e",
            "self": "/object_occurrence_relations/10c366ea-0951-4fb6-a77d-59e37884fe1f/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "7de6f179-2433-4524-984c-9a447b184c9c",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/7de6f179-2433-4524-984c-9a447b184c9c",
            "self": "/object_occurrence_relations/10c366ea-0951-4fb6-a77d-59e37884fe1f/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "cb668fea-e954-44d1-8241-8e2da847295e",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm d295e4124d4e",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=cb668fea-e954-44d1-8241-8e2da847295e",
            "self": "/classification_entries/cb668fea-e954-44d1-8241-8e2da847295e/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=cb668fea-e954-44d1-8241-8e2da847295e",
            "self": "/classification_entries/cb668fea-e954-44d1-8241-8e2da847295e/relationships/classification_entries",
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
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=c9ce073c-2946-4d83-b279-aaeea759bd1a&amp;filter[object_occurrence_source_ids_cont][]=581a8ebd-fa72-4258-ac60-3f8a5b98f71b&amp;filter[object_occurrence_target_ids_cont][]=99dc3f3e-aef2-446e-a440-824696b4fa79
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;c9ce073c-2946-4d83-b279-aaeea759bd1a&quot;, &quot;581a8ebd-fa72-4258-ac60-3f8a5b98f71b&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;99dc3f3e-aef2-446e-a440-824696b4fa79&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ed4c3d24-100d-4406-8c26-cee117dfcd37
200 OK
```


```json
{
  "data": [
    {
      "id": "856e3074-d97f-4cc1-8b1b-f421df9e3673",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 96e67916994d",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=856e3074-d97f-4cc1-8b1b-f421df9e3673",
            "self": "/object_occurrence_relations/856e3074-d97f-4cc1-8b1b-f421df9e3673/relationships/tags"
          }
        },
        "progress_step_checked": {
          "data": [

          ],
          "links": {
            "related": "/progress?filter[target_id_eq]=856e3074-d97f-4cc1-8b1b-f421df9e3673"
          }
        },
        "classification_entry": {
          "data": {
            "id": "d680fe69-a788-4857-bd67-d148c2093ed5",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/d680fe69-a788-4857-bd67-d148c2093ed5",
            "self": "/object_occurrence_relations/856e3074-d97f-4cc1-8b1b-f421df9e3673/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "99dc3f3e-aef2-446e-a440-824696b4fa79",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/99dc3f3e-aef2-446e-a440-824696b4fa79",
            "self": "/object_occurrence_relations/856e3074-d97f-4cc1-8b1b-f421df9e3673/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "c9ce073c-2946-4d83-b279-aaeea759bd1a",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/c9ce073c-2946-4d83-b279-aaeea759bd1a",
            "self": "/object_occurrence_relations/856e3074-d97f-4cc1-8b1b-f421df9e3673/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "d680fe69-a788-4857-bd67-d148c2093ed5",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 8837f4128960",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "data": [

          ],
          "links": {
            "related": "/tags?filter[target_id_eq]=d680fe69-a788-4857-bd67-d148c2093ed5",
            "self": "/classification_entries/d680fe69-a788-4857-bd67-d148c2093ed5/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=d680fe69-a788-4857-bd67-d148c2093ed5",
            "self": "/classification_entries/d680fe69-a788-4857-bd67-d148c2093ed5/relationships/classification_entries",
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
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=c9ce073c-2946-4d83-b279-aaeea759bd1a&filter[object_occurrence_source_ids_cont][]=581a8ebd-fa72-4258-ac60-3f8a5b98f71b&filter[object_occurrence_target_ids_cont][]=99dc3f3e-aef2-446e-a440-824696b4fa79",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=c9ce073c-2946-4d83-b279-aaeea759bd1a&filter[object_occurrence_source_ids_cont][]=581a8ebd-fa72-4258-ac60-3f8a5b98f71b&filter[object_occurrence_target_ids_cont][]=99dc3f3e-aef2-446e-a440-824696b4fa79&include=tags,owners,classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/201cc7a6-ae89-44a2-a727-e443aae9373e
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
X-Request-Id: 21889254-fc72-499c-9b11-231c72a20a24
200 OK
```


```json
{
  "data": {
    "id": "201cc7a6-ae89-44a2-a727-e443aae9373e",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "OOR c96bf8270c03",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "data": [

        ],
        "links": {
          "related": "/tags?filter[target_id_eq]=201cc7a6-ae89-44a2-a727-e443aae9373e",
          "self": "/object_occurrence_relations/201cc7a6-ae89-44a2-a727-e443aae9373e/relationships/tags"
        }
      },
      "progress_step_checked": {
        "data": [

        ],
        "links": {
          "related": "/progress?filter[target_id_eq]=201cc7a6-ae89-44a2-a727-e443aae9373e"
        }
      },
      "classification_entry": {
        "data": {
          "id": "449ace0c-0a53-40d4-a5b6-e46c2266730a",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/449ace0c-0a53-40d4-a5b6-e46c2266730a",
          "self": "/object_occurrence_relations/201cc7a6-ae89-44a2-a727-e443aae9373e/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "01163fa8-2fb7-4e1d-b821-c27f4d0bc252",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/01163fa8-2fb7-4e1d-b821-c27f4d0bc252",
          "self": "/object_occurrence_relations/201cc7a6-ae89-44a2-a727-e443aae9373e/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "7d15493d-0d52-4664-afa2-d66edbd8a238",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/7d15493d-0d52-4664-afa2-d66edbd8a238",
          "self": "/object_occurrence_relations/201cc7a6-ae89-44a2-a727-e443aae9373e/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/201cc7a6-ae89-44a2-a727-e443aae9373e"
  },
  "included": [

  ]
}
```



# Object Occurrences - Classification Entries Stats

Aggregated view of Object Occurrencs groupped by Classification Entry


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
X-Request-Id: 881d5362-d4db-445f-951f-6c425b11688e
200 OK
```


```json
{
  "data": [
    {
      "id": "0b63a35876b3e77d3de5c17b50a61b0e08ad930071b31c32de4854af87a49371",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "e1f497c8-5152-4b6f-829c-82443a81d646",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/e1f497c8-5152-4b6f-829c-82443a81d646"
          }
        }
      }
    },
    {
      "id": "7f8b93b5ed5d247e482572c5eee6340d86dc4808e3e4133bffec79afb3e4540b",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "e03ae967-c8c7-44c5-892e-695aee69f055",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/e03ae967-c8c7-44c5-892e-695aee69f055"
          }
        }
      }
    },
    {
      "id": "4ff1bec6b31473cc4145f06a72d2acda94b1acb5588b7af6f89a597412a0b37d",
      "type": "ooc_classification_entry_stat",
      "attributes": {
        "ooc_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "26eb1a10-f139-4349-bd67-d8420b26bf3d",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/26eb1a10-f139-4349-bd67-d8420b26bf3d"
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
X-Request-Id: b00911d0-c6ef-4bc4-bdc4-7f10a12ab5fb
200 OK
```


```json
{
  "data": [
    {
      "id": "38f68c3f-8d21-4a0d-9892-5bbc860ec2a5",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "409e8e6b-f9cc-44de-9c22-ba9c4dc1e056",
            "type": "project"
          },
          "links": {
            "related": "/projects/409e8e6b-f9cc-44de-9c22-ba9c4dc1e056"
          }
        },
        "user": {
          "data": {
            "id": "58fddc56-f0d2-4191-ac75-45fff2cdfd3a",
            "type": "user"
          },
          "links": {
            "related": "/users/58fddc56-f0d2-4191-ac75-45fff2cdfd3a"
          }
        },
        "permission": {
          "data": {
            "id": "96d6aee4-088e-4adc-8277-a6821e3d5e75",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/96d6aee4-088e-4adc-8277-a6821e3d5e75"
          }
        }
      }
    },
    {
      "id": "6c5ab843-b8e3-4232-a534-2654d3fbbcd5",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "3fef5fe8-2a7d-47bd-b35a-a2b25cbb9dad",
            "type": "context"
          },
          "links": {
            "related": "/contexts/3fef5fe8-2a7d-47bd-b35a-a2b25cbb9dad"
          }
        },
        "user": {
          "data": {
            "id": "58fddc56-f0d2-4191-ac75-45fff2cdfd3a",
            "type": "user"
          },
          "links": {
            "related": "/users/58fddc56-f0d2-4191-ac75-45fff2cdfd3a"
          }
        },
        "permission": {
          "data": {
            "id": "767a3cfd-377d-42eb-a8c8-55acbfe5be48",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/767a3cfd-377d-42eb-a8c8-55acbfe5be48"
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
GET /user_permissions?filter[target_type_eq]=project&amp;filter[target_id_eq]=6b36e234-bb40-4da9-b313-bb6f814493c9&amp;filter[user_id_eq]=547d7733-8890-48d1-8e10-0b3013501e03&amp;filter[permission_id_eq]=4995faa9-cfcd-4abc-a209-2fd789f9a008
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /user_permissions`

#### Parameters


```json
filter: {&quot;target_type_eq&quot;=&gt;&quot;project&quot;, &quot;target_id_eq&quot;=&gt;&quot;6b36e234-bb40-4da9-b313-bb6f814493c9&quot;, &quot;user_id_eq&quot;=&gt;&quot;547d7733-8890-48d1-8e10-0b3013501e03&quot;, &quot;permission_id_eq&quot;=&gt;&quot;4995faa9-cfcd-4abc-a209-2fd789f9a008&quot;}
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
X-Request-Id: bca94dfc-95d7-4a69-8ffb-501ca6b6ee98
200 OK
```


```json
{
  "data": [
    {
      "id": "ded3f80d-4374-49b0-8e06-3869e446c077",
      "type": "user_permission",
      "relationships": {
        "target": {
          "data": {
            "id": "6b36e234-bb40-4da9-b313-bb6f814493c9",
            "type": "project"
          },
          "links": {
            "related": "/projects/6b36e234-bb40-4da9-b313-bb6f814493c9"
          }
        },
        "user": {
          "data": {
            "id": "547d7733-8890-48d1-8e10-0b3013501e03",
            "type": "user"
          },
          "links": {
            "related": "/users/547d7733-8890-48d1-8e10-0b3013501e03"
          }
        },
        "permission": {
          "data": {
            "id": "4995faa9-cfcd-4abc-a209-2fd789f9a008",
            "type": "permission"
          },
          "links": {
            "related": "/permissions/4995faa9-cfcd-4abc-a209-2fd789f9a008"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 1
  },
  "links": {
    "self": "http://example.org/user_permissions?filter[target_type_eq]=project&filter[target_id_eq]=6b36e234-bb40-4da9-b313-bb6f814493c9&filter[user_id_eq]=547d7733-8890-48d1-8e10-0b3013501e03&filter[permission_id_eq]=4995faa9-cfcd-4abc-a209-2fd789f9a008",
    "current": "http://example.org/user_permissions?filter[permission_id_eq]=4995faa9-cfcd-4abc-a209-2fd789f9a008&filter[target_id_eq]=6b36e234-bb40-4da9-b313-bb6f814493c9&filter[target_type_eq]=project&filter[user_id_eq]=547d7733-8890-48d1-8e10-0b3013501e03&page[number]=1"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /user_permissions/ff89518c-bba4-49a7-a95f-7961a00da863
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
X-Request-Id: 89a08af6-3b30-4e82-af93-91f84abdd3fc
200 OK
```


```json
{
  "data": {
    "id": "ff89518c-bba4-49a7-a95f-7961a00da863",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "773fabfe-ddde-434c-944e-4d061982d177",
          "type": "project"
        },
        "links": {
          "related": "/projects/773fabfe-ddde-434c-944e-4d061982d177"
        }
      },
      "user": {
        "data": {
          "id": "a72f27b1-7d39-4465-b09a-83dea0a8333b",
          "type": "user"
        },
        "links": {
          "related": "/users/a72f27b1-7d39-4465-b09a-83dea0a8333b"
        }
      },
      "permission": {
        "data": {
          "id": "5f1a4735-d3fb-43e2-805e-d3528bfd5e92",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/5f1a4735-d3fb-43e2-805e-d3528bfd5e92"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/user_permissions/ff89518c-bba4-49a7-a95f-7961a00da863"
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
          "id": "00f49d45-a2b5-4b5d-a7fe-264cff9ec98b"
        }
      },
      "permission": {
        "data": {
          "type": "permission",
          "id": "11c35f85-a4e8-4d06-9f57-776fa97d3125"
        }
      },
      "user": {
        "data": {
          "type": "user",
          "id": "3300a4ce-fa5a-438b-a584-75bdcf860ba4"
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
X-Request-Id: ffa5ed0b-1dea-4ef8-a61d-02009761ad04
201 Created
```


```json
{
  "data": {
    "id": "97ecd107-94a1-4f78-8e1e-13dd1f14f6c1",
    "type": "user_permission",
    "relationships": {
      "target": {
        "data": {
          "id": "00f49d45-a2b5-4b5d-a7fe-264cff9ec98b",
          "type": "project"
        },
        "links": {
          "related": "/projects/00f49d45-a2b5-4b5d-a7fe-264cff9ec98b"
        }
      },
      "user": {
        "data": {
          "id": "3300a4ce-fa5a-438b-a584-75bdcf860ba4",
          "type": "user"
        },
        "links": {
          "related": "/users/3300a4ce-fa5a-438b-a584-75bdcf860ba4"
        }
      },
      "permission": {
        "data": {
          "id": "11c35f85-a4e8-4d06-9f57-776fa97d3125",
          "type": "permission"
        },
        "links": {
          "related": "/permissions/11c35f85-a4e8-4d06-9f57-776fa97d3125"
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
DELETE /user_permissions/c7f5420a-6e1e-4c81-a73a-43b2e6a9d1da
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /user_permissions/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 86b80b48-0b57-46b1-a212-9fececce64d2
204 No Content
```




# Object Occurrence Relations - Classification Entries Stats

Aggregated view of Object Occurrence Relations groupped by Classification Entry


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
X-Request-Id: 45567a8b-57d2-44e7-a186-16bdb6083151
200 OK
```


```json
{
  "data": [
    {
      "id": "72f7f1550d90ce555d8a6e8ba3b48a76e57c7d6d8f127485700bb9cae33c0403",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "7fe2a956-e9ec-461e-9018-facc75f11190",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/7fe2a956-e9ec-461e-9018-facc75f11190"
          }
        }
      }
    },
    {
      "id": "b563a6c21700bce3f23acd167c09582714c036d6a9a00e5e910eb17f9747a7dd",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 1
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "14564db2-1ad5-4f1c-a904-fc38915b560d",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/14564db2-1ad5-4f1c-a904-fc38915b560d"
          }
        }
      }
    },
    {
      "id": "4fb58ccf1188ca5382d1d5d0a670f3c485a43b25ad4da7c168e06c9d728f16c0",
      "type": "oor_classification_entry_stat",
      "attributes": {
        "oor_count": 2
      },
      "relationships": {
        "classification_entry": {
          "data": {
            "id": "9d60fbc5-2bfe-4b48-8032-6f6a4fe595c4",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/9d60fbc5-2bfe-4b48-8032-6f6a4fe595c4"
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
X-Request-Id: b0cb7c5a-5c30-4fb2-bfc0-fa201b0b60eb
200 OK
```


```json
{
  "data": [
    {
      "id": "97ff8bd3-1044-472d-85e0-e4f5c03d9ffe",
      "type": "tag",
      "attributes": {
        "value": "tag value 7"
      },
      "relationships": {
      }
    },
    {
      "id": "44c57045-ad07-4143-b148-25987e85e925",
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
X-Request-Id: 9975e759-7542-4ae6-8154-032044825fe7
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
GET /permissions/8e100617-9b65-4916-aa80-d49c4040e2b9
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
X-Request-Id: 9e8ff844-3c6f-49d8-b315-2579e03c3121
200 OK
```


```json
{
  "data": {
    "id": "8e100617-9b65-4916-aa80-d49c4040e2b9",
    "type": "permission",
    "attributes": {
      "name": "account:write",
      "description": "MyText"
    }
  },
  "links": {
    "self": "http://example.org/permissions/8e100617-9b65-4916-aa80-d49c4040e2b9"
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
GET /utils/path/from/object_occurrence/b81fc721-aff9-4f8d-94cc-74c065c22be7/to/object_occurrence/b9f99cae-8b42-4b76-b2ef-8db4f49a7302
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
X-Request-Id: be133e79-9b5d-4159-a7c6-18898a324d9c
200 OK
```


```json
[
  {
    "id": "b81fc721-aff9-4f8d-94cc-74c065c22be7",
    "type": "object_occurrence"
  },
  {
    "id": "73525e93-da4c-4a24-81d2-be0b5881b906",
    "type": "object_occurrence"
  },
  {
    "id": "bab9f6e3-6763-4333-b452-41be9c0e3eac",
    "type": "object_occurrence"
  },
  {
    "id": "549745f2-1256-4776-ae63-ee8d53ade370",
    "type": "object_occurrence"
  },
  {
    "id": "dab723ae-64f8-4e6f-be67-9baef5a6f401",
    "type": "object_occurrence"
  },
  {
    "id": "02a6a5a6-16dc-40b6-b204-85b92d3adc7d",
    "type": "object_occurrence"
  },
  {
    "id": "b9f99cae-8b42-4b76-b2ef-8db4f49a7302",
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
X-Request-Id: 3b3d1144-0f09-4dbc-9a90-b436334d279c
200 OK
```


```json
{
  "data": [
    {
      "id": "c471ae38-8215-4ca3-a179-b7e57026c3ac",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/8366c7c7-d919-4b14-844f-ed1086685c2c"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/47d08543-b78f-4359-b65c-ed88acfc0913"
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
X-Request-Id: 06f5c5a8-17c5-44c5-88c5-4cceb7a1daed
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



