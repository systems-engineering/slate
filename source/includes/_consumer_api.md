# SEC-Hub Consumer API

This API exposes information that allowes an authenticated client to manipulate the CORE, SIMO,
DOCU, DOMA, and STEM concepts.

This documentation's permalink is: [https://sec-hub.com/docs/consumer/api](https://sec-hub.com/docs/consumer/api)

## Authentication

```
GET /resource
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

Authentication happens through <a href="https://auth0.com/docs/quickstarts" target="_blank">Auth0</a>
with a preconfigured OAuth2 Client.

Any client must first be setup to access the <code>subdomain</code>'s Auth0 tenant, and then
authenticate with the Auth0 API to retrieve a bearer token.

Then access this API with the bearer token in the Authorization header:

<aside class="notice">
  The client <strong>MUST</strong> send the <code>Authorization</code> header along with every
  request.
</aside>

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
GET /projects?filter[name_or_description_matches_any]=some%20text
```

All of the list endpoints [support filtering](https://jsonapi.org/format/1.1/#fetching-filtering).
The filtering is implemented using [Ransack matchers](https://github.com/activerecord-hackery/ransack#search-matchers)

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
X-Request-Id: 71a3e78e-6306-4fb7-a430-826869178090
200 OK
```


```json
{
  "data": {
    "id": "58693ab2-6270-46c1-b800-ed08cea4d426",
    "type": "account",
    "attributes": {
      "name": "Account 081d7d8ffad8"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects"
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
    "id": "1d901c3a-0261-4901-b645-7460a35c3f93",
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
X-Request-Id: eba50f09-80c6-46c5-b719-ac0d7e155ecb
200 OK
```


```json
{
  "data": {
    "id": "1d901c3a-0261-4901-b645-7460a35c3f93",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    },
    "relationships": {
      "projects": {
        "links": {
          "related": "/projects"
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


None known.


### Response

```plaintext
X-Request-Id: 8b457a9f-0cb8-4c25-9137-9d3cbf14f951
200 OK
```


```json
{
  "data": [
    {
      "id": "e0e257db-16bb-4bbb-81b2-9907af3864a2",
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
            "related": "/contexts?filter[project_id_eq]=e0e257db-16bb-4bbb-81b2-9907af3864a2"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/projects",
    "current": "http://example.org/projects?page[number]=1"
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
GET /projects/b68f263a-e6fd-49eb-bdf3-a6cea419d30a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: db351cd2-ef4c-4496-afa2-1f290bf159fa
200 OK
```


```json
{
  "data": {
    "id": "b68f263a-e6fd-49eb-bdf3-a6cea419d30a",
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
          "related": "/contexts?filter[project_id_eq]=b68f263a-e6fd-49eb-bdf3-a6cea419d30a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b68f263a-e6fd-49eb-bdf3-a6cea419d30a"
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
PATCH /projects/3ab18f36-f408-46ca-bdd8-4a0ccf05dd85
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "3ab18f36-f408-46ca-bdd8-4a0ccf05dd85",
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
X-Request-Id: b1745a0a-50ef-4cfc-826b-b40a980e9010
200 OK
```


```json
{
  "data": {
    "id": "3ab18f36-f408-46ca-bdd8-4a0ccf05dd85",
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
          "related": "/contexts?filter[project_id_eq]=3ab18f36-f408-46ca-bdd8-4a0ccf05dd85"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/3ab18f36-f408-46ca-bdd8-4a0ccf05dd85"
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
POST /projects/746793d0-4358-4a2f-a76c-776f2c354e9a/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 03bbd0c8-1501-4f91-95e5-fda423557e0e
200 OK
```


```json
{
  "data": {
    "id": "746793d0-4358-4a2f-a76c-776f2c354e9a",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2019-12-11T06:32:17.354Z",
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
          "related": "/contexts?filter[project_id_eq]=746793d0-4358-4a2f-a76c-776f2c354e9a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/746793d0-4358-4a2f-a76c-776f2c354e9a/archive"
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
DELETE /projects/128c3e47-f668-44de-8a1d-b09af05c1f80
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 531790d5-5290-46fe-8511-f966d29147d1
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


None known.


### Response

```plaintext
X-Request-Id: a30c7cb7-b291-4864-8d28-029c83085df9
200 OK
```


```json
{
  "data": [
    {
      "id": "e857f22f-64b2-42ad-94a9-db9d6eb30cb7",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 1",
        "project_id": "5af746a9-e0a9-4eb4-b237-cf0131a554d9",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/5af746a9-e0a9-4eb4-b237-cf0131a554d9"
          }
        }
      }
    },
    {
      "id": "2166ade0-60f4-411b-a3c5-ca5174d795c4",
      "type": "context",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "description": null,
        "name": "Context 2",
        "project_id": "5af746a9-e0a9-4eb4-b237-cf0131a554d9",
        "published_at": null
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/5af746a9-e0a9-4eb4-b237-cf0131a554d9"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/contexts",
    "current": "http://example.org/contexts?page[number]=1"
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
GET /contexts/3d39a353-6f3f-4741-a991-e994eb4de6ca
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5b9dd048-78ba-4485-8a77-09bd0bb98a70
200 OK
```


```json
{
  "data": {
    "id": "3d39a353-6f3f-4741-a991-e994eb4de6ca",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "project_id": "e9005b82-4c0e-4f09-832b-5ac8302a699c",
      "published_at": null
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/e9005b82-4c0e-4f09-832b-5ac8302a699c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/3d39a353-6f3f-4741-a991-e994eb4de6ca"
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
PATCH /contexts/627021fb-d0ec-439c-999b-b31dfba27da9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "627021fb-d0ec-439c-999b-b31dfba27da9",
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
X-Request-Id: ed4bb41d-f1ca-4b74-b9cf-e54ef1183f47
200 OK
```


```json
{
  "data": {
    "id": "627021fb-d0ec-439c-999b-b31dfba27da9",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "New context name",
      "project_id": "8347d04e-38d4-4ca7-b45a-ceccbf83ad28",
      "published_at": null
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/8347d04e-38d4-4ca7-b45a-ceccbf83ad28"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/5be170cb-017f-46b4-aff5-96dc5f9e9ad8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/627021fb-d0ec-439c-999b-b31dfba27da9"
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
POST /contexts
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts`

#### Parameters


```json
{
  "data": {
    "type": "context",
    "attributes": {
      "name": "Context",
      "project_id": "f2486d14-8393-4233-a12e-2a8f676df8b3"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 225dc33d-be41-45ef-99a6-d7fe4165e718
201 Created
```


```json
{
  "data": {
    "id": "641e382b-1bd5-4a19-8fc2-6dfd6912e3ec",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context",
      "project_id": "f2486d14-8393-4233-a12e-2a8f676df8b3",
      "published_at": null
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/f2486d14-8393-4233-a12e-2a8f676df8b3"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/89f4a860-7ed8-44ec-9403-377e8ad16978"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts"
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


## Delete


### Request

#### Endpoint

```plaintext
DELETE /contexts/5638ec29-67b7-4b54-acd9-620c774eff5a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ca03955c-1abb-452a-b905-9f9c1cdba160
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


## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/89d350df-1298-4105-90a5-a4f0421eff6c
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
X-Request-Id: 9a1003e9-dd08-42bb-9808-d2c929958161
200 OK
```


```json
{
  "data": {
    "id": "89d350df-1298-4105-90a5-a4f0421eff6c",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "cab9ba79-37ee-43ca-a6ca-4096a5c7da26",
      "description": null,
      "hex_color": null,
      "name": "OOC 1",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": ""
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/cab9ba79-37ee-43ca-a6ca-4096a5c7da26"
        }
      },
      "components": {
        "data": [
          {
            "id": "e5503123-ae98-4d65-8418-0b128969f97f",
            "type": "object_occurrence"
          }
        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/89d350df-1298-4105-90a5-a4f0421eff6c"
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
POST /object_occurrences
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences`

#### Parameters


```json
{
  "data": {
    "type": "object_occurrence",
    "attributes": {
      "name": "ooc",
      "context_id": "e55b9e84-cd7e-45e9-859a-9ba37f1b76e8"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 41dc1a53-ed4c-4c1f-baaf-4b1df9c0015e
201 Created
```


```json
{
  "data": {
    "id": "23aec673-d6b5-437e-9e24-04d60f83133e",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "e55b9e84-cd7e-45e9-859a-9ba37f1b76e8",
      "description": null,
      "hex_color": null,
      "name": "ooc",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": ""
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/e55b9e84-cd7e-45e9-859a-9ba37f1b76e8"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences"
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
PATCH /object_occurrences/dc377146-a763-48a3-9b07-413c8c3a82c5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "dc377146-a763-48a3-9b07-413c8c3a82c5",
    "type": "object_occurrence",
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
X-Request-Id: ddb567c8-fb25-4e26-8729-e4fb2e8fc0db
200 OK
```


```json
{
  "data": {
    "id": "dc377146-a763-48a3-9b07-413c8c3a82c5",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "context_id": "2261ea3b-1010-46e2-a6c1-db186b8e7819",
      "description": null,
      "hex_color": null,
      "name": "New name",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": "0"
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/2261ea3b-1010-46e2-a6c1-db186b8e7819"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/a58907bf-e71c-4c9e-9ab4-12a0f958a57e"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/dc377146-a763-48a3-9b07-413c8c3a82c5"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/055b03d2-4f18-4377-8a4e-49802b6deea5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 398c85bc-7cac-44dc-884d-47d1b71bca75
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


# Classification Tables

Classification tables represent a strategic breakdown of the company product(s) into a nuanced
and logically separated classification table structure.

Each classification table has multiple classification entries.


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


None known.


### Response

```plaintext
X-Request-Id: e1557079-bdc4-47e0-b26b-61bf67b34f46
200 OK
```


```json
{
  "data": [
    {
      "id": "a8cb3abb-9285-4954-b0a0-3edbc8dde767",
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
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=a8cb3abb-9285-4954-b0a0-3edbc8dde767"
          }
        }
      }
    },
    {
      "id": "7744f2d8-3c25-4c4b-944a-aa3bd4fb292c",
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
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=7744f2d8-3c25-4c4b-944a-aa3bd4fb292c"
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
GET /classification_tables/64d23be0-9e5c-4d8e-9e5a-079e211a6d4e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cc0a3263-78f2-48e6-9ff5-1b05cb748be4
200 OK
```


```json
{
  "data": {
    "id": "64d23be0-9e5c-4d8e-9e5a-079e211a6d4e",
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
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=64d23be0-9e5c-4d8e-9e5a-079e211a6d4e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/64d23be0-9e5c-4d8e-9e5a-079e211a6d4e"
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
PATCH /classification_tables/2a6822b1-bbec-4893-ad4e-d244910c4ce5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "2a6822b1-bbec-4893-ad4e-d244910c4ce5",
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
X-Request-Id: 42c19b0d-eac4-4cd1-afea-fa1bfb1bb498
200 OK
```


```json
{
  "data": {
    "id": "2a6822b1-bbec-4893-ad4e-d244910c4ce5",
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
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=2a6822b1-bbec-4893-ad4e-d244910c4ce5"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/2a6822b1-bbec-4893-ad4e-d244910c4ce5"
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
DELETE /classification_tables/56c08d78-a218-46ab-ba7d-470c2da75ac1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e923cc1c-3650-4e36-80ef-ce4f576150ec
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
POST /classification_tables/0486bfff-539c-469f-8ac5-46a5a245ad21/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f55019a9-8811-4e9b-adef-715a1f5c281d
200 OK
```


```json
{
  "data": {
    "id": "0486bfff-539c-469f-8ac5-46a5a245ad21",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2019-12-11T06:32:23.988Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=0486bfff-539c-469f-8ac5-46a5a245ad21"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0486bfff-539c-469f-8ac5-46a5a245ad21/publish"
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
POST /classification_tables/874453a5-fdb2-4ebd-a897-55c5880b0d8b/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: bc54aa77-ccbb-4243-b4cf-7dc78a61b667
200 OK
```


```json
{
  "data": {
    "id": "874453a5-fdb2-4ebd-a897-55c5880b0d8b",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2019-12-11T06:32:24.246Z",
      "description": null,
      "name": "CT 1",
      "published": false,
      "published_at": null,
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=874453a5-fdb2-4ebd-a897-55c5880b0d8b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/874453a5-fdb2-4ebd-a897-55c5880b0d8b/archive"
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
X-Request-Id: 49f70859-84de-44e5-aa2b-bc89ea7e419b
201 Created
```


```json
{
  "data": {
    "id": "e41012f3-d1ad-47ab-a88d-43e6aa731f15",
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
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=e41012f3-d1ad-47ab-a88d-43e6aa731f15"
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


None known.


### Response

```plaintext
X-Request-Id: 4a68b4ce-92a0-42da-b966-6edb2f741728
200 OK
```


```json
{
  "data": [
    {
      "id": "2ec810c0-c3cf-4310-8ceb-c3b32b2be328",
      "type": "syntax",
      "attributes": {
        "account_id": "7d251bdc-5e8b-4977-a2b1-ba116c700731",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 66f531b76cbc",
        "published": false,
        "published_at": null
      },
      "relationships": {
        "account": {
          "links": {
            "related": "/"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/syntaxes",
    "current": "http://example.org/syntaxes?page[number]=1"
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
GET /syntaxes/1639fd05-8033-42e4-a462-e6623bb6da45
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 84862ae5-88d5-472e-9782-868f597be805
200 OK
```


```json
{
  "data": {
    "id": "1639fd05-8033-42e4-a462-e6623bb6da45",
    "type": "syntax",
    "attributes": {
      "account_id": "43efe517-c4be-4af0-b172-c8c141549a67",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 48ef53df78d9",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/1639fd05-8033-42e4-a462-e6623bb6da45"
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
X-Request-Id: 2b44ae9e-d94f-4694-ae81-db1933c7cf9f
201 Created
```


```json
{
  "data": {
    "id": "4446f913-244b-4df8-b908-d5a71b98eddf",
    "type": "syntax",
    "attributes": {
      "account_id": "ee5e799e-f0ca-41ce-af41-191c21822940",
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
PATCH /syntaxes/f839e2ea-b52b-40c6-984a-eedf723967f5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "f839e2ea-b52b-40c6-984a-eedf723967f5",
    "type": "syntaxes",
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
X-Request-Id: 59f88230-d715-4fdf-9151-39d4c1fd9d39
200 OK
```


```json
{
  "data": {
    "id": "f839e2ea-b52b-40c6-984a-eedf723967f5",
    "type": "syntax",
    "attributes": {
      "account_id": "7279912b-3cbd-45ef-9b0e-b7e57d4b4ccb",
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
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/f839e2ea-b52b-40c6-984a-eedf723967f5"
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
DELETE /syntaxes/814a8b46-7ddf-49a4-94be-1632ff8207c8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d50df98a-5408-47d0-a609-ccd39cfabc47
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
POST /syntaxes/34e728eb-e778-4f27-9716-b8844d00e854/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3e4beb17-f41b-4dd2-832d-ac3906ecc63b
200 OK
```


```json
{
  "data": {
    "id": "34e728eb-e778-4f27-9716-b8844d00e854",
    "type": "syntax",
    "attributes": {
      "account_id": "a1f2d2a7-6d02-4830-9c51-44bbb05577b9",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax debbeba8bbd6",
      "published": true,
      "published_at": "2019-12-11T06:32:26.247Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/34e728eb-e778-4f27-9716-b8844d00e854/publish"
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
POST /syntaxes/305e4f46-d763-43a5-b01f-5399e056078b/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fb208144-0407-457b-bdbe-77550290997a
200 OK
```


```json
{
  "data": {
    "id": "305e4f46-d763-43a5-b01f-5399e056078b",
    "type": "syntax",
    "attributes": {
      "account_id": "bfd7c3d0-548e-440f-b76c-f9d2c755d784",
      "archived": true,
      "archived_at": "2019-12-11T06:32:26.558Z",
      "description": "Description",
      "name": "Syntax 88b2aac48813",
      "published": false,
      "published_at": null
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/305e4f46-d763-43a5-b01f-5399e056078b/archive"
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


None known.


### Response

```plaintext
X-Request-Id: a4e569d7-d0ce-45ef-8dbf-83e7afb528f0
200 OK
```


```json
{
  "data": [
    {
      "id": "8a4950dc-57d7-4f99-95c5-44804189606e",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "e72cd02b-1c55-4944-af6e-cb22d0f34d01",
        "hex_color": "27622c",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 43b49e046d34",
        "syntax_id": "02dbed68-f1b2-459e-864e-00c73a89bbe5"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/02dbed68-f1b2-459e-864e-00c73a89bbe5"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/e72cd02b-1c55-4944-af6e-cb22d0f34d01"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://example.org/syntax_elements",
    "current": "http://example.org/syntax_elements?page[number]=1"
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
GET /syntax_elements/2ee8a213-2c65-4c3b-87ab-71b9cc5ad5cf
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 47c61583-e987-48d9-ab45-c5bca3510c70
200 OK
```


```json
{
  "data": {
    "id": "2ee8a213-2c65-4c3b-87ab-71b9cc5ad5cf",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "97a2b116-eac3-40cb-8d0d-a849086d4bbc",
      "hex_color": "4a5eac",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 5a1f8439d90f",
      "syntax_id": "cf0ab9ef-8c72-4350-9486-b028679863d9"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/cf0ab9ef-8c72-4350-9486-b028679863d9"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/97a2b116-eac3-40cb-8d0d-a849086d4bbc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/2ee8a213-2c65-4c3b-87ab-71b9cc5ad5cf"
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
POST /syntax_elements
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntax_elements`

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
      "aspect": "#",
      "syntax_id": "255aa72e-97b1-4b85-a646-bd139f1e750e",
      "classification_table_id": "3048d17d-627a-461c-8d10-d9c5c9df253c"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 32333ead-8aa5-4837-a9ff-87293c09cc19
201 Created
```


```json
{
  "data": {
    "id": "5ddd1921-b6b0-47c9-969d-8ead575e7270",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "3048d17d-627a-461c-8d10-d9c5c9df253c",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "syntax_id": "255aa72e-97b1-4b85-a646-bd139f1e750e"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/255aa72e-97b1-4b85-a646-bd139f1e750e"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/3048d17d-627a-461c-8d10-d9c5c9df253c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements"
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
PATCH /syntax_elements/cee0222a-8439-4a13-830b-7eb2e9b6f2c6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "cee0222a-8439-4a13-830b-7eb2e9b6f2c6",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New name |



### Response

```plaintext
X-Request-Id: 5ccb4cab-b8df-4ef1-91b0-733d3cf01f21
200 OK
```


```json
{
  "data": {
    "id": "cee0222a-8439-4a13-830b-7eb2e9b6f2c6",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "7f183203-72a4-4bd0-83f7-51870dcce471",
      "hex_color": "4e7253",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "syntax_id": "e17c59e1-75ef-467c-bec3-4269e46172d8"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e17c59e1-75ef-467c-bec3-4269e46172d8"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/7f183203-72a4-4bd0-83f7-51870dcce471"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/cee0222a-8439-4a13-830b-7eb2e9b6f2c6"
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
DELETE /syntax_elements/98507985-16c4-4a62-84d5-3d01ac46a399
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6fcca1ab-11b4-4641-a3f0-d3f88f2d0278
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
GET /syntax_nodes/08f3c71d-3e83-47fb-9ddb-04e5f1b57cd0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_nodes/:id`

#### Parameters



| Name | Description |
|:-----|:------------|
| depth  | Components depth |



### Response

```plaintext
X-Request-Id: fe25c88f-eee8-4347-9387-db07f423979b
200 OK
```


```json
{
  "data": {
    "id": "08f3c71d-3e83-47fb-9ddb-04e5f1b57cd0",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1,
      "syntax_element_id": "621a51f6-4a6f-4356-8ebf-d678da2e4100"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/621a51f6-4a6f-4356-8ebf-d678da2e4100"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/08f3c71d-3e83-47fb-9ddb-04e5f1b57cd0"
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


## Create


### Request

#### Endpoint

```plaintext
POST /syntax_nodes
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntax_nodes`

#### Parameters


```json
{
  "data": {
    "type": "syntax_node",
    "attributes": {
      "position": 9,
      "min_depth": 1,
      "max_depth": 5,
      "syntax_element_id": "ff25ed50-b980-45b5-bcd7-ae40f75e3541"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: a0680315-da89-4685-8298-498e52cc0ca4
201 Created
```


```json
{
  "data": {
    "id": "cdd9df64-7b8c-40f3-a28e-0d94abb840f5",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9,
      "syntax_element_id": "ff25ed50-b980-45b5-bcd7-ae40f75e3541"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/ff25ed50-b980-45b5-bcd7-ae40f75e3541"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes"
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
PATCH /syntax_nodes/78757a96-406e-44b0-91e8-de1d0216f04f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "78757a96-406e-44b0-91e8-de1d0216f04f",
    "type": "syntax_node",
    "attributes": {
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
X-Request-Id: d260e5fd-1a5a-4ed8-8188-4a5bf48f1a55
200 OK
```


```json
{
  "data": {
    "id": "78757a96-406e-44b0-91e8-de1d0216f04f",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5,
      "syntax_element_id": "1ad75926-49d6-4e88-a8ff-f498f2659ea4"
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/1ad75926-49d6-4e88-a8ff-f498f2659ea4"
        }
      },
      "components": {
        "data": [

        ]
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/78757a96-406e-44b0-91e8-de1d0216f04f"
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
DELETE /syntax_nodes/7ff9a24d-4068-4e12-a607-0e1b80856d87
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 961c2d13-9c68-4768-8efe-ff41b515a51f
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


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
X-Request-Id: aa6038f7-457c-4bea-ba85-a0daebcb1989
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



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


None known.


### Response

```plaintext
X-Request-Id: 73c226f8-1b20-4781-a319-b9298d70b389
200 OK
```


```json
{
  "data": [
    {
      "id": "d88f385b-20d9-4a63-9d8e-8d10eddb98d9",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/1697adf5-19d8-4922-ab1f-d94cf0804f9c"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/05a70b46-f5c8-40a1-a1d2-915a5d8ab5af"
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


