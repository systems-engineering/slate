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

When negotiating authentication with Auth0 the client should use the `https://<subdomain>.eu.auth0.com/api/v2` audience.

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
X-Request-Id: 437d46cd-33cc-4ded-8655-11656339d756
200 OK
```


```json
{
  "data": {
    "id": "c0418c45-464e-4927-be6f-bd078805dd36",
    "type": "account",
    "attributes": {
      "name": "Account 5dfc61f4ebd9"
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
    "id": "478179e8-3666-44f0-a6ea-3d68e3679c7b",
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
X-Request-Id: 9282702e-ae63-4aeb-abcd-29345dd3b14e
200 OK
```


```json
{
  "data": {
    "id": "478179e8-3666-44f0-a6ea-3d68e3679c7b",
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
X-Request-Id: 29ea7bbf-6cd8-406a-92dd-fd819191663d
200 OK
```


```json
{
  "data": [
    {
      "id": "ec47c400-c873-4a39-9fab-71d560587963",
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
            "related": "/contexts?filter[project_id_eq]=ec47c400-c873-4a39-9fab-71d560587963",
            "self": "/projects/ec47c400-c873-4a39-9fab-71d560587963/relationships/contexts"
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
GET /projects/156767c9-f2e1-49f7-a355-284323414b82
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3fcd4590-1c6a-4e11-be25-0b79230fce1e
200 OK
```


```json
{
  "data": {
    "id": "156767c9-f2e1-49f7-a355-284323414b82",
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
          "related": "/contexts?filter[project_id_eq]=156767c9-f2e1-49f7-a355-284323414b82",
          "self": "/projects/156767c9-f2e1-49f7-a355-284323414b82/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/156767c9-f2e1-49f7-a355-284323414b82"
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
PATCH /projects/7f537f12-55ef-4f34-afbb-f5cd8d331782
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "7f537f12-55ef-4f34-afbb-f5cd8d331782",
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
X-Request-Id: c93c37aa-1186-4933-aafc-5515d9c96a2d
200 OK
```


```json
{
  "data": {
    "id": "7f537f12-55ef-4f34-afbb-f5cd8d331782",
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
          "related": "/contexts?filter[project_id_eq]=7f537f12-55ef-4f34-afbb-f5cd8d331782",
          "self": "/projects/7f537f12-55ef-4f34-afbb-f5cd8d331782/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7f537f12-55ef-4f34-afbb-f5cd8d331782"
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
POST /projects/fffc717f-8de3-4549-9ef3-25bac2706857/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /projects/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: da245be6-ab8e-4670-863e-6c3089cd41f7
200 OK
```


```json
{
  "data": {
    "id": "fffc717f-8de3-4549-9ef3-25bac2706857",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-01-08T09:13:31.729Z",
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
          "related": "/contexts?filter[project_id_eq]=fffc717f-8de3-4549-9ef3-25bac2706857",
          "self": "/projects/fffc717f-8de3-4549-9ef3-25bac2706857/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/fffc717f-8de3-4549-9ef3-25bac2706857/archive"
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
DELETE /projects/ffb7b50f-8c9e-41c1-a24c-f290ab373c59
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: dd781ec3-e4b9-4d8a-befc-58fa87d00555
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
X-Request-Id: e6ff3918-e95a-4abd-bb60-c50d4afaf303
200 OK
```


```json
{
  "data": [
    {
      "id": "774f3002-c87d-4078-a2ae-d2b181a8a89f",
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
        "project": {
          "links": {
            "related": "/projects/1e65961f-cf36-4c84-8924-72af5b96f73b"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/2fefc085-da36-4e66-a937-f487254cbe97"
          }
        }
      }
    },
    {
      "id": "fa2b1cbe-f099-47e6-95bc-d09f0af378c0",
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
        "project": {
          "links": {
            "related": "/projects/1e65961f-cf36-4c84-8924-72af5b96f73b"
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
GET /contexts/4b679ae3-976b-4451-ac25-3f7ab0c39ffc
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9cb0f905-ab27-4e14-8483-9bda5eba5ba0
200 OK
```


```json
{
  "data": {
    "id": "4b679ae3-976b-4451-ac25-3f7ab0c39ffc",
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
      "project": {
        "links": {
          "related": "/projects/083ec4dd-4712-44a2-b191-47872da2d47d"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/b04d4dc5-1614-4c79-9252-ec9930644d26"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/4b679ae3-976b-4451-ac25-3f7ab0c39ffc"
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
PATCH /contexts/6a342cfc-725b-413a-b631-90fabff5957e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "6a342cfc-725b-413a-b631-90fabff5957e",
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
X-Request-Id: 7a4e127c-887c-444c-90df-d2e515aa8897
200 OK
```


```json
{
  "data": {
    "id": "6a342cfc-725b-413a-b631-90fabff5957e",
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
      "project": {
        "links": {
          "related": "/projects/617027cf-1654-4910-b47c-7ef06b2432e8"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/0940fff2-3d4f-4cb8-b1d8-ccba67211ea4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/6a342cfc-725b-413a-b631-90fabff5957e"
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
POST /projects/536f1518-bb22-4f1d-8a3a-22fbc1896b77/relationships/contexts
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
X-Request-Id: 4210cb25-5351-4345-bf12-d7ba18b9cfbb
201 Created
```


```json
{
  "data": {
    "id": "ffa9deb9-ee87-4463-bcdf-93d83877cb38",
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
      "project": {
        "links": {
          "related": "/projects/536f1518-bb22-4f1d-8a3a-22fbc1896b77"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/9b6825aa-2d46-46f1-92cc-0d4e3e9db912"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/536f1518-bb22-4f1d-8a3a-22fbc1896b77/relationships/contexts"
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
POST /contexts/c9ea50e3-2752-4a5b-b132-40517853c57b/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2e27914a-deaf-4da2-96b6-74f767577a4b
201 Created
```


```json
{
  "data": {
    "id": "62aeff75-8897-4512-9e55-3cd28216dff7",
    "type": "context",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "Context 1",
      "published_at": null,
      "revision": 1
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/f14681ee-d78a-4703-ad99-bfad52809345"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/9c501c21-fc45-4194-ad2d-569a7eeaf8e6"
        }
      },
      "prev_revision": {
        "data": {
          "id": "c9ea50e3-2752-4a5b-b132-40517853c57b",
          "type": "context"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/c9ea50e3-2752-4a5b-b132-40517853c57b/revision"
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
DELETE /contexts/9bde9315-23e8-41bf-a31b-52c9d09c5fa8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8cc7898d-0074-4e4f-945c-363f944ef266
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
GET /object_occurrences/d8ea1869-b675-4b30-9fc2-f81a3719c072
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
X-Request-Id: 384e40ff-8cd5-4156-89aa-b4877fb66972
200 OK
```


```json
{
  "data": {
    "id": "d8ea1869-b675-4b30-9fc2-f81a3719c072",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
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
          "related": "/contexts/1bb38ce5-1407-4f74-8d95-b1ddff4684a6"
        }
      },
      "components": {
        "data": [
          {
            "id": "e50a633f-1d8f-4bbf-bfc8-a9a402d78dab",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/d8ea1869-b675-4b30-9fc2-f81a3719c072/relationships/components"
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
    "self": "http://example.org/object_occurrences/d8ea1869-b675-4b30-9fc2-f81a3719c072"
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
POST /object_occurrences/6170d91c-597e-4413-82a4-50f0600f5e49/relationships/components
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
      "name": "ooc"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 1db48c83-d130-485c-9cd3-d92a1adda752
201 Created
```


```json
{
  "data": {
    "id": "0ab9172e-fe16-4c2b-9bb8-a04b22ed360a",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "hex_color": null,
      "name": "ooc",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": "0"
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/d9514fb7-b2ab-4f95-b797-9d9fe7b8223c"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6170d91c-597e-4413-82a4-50f0600f5e49",
          "self": "/object_occurrences/0ab9172e-fe16-4c2b-9bb8-a04b22ed360a/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/0ab9172e-fe16-4c2b-9bb8-a04b22ed360a/relationships/components"
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
    "self": "http://example.org/object_occurrences/6170d91c-597e-4413-82a4-50f0600f5e49/relationships/components"
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
PATCH /object_occurrences/7e35e6bf-45ff-44ce-9f82-dc8e5d82e7b1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "7e35e6bf-45ff-44ce-9f82-dc8e5d82e7b1",
    "type": "object_occurrence",
    "attributes": {
      "name": "New name"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "c5ce3553-d452-4843-a95e-48c80a79c36f"
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
X-Request-Id: 10642620-0444-4807-9b9f-2ef7d53eda95
200 OK
```


```json
{
  "data": {
    "id": "7e35e6bf-45ff-44ce-9f82-dc8e5d82e7b1",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
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
          "related": "/contexts/d51f3791-7387-4511-8ef2-9bfee115e665"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/c5ce3553-d452-4843-a95e-48c80a79c36f",
          "self": "/object_occurrences/7e35e6bf-45ff-44ce-9f82-dc8e5d82e7b1/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/7e35e6bf-45ff-44ce-9f82-dc8e5d82e7b1/relationships/components"
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
    "self": "http://example.org/object_occurrences/7e35e6bf-45ff-44ce-9f82-dc8e5d82e7b1"
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
DELETE /object_occurrences/2492b48b-f5fc-41dd-b787-0cb85e98297b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 44034d2f-27f9-4857-a38a-8e8b24f7cbfe
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
PATCH /object_occurrences/82e2492d-8d59-4604-ad10-091cf9fd67cf/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "8832d98d-f971-4a91-9d19-b0d148c99194",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 727ed617-f98d-438d-b1fe-a1b8fcc3b5cc
200 OK
```


```json
{
  "data": {
    "id": "82e2492d-8d59-4604-ad10-091cf9fd67cf",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "hex_color": null,
      "name": "OOC 2",
      "position": null,
      "prefix": null,
      "system_element_relation_id": null,
      "type": "regular",
      "number": "0"
    },
    "relationships": {
      "context": {
        "links": {
          "related": "/contexts/74094b14-ca33-439b-beac-ba169a8f4ae2"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/8832d98d-f971-4a91-9d19-b0d148c99194",
          "self": "/object_occurrences/82e2492d-8d59-4604-ad10-091cf9fd67cf/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/82e2492d-8d59-4604-ad10-091cf9fd67cf/relationships/components"
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
    "self": "http://example.org/object_occurrences/82e2492d-8d59-4604-ad10-091cf9fd67cf/relationships/part_of"
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
X-Request-Id: 350c9ed8-b609-4a2a-8bd9-6c1192767a27
200 OK
```


```json
{
  "data": [
    {
      "id": "5e761a62-a874-4adc-9006-342ba897e8a5",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=5e761a62-a874-4adc-9006-342ba897e8a5",
            "self": "/classification_tables/5e761a62-a874-4adc-9006-342ba897e8a5/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "0a6a2f34-2954-49c3-90c1-6b3ae9029d18",
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
            "related": "/classification_entries?filter[classification_table_id_eq]=0a6a2f34-2954-49c3-90c1-6b3ae9029d18",
            "self": "/classification_tables/0a6a2f34-2954-49c3-90c1-6b3ae9029d18/relationships/classification_entries"
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
GET /classification_tables/49ed182d-4292-44b8-83bb-bb4b2fcbaff3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0902a94a-c0a6-406f-80da-a48b2b21cbde
200 OK
```


```json
{
  "data": {
    "id": "49ed182d-4292-44b8-83bb-bb4b2fcbaff3",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=49ed182d-4292-44b8-83bb-bb4b2fcbaff3",
          "self": "/classification_tables/49ed182d-4292-44b8-83bb-bb4b2fcbaff3/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/49ed182d-4292-44b8-83bb-bb4b2fcbaff3"
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
PATCH /classification_tables/82ced492-ebf4-46c0-a1e0-8396ca68cc93
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "82ced492-ebf4-46c0-a1e0-8396ca68cc93",
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
X-Request-Id: 66b24d42-f6a2-467a-887d-d832db6f7b1e
200 OK
```


```json
{
  "data": {
    "id": "82ced492-ebf4-46c0-a1e0-8396ca68cc93",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=82ced492-ebf4-46c0-a1e0-8396ca68cc93",
          "self": "/classification_tables/82ced492-ebf4-46c0-a1e0-8396ca68cc93/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/82ced492-ebf4-46c0-a1e0-8396ca68cc93"
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
DELETE /classification_tables/597ce6b3-514c-4a56-8251-6c6f64fbbfd0
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: eb1d346a-e983-4745-9363-30bfb8149898
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
POST /classification_tables/7fca5407-c5a2-47ac-ae70-e9c78291b2f4/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4d7241d5-542f-4a98-b2fb-1e9710ed966a
200 OK
```


```json
{
  "data": {
    "id": "7fca5407-c5a2-47ac-ae70-e9c78291b2f4",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-01-08T09:13:40.547Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=7fca5407-c5a2-47ac-ae70-e9c78291b2f4",
          "self": "/classification_tables/7fca5407-c5a2-47ac-ae70-e9c78291b2f4/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/7fca5407-c5a2-47ac-ae70-e9c78291b2f4/publish"
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
POST /classification_tables/3d955c39-f89f-4d0b-a3eb-08eb69b4dbda/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /classification_tables/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b38d1982-b636-45cc-acbd-4b8d9be8e47b
200 OK
```


```json
{
  "data": {
    "id": "3d955c39-f89f-4d0b-a3eb-08eb69b4dbda",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-01-08T09:13:40.909Z",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=3d955c39-f89f-4d0b-a3eb-08eb69b4dbda",
          "self": "/classification_tables/3d955c39-f89f-4d0b-a3eb-08eb69b4dbda/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/3d955c39-f89f-4d0b-a3eb-08eb69b4dbda/archive"
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
X-Request-Id: bdc1bf1b-8c11-4d2a-87e2-83fc4fa6ddef
201 Created
```


```json
{
  "data": {
    "id": "2de2fc44-b709-462c-b7f6-6b8890c48a94",
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
          "related": "/classification_entries?filter[classification_table_id_eq]=2de2fc44-b709-462c-b7f6-6b8890c48a94",
          "self": "/classification_tables/2de2fc44-b709-462c-b7f6-6b8890c48a94/relationships/classification_entries"
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
X-Request-Id: ceb70a04-939f-4ea2-937d-53b9ca8c8656
200 OK
```


```json
{
  "data": [
    {
      "id": "221bb7f0-daba-4bda-bac0-b657a363a3f8",
      "type": "syntax",
      "attributes": {
        "account_id": "d9ecab8e-f1fa-4c8c-8394-0eef5b4b6465",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 433355a36b24",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=221bb7f0-daba-4bda-bac0-b657a363a3f8",
            "self": "/syntaxes/221bb7f0-daba-4bda-bac0-b657a363a3f8/relationships/syntax_elements"
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
GET /syntaxes/e53ef90e-5698-493f-b344-bd0128ff14b1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f73a3c0b-1af3-4b46-adec-44403a5a74c7
200 OK
```


```json
{
  "data": {
    "id": "e53ef90e-5698-493f-b344-bd0128ff14b1",
    "type": "syntax",
    "attributes": {
      "account_id": "26231f82-36c0-40bf-ac30-3f0676ecc73c",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 58bf989876f7",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=e53ef90e-5698-493f-b344-bd0128ff14b1",
          "self": "/syntaxes/e53ef90e-5698-493f-b344-bd0128ff14b1/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/e53ef90e-5698-493f-b344-bd0128ff14b1"
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
X-Request-Id: 0900527e-3711-4a67-9c98-370e542ef063
201 Created
```


```json
{
  "data": {
    "id": "358792d8-0a56-4b18-80b1-9074df9ce31e",
    "type": "syntax",
    "attributes": {
      "account_id": "3fdaf19c-ae8b-40a7-a76c-882fb764224f",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=358792d8-0a56-4b18-80b1-9074df9ce31e",
          "self": "/syntaxes/358792d8-0a56-4b18-80b1-9074df9ce31e/relationships/syntax_elements"
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
PATCH /syntaxes/ef807e67-254f-406a-8927-c58b3fb69a93
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "ef807e67-254f-406a-8927-c58b3fb69a93",
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
X-Request-Id: 8607d769-7f29-4a29-8d54-ed21bbd4eb90
200 OK
```


```json
{
  "data": {
    "id": "ef807e67-254f-406a-8927-c58b3fb69a93",
    "type": "syntax",
    "attributes": {
      "account_id": "225d4742-7143-4b08-9de4-5a28ccbad76a",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ef807e67-254f-406a-8927-c58b3fb69a93",
          "self": "/syntaxes/ef807e67-254f-406a-8927-c58b3fb69a93/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ef807e67-254f-406a-8927-c58b3fb69a93"
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
DELETE /syntaxes/775d4704-c43c-47fd-a84e-33af1b051690
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7497a05c-b213-4d12-b13d-34c5e34cc8ea
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
POST /syntaxes/f53285de-102c-4d40-9a4c-193c1098f08f/publish
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/publish`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b91d8daf-045b-4c71-a2e5-5430b46de80f
200 OK
```


```json
{
  "data": {
    "id": "f53285de-102c-4d40-9a4c-193c1098f08f",
    "type": "syntax",
    "attributes": {
      "account_id": "3901956d-ac18-43da-9be9-e96cb22a759c",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 5ac9bbefcb74",
      "published": true,
      "published_at": "2020-01-08T09:13:43.464Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=f53285de-102c-4d40-9a4c-193c1098f08f",
          "self": "/syntaxes/f53285de-102c-4d40-9a4c-193c1098f08f/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/f53285de-102c-4d40-9a4c-193c1098f08f/publish"
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
POST /syntaxes/6ffa7b1a-fe64-4e3d-8ce4-0ad5e327f97b/archive
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /syntaxes/:id/archive`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5a97f29c-1343-48fd-a46e-9251aca04e43
200 OK
```


```json
{
  "data": {
    "id": "6ffa7b1a-fe64-4e3d-8ce4-0ad5e327f97b",
    "type": "syntax",
    "attributes": {
      "account_id": "70161ca2-4637-458b-b781-2629abdf8e61",
      "archived": true,
      "archived_at": "2020-01-08T09:13:43.817Z",
      "description": "Description",
      "name": "Syntax be38fa37a3c0",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=6ffa7b1a-fe64-4e3d-8ce4-0ad5e327f97b",
          "self": "/syntaxes/6ffa7b1a-fe64-4e3d-8ce4-0ad5e327f97b/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/6ffa7b1a-fe64-4e3d-8ce4-0ad5e327f97b/archive"
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
X-Request-Id: 502e744f-bac8-4f78-b84c-789f684fd3a8
200 OK
```


```json
{
  "data": [
    {
      "id": "50b91576-aaec-47dc-b8f6-b563a5423caf",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "e9d89337-5f61-4ad1-bc33-a7298e38adca",
        "hex_color": "cba872",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 1ff914b77800"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/bbbda8d9-94a6-4968-b66f-f8d985f9a941"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/e9d89337-5f61-4ad1-bc33-a7298e38adca",
            "self": "/syntax_elements/50b91576-aaec-47dc-b8f6-b563a5423caf/relationships/classification_table"
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
GET /syntax_elements/eb73dfb5-2215-4bf9-b27b-b617bf59fdb9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9f8382c8-8fdd-4ab8-a49e-80c4301be614
200 OK
```


```json
{
  "data": {
    "id": "eb73dfb5-2215-4bf9-b27b-b617bf59fdb9",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "b5a861c3-94de-41c8-9c3e-d37d07c14d39",
      "hex_color": "765fb1",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element c7a35093c0cb"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/a738f2c5-6c23-418c-ae12-f7d36d6b2223"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/b5a861c3-94de-41c8-9c3e-d37d07c14d39",
          "self": "/syntax_elements/eb73dfb5-2215-4bf9-b27b-b617bf59fdb9/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/eb73dfb5-2215-4bf9-b27b-b617bf59fdb9"
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
POST /syntaxes/fc71c817-d743-432f-b341-0fc50a116b8a/relationships/syntax_elements
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
          "id": "2eeded28-48c3-4e9b-a16b-917282a523ef"
        }
      }
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: e8ad289a-98d9-4e8c-8305-f79393c8b10f
201 Created
```


```json
{
  "data": {
    "id": "22b3766c-2ab9-4434-9935-b1d624bdba3f",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "2eeded28-48c3-4e9b-a16b-917282a523ef",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/fc71c817-d743-432f-b341-0fc50a116b8a"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/2eeded28-48c3-4e9b-a16b-917282a523ef",
          "self": "/syntax_elements/22b3766c-2ab9-4434-9935-b1d624bdba3f/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/fc71c817-d743-432f-b341-0fc50a116b8a/relationships/syntax_elements"
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
PATCH /syntax_elements/a5a0776d-b871-4ea6-aa2b-72f93a744d54
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "a5a0776d-b871-4ea6-aa2b-72f93a744d54",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "227e1c2a-f96a-4a12-b1fb-ff21bc8b9266"
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
X-Request-Id: 2d7d5183-0a7c-454c-84d6-b3758cb733d9
200 OK
```


```json
{
  "data": {
    "id": "a5a0776d-b871-4ea6-aa2b-72f93a744d54",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "227e1c2a-f96a-4a12-b1fb-ff21bc8b9266",
      "hex_color": "d4146c",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/389a2e69-d8a8-451b-824e-8114e3c81e93"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/227e1c2a-f96a-4a12-b1fb-ff21bc8b9266",
          "self": "/syntax_elements/a5a0776d-b871-4ea6-aa2b-72f93a744d54/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/a5a0776d-b871-4ea6-aa2b-72f93a744d54"
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
DELETE /syntax_elements/2f2caf20-aed5-4b28-99c0-f5e39108be5b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 824b4162-1e37-48a2-97cd-ed89d855daa0
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
PATCH /syntax_elements/67d63783-f0b2-4601-8dd8-cb10737468d7/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "990aaa1c-ae2b-41c9-a2d3-eb0a5791a34a",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 5ac8a229-bbc9-4c25-8eef-cd419b825fbb
200 OK
```


```json
{
  "data": {
    "id": "67d63783-f0b2-4601-8dd8-cb10737468d7",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "990aaa1c-ae2b-41c9-a2d3-eb0a5791a34a",
      "hex_color": "c6b95c",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element b4100e70dd6d"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/865f2774-a7c0-4701-af1b-f9b693f38555"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/990aaa1c-ae2b-41c9-a2d3-eb0a5791a34a",
          "self": "/syntax_elements/67d63783-f0b2-4601-8dd8-cb10737468d7/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/67d63783-f0b2-4601-8dd8-cb10737468d7/relationships/classification_table"
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
DELETE /syntax_elements/4c7ea36d-1b88-4bf0-921b-66275a79e898/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0d751351-474c-421d-a984-7fe06f2c3bfb
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
GET /syntax_nodes/b49644ae-48e3-4825-a4e5-9a9019c41f78
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
X-Request-Id: a14a1710-b213-4e46-9f94-673e74ff4fb2
200 OK
```


```json
{
  "data": {
    "id": "b49644ae-48e3-4825-a4e5-9a9019c41f78",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/62dc82b0-2996-420d-86ae-b8009250265b"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/b49644ae-48e3-4825-a4e5-9a9019c41f78/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/b49644ae-48e3-4825-a4e5-9a9019c41f78"
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
POST /syntax_nodes/9cef70ba-187d-4fec-a6be-0593c2f7346a/relationships/components
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
X-Request-Id: 54c60f08-9add-4ed9-a588-509b771a73bb
201 Created
```


```json
{
  "data": {
    "id": "b93dd7d5-51f2-4b24-9647-e01d8aeae6c4",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/20365d4b-0997-4620-b1a5-649600af9866"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/b93dd7d5-51f2-4b24-9647-e01d8aeae6c4/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/9cef70ba-187d-4fec-a6be-0593c2f7346a/relationships/components"
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
PATCH /syntax_nodes/39fa306d-2f1f-41f2-b3c4-4177720195c9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "39fa306d-2f1f-41f2-b3c4-4177720195c9",
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
X-Request-Id: 403cd6de-952c-4b37-9493-07bd35f347ff
200 OK
```


```json
{
  "data": {
    "id": "39fa306d-2f1f-41f2-b3c4-4177720195c9",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/d3ea1a1d-bdd9-48c0-bb97-62c52f6b0a10"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/39fa306d-2f1f-41f2-b3c4-4177720195c9/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/39fa306d-2f1f-41f2-b3c4-4177720195c9"
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
DELETE /syntax_nodes/9bed6173-bed8-4b3f-95da-31d336f866f7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2052519a-3555-4d49-bf55-3d4980ce98d4
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][position] | Syntax node position |
| data[attributes][min_depth] | Min depth |
| data[attributes][max_depth] | Max depth |
| data[attributes][syntax_element_id] | Syntax element ID |


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


None known.


### Response

```plaintext
X-Request-Id: 3c4ea3ce-65aa-43fb-8da3-91f3216a81b5
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
X-Request-Id: 3746aad1-f973-44ec-86a4-1cf992ad7f6f
200 OK
```


```json
{
  "data": [
    {
      "id": "30d375c9-62fe-43e9-9693-6a8deb4cc978",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/a37e1a52-e5e4-40f9-a16a-5e584f799a68"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/425bb965-3bc3-412a-b61a-6caf57f41366"
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
X-Request-Id: ba3a97b5-80f0-4888-97a1-30dfe16f1e54
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



