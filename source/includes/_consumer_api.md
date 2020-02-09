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
X-Request-Id: 18523e6e-2687-491b-b07a-71bcf2926837
200 OK
```


```json
{
  "data": {
    "id": "336b9ff4-4b42-41b3-a663-9c77a3d12bd6",
    "type": "account",
    "attributes": {
      "name": "Account 59b8d26ea398"
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
    "id": "edcba7b7-24ed-4944-b944-32a2f8697a1c",
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
X-Request-Id: 4b40cb28-10f3-485a-881c-958b81448bd5
200 OK
```


```json
{
  "data": {
    "id": "edcba7b7-24ed-4944-b944-32a2f8697a1c",
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
POST /projects/cf0dcd3d-5586-4555-ab6c-4b45046f0498/relationships/tags
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
X-Request-Id: 3eff0a54-bb04-444c-9957-ae05fbc58d70
201 Created
```


```json
{
  "data": {
    "id": "ed29d47c-1429-4910-8f68-8c27605d8b92",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/cf0dcd3d-5586-4555-ab6c-4b45046f0498/relationships/tags"
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
POST /projects/7c176fa9-0eb6-40d3-8d4f-b4d471101513/relationships/tags
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
    "id": "a31df024-eac9-40c7-96d0-57c48fd84a2b"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 42a556c0-efb4-4b9c-8331-1736874964c4
201 Created
```


```json
{
  "data": {
    "id": "a31df024-eac9-40c7-96d0-57c48fd84a2b",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/7c176fa9-0eb6-40d3-8d4f-b4d471101513/relationships/tags"
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
DELETE /projects/ac536c26-187d-4662-819e-c7b941b5b9e2/relationships/tags/afcea8a1-281e-4952-8d75-ec78b6fdfb3d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3faa2fed-849e-480d-b633-939fa81dcb21
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
X-Request-Id: f1a6e5ff-a77d-492c-8272-c6fb56449150
200 OK
```


```json
{
  "data": [
    {
      "id": "812e5627-6bca-4abd-ab41-8415ad9c7149",
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
            "related": "/tags?filter[target_id_eq]=812e5627-6bca-4abd-ab41-8415ad9c7149&filter[target_type_eq]=Project",
            "self": "/projects/812e5627-6bca-4abd-ab41-8415ad9c7149/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=812e5627-6bca-4abd-ab41-8415ad9c7149",
            "self": "/projects/812e5627-6bca-4abd-ab41-8415ad9c7149/relationships/contexts"
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
GET /projects/1a5a1b07-fd7e-4212-9c29-1d91728250a2
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
X-Request-Id: 7e6b1796-0dc3-462e-a7f2-c2eb7b5c75c2
200 OK
```


```json
{
  "data": {
    "id": "1a5a1b07-fd7e-4212-9c29-1d91728250a2",
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
          "related": "/tags?filter[target_id_eq]=1a5a1b07-fd7e-4212-9c29-1d91728250a2&filter[target_type_eq]=Project",
          "self": "/projects/1a5a1b07-fd7e-4212-9c29-1d91728250a2/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=1a5a1b07-fd7e-4212-9c29-1d91728250a2",
          "self": "/projects/1a5a1b07-fd7e-4212-9c29-1d91728250a2/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/1a5a1b07-fd7e-4212-9c29-1d91728250a2"
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
PATCH /projects/b986a4d3-3b6d-499d-b8af-43a9607717a8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "b986a4d3-3b6d-499d-b8af-43a9607717a8",
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
X-Request-Id: 512ccb14-3c29-494a-91c1-a692402108cb
200 OK
```


```json
{
  "data": {
    "id": "b986a4d3-3b6d-499d-b8af-43a9607717a8",
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
          "related": "/tags?filter[target_id_eq]=b986a4d3-3b6d-499d-b8af-43a9607717a8&filter[target_type_eq]=Project",
          "self": "/projects/b986a4d3-3b6d-499d-b8af-43a9607717a8/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=b986a4d3-3b6d-499d-b8af-43a9607717a8",
          "self": "/projects/b986a4d3-3b6d-499d-b8af-43a9607717a8/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b986a4d3-3b6d-499d-b8af-43a9607717a8"
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
POST /projects/8b35d537-1ad8-465b-ac35-1cb2e778ffab/archive
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
X-Request-Id: b9b1fb0a-8aa4-4ffb-92de-ba2f7a44a5f2
200 OK
```


```json
{
  "data": {
    "id": "8b35d537-1ad8-465b-ac35-1cb2e778ffab",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:07:46.848Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=8b35d537-1ad8-465b-ac35-1cb2e778ffab&filter[target_type_eq]=Project",
          "self": "/projects/8b35d537-1ad8-465b-ac35-1cb2e778ffab/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=8b35d537-1ad8-465b-ac35-1cb2e778ffab",
          "self": "/projects/8b35d537-1ad8-465b-ac35-1cb2e778ffab/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/8b35d537-1ad8-465b-ac35-1cb2e778ffab/archive"
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
DELETE /projects/69c0392d-c5d1-420a-850d-746dbad73b3c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6d464659-b171-4095-a5b6-ac5d3102ffb9
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
POST /contexts/574091b2-2584-42e0-9b83-7b4f8fe51eff/relationships/tags
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
X-Request-Id: 6cc5857c-83dc-418a-a065-c44dd1106700
201 Created
```


```json
{
  "data": {
    "id": "071b3940-6cd9-4393-a7bf-0dff110ae0f2",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/574091b2-2584-42e0-9b83-7b4f8fe51eff/relationships/tags"
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
POST /contexts/fa70e4cd-8dbb-4cb8-af2c-fab9a59212d6/relationships/tags
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
    "id": "dbf28297-dc6c-4b5f-a2bb-98012a354865"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: e370d0ef-9321-4e22-8c34-ca12b8f5cfb9
201 Created
```


```json
{
  "data": {
    "id": "dbf28297-dc6c-4b5f-a2bb-98012a354865",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/fa70e4cd-8dbb-4cb8-af2c-fab9a59212d6/relationships/tags"
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
DELETE /contexts/f30b6138-63aa-4a05-aa51-f45419e2c759/relationships/tags/68e56de1-b8f8-49ea-b8fd-f32f8d0437ce
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 91818c80-e043-49f9-8c0b-abe358729361
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
X-Request-Id: e17f2dca-31a8-42ca-a3da-61086c2daadb
200 OK
```


```json
{
  "data": [
    {
      "id": "ac4f4a46-03f2-4d60-9c08-de18b523e247",
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
            "related": "/tags?filter[target_id_eq]=ac4f4a46-03f2-4d60-9c08-de18b523e247&filter[target_type_eq]=Context",
            "self": "/contexts/ac4f4a46-03f2-4d60-9c08-de18b523e247/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/fe629790-a279-4888-bc87-9ce92e54abc3"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/f52544b9-b8c9-4d24-84bf-9b0540744658"
          }
        }
      }
    },
    {
      "id": "fc5fff49-6454-434e-9e01-84a702247d8a",
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
            "related": "/tags?filter[target_id_eq]=fc5fff49-6454-434e-9e01-84a702247d8a&filter[target_type_eq]=Context",
            "self": "/contexts/fc5fff49-6454-434e-9e01-84a702247d8a/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/fe629790-a279-4888-bc87-9ce92e54abc3"
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
GET /contexts/28726c0c-72bc-450e-8978-7aa5e0626c08
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
X-Request-Id: 7d9a2169-d21e-49f7-8dd1-ae926c755a5f
200 OK
```


```json
{
  "data": {
    "id": "28726c0c-72bc-450e-8978-7aa5e0626c08",
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
          "related": "/tags?filter[target_id_eq]=28726c0c-72bc-450e-8978-7aa5e0626c08&filter[target_type_eq]=Context",
          "self": "/contexts/28726c0c-72bc-450e-8978-7aa5e0626c08/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/db59880f-2f40-4c6b-9f2d-b45e52ea854a"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/f47ed223-060f-444d-8231-63ad7a8916a5"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/28726c0c-72bc-450e-8978-7aa5e0626c08"
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
PATCH /contexts/70cf8118-6f23-4a72-a580-4901dd3da0c1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "70cf8118-6f23-4a72-a580-4901dd3da0c1",
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
X-Request-Id: f4427d0a-6ec3-4209-a293-5bda01bf57dd
200 OK
```


```json
{
  "data": {
    "id": "70cf8118-6f23-4a72-a580-4901dd3da0c1",
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
          "related": "/tags?filter[target_id_eq]=70cf8118-6f23-4a72-a580-4901dd3da0c1&filter[target_type_eq]=Context",
          "self": "/contexts/70cf8118-6f23-4a72-a580-4901dd3da0c1/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/fad961a7-6f42-4115-a71c-a2e3b66977d2"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/9ac35db3-fde1-44e9-8e20-0b05be1439aa"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/70cf8118-6f23-4a72-a580-4901dd3da0c1"
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
POST /projects/339a6f48-8c33-4f1a-b10c-944a3aa331bd/relationships/contexts
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
X-Request-Id: 158b9881-29cc-41c5-b4cb-51ee5b434dbe
201 Created
```


```json
{
  "data": {
    "id": "902aaff5-2062-4cfb-a6a2-a9800598d848",
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
          "related": "/tags?filter[target_id_eq]=902aaff5-2062-4cfb-a6a2-a9800598d848&filter[target_type_eq]=Context",
          "self": "/contexts/902aaff5-2062-4cfb-a6a2-a9800598d848/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/339a6f48-8c33-4f1a-b10c-944a3aa331bd"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/aac75d5d-0766-4285-8741-d8b51b4dd7b4"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/339a6f48-8c33-4f1a-b10c-944a3aa331bd/relationships/contexts"
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
POST /contexts/aa812942-1115-4567-8880-63ae549ed143/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/50aab746b1850c04b3c47dac
Content-Type: text/html; charset=utf-8
X-Request-Id: 06cdbc13-6e68-443e-83c5-d7271f1021c7
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/50aab746b1850c04b3c47dac">redirected</a>.</body></html>
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
DELETE /contexts/4bc25c86-56bc-4045-a370-1d5456ad998b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5668c627-38ad-4a5e-b34c-1439138df8db
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
POST /object_occurrences/03725475-3b48-49ae-b0fa-a7ecb0bc267a/relationships/tags
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
X-Request-Id: 18662a77-53b8-4729-9630-bbbb1eedd4e5
201 Created
```


```json
{
  "data": {
    "id": "eb3ba3e7-c672-4f69-963f-342e2a93a1ae",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/03725475-3b48-49ae-b0fa-a7ecb0bc267a/relationships/tags"
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
POST /object_occurrences/e2ec5622-9389-4641-b866-3c69d8c47f59/relationships/tags
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
    "id": "42b2fb7e-bbf5-4c99-bf3d-b2ce95a7869b"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 82582b34-23bc-4e9b-b8e6-51676ee558f4
201 Created
```


```json
{
  "data": {
    "id": "42b2fb7e-bbf5-4c99-bf3d-b2ce95a7869b",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/e2ec5622-9389-4641-b866-3c69d8c47f59/relationships/tags"
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
DELETE /object_occurrences/b8ab23c9-6e7a-45b9-b5f2-e27b9b229620/relationships/tags/04e73a47-2f51-48e3-b967-db5c7904f7c7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 66ae74fb-5e29-4909-97c4-53fe8d8aea57
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
GET /object_occurrences/4d3c60fa-75f4-41bb-90d9-5d19d99529ab
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
X-Request-Id: de0dab56-29f3-4c32-ae04-3f9c559d70cd
200 OK
```


```json
{
  "data": {
    "id": "4d3c60fa-75f4-41bb-90d9-5d19d99529ab",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "hex_color": null,
      "name": "OOC 1",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=4d3c60fa-75f4-41bb-90d9-5d19d99529ab&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/4d3c60fa-75f4-41bb-90d9-5d19d99529ab/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/4333b24f-3c61-4399-945a-de6129619630"
        }
      },
      "components": {
        "data": [
          {
            "id": "65aa3552-b506-4540-97f2-6dd4f32c26b0",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/4d3c60fa-75f4-41bb-90d9-5d19d99529ab/relationships/components"
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
    "self": "http://example.org/object_occurrences/4d3c60fa-75f4-41bb-90d9-5d19d99529ab"
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
POST /object_occurrences/5c156dc4-ac6b-45b0-9c0c-5cacb2371899/relationships/components
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
X-Request-Id: d3f1d2d4-d646-4a9f-84fa-b3ed94c205f5
201 Created
```


```json
{
  "data": {
    "id": "11969b1c-11e9-4b77-9aa3-feb7e084aa27",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "hex_color": null,
      "name": "ooc",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=11969b1c-11e9-4b77-9aa3-feb7e084aa27&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/11969b1c-11e9-4b77-9aa3-feb7e084aa27/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/49e9143d-a7bb-4464-8668-9c25af0531c2"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/5c156dc4-ac6b-45b0-9c0c-5cacb2371899",
          "self": "/object_occurrences/11969b1c-11e9-4b77-9aa3-feb7e084aa27/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/11969b1c-11e9-4b77-9aa3-feb7e084aa27/relationships/components"
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
    "self": "http://example.org/object_occurrences/5c156dc4-ac6b-45b0-9c0c-5cacb2371899/relationships/components"
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
PATCH /object_occurrences/093d0c36-ec3f-462d-9a13-88d375ed9e83
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "093d0c36-ec3f-462d-9a13-88d375ed9e83",
    "type": "object_occurrence",
    "attributes": {
      "name": "New name"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "04aa94d2-1981-4ef7-a0e8-06838aa46749"
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
X-Request-Id: 7f479b7e-6a58-47d7-92f1-1cabe7c019fe
200 OK
```


```json
{
  "data": {
    "id": "093d0c36-ec3f-462d-9a13-88d375ed9e83",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "hex_color": null,
      "name": "New name",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=093d0c36-ec3f-462d-9a13-88d375ed9e83&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/093d0c36-ec3f-462d-9a13-88d375ed9e83/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/9ed60df5-23f3-4243-911e-8ebcf0ce6ff3"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/04aa94d2-1981-4ef7-a0e8-06838aa46749",
          "self": "/object_occurrences/093d0c36-ec3f-462d-9a13-88d375ed9e83/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/093d0c36-ec3f-462d-9a13-88d375ed9e83/relationships/components"
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
    "self": "http://example.org/object_occurrences/093d0c36-ec3f-462d-9a13-88d375ed9e83"
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
POST /object_occurrences/38ad0af8-e3e4-4344-96fa-c0c46a00bc86/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "96bf2dc6-30d3-4886-b0dd-edc58bd6a470",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/fb82deb8085d0352b31e04cb
Content-Type: text/html; charset=utf-8
X-Request-Id: 6b82fd15-dde2-46e7-930a-7af0fa5f6d52
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/fb82deb8085d0352b31e04cb">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/08bb749e-e16f-4a06-a6fd-becbca9c3e73
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 36a079e1-8f61-4b8c-9fea-00b12b973f38
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
PATCH /object_occurrences/a1cedd1e-a104-476b-83f1-46c5fea3f2fe/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "6ff623ef-670b-4482-b2ca-a5750521d0f4",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 321421a7-3e2c-4c9c-9be0-a3722af40953
200 OK
```


```json
{
  "data": {
    "id": "a1cedd1e-a104-476b-83f1-46c5fea3f2fe",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "hex_color": null,
      "name": "OOC 2",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=a1cedd1e-a104-476b-83f1-46c5fea3f2fe&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/a1cedd1e-a104-476b-83f1-46c5fea3f2fe/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/dc2ec9ea-bf02-4c5f-a38b-6a51cb07d8d3"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6ff623ef-670b-4482-b2ca-a5750521d0f4",
          "self": "/object_occurrences/a1cedd1e-a104-476b-83f1-46c5fea3f2fe/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/a1cedd1e-a104-476b-83f1-46c5fea3f2fe/relationships/components"
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
    "self": "http://example.org/object_occurrences/a1cedd1e-a104-476b-83f1-46c5fea3f2fe/relationships/part_of"
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
POST /classification_tables/ca211d3a-509c-42bd-ba50-08d09d17d4f3/relationships/tags
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
X-Request-Id: ff4e01b0-1c6c-413a-85ee-b17a4a55dc93
201 Created
```


```json
{
  "data": {
    "id": "6613dddb-cf2e-4711-8683-bf4d28ea3fa1",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/ca211d3a-509c-42bd-ba50-08d09d17d4f3/relationships/tags"
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
POST /classification_tables/01f10450-c5c7-4890-87db-0b1e29eaf405/relationships/tags
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
    "id": "73b9a7c2-d132-4585-b412-0aa793877587"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: d206d9a8-5b4c-4a30-a0a2-a3a943d64fae
201 Created
```


```json
{
  "data": {
    "id": "73b9a7c2-d132-4585-b412-0aa793877587",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/01f10450-c5c7-4890-87db-0b1e29eaf405/relationships/tags"
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
DELETE /classification_tables/72da3c65-6b08-4b76-8f5e-9e4773e3dd64/relationships/tags/dbef6252-e0bc-42d6-8f67-36bfa76d481b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e294b9f4-fbb3-4a19-b941-b1d66a79fe4d
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
X-Request-Id: a6cc3411-a68e-448e-8073-cb7724f2f3d7
200 OK
```


```json
{
  "data": [
    {
      "id": "5de0c497-585c-4e6d-ba7b-71890803823a",
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
            "related": "/tags?filter[target_id_eq]=5de0c497-585c-4e6d-ba7b-71890803823a&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/5de0c497-585c-4e6d-ba7b-71890803823a/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=5de0c497-585c-4e6d-ba7b-71890803823a",
            "self": "/classification_tables/5de0c497-585c-4e6d-ba7b-71890803823a/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "6f5fb268-99df-406f-bdba-0599c283da9f",
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
            "related": "/tags?filter[target_id_eq]=6f5fb268-99df-406f-bdba-0599c283da9f&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/6f5fb268-99df-406f-bdba-0599c283da9f/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=6f5fb268-99df-406f-bdba-0599c283da9f",
            "self": "/classification_tables/6f5fb268-99df-406f-bdba-0599c283da9f/relationships/classification_entries",
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
X-Request-Id: 9134de55-0d15-40e5-a38e-d16e2ee6702a
200 OK
```


```json
{
  "data": [
    {
      "id": "510304d4-e90a-44cc-85d9-230da6a1495f",
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
            "related": "/tags?filter[target_id_eq]=510304d4-e90a-44cc-85d9-230da6a1495f&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/510304d4-e90a-44cc-85d9-230da6a1495f/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=510304d4-e90a-44cc-85d9-230da6a1495f",
            "self": "/classification_tables/510304d4-e90a-44cc-85d9-230da6a1495f/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "dbf458ec-9b2c-4bb7-9ffe-3f01671c524b",
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
            "related": "/tags?filter[target_id_eq]=dbf458ec-9b2c-4bb7-9ffe-3f01671c524b&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/dbf458ec-9b2c-4bb7-9ffe-3f01671c524b/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=dbf458ec-9b2c-4bb7-9ffe-3f01671c524b",
            "self": "/classification_tables/dbf458ec-9b2c-4bb7-9ffe-3f01671c524b/relationships/classification_entries",
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
GET /classification_tables/472bd87c-fcdc-4095-a6d7-022b77beb6f3
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
X-Request-Id: 203bb39b-b6ca-442d-bf8f-6ab36e261371
200 OK
```


```json
{
  "data": {
    "id": "472bd87c-fcdc-4095-a6d7-022b77beb6f3",
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
          "related": "/tags?filter[target_id_eq]=472bd87c-fcdc-4095-a6d7-022b77beb6f3&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/472bd87c-fcdc-4095-a6d7-022b77beb6f3/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=472bd87c-fcdc-4095-a6d7-022b77beb6f3",
          "self": "/classification_tables/472bd87c-fcdc-4095-a6d7-022b77beb6f3/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/472bd87c-fcdc-4095-a6d7-022b77beb6f3"
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
PATCH /classification_tables/1205193b-271f-428b-bf5f-6bb0c8580721
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "1205193b-271f-428b-bf5f-6bb0c8580721",
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
X-Request-Id: 25afea9a-e95b-4eb8-98ba-9762fa534eb8
200 OK
```


```json
{
  "data": {
    "id": "1205193b-271f-428b-bf5f-6bb0c8580721",
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
          "related": "/tags?filter[target_id_eq]=1205193b-271f-428b-bf5f-6bb0c8580721&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/1205193b-271f-428b-bf5f-6bb0c8580721/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=1205193b-271f-428b-bf5f-6bb0c8580721",
          "self": "/classification_tables/1205193b-271f-428b-bf5f-6bb0c8580721/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/1205193b-271f-428b-bf5f-6bb0c8580721"
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
DELETE /classification_tables/649378c5-fd9a-4a79-8dec-593cab7d9984
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cc3a586f-2f57-4919-8440-11603bbde89a
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
POST /classification_tables/f891e467-aa9a-4e80-b787-b1adc02f9fab/publish
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
X-Request-Id: a8adb545-f7ba-4c57-97e3-aa49fe88dc31
200 OK
```


```json
{
  "data": {
    "id": "f891e467-aa9a-4e80-b787-b1adc02f9fab",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-09T22:08:09.178Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=f891e467-aa9a-4e80-b787-b1adc02f9fab&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/f891e467-aa9a-4e80-b787-b1adc02f9fab/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=f891e467-aa9a-4e80-b787-b1adc02f9fab",
          "self": "/classification_tables/f891e467-aa9a-4e80-b787-b1adc02f9fab/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/f891e467-aa9a-4e80-b787-b1adc02f9fab/publish"
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
POST /classification_tables/999a0a87-e0c8-4da8-923f-a761e9c5ba02/archive
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
X-Request-Id: 33c08275-072b-40b7-befc-8337f7a01914
200 OK
```


```json
{
  "data": {
    "id": "999a0a87-e0c8-4da8-923f-a761e9c5ba02",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:08:09.776Z",
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
          "related": "/tags?filter[target_id_eq]=999a0a87-e0c8-4da8-923f-a761e9c5ba02&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/999a0a87-e0c8-4da8-923f-a761e9c5ba02/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=999a0a87-e0c8-4da8-923f-a761e9c5ba02",
          "self": "/classification_tables/999a0a87-e0c8-4da8-923f-a761e9c5ba02/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/999a0a87-e0c8-4da8-923f-a761e9c5ba02/archive"
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
X-Request-Id: 71d584d5-9ea4-4772-941f-b89616156021
201 Created
```


```json
{
  "data": {
    "id": "7d8930ff-723c-475a-88de-d0b18d6a954c",
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
          "related": "/tags?filter[target_id_eq]=7d8930ff-723c-475a-88de-d0b18d6a954c&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/7d8930ff-723c-475a-88de-d0b18d6a954c/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=7d8930ff-723c-475a-88de-d0b18d6a954c",
          "self": "/classification_tables/7d8930ff-723c-475a-88de-d0b18d6a954c/relationships/classification_entries",
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
POST /classification_entries/f8d658a9-97cf-445c-98e9-04815eb265a3/relationships/tags
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
X-Request-Id: 09eb275c-a4c3-48da-bc9b-1ee5cbb20a8c
201 Created
```


```json
{
  "data": {
    "id": "88c3d025-80ae-40a1-ab73-619f37a8b94f",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/f8d658a9-97cf-445c-98e9-04815eb265a3/relationships/tags"
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
POST /classification_entries/43b47681-a499-4f3c-9526-707420fd00e6/relationships/tags
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
    "id": "7d1fb1c8-7c19-480b-9149-730d15bfcd3c"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 470c0b9c-915b-4f4b-a930-196ea5506695
201 Created
```


```json
{
  "data": {
    "id": "7d1fb1c8-7c19-480b-9149-730d15bfcd3c",
    "type": "tag",
    "attributes": {
      "value": "Tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/43b47681-a499-4f3c-9526-707420fd00e6/relationships/tags"
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
DELETE /classification_entries/176d373e-17b1-468b-a887-dda5c94a60b6/relationships/tags/d5441a86-181a-4d3c-a908-1af8374e8eb9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2a7f1861-71b4-4b89-918e-40a97049c00d
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
X-Request-Id: 92623e7d-eda6-4fa1-960d-8b69eadc0227
200 OK
```


```json
{
  "data": [
    {
      "id": "9fbec23f-3c60-482e-b31e-fde8444de628",
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
            "related": "/tags?filter[target_id_eq]=9fbec23f-3c60-482e-b31e-fde8444de628&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/9fbec23f-3c60-482e-b31e-fde8444de628/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=9fbec23f-3c60-482e-b31e-fde8444de628",
            "self": "/classification_entries/9fbec23f-3c60-482e-b31e-fde8444de628/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "4c8b0d02-0d3d-4d5b-85b1-3ebd1e49f6d5",
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
            "related": "/tags?filter[target_id_eq]=4c8b0d02-0d3d-4d5b-85b1-3ebd1e49f6d5&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/4c8b0d02-0d3d-4d5b-85b1-3ebd1e49f6d5/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "9fbec23f-3c60-482e-b31e-fde8444de628",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/4c8b0d02-0d3d-4d5b-85b1-3ebd1e49f6d5"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=4c8b0d02-0d3d-4d5b-85b1-3ebd1e49f6d5",
            "self": "/classification_entries/4c8b0d02-0d3d-4d5b-85b1-3ebd1e49f6d5/relationships/classification_entries"
          }
        }
      }
    },
    {
      "id": "94e37d0f-457e-4d39-a1a3-46ec82fb2329",
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
            "related": "/tags?filter[target_id_eq]=94e37d0f-457e-4d39-a1a3-46ec82fb2329&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/94e37d0f-457e-4d39-a1a3-46ec82fb2329/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=94e37d0f-457e-4d39-a1a3-46ec82fb2329",
            "self": "/classification_entries/94e37d0f-457e-4d39-a1a3-46ec82fb2329/relationships/classification_entries"
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
GET /classification_entries/42bcbb53-a820-4c6b-b4ae-3aee2902471e
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
X-Request-Id: 3f2bfd47-0ebc-4978-b162-119062517d84
200 OK
```


```json
{
  "data": {
    "id": "42bcbb53-a820-4c6b-b4ae-3aee2902471e",
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
          "related": "/tags?filter[target_id_eq]=42bcbb53-a820-4c6b-b4ae-3aee2902471e&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/42bcbb53-a820-4c6b-b4ae-3aee2902471e/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=42bcbb53-a820-4c6b-b4ae-3aee2902471e",
          "self": "/classification_entries/42bcbb53-a820-4c6b-b4ae-3aee2902471e/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/42bcbb53-a820-4c6b-b4ae-3aee2902471e"
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
PATCH /classification_entries/786431c4-c3eb-4544-a55a-7ddc56472752
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "786431c4-c3eb-4544-a55a-7ddc56472752",
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
X-Request-Id: 809d6a2b-4f73-4041-b7cd-6ea225da13b0
200 OK
```


```json
{
  "data": {
    "id": "786431c4-c3eb-4544-a55a-7ddc56472752",
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
          "related": "/tags?filter[target_id_eq]=786431c4-c3eb-4544-a55a-7ddc56472752&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/786431c4-c3eb-4544-a55a-7ddc56472752/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "c081d069-5ff8-4533-8949-382753fff95e",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/786431c4-c3eb-4544-a55a-7ddc56472752"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=786431c4-c3eb-4544-a55a-7ddc56472752",
          "self": "/classification_entries/786431c4-c3eb-4544-a55a-7ddc56472752/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/786431c4-c3eb-4544-a55a-7ddc56472752"
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
DELETE /classification_entries/3b7d3578-4d30-47f7-bf97-261b66bd65d7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 899b1770-2898-4f4e-ad59-90f9ec7deddb
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
POST /classification_tables/a7506ffb-7cd1-47d1-a0e4-4a4ef800f7e7/relationships/classification_entries
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
X-Request-Id: 93ed08ac-4aed-41b1-850d-a64a19b2d800
201 Created
```


```json
{
  "data": {
    "id": "eb162595-2e38-4e2b-af99-2a2b26c83762",
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
          "related": "/tags?filter[target_id_eq]=eb162595-2e38-4e2b-af99-2a2b26c83762&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/eb162595-2e38-4e2b-af99-2a2b26c83762/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=eb162595-2e38-4e2b-af99-2a2b26c83762",
          "self": "/classification_entries/eb162595-2e38-4e2b-af99-2a2b26c83762/relationships/classification_entries"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a7506ffb-7cd1-47d1-a0e4-4a4ef800f7e7/relationships/classification_entries"
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
X-Request-Id: b1ca9470-0476-441f-9ba0-91874601b8de
200 OK
```


```json
{
  "data": [
    {
      "id": "ec2daa33-ebb9-49ef-adfa-fc2aeb0046fe",
      "type": "syntax",
      "attributes": {
        "account_id": "d2a3cdc8-6d6d-4535-9f15-cbd30b66f8ee",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax dbff7a7b42f5",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=ec2daa33-ebb9-49ef-adfa-fc2aeb0046fe",
            "self": "/syntaxes/ec2daa33-ebb9-49ef-adfa-fc2aeb0046fe/relationships/syntax_elements"
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
GET /syntaxes/ee7fc3af-45fa-4568-8fca-8d9a70de9a29
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
X-Request-Id: 114bada4-3cb2-4599-8214-d8cd92920026
200 OK
```


```json
{
  "data": {
    "id": "ee7fc3af-45fa-4568-8fca-8d9a70de9a29",
    "type": "syntax",
    "attributes": {
      "account_id": "0dd68acb-f353-4e4e-8407-833e5c06aca3",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax aabeef44574f",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ee7fc3af-45fa-4568-8fca-8d9a70de9a29",
          "self": "/syntaxes/ee7fc3af-45fa-4568-8fca-8d9a70de9a29/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ee7fc3af-45fa-4568-8fca-8d9a70de9a29"
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
X-Request-Id: d7fe76ec-fd48-47ed-8a65-f365c422b2f6
201 Created
```


```json
{
  "data": {
    "id": "ce0532ec-e6c9-4015-941c-62b4f099fd5b",
    "type": "syntax",
    "attributes": {
      "account_id": "accccf9f-ef2f-461e-9fc9-2576be7630a4",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ce0532ec-e6c9-4015-941c-62b4f099fd5b",
          "self": "/syntaxes/ce0532ec-e6c9-4015-941c-62b4f099fd5b/relationships/syntax_elements"
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
PATCH /syntaxes/254c15b9-6aaa-422c-b298-39efadc167d3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "254c15b9-6aaa-422c-b298-39efadc167d3",
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
X-Request-Id: 9e6e4bc9-9ef5-4a27-8058-dd9e698a8fce
200 OK
```


```json
{
  "data": {
    "id": "254c15b9-6aaa-422c-b298-39efadc167d3",
    "type": "syntax",
    "attributes": {
      "account_id": "66ee2102-6bd0-4aee-9e5f-8e42030be09a",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=254c15b9-6aaa-422c-b298-39efadc167d3",
          "self": "/syntaxes/254c15b9-6aaa-422c-b298-39efadc167d3/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/254c15b9-6aaa-422c-b298-39efadc167d3"
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
DELETE /syntaxes/c67dac30-cb32-4bcc-836a-680c1c8ac05b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: fe118e84-61e8-4333-926b-4edaefa1a5bd
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
POST /syntaxes/50102e08-1f08-462b-9732-ddda073a7c70/publish
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
X-Request-Id: 7f551ce6-e5a1-4329-bb39-d88b07008b9e
200 OK
```


```json
{
  "data": {
    "id": "50102e08-1f08-462b-9732-ddda073a7c70",
    "type": "syntax",
    "attributes": {
      "account_id": "81fe3529-7aa0-4b9b-9dc3-89f12a15d761",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax e3d3f9838063",
      "published": true,
      "published_at": "2020-02-09T22:08:19.014Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=50102e08-1f08-462b-9732-ddda073a7c70",
          "self": "/syntaxes/50102e08-1f08-462b-9732-ddda073a7c70/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/50102e08-1f08-462b-9732-ddda073a7c70/publish"
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
POST /syntaxes/ffe7c75c-f38a-496e-89a2-254829b96d45/archive
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
X-Request-Id: 14512aef-f2f8-41ba-8e7f-d9b302a7d6a2
200 OK
```


```json
{
  "data": {
    "id": "ffe7c75c-f38a-496e-89a2-254829b96d45",
    "type": "syntax",
    "attributes": {
      "account_id": "8e4a38e2-a25f-456b-85b5-11d2d3aad3ea",
      "archived": true,
      "archived_at": "2020-02-09T22:08:19.385Z",
      "description": "Description",
      "name": "Syntax 79ff0e034319",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=ffe7c75c-f38a-496e-89a2-254829b96d45",
          "self": "/syntaxes/ffe7c75c-f38a-496e-89a2-254829b96d45/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/ffe7c75c-f38a-496e-89a2-254829b96d45/archive"
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
X-Request-Id: 0fd94d52-7feb-43e6-9943-9616141787f4
200 OK
```


```json
{
  "data": [
    {
      "id": "1895ab26-f9e9-41d1-a327-3666f52da1a2",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "f99e8a1a-6a57-408f-bdde-71f562e68edd",
        "hex_color": "88c22b",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element fc1ba715ca99"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/20ced759-4817-4b19-809c-50b0518cfe59"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/f99e8a1a-6a57-408f-bdde-71f562e68edd",
            "self": "/syntax_elements/1895ab26-f9e9-41d1-a327-3666f52da1a2/relationships/classification_table"
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
GET /syntax_elements/02370a49-5186-4756-bffb-f9026bd12a2a
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
X-Request-Id: 31ee1af3-6b46-4b5b-a089-5298bc81c27d
200 OK
```


```json
{
  "data": {
    "id": "02370a49-5186-4756-bffb-f9026bd12a2a",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "65a1cb0b-313f-418b-8f30-b244ccd247f3",
      "hex_color": "83b822",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 2d2fa1489f85"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/f8d10a08-3bfd-4182-bc28-9e3c13b281cb"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/65a1cb0b-313f-418b-8f30-b244ccd247f3",
          "self": "/syntax_elements/02370a49-5186-4756-bffb-f9026bd12a2a/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/02370a49-5186-4756-bffb-f9026bd12a2a"
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
POST /syntaxes/6e6b428c-e002-42ee-8697-fdafa45e0cdb/relationships/syntax_elements
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
          "id": "77d665bc-3629-49e4-8076-aa94251aa26b"
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
X-Request-Id: 5f0f513c-2cf6-42ac-b3bc-5d017a23687a
201 Created
```


```json
{
  "data": {
    "id": "f7493a08-6332-4027-bd8b-167849abe03d",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "77d665bc-3629-49e4-8076-aa94251aa26b",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/6e6b428c-e002-42ee-8697-fdafa45e0cdb"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/77d665bc-3629-49e4-8076-aa94251aa26b",
          "self": "/syntax_elements/f7493a08-6332-4027-bd8b-167849abe03d/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/6e6b428c-e002-42ee-8697-fdafa45e0cdb/relationships/syntax_elements"
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
PATCH /syntax_elements/9fbb9fc9-0e39-4fb1-bd59-35b007bd0ca8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "9fbb9fc9-0e39-4fb1-bd59-35b007bd0ca8",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "c17f35e6-3ae7-4a92-acb7-ffcb19467ef1"
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
X-Request-Id: 5df38cd4-43bf-4915-a3f2-8f0115c64206
200 OK
```


```json
{
  "data": {
    "id": "9fbb9fc9-0e39-4fb1-bd59-35b007bd0ca8",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "c17f35e6-3ae7-4a92-acb7-ffcb19467ef1",
      "hex_color": "246480",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/34257b8b-5f20-4194-b8e9-16103c6be036"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/c17f35e6-3ae7-4a92-acb7-ffcb19467ef1",
          "self": "/syntax_elements/9fbb9fc9-0e39-4fb1-bd59-35b007bd0ca8/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/9fbb9fc9-0e39-4fb1-bd59-35b007bd0ca8"
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
DELETE /syntax_elements/27690056-44af-4449-956c-06a85ca45c37
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8fbbeb44-bd52-4dd8-84aa-cdb48fe54de7
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
PATCH /syntax_elements/4f415e85-5a77-45bc-83da-4cca3212a340/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "8a6806fc-b71a-4955-8be8-3c505f5faa86",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 2b4bea07-376a-4d31-904d-4e6e91525ca1
200 OK
```


```json
{
  "data": {
    "id": "4f415e85-5a77-45bc-83da-4cca3212a340",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "8a6806fc-b71a-4955-8be8-3c505f5faa86",
      "hex_color": "e29ebb",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 6ac2425aeb6d"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/d5819c76-bf02-4820-9486-a8218a5105d0"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/8a6806fc-b71a-4955-8be8-3c505f5faa86",
          "self": "/syntax_elements/4f415e85-5a77-45bc-83da-4cca3212a340/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/4f415e85-5a77-45bc-83da-4cca3212a340/relationships/classification_table"
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
DELETE /syntax_elements/501fb6c0-42d6-4c0f-8b76-4b8029a8464e/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7fc0e422-6b26-4c41-8758-f4687594b02b
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
GET /syntax_nodes/5c2d034a-4024-4452-98d2-935743cf2a47
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 20fc162c-ce27-47c3-afe1-91f3598249a7
200 OK
```


```json
{
  "data": {
    "id": "5c2d034a-4024-4452-98d2-935743cf2a47",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/36cbcbc8-c6a7-4898-9558-edb8dd24281a"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/5c2d034a-4024-4452-98d2-935743cf2a47/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/5c2d034a-4024-4452-98d2-935743cf2a47"
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
POST /syntax_nodes/32807a72-db73-4fb2-926c-ffbb58aef07e/relationships/components
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
X-Request-Id: 04ac5b96-8e35-4532-8f31-dc020c8bf7ce
201 Created
```


```json
{
  "data": {
    "id": "323a8dd6-7270-48a7-b9dc-829a5af7d896",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/931d5cba-5bc2-4113-a6a2-cd0a96f4912a"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/323a8dd6-7270-48a7-b9dc-829a5af7d896/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/32807a72-db73-4fb2-926c-ffbb58aef07e/relationships/components"
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
PATCH /syntax_nodes/e8992175-7b0c-488a-a11b-d4060659b375
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "e8992175-7b0c-488a-a11b-d4060659b375",
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
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 43e369be-1aea-4818-8b8c-024af42ed673
200 OK
```


```json
{
  "data": {
    "id": "e8992175-7b0c-488a-a11b-d4060659b375",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/7d6cbb3b-b7c7-4d32-9005-c13138e1b935"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/e8992175-7b0c-488a-a11b-d4060659b375/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/e8992175-7b0c-488a-a11b-d4060659b375"
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
DELETE /syntax_nodes/f209d0e0-4225-41fa-aa07-fb5f8d28668a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 8cc128ef-33dd-40c0-b101-381e2c476f42
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
X-Request-Id: 805ff68b-5178-434d-b9bb-6f3de7c2ae3c
200 OK
```


```json
{
  "data": [
    {
      "id": "43ad7706-29b8-49d0-b166-7d2ff8e6aafe",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-09T22:08:26.710Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=43ad7706-29b8-49d0-b166-7d2ff8e6aafe",
            "self": "/progress_models/43ad7706-29b8-49d0-b166-7d2ff8e6aafe/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "c0983353-8bbc-4857-9bdf-b7b1216dcb69",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=c0983353-8bbc-4857-9bdf-b7b1216dcb69",
            "self": "/progress_models/c0983353-8bbc-4857-9bdf-b7b1216dcb69/relationships/progress_steps"
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
GET /progress_models/57abe2f7-82f1-4d9a-aadc-2bfcc63b9cd6
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
X-Request-Id: 00ca3bc6-f26b-49c3-b6f8-9350362c5908
200 OK
```


```json
{
  "data": {
    "id": "57abe2f7-82f1-4d9a-aadc-2bfcc63b9cd6",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-09T22:08:27.308Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=57abe2f7-82f1-4d9a-aadc-2bfcc63b9cd6",
          "self": "/progress_models/57abe2f7-82f1-4d9a-aadc-2bfcc63b9cd6/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/57abe2f7-82f1-4d9a-aadc-2bfcc63b9cd6"
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
PATCH /progress_models/040886b4-2ebe-4af5-b9d6-ff1b8e49e0e5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "040886b4-2ebe-4af5-b9d6-ff1b8e49e0e5",
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
X-Request-Id: 3767b062-9b2a-4956-8879-994ff2c9108b
200 OK
```


```json
{
  "data": {
    "id": "040886b4-2ebe-4af5-b9d6-ff1b8e49e0e5",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=040886b4-2ebe-4af5-b9d6-ff1b8e49e0e5",
          "self": "/progress_models/040886b4-2ebe-4af5-b9d6-ff1b8e49e0e5/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/040886b4-2ebe-4af5-b9d6-ff1b8e49e0e5"
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
DELETE /progress_models/88fd5817-f741-461c-bb0f-90eecead94d9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 534b302c-2705-4e57-995c-1942df843ec5
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
POST /progress_models/42fd9efb-944b-40d8-acd9-47fd33e019e6/publish
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
X-Request-Id: 2e88f379-dea7-4b92-a5c2-0977270868e3
200 OK
```


```json
{
  "data": {
    "id": "42fd9efb-944b-40d8-acd9-47fd33e019e6",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-09T22:08:29.561Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=42fd9efb-944b-40d8-acd9-47fd33e019e6",
          "self": "/progress_models/42fd9efb-944b-40d8-acd9-47fd33e019e6/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/42fd9efb-944b-40d8-acd9-47fd33e019e6/publish"
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
POST /progress_models/9dce233a-9d29-4209-b95d-a8438d0c0234/archive
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
X-Request-Id: e8ef43a6-b798-46cd-bdc2-701291adfb99
200 OK
```


```json
{
  "data": {
    "id": "9dce233a-9d29-4209-b95d-a8438d0c0234",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-09T22:08:30.001Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=9dce233a-9d29-4209-b95d-a8438d0c0234",
          "self": "/progress_models/9dce233a-9d29-4209-b95d-a8438d0c0234/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/9dce233a-9d29-4209-b95d-a8438d0c0234/archive"
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
X-Request-Id: 1f15ca31-12a1-4757-bdf3-25e4c6c9ce97
201 Created
```


```json
{
  "data": {
    "id": "1e328fe5-990a-46a7-8a35-9faf8341e185",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=1e328fe5-990a-46a7-8a35-9faf8341e185",
          "self": "/progress_models/1e328fe5-990a-46a7-8a35-9faf8341e185/relationships/progress_steps"
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
X-Request-Id: 2c8c78fd-7d6e-473f-87d9-589952ce4734
200 OK
```


```json
{
  "data": [
    {
      "id": "c6041975-872c-4ee0-ad61-c1c6962b3064",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/aebd3945-88b7-404b-aecd-98066441c0a8"
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
GET /progress_steps/3ec44aba-5e99-49fd-9184-fbaa58d0c2e6
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
X-Request-Id: 60ec79db-a03b-4b72-a30a-6ee3192e62b8
200 OK
```


```json
{
  "data": {
    "id": "3ec44aba-5e99-49fd-9184-fbaa58d0c2e6",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/a6842590-a7c3-4ecc-878a-0fec7bd74d42"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/3ec44aba-5e99-49fd-9184-fbaa58d0c2e6"
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
PATCH /progress_steps/8a0cef00-c55c-431b-acc1-d263d56e5a1b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "8a0cef00-c55c-431b-acc1-d263d56e5a1b",
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
X-Request-Id: bac33674-d4d8-4c3b-80a5-676d0e0a9e5d
200 OK
```


```json
{
  "data": {
    "id": "8a0cef00-c55c-431b-acc1-d263d56e5a1b",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/a7e23888-89c0-46a1-9744-3e8250e5a662"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/8a0cef00-c55c-431b-acc1-d263d56e5a1b"
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
DELETE /progress_steps/ae52e512-0924-4caa-b192-3c067710c96d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6768be9a-a856-4501-bbe5-c98cc81e6cad
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
POST /progress_models/35e97f56-6b13-4c69-8d30-3960b280bacc/relationships/progress_steps
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
X-Request-Id: 8797ec7b-fad3-4c75-9729-44aa45103ae6
201 Created
```


```json
{
  "data": {
    "id": "2cb34f6c-8a86-4668-8f27-0c954a6c3b72",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/35e97f56-6b13-4c69-8d30-3960b280bacc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/35e97f56-6b13-4c69-8d30-3960b280bacc/relationships/progress_steps"
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
X-Request-Id: 9d4a5734-2b8f-4f39-85b1-be9b8324003a
200 OK
```


```json
{
  "data": [
    {
      "id": "7e5a08e3-9859-41c9-947f-3f340fa3328f",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/08017eef-741a-4af8-a298-c501ec06e5d4"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/cc2492a4-6aa8-4504-a9a2-80f982c017c2"
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
GET /progress/26a8d708-4f1b-415c-a9ae-6b8cd4c4f480
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
X-Request-Id: 03e19b4e-715f-4d57-a045-7827f95833aa
200 OK
```


```json
{
  "data": {
    "id": "26a8d708-4f1b-415c-a9ae-6b8cd4c4f480",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/6517bfc1-9da7-4454-aa80-dbd7ceaa1b40"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/9007bdbd-51cc-4c29-ae79-5fb90d747bff"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/26a8d708-4f1b-415c-a9ae-6b8cd4c4f480"
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
DELETE /progress/b34a456f-764c-4cf1-8da0-b4abf47b45d4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 570472e2-b567-4f6b-932a-ded237dcb5d2
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
          "id": "6042a038-1eb4-4422-879d-b0cceaefa83c"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "f8c580e9-717b-4204-b757-d3b69acb9e1b"
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
X-Request-Id: f10e0632-cd2b-4fee-ae07-75c616f5419c
201 Created
```


```json
{
  "data": {
    "id": "b47851a5-c30a-400a-bbe2-5441497eab0e",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/6042a038-1eb4-4422-879d-b0cceaefa83c"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/f8c580e9-717b-4204-b757-d3b69acb9e1b"
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
X-Request-Id: fe9499cd-cd56-40fb-978f-43521c2371d0
200 OK
```


```json
{
  "data": [
    {
      "id": "adfbf36f-6e3d-4539-b5b3-85b94e7c085a",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "543c1b39-ec54-4ab7-9632-fd19af73bde3"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/543c1b39-ec54-4ab7-9632-fd19af73bde3"
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
GET /projects/1ec3b24c-117b-4d43-91ae-748d4ec3e23d/relationships/project_setting
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
X-Request-Id: 3537e2dd-97ea-43d0-bf6d-183be8f9df40
200 OK
```


```json
{
  "data": {
    "id": "09c83774-da93-4e81-8c8f-fa3c5258c8aa",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "1ec3b24c-117b-4d43-91ae-748d4ec3e23d"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/1ec3b24c-117b-4d43-91ae-748d4ec3e23d"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/1ec3b24c-117b-4d43-91ae-748d4ec3e23d/relationships/project_setting"
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
PATCH /projects/45850269-47d4-4521-bd6c-a4e0ccff839c/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "45850269-47d4-4521-bd6c-a4e0ccff839c",
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
X-Request-Id: d0692cbe-b008-4172-a0eb-8403a4efd107
200 OK
```


```json
{
  "data": {
    "id": "d6c05b51-afb0-4f66-95ba-90872dafd8ba",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "45850269-47d4-4521-bd6c-a4e0ccff839c"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/45850269-47d4-4521-bd6c-a4e0ccff839c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/45850269-47d4-4521-bd6c-a4e0ccff839c/relationships/project_setting"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][contexts_limit] | The limit of active (none archived and current revision) contexts within the project. |
| data[attributes][context_revisions_to_keep] | Limits the number of revisions kept of each context. While the system will keep all of the revisions of all of the contexts, only the latest n will be available to the user limited by this number. |


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
X-Request-Id: 4427ccac-3801-43cd-88fa-dfe1506107c1
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
X-Request-Id: 67e2406b-fc01-4e03-b112-fabb200a4d35
200 OK
```


```json
{
  "data": {
    "id": "60028f28-b1f8-41e5-aa11-fd65cb3d00db",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "3fc3c949-e077-420e-9739-d18f2c26e3d9"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/3fc3c949-e077-420e-9739-d18f2c26e3d9"
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
X-Request-Id: 06da002e-4cd8-4446-ba25-fa128b57ea47
200 OK
```


```json
{
  "data": {
    "id": "bfd665d3-e560-46a7-9f59-8605fe24c12b",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "47bb8cc6-26fe-46ae-ac61-de22dbb8b193"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/47bb8cc6-26fe-46ae-ac61-de22dbb8b193"
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


# Utils

Events is a way to track which changes and events has happened to resources.


## Look up path


### Request

#### Endpoint

```plaintext
GET /utils/path/from/object_occurrence/87ad614b-d3b4-4eb3-8b3e-0683ecfcc8a3/to/object_occurrence/f364ffe2-3887-41c3-991a-444348840c11
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
X-Request-Id: 812ef6d3-0de9-4aa6-a031-eb2fada0ab38
200 OK
```


```json
[
  {
    "id": "87ad614b-d3b4-4eb3-8b3e-0683ecfcc8a3",
    "type": "object_occurrence"
  },
  {
    "id": "ebba6f81-bbd4-48ae-9bab-b9f064285546",
    "type": "object_occurrence"
  },
  {
    "id": "90a74836-d62b-42e0-a1a4-a2489cf5c6c0",
    "type": "object_occurrence"
  },
  {
    "id": "31bd1eb8-0b17-4965-bec6-26efd896998a",
    "type": "object_occurrence"
  },
  {
    "id": "470d7b11-2d09-4ddb-991f-033f63dc20a3",
    "type": "object_occurrence"
  },
  {
    "id": "c4eea94f-3b75-4a63-9366-fe1170860f6a",
    "type": "object_occurrence"
  },
  {
    "id": "f364ffe2-3887-41c3-991a-444348840c11",
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
X-Request-Id: 11c301e7-f45a-47cc-b9f5-2c79efe78b6c
200 OK
```


```json
{
  "data": [
    {
      "id": "57226f3c-70b7-4701-b673-9294c7f3181b",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/02d98848-41ef-44d6-8799-7217e62eea23"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/f6666263-0376-4408-962e-594cfbbca496"
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
X-Request-Id: 3985f0e4-a0e6-46e6-af80-881134b523d7
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



