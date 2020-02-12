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

## Caching

The API uses standard <a href="https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control" target="_blank">HTTP Cache-Control</a>.

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
X-Request-Id: f29af0f1-e030-4db0-bec5-283d8aa8dbe4
200 OK
```


```json
{
  "data": {
    "id": "50659d93-d9b6-44ec-9abf-beb6adfa162f",
    "type": "account",
    "attributes": {
      "name": "Account a0b78d0cd268"
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
    "id": "2a05ca93-8524-4bfa-8796-9176fbec8d12",
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
X-Request-Id: 1d681cdd-9d29-419d-abf1-bc0e0cefbe27
200 OK
```


```json
{
  "data": {
    "id": "2a05ca93-8524-4bfa-8796-9176fbec8d12",
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
POST /projects/aea91196-07f2-4f5a-95a1-0ca80874e60b/relationships/tags
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
X-Request-Id: f21f0f72-ad03-448e-9b3d-9f7d89784970
201 Created
```


```json
{
  "data": {
    "id": "3a59eda3-24ff-42b2-a7e0-9ceec79379ba",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/aea91196-07f2-4f5a-95a1-0ca80874e60b/relationships/tags"
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
POST /projects/d45475d7-6c82-4592-97c8-1490e7ca45e6/relationships/tags
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
    "id": "8faa98c3-2dcb-4b9b-9194-bc0899aa6e8a"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a4ce7d73-d95c-425f-b7e1-90ba76d85a16
201 Created
```


```json
{
  "data": {
    "id": "8faa98c3-2dcb-4b9b-9194-bc0899aa6e8a",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/d45475d7-6c82-4592-97c8-1490e7ca45e6/relationships/tags"
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
DELETE /projects/f7e75290-f764-497b-a927-71bdf1b7f3de/relationships/tags/3b6021e6-c953-4c43-8ca3-2831a29160ab
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: d1ede735-a2a2-4c04-8c84-a6d4f1277ba4
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
X-Request-Id: 20fdf134-e0b6-4129-8082-b358b1c5f230
200 OK
```


```json
{
  "data": [
    {
      "id": "3542b688-a317-4818-8ad3-9e4c41b29f63",
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
            "related": "/tags?filter[target_id_eq]=3542b688-a317-4818-8ad3-9e4c41b29f63&filter[target_type_eq]=Project",
            "self": "/projects/3542b688-a317-4818-8ad3-9e4c41b29f63/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=3542b688-a317-4818-8ad3-9e4c41b29f63",
            "self": "/projects/3542b688-a317-4818-8ad3-9e4c41b29f63/relationships/contexts"
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
GET /projects/75835f30-94ec-4113-8059-958218f4a4ea
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
X-Request-Id: 9bc39342-4e52-45be-a41f-440520f70b14
200 OK
```


```json
{
  "data": {
    "id": "75835f30-94ec-4113-8059-958218f4a4ea",
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
          "related": "/tags?filter[target_id_eq]=75835f30-94ec-4113-8059-958218f4a4ea&filter[target_type_eq]=Project",
          "self": "/projects/75835f30-94ec-4113-8059-958218f4a4ea/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=75835f30-94ec-4113-8059-958218f4a4ea",
          "self": "/projects/75835f30-94ec-4113-8059-958218f4a4ea/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/75835f30-94ec-4113-8059-958218f4a4ea"
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
PATCH /projects/6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c",
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
X-Request-Id: 33db3701-1879-4ecd-bb56-cfad9ac0e85f
200 OK
```


```json
{
  "data": {
    "id": "6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c",
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
          "related": "/tags?filter[target_id_eq]=6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c&filter[target_type_eq]=Project",
          "self": "/projects/6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c",
          "self": "/projects/6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/6d0f2e3a-8718-49a3-a9fd-bb5b14a07e4c"
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
POST /projects/ee8f4088-8525-4e32-8026-839025e2cf53/archive
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
X-Request-Id: 5b848672-b9b1-4b30-acb3-69fc2cf554cf
200 OK
```


```json
{
  "data": {
    "id": "ee8f4088-8525-4e32-8026-839025e2cf53",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T09:44:12.699Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=ee8f4088-8525-4e32-8026-839025e2cf53&filter[target_type_eq]=Project",
          "self": "/projects/ee8f4088-8525-4e32-8026-839025e2cf53/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=ee8f4088-8525-4e32-8026-839025e2cf53",
          "self": "/projects/ee8f4088-8525-4e32-8026-839025e2cf53/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/ee8f4088-8525-4e32-8026-839025e2cf53/archive"
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
DELETE /projects/7a16cff5-287f-4ae8-93cf-8f55740da3a9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5c5fb827-3e36-46b9-a092-1f6752d626af
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
POST /contexts/d89be56f-15ee-4468-bb38-1afcb899af3e/relationships/tags
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
X-Request-Id: b909adfc-51ba-4569-b969-ce9779f66754
201 Created
```


```json
{
  "data": {
    "id": "0a0edc76-1045-45d6-a048-d5217061944a",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/d89be56f-15ee-4468-bb38-1afcb899af3e/relationships/tags"
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
POST /contexts/8b43cebd-ed5f-4e3a-a9ea-82cbd2478030/relationships/tags
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
    "id": "9fad2bcc-7c6e-4e47-a1a6-2c9aae01e28f"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: af44bbcf-75fc-4e11-a572-85d5b3a1dced
201 Created
```


```json
{
  "data": {
    "id": "9fad2bcc-7c6e-4e47-a1a6-2c9aae01e28f",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/8b43cebd-ed5f-4e3a-a9ea-82cbd2478030/relationships/tags"
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
DELETE /contexts/24a5662f-bfeb-41c8-a576-581952eb6bcb/relationships/tags/dedde67b-e946-4aaf-83ab-bde518e6d49a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e57ae4fe-5c13-4d95-b11e-d8ea56a1221c
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
X-Request-Id: 86c91fc7-ca7f-4759-acf7-4342d2f88b83
200 OK
```


```json
{
  "data": [
    {
      "id": "46ff2254-e03a-4471-9c6a-25255f2e7e1e",
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
            "related": "/tags?filter[target_id_eq]=46ff2254-e03a-4471-9c6a-25255f2e7e1e&filter[target_type_eq]=Context",
            "self": "/contexts/46ff2254-e03a-4471-9c6a-25255f2e7e1e/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/fc47bfc5-3b19-44ea-ba2d-bbcf8d07df40"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/f6d36595-7740-41ac-8bfc-15e02d131bd4"
          }
        }
      }
    },
    {
      "id": "e42da53b-ba82-4cef-a236-66e89df50ab8",
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
            "related": "/tags?filter[target_id_eq]=e42da53b-ba82-4cef-a236-66e89df50ab8&filter[target_type_eq]=Context",
            "self": "/contexts/e42da53b-ba82-4cef-a236-66e89df50ab8/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/fc47bfc5-3b19-44ea-ba2d-bbcf8d07df40"
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
GET /contexts/70447d3b-19e5-4858-8b5d-a1d6fe335cdf
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
X-Request-Id: 1dee3ed2-2573-47cd-996d-3456b53405c4
200 OK
```


```json
{
  "data": {
    "id": "70447d3b-19e5-4858-8b5d-a1d6fe335cdf",
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
          "related": "/tags?filter[target_id_eq]=70447d3b-19e5-4858-8b5d-a1d6fe335cdf&filter[target_type_eq]=Context",
          "self": "/contexts/70447d3b-19e5-4858-8b5d-a1d6fe335cdf/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/147243f8-6762-4e43-b2a5-76c654bebe88"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/7476ca67-8e24-475d-a26d-a30da7e97a93"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/70447d3b-19e5-4858-8b5d-a1d6fe335cdf"
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
PATCH /contexts/11a6c770-08c7-43f2-8eab-0db0fda97167
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "11a6c770-08c7-43f2-8eab-0db0fda97167",
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
X-Request-Id: d6d3d1bf-518d-45b6-9df9-2f494b5fc99d
200 OK
```


```json
{
  "data": {
    "id": "11a6c770-08c7-43f2-8eab-0db0fda97167",
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
          "related": "/tags?filter[target_id_eq]=11a6c770-08c7-43f2-8eab-0db0fda97167&filter[target_type_eq]=Context",
          "self": "/contexts/11a6c770-08c7-43f2-8eab-0db0fda97167/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/21e206b2-4f91-44ec-b411-997ea329e53e"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/120b17fa-d626-46f4-9f05-57ed5548efb6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/11a6c770-08c7-43f2-8eab-0db0fda97167"
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
POST /projects/b4ec9e28-415f-4d28-b93a-880a65872e1f/relationships/contexts
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
X-Request-Id: d08b0e45-d5c2-45a9-b8fb-d3dc50723e86
201 Created
```


```json
{
  "data": {
    "id": "47ed2d67-6e4c-4ace-9de2-37c1b883c39b",
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
          "related": "/tags?filter[target_id_eq]=47ed2d67-6e4c-4ace-9de2-37c1b883c39b&filter[target_type_eq]=Context",
          "self": "/contexts/47ed2d67-6e4c-4ace-9de2-37c1b883c39b/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/b4ec9e28-415f-4d28-b93a-880a65872e1f"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/9421d0a6-c443-466a-8c5c-1f5375446f59"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/b4ec9e28-415f-4d28-b93a-880a65872e1f/relationships/contexts"
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
POST /contexts/f1912678-52f5-4f5c-948d-9ae6d3c9e129/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/c9ea46370ba9535ed72be5c3
Content-Type: text/html; charset=utf-8
X-Request-Id: ffb25ca5-d555-46f7-8216-fcf3a8f1f90c
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/c9ea46370ba9535ed72be5c3">redirected</a>.</body></html>
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
DELETE /contexts/fbc9ad4f-ea8e-4005-a4f6-8abcf9c2cb81
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 298c3092-67c3-4a9f-8094-d24e45ab0eec
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
POST /object_occurrences/37b52c9c-5f19-4ac4-8769-4bfec7f7fa1d/relationships/tags
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
X-Request-Id: 3c7ad578-a41c-4a5c-88c3-4c8c94356121
201 Created
```


```json
{
  "data": {
    "id": "8a61b537-64ae-466e-bc6b-b27cbe4152e2",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/37b52c9c-5f19-4ac4-8769-4bfec7f7fa1d/relationships/tags"
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
POST /object_occurrences/be9db8b2-739e-4b35-aea2-35e47e1a52fc/relationships/tags
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
    "id": "1573e2c7-f2d7-4104-9221-1a6bbb5aaa2c"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 93311b71-a07c-4b72-9761-a99afd0d33bf
201 Created
```


```json
{
  "data": {
    "id": "1573e2c7-f2d7-4104-9221-1a6bbb5aaa2c",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/be9db8b2-739e-4b35-aea2-35e47e1a52fc/relationships/tags"
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
DELETE /object_occurrences/62b83bce-f1ba-462f-8430-c29e9d18d5e7/relationships/tags/e7265c88-e675-4fd7-9a2e-22ef10a49423
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 4af63d88-a5dd-458c-9cc1-5097c2c05bf7
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
GET /object_occurrences/4ffa3acb-da2c-4643-bc58-09159c62f5e5
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
X-Request-Id: 32918ed3-a285-4684-8286-adc12e47e186
200 OK
```


```json
{
  "data": {
    "id": "4ffa3acb-da2c-4643-bc58-09159c62f5e5",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 1",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=4ffa3acb-da2c-4643-bc58-09159c62f5e5&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/4ffa3acb-da2c-4643-bc58-09159c62f5e5/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/537b2eb2-7765-46c2-a8fe-49307065d5c7"
        }
      },
      "components": {
        "data": [
          {
            "id": "03ecf4a2-3a7e-4a76-88ad-2ed1236dd607",
            "type": "object_occurrence"
          },
          {
            "id": "2e442bf8-7946-4c2d-ab83-a83d89ebe8eb",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/4ffa3acb-da2c-4643-bc58-09159c62f5e5/relationships/components"
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
    "self": "http://example.org/object_occurrences/4ffa3acb-da2c-4643-bc58-09159c62f5e5"
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
POST /object_occurrences/eddf8f3e-cbdf-4e4a-8fc9-debec6cca7ab/relationships/components
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
X-Request-Id: 04a23094-ca1c-4d74-a48c-47e9cf8d81bb
201 Created
```


```json
{
  "data": {
    "id": "7288e374-b6e1-4846-b342-c9ecd0faedda",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "name": "ooc",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=7288e374-b6e1-4846-b342-c9ecd0faedda&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/7288e374-b6e1-4846-b342-c9ecd0faedda/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/40353257-33e8-4beb-8365-7d961077dffc"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/eddf8f3e-cbdf-4e4a-8fc9-debec6cca7ab",
          "self": "/object_occurrences/7288e374-b6e1-4846-b342-c9ecd0faedda/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/7288e374-b6e1-4846-b342-c9ecd0faedda/relationships/components"
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
    "self": "http://example.org/object_occurrences/eddf8f3e-cbdf-4e4a-8fc9-debec6cca7ab/relationships/components"
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
PATCH /object_occurrences/170f4bea-4923-4aa3-905a-21e1d978dd92
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "170f4bea-4923-4aa3-905a-21e1d978dd92",
    "type": "object_occurrence",
    "attributes": {
      "description": "New description",
      "name": "New name",
      "number": 8,
      "position": 2,
      "prefix": "%",
      "type": "external",
      "hex_color": "#FFA500"
    },
    "relationships": {
      "part_of": {
        "data": {
          "type": "object_occurrence",
          "id": "27009825-eb1b-4ac2-b8ee-b3752d700aa7"
        }
      }
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| data[attributes][name]  | New name |
| data[attributes][description]  | New description |
| data[attributes][hex_color]  | Specify a OOC color |
| data[attributes][position]  | Update sorting position |
| data[attributes][prefix]  | Update prefix |
| data[attributes][prefix]  | Update prefix |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4961e790-7430-41d2-83eb-749dd59894f6
200 OK
```


```json
{
  "data": {
    "id": "170f4bea-4923-4aa3-905a-21e1d978dd92",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "system_element_relation_id": null,
      "type": "external",
      "hex_color": "#ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=170f4bea-4923-4aa3-905a-21e1d978dd92&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/170f4bea-4923-4aa3-905a-21e1d978dd92/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/6b0cd9c5-5eb8-46fb-8f29-f087c8f8cd9d"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/27009825-eb1b-4ac2-b8ee-b3752d700aa7",
          "self": "/object_occurrences/170f4bea-4923-4aa3-905a-21e1d978dd92/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/170f4bea-4923-4aa3-905a-21e1d978dd92/relationships/components"
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
    "self": "http://example.org/object_occurrences/170f4bea-4923-4aa3-905a-21e1d978dd92"
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
POST /object_occurrences/0da3fd29-9219-465f-bc53-08d17bb3b4b0/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "a44c358c-a286-469e-8d1e-67c09b4136ff",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/94d5449dbe448002828ed958
Content-Type: text/html; charset=utf-8
X-Request-Id: 4720525b-36fe-446a-9a0d-57093b66f16f
303 See Other
```


```json
<html><body>You are being <a href="http://example.org/polling/94d5449dbe448002828ed958">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/8bb3d12f-479e-4885-804b-1bc1b4ffa030
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c75f459c-4cd5-4cfe-ae54-72c9c6a23d05
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
PATCH /object_occurrences/137bf2e8-b50b-4af4-a458-ba002a150c30/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "acee929c-c288-4f42-b114-35fb5f67b859",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8b9b34d2-cebb-4263-a843-65966eb9e914
200 OK
```


```json
{
  "data": {
    "id": "137bf2e8-b50b-4af4-a458-ba002a150c30",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 2",
      "position": null,
      "prefix": "=",
      "system_element_relation_id": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=137bf2e8-b50b-4af4-a458-ba002a150c30&filter[target_type_eq]=ObjectOccurrence",
          "self": "/object_occurrences/137bf2e8-b50b-4af4-a458-ba002a150c30/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/ef6fb1d9-3984-49f2-8033-f315f99d764a"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/acee929c-c288-4f42-b114-35fb5f67b859",
          "self": "/object_occurrences/137bf2e8-b50b-4af4-a458-ba002a150c30/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/137bf2e8-b50b-4af4-a458-ba002a150c30/relationships/components"
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
    "self": "http://example.org/object_occurrences/137bf2e8-b50b-4af4-a458-ba002a150c30/relationships/part_of"
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
POST /classification_tables/6d85a729-1d2e-4b94-b868-f10f6899b243/relationships/tags
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
X-Request-Id: 13d3bd12-d269-460d-b24d-7b18f8ac285e
201 Created
```


```json
{
  "data": {
    "id": "70c9ab54-8dd4-435c-989f-db05415f2c56",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/6d85a729-1d2e-4b94-b868-f10f6899b243/relationships/tags"
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
POST /classification_tables/7f226407-374a-499f-9f36-a1e0b2c7774a/relationships/tags
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
    "id": "4b9db965-a07b-45ec-9dd4-fe1e5b17af31"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ae24e8e5-3295-4581-b094-08ffd289e674
201 Created
```


```json
{
  "data": {
    "id": "4b9db965-a07b-45ec-9dd4-fe1e5b17af31",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/7f226407-374a-499f-9f36-a1e0b2c7774a/relationships/tags"
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
DELETE /classification_tables/c836e796-fee1-47bb-80f8-58f672b40567/relationships/tags/a99282d3-de84-4f44-b8c8-ab56e2419a81
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7df2aede-8711-4634-964a-4544002db485
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
X-Request-Id: 1272c8f5-af27-41a1-a15e-5a54c326428b
200 OK
```


```json
{
  "data": [
    {
      "id": "796c9f7d-3a07-4ed2-ae16-fae4d8f8e343",
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
            "related": "/tags?filter[target_id_eq]=796c9f7d-3a07-4ed2-ae16-fae4d8f8e343&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/796c9f7d-3a07-4ed2-ae16-fae4d8f8e343/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=796c9f7d-3a07-4ed2-ae16-fae4d8f8e343",
            "self": "/classification_tables/796c9f7d-3a07-4ed2-ae16-fae4d8f8e343/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "df6d5c32-c129-4169-be1d-c7ac1317e0fd",
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
            "related": "/tags?filter[target_id_eq]=df6d5c32-c129-4169-be1d-c7ac1317e0fd&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/df6d5c32-c129-4169-be1d-c7ac1317e0fd/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=df6d5c32-c129-4169-be1d-c7ac1317e0fd",
            "self": "/classification_tables/df6d5c32-c129-4169-be1d-c7ac1317e0fd/relationships/classification_entries",
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
X-Request-Id: 78f59ecc-b7e7-419c-b6b0-47e47dbcf516
200 OK
```


```json
{
  "data": [
    {
      "id": "910bb6d7-0f4d-4659-8246-89f53c22b9d3",
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
            "related": "/tags?filter[target_id_eq]=910bb6d7-0f4d-4659-8246-89f53c22b9d3&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/910bb6d7-0f4d-4659-8246-89f53c22b9d3/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=910bb6d7-0f4d-4659-8246-89f53c22b9d3",
            "self": "/classification_tables/910bb6d7-0f4d-4659-8246-89f53c22b9d3/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "be513a5d-2e99-4650-a5da-2de8368f780b",
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
            "related": "/tags?filter[target_id_eq]=be513a5d-2e99-4650-a5da-2de8368f780b&filter[target_type_eq]=ClassificationTable",
            "self": "/classification_tables/be513a5d-2e99-4650-a5da-2de8368f780b/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=be513a5d-2e99-4650-a5da-2de8368f780b",
            "self": "/classification_tables/be513a5d-2e99-4650-a5da-2de8368f780b/relationships/classification_entries",
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
GET /classification_tables/bccbf2f0-3750-4841-81e5-39eb3e2853f6
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
X-Request-Id: 0a5ce8c0-c994-46eb-b695-d08d0cb75612
200 OK
```


```json
{
  "data": {
    "id": "bccbf2f0-3750-4841-81e5-39eb3e2853f6",
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
          "related": "/tags?filter[target_id_eq]=bccbf2f0-3750-4841-81e5-39eb3e2853f6&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/bccbf2f0-3750-4841-81e5-39eb3e2853f6/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=bccbf2f0-3750-4841-81e5-39eb3e2853f6",
          "self": "/classification_tables/bccbf2f0-3750-4841-81e5-39eb3e2853f6/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/bccbf2f0-3750-4841-81e5-39eb3e2853f6"
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
PATCH /classification_tables/1e2e0655-df90-4c92-8e71-3b766919ee3e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "1e2e0655-df90-4c92-8e71-3b766919ee3e",
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
X-Request-Id: 50b8fa65-2e2e-4503-a66e-32391e566935
200 OK
```


```json
{
  "data": {
    "id": "1e2e0655-df90-4c92-8e71-3b766919ee3e",
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
          "related": "/tags?filter[target_id_eq]=1e2e0655-df90-4c92-8e71-3b766919ee3e&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/1e2e0655-df90-4c92-8e71-3b766919ee3e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=1e2e0655-df90-4c92-8e71-3b766919ee3e",
          "self": "/classification_tables/1e2e0655-df90-4c92-8e71-3b766919ee3e/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/1e2e0655-df90-4c92-8e71-3b766919ee3e"
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
DELETE /classification_tables/cf8ec916-4709-4cf8-9960-46a0fd5c0893
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0dddc4fa-fbf2-4791-bde1-61c6db3761bc
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
POST /classification_tables/60f7e106-38f2-4a63-b08b-d4dc28aa65e9/publish
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
X-Request-Id: 2b330d6c-e93f-46b4-9a53-b9c3ecd613a1
200 OK
```


```json
{
  "data": {
    "id": "60f7e106-38f2-4a63-b08b-d4dc28aa65e9",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-02-12T09:44:33.046Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=60f7e106-38f2-4a63-b08b-d4dc28aa65e9&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/60f7e106-38f2-4a63-b08b-d4dc28aa65e9/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=60f7e106-38f2-4a63-b08b-d4dc28aa65e9",
          "self": "/classification_tables/60f7e106-38f2-4a63-b08b-d4dc28aa65e9/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/60f7e106-38f2-4a63-b08b-d4dc28aa65e9/publish"
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
POST /classification_tables/cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7/archive
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
X-Request-Id: eba3d94f-6586-41a0-a86b-af5acdd05628
200 OK
```


```json
{
  "data": {
    "id": "cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T09:44:33.557Z",
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
          "related": "/tags?filter[target_id_eq]=cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7",
          "self": "/classification_tables/cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/cfe5ff60-ea9e-4a56-a1cb-39f7a9abd4b7/archive"
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
X-Request-Id: 2fe6f7d5-7280-4fef-b503-73d57ca8e5de
201 Created
```


```json
{
  "data": {
    "id": "d73522a2-3b53-4d7a-b9d4-d7088dbd1d1b",
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
          "related": "/tags?filter[target_id_eq]=d73522a2-3b53-4d7a-b9d4-d7088dbd1d1b&filter[target_type_eq]=ClassificationTable",
          "self": "/classification_tables/d73522a2-3b53-4d7a-b9d4-d7088dbd1d1b/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=d73522a2-3b53-4d7a-b9d4-d7088dbd1d1b",
          "self": "/classification_tables/d73522a2-3b53-4d7a-b9d4-d7088dbd1d1b/relationships/classification_entries",
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
POST /classification_entries/d51feade-d368-43c7-86ee-4fa8c16be80d/relationships/tags
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
X-Request-Id: 581216d3-4ec0-414c-81de-24245cc7d713
201 Created
```


```json
{
  "data": {
    "id": "2143b14e-9520-4e56-a261-839db5325eb1",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/d51feade-d368-43c7-86ee-4fa8c16be80d/relationships/tags"
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
POST /classification_entries/5d92ff16-e051-4c5f-b9c4-39ea3c569953/relationships/tags
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
    "id": "4daab85c-2de3-4d23-a70c-216effc41794"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 7a431a73-5ae4-4ecd-afc9-ea74eb0dd7ef
201 Created
```


```json
{
  "data": {
    "id": "4daab85c-2de3-4d23-a70c-216effc41794",
    "type": "tag",
    "attributes": {
      "value": "Tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/5d92ff16-e051-4c5f-b9c4-39ea3c569953/relationships/tags"
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
DELETE /classification_entries/964a1978-294f-4231-a88d-2b23a21f76b1/relationships/tags/7fb04eb6-ebc3-4ede-9ca0-d1f974608b8a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ead92eb6-0119-493d-8140-d492571ab522
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
X-Request-Id: ae3f7b12-a5be-41b7-bdcb-01563ec993b1
200 OK
```


```json
{
  "data": [
    {
      "id": "c04da4ed-b151-4ba4-8924-160fd68bf354",
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
            "related": "/tags?filter[target_id_eq]=c04da4ed-b151-4ba4-8924-160fd68bf354&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/c04da4ed-b151-4ba4-8924-160fd68bf354/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=c04da4ed-b151-4ba4-8924-160fd68bf354",
            "self": "/classification_entries/c04da4ed-b151-4ba4-8924-160fd68bf354/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "4cb9d449-0169-414f-96a0-847eaf6a10b5",
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
            "related": "/tags?filter[target_id_eq]=4cb9d449-0169-414f-96a0-847eaf6a10b5&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/4cb9d449-0169-414f-96a0-847eaf6a10b5/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "c04da4ed-b151-4ba4-8924-160fd68bf354",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/4cb9d449-0169-414f-96a0-847eaf6a10b5"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=4cb9d449-0169-414f-96a0-847eaf6a10b5",
            "self": "/classification_entries/4cb9d449-0169-414f-96a0-847eaf6a10b5/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "82e81b10-b21a-4464-9d41-7ba5e02a4d0a",
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
            "related": "/tags?filter[target_id_eq]=82e81b10-b21a-4464-9d41-7ba5e02a4d0a&filter[target_type_eq]=ClassificationEntry",
            "self": "/classification_entries/82e81b10-b21a-4464-9d41-7ba5e02a4d0a/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=82e81b10-b21a-4464-9d41-7ba5e02a4d0a",
            "self": "/classification_entries/82e81b10-b21a-4464-9d41-7ba5e02a4d0a/relationships/classification_entries",
            "meta": {
              "count": 0
            }
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
GET /classification_entries/3e559f5b-23b6-408d-b5f7-21811a40e97c
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
X-Request-Id: 8c2c8a2a-6771-4997-a847-890b365d6ce7
200 OK
```


```json
{
  "data": {
    "id": "3e559f5b-23b6-408d-b5f7-21811a40e97c",
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
          "related": "/tags?filter[target_id_eq]=3e559f5b-23b6-408d-b5f7-21811a40e97c&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/3e559f5b-23b6-408d-b5f7-21811a40e97c/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=3e559f5b-23b6-408d-b5f7-21811a40e97c",
          "self": "/classification_entries/3e559f5b-23b6-408d-b5f7-21811a40e97c/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/3e559f5b-23b6-408d-b5f7-21811a40e97c"
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
PATCH /classification_entries/fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c",
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
X-Request-Id: cc94066d-52ca-4b30-bcca-cec88ad8fdf1
200 OK
```


```json
{
  "data": {
    "id": "fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c",
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
          "related": "/tags?filter[target_id_eq]=fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "0c76a5b4-0fad-4901-889d-ed69b9c9dfc2",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c",
          "self": "/classification_entries/fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/fee7a5cb-7af8-4c7f-ae0a-d14b14a0873c"
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
DELETE /classification_entries/090ca5cc-fc5f-4aac-afee-c1469c066cae
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f194c350-8703-4574-85b8-570ca2c3f8c6
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
POST /classification_tables/80702560-f773-46ea-a07e-755d53db108e/relationships/classification_entries
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
X-Request-Id: 80ab9969-0461-4aab-8e1b-10a964ed907b
201 Created
```


```json
{
  "data": {
    "id": "f617d203-c67c-4b51-af6a-9aac76224973",
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
          "related": "/tags?filter[target_id_eq]=f617d203-c67c-4b51-af6a-9aac76224973&filter[target_type_eq]=ClassificationEntry",
          "self": "/classification_entries/f617d203-c67c-4b51-af6a-9aac76224973/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=f617d203-c67c-4b51-af6a-9aac76224973",
          "self": "/classification_entries/f617d203-c67c-4b51-af6a-9aac76224973/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/80702560-f773-46ea-a07e-755d53db108e/relationships/classification_entries"
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
X-Request-Id: e3ddad33-2ec4-45c2-b25c-8d5f9414f931
200 OK
```


```json
{
  "data": [
    {
      "id": "30a98ed9-a3b0-4b84-a600-3e8fd24edc19",
      "type": "syntax",
      "attributes": {
        "account_id": "611dea66-4d2a-4fb1-bfd9-d956b36f35ec",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 266f7cd7a211",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=30a98ed9-a3b0-4b84-a600-3e8fd24edc19",
            "self": "/syntaxes/30a98ed9-a3b0-4b84-a600-3e8fd24edc19/relationships/syntax_elements"
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
GET /syntaxes/d5316940-9bdb-477c-b862-a2ff687eeee6
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
X-Request-Id: a53f9607-23e3-4c27-bc46-7de1940b8234
200 OK
```


```json
{
  "data": {
    "id": "d5316940-9bdb-477c-b862-a2ff687eeee6",
    "type": "syntax",
    "attributes": {
      "account_id": "4ddfb74f-4391-4f0e-8e9a-5bae48a60fa8",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 9519acdf95ed",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=d5316940-9bdb-477c-b862-a2ff687eeee6",
          "self": "/syntaxes/d5316940-9bdb-477c-b862-a2ff687eeee6/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/d5316940-9bdb-477c-b862-a2ff687eeee6"
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
X-Request-Id: 8bac04ae-7ed0-46f2-b961-4aeab39cac74
201 Created
```


```json
{
  "data": {
    "id": "514a93e5-4310-45c6-8dfa-3e55fca41a89",
    "type": "syntax",
    "attributes": {
      "account_id": "5a757bce-414c-45ca-ba08-af44ca7c3ddd",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=514a93e5-4310-45c6-8dfa-3e55fca41a89",
          "self": "/syntaxes/514a93e5-4310-45c6-8dfa-3e55fca41a89/relationships/syntax_elements"
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
PATCH /syntaxes/87e53039-3d33-48e6-baa1-72d7e0d000ad
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "87e53039-3d33-48e6-baa1-72d7e0d000ad",
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
X-Request-Id: dcd08196-a246-4499-9468-bf6677e11e0a
200 OK
```


```json
{
  "data": {
    "id": "87e53039-3d33-48e6-baa1-72d7e0d000ad",
    "type": "syntax",
    "attributes": {
      "account_id": "32979a90-3185-4037-84e0-b46f4697597d",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=87e53039-3d33-48e6-baa1-72d7e0d000ad",
          "self": "/syntaxes/87e53039-3d33-48e6-baa1-72d7e0d000ad/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/87e53039-3d33-48e6-baa1-72d7e0d000ad"
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
DELETE /syntaxes/b616a38b-f071-41d9-95a4-cd61f9df74b3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f7a49c8a-aef0-446b-be54-0d12b7fad5d1
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
POST /syntaxes/530e252d-1c6a-49c5-9b82-8d0354c4b4ff/publish
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
X-Request-Id: fc7d9c6f-24b7-4f9c-91aa-aafafe27934f
200 OK
```


```json
{
  "data": {
    "id": "530e252d-1c6a-49c5-9b82-8d0354c4b4ff",
    "type": "syntax",
    "attributes": {
      "account_id": "47641602-838b-4a1f-98fe-128c0a4120d5",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 645882522d7a",
      "published": true,
      "published_at": "2020-02-12T09:44:41.281Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=530e252d-1c6a-49c5-9b82-8d0354c4b4ff",
          "self": "/syntaxes/530e252d-1c6a-49c5-9b82-8d0354c4b4ff/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/530e252d-1c6a-49c5-9b82-8d0354c4b4ff/publish"
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
POST /syntaxes/beb91ab5-6502-4f73-982b-eea220a4252a/archive
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
X-Request-Id: aeb9e1bd-97f8-4802-a40d-0874d6922904
200 OK
```


```json
{
  "data": {
    "id": "beb91ab5-6502-4f73-982b-eea220a4252a",
    "type": "syntax",
    "attributes": {
      "account_id": "227f4d20-f7a7-4c19-a14c-97b897f37dc3",
      "archived": true,
      "archived_at": "2020-02-12T09:44:41.840Z",
      "description": "Description",
      "name": "Syntax a02719957293",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=beb91ab5-6502-4f73-982b-eea220a4252a",
          "self": "/syntaxes/beb91ab5-6502-4f73-982b-eea220a4252a/relationships/syntax_elements"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/beb91ab5-6502-4f73-982b-eea220a4252a/archive"
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
X-Request-Id: bc7dc2f0-51c7-432d-99dc-d0774332fe86
200 OK
```


```json
{
  "data": [
    {
      "id": "ed483b56-a9b7-4c48-ae79-ee4f8275a07a",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "3a3b5546-6c0f-4806-b263-7d3abee33f36",
        "hex_color": "94d3b5",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 392457298339"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/01e58a37-eb1e-473c-80d1-52c0965a51d9"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/3a3b5546-6c0f-4806-b263-7d3abee33f36",
            "self": "/syntax_elements/ed483b56-a9b7-4c48-ae79-ee4f8275a07a/relationships/classification_table"
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
GET /syntax_elements/24668759-1456-42cf-b8c8-d95bc278874e
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
X-Request-Id: 82bd7ffe-9e7a-4132-afd5-cacd12bd60e2
200 OK
```


```json
{
  "data": {
    "id": "24668759-1456-42cf-b8c8-d95bc278874e",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "749aa342-264d-4716-87d9-f6cef6fb7571",
      "hex_color": "db84dc",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 8639a03147a5"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/75b0bb37-ff12-4fbf-b570-f460d6159188"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/749aa342-264d-4716-87d9-f6cef6fb7571",
          "self": "/syntax_elements/24668759-1456-42cf-b8c8-d95bc278874e/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/24668759-1456-42cf-b8c8-d95bc278874e"
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
POST /syntaxes/77cc3050-e04c-49bd-aa7e-252302d698fc/relationships/syntax_elements
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
          "id": "f49d2554-26c2-4c7b-9c82-6404e7e47d52"
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
X-Request-Id: 97719673-43c7-4d2b-bcbd-5f22aabeb7ba
201 Created
```


```json
{
  "data": {
    "id": "3bc80d48-de68-4dcb-9ae8-d2b838e01c2d",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "f49d2554-26c2-4c7b-9c82-6404e7e47d52",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/77cc3050-e04c-49bd-aa7e-252302d698fc"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/f49d2554-26c2-4c7b-9c82-6404e7e47d52",
          "self": "/syntax_elements/3bc80d48-de68-4dcb-9ae8-d2b838e01c2d/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/77cc3050-e04c-49bd-aa7e-252302d698fc/relationships/syntax_elements"
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
PATCH /syntax_elements/8acfedee-bda8-4c19-bcdb-91859e787d7d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "8acfedee-bda8-4c19-bcdb-91859e787d7d",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "6fb21985-645f-49ab-a915-a81995c0e91f"
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
X-Request-Id: 332d55be-1a4c-4ebd-9af4-ebc33ee3a3e8
200 OK
```


```json
{
  "data": {
    "id": "8acfedee-bda8-4c19-bcdb-91859e787d7d",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "6fb21985-645f-49ab-a915-a81995c0e91f",
      "hex_color": "94b6ee",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/3a18fd5b-73b5-473b-9333-142f64220403"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/6fb21985-645f-49ab-a915-a81995c0e91f",
          "self": "/syntax_elements/8acfedee-bda8-4c19-bcdb-91859e787d7d/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/8acfedee-bda8-4c19-bcdb-91859e787d7d"
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
DELETE /syntax_elements/1254ec38-2783-49ce-bc02-169dfe3d2abd
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9010d890-9abe-4998-a1d6-f2332edb7ae1
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
PATCH /syntax_elements/8d5b5ce2-57e8-4d13-9852-57414ba26d8b/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "8a0e7e50-ee74-4a86-b49e-250bbda080ab",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c5574253-fbd7-4c71-b616-82dcce4cdcd4
200 OK
```


```json
{
  "data": {
    "id": "8d5b5ce2-57e8-4d13-9852-57414ba26d8b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "8a0e7e50-ee74-4a86-b49e-250bbda080ab",
      "hex_color": "7307ca",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 019b16e37b66"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/3b6d39cd-d62a-4c18-b85a-2deb9c03e08a"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/8a0e7e50-ee74-4a86-b49e-250bbda080ab",
          "self": "/syntax_elements/8d5b5ce2-57e8-4d13-9852-57414ba26d8b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/8d5b5ce2-57e8-4d13-9852-57414ba26d8b/relationships/classification_table"
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
DELETE /syntax_elements/459e1cd8-4633-4860-844a-325effad5609/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f4039ea7-8c87-48f2-936d-1db9bfb2381f
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
GET /syntax_nodes/b064517f-d767-4d99-ada8-e68620c70d4c?depth=2
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
X-Request-Id: 9c313d5c-95d8-48e7-9e74-f3eefecb1d79
200 OK
```


```json
{
  "data": {
    "id": "b064517f-d767-4d99-ada8-e68620c70d4c",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/c40ee837-8672-4dec-9883-a64a6c8c980e"
        }
      },
      "components": {
        "data": [
          {
            "id": "0c3a99bd-ffdb-4e2d-b081-b5b349bf24cf",
            "type": "syntax_node"
          },
          {
            "id": "37a4f338-8032-4cef-a77c-f43010ab22ce",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/b064517f-d767-4d99-ada8-e68620c70d4c/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/b064517f-d767-4d99-ada8-e68620c70d4c?depth=2"
  },
  "included": [
    {
      "id": "37a4f338-8032-4cef-a77c-f43010ab22ce",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c40ee837-8672-4dec-9883-a64a6c8c980e"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/37a4f338-8032-4cef-a77c-f43010ab22ce/relationships/components"
          }
        }
      }
    },
    {
      "id": "0c3a99bd-ffdb-4e2d-b081-b5b349bf24cf",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c40ee837-8672-4dec-9883-a64a6c8c980e"
          }
        },
        "components": {
          "data": [
            {
              "id": "b9cfc165-54af-433b-a98a-6b6d4fbecb6b",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/0c3a99bd-ffdb-4e2d-b081-b5b349bf24cf/relationships/components"
          }
        }
      }
    },
    {
      "id": "b9cfc165-54af-433b-a98a-6b6d4fbecb6b",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c40ee837-8672-4dec-9883-a64a6c8c980e"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/b9cfc165-54af-433b-a98a-6b6d4fbecb6b/relationships/components"
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
POST /syntax_nodes/7118ea73-445c-4a81-8695-d32180eec9a9/relationships/components
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
X-Request-Id: 5ff2c476-a648-4988-af95-2451ccad004d
201 Created
```


```json
{
  "data": {
    "id": "8e84692f-8d1b-4991-a8e7-e8712ea27d8a",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/20934169-abb1-4f9e-974b-82b56eea9f71"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/8e84692f-8d1b-4991-a8e7-e8712ea27d8a/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/7118ea73-445c-4a81-8695-d32180eec9a9/relationships/components"
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
PATCH /syntax_nodes/b2b59332-a2d2-475e-b545-858bb97f4881
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "b2b59332-a2d2-475e-b545-858bb97f4881",
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
X-Request-Id: e5ff5e48-aba7-4476-a7ca-322e343cbea4
200 OK
```


```json
{
  "data": {
    "id": "b2b59332-a2d2-475e-b545-858bb97f4881",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/87f287a3-89d6-453e-875b-a765a779bbac"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/b2b59332-a2d2-475e-b545-858bb97f4881/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/b2b59332-a2d2-475e-b545-858bb97f4881"
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
DELETE /syntax_nodes/69ef9b48-0760-4e65-aee1-4a754fac00b9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 6b78267d-239e-44b5-9db5-baa459da3aff
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
X-Request-Id: 21c04785-d5fe-48db-b849-71832bcdb890
200 OK
```


```json
{
  "data": [
    {
      "id": "2aa1562f-e187-4258-ace7-445b39302a00",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-02-12T09:44:47.949Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=2aa1562f-e187-4258-ace7-445b39302a00",
            "self": "/progress_models/2aa1562f-e187-4258-ace7-445b39302a00/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "2453875d-cd55-46a5-bb29-af88bb25643c",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=2453875d-cd55-46a5-bb29-af88bb25643c",
            "self": "/progress_models/2453875d-cd55-46a5-bb29-af88bb25643c/relationships/progress_steps"
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
GET /progress_models/033e6841-aef6-4816-9826-f4005cc90fcf
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
X-Request-Id: ec28d156-2c27-4def-ae09-8fbaeaf4e4cd
200 OK
```


```json
{
  "data": {
    "id": "033e6841-aef6-4816-9826-f4005cc90fcf",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-02-12T09:44:48.412Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=033e6841-aef6-4816-9826-f4005cc90fcf",
          "self": "/progress_models/033e6841-aef6-4816-9826-f4005cc90fcf/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/033e6841-aef6-4816-9826-f4005cc90fcf"
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
PATCH /progress_models/a94830b5-36b0-435e-8afd-de2ea7b7ba43
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "a94830b5-36b0-435e-8afd-de2ea7b7ba43",
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
X-Request-Id: 7ddcfec3-990f-46ca-b16b-745c048d8731
200 OK
```


```json
{
  "data": {
    "id": "a94830b5-36b0-435e-8afd-de2ea7b7ba43",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=a94830b5-36b0-435e-8afd-de2ea7b7ba43",
          "self": "/progress_models/a94830b5-36b0-435e-8afd-de2ea7b7ba43/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/a94830b5-36b0-435e-8afd-de2ea7b7ba43"
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
DELETE /progress_models/39681b55-bf82-43b7-a37a-36eaf88afb7f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 779807ed-4ea2-4640-bc3e-1c31ef343975
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
POST /progress_models/b777650d-176d-4149-9c84-1a27e47b5372/publish
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
X-Request-Id: 04ece507-7e48-48be-a380-1be522e9c471
200 OK
```


```json
{
  "data": {
    "id": "b777650d-176d-4149-9c84-1a27e47b5372",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-02-12T09:44:49.942Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=b777650d-176d-4149-9c84-1a27e47b5372",
          "self": "/progress_models/b777650d-176d-4149-9c84-1a27e47b5372/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/b777650d-176d-4149-9c84-1a27e47b5372/publish"
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
POST /progress_models/f4347529-327c-4e09-acb0-0064a9008af0/archive
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
X-Request-Id: def4ab34-d5d1-452a-8651-5c234146f98b
200 OK
```


```json
{
  "data": {
    "id": "f4347529-327c-4e09-acb0-0064a9008af0",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-02-12T09:44:50.473Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=f4347529-327c-4e09-acb0-0064a9008af0",
          "self": "/progress_models/f4347529-327c-4e09-acb0-0064a9008af0/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/f4347529-327c-4e09-acb0-0064a9008af0/archive"
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
X-Request-Id: 1a234be6-c0ca-48c6-ad5d-fe88aac06c9e
201 Created
```


```json
{
  "data": {
    "id": "d62918ec-e0b4-4fa3-bb81-f6eeec5abf45",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=d62918ec-e0b4-4fa3-bb81-f6eeec5abf45",
          "self": "/progress_models/d62918ec-e0b4-4fa3-bb81-f6eeec5abf45/relationships/progress_steps"
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
X-Request-Id: 8b6b1aac-53a4-4d3e-ae40-2d321c9fcaac
200 OK
```


```json
{
  "data": [
    {
      "id": "f2d2061f-711e-4ee7-ac85-70f238c1702a",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/8f57bd16-0ebe-472c-8bf9-068f62ebe181"
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
GET /progress_steps/c25f5357-b981-472b-9d4b-342f1d993e67
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
X-Request-Id: 22e1cbc1-ad8e-4c65-8044-50dc1faad38d
200 OK
```


```json
{
  "data": {
    "id": "c25f5357-b981-472b-9d4b-342f1d993e67",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/0fe9dd79-2579-47fe-9002-4dbf21ec29c7"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/c25f5357-b981-472b-9d4b-342f1d993e67"
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
PATCH /progress_steps/9e032573-943c-4bd2-b234-6f119dcd5931
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "9e032573-943c-4bd2-b234-6f119dcd5931",
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
X-Request-Id: d5021edf-3026-46fd-8c11-09106b6e84bd
200 OK
```


```json
{
  "data": {
    "id": "9e032573-943c-4bd2-b234-6f119dcd5931",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/dfb16c20-a7ec-4cd7-80da-fa50d37efb9e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/9e032573-943c-4bd2-b234-6f119dcd5931"
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
DELETE /progress_steps/598c8eb9-4fb7-4809-851b-39e2b8fceb6d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f1c77eb0-2d54-4400-a515-968ea1707b1f
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
POST /progress_models/0339a732-d3fa-4978-9b4d-963fb9492c47/relationships/progress_steps
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
X-Request-Id: d5e81125-1428-43c0-9726-ace3c5179d0f
201 Created
```


```json
{
  "data": {
    "id": "2f5e2865-8ecf-48fa-8f7e-466928eb5755",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/0339a732-d3fa-4978-9b4d-963fb9492c47"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/0339a732-d3fa-4978-9b4d-963fb9492c47/relationships/progress_steps"
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
X-Request-Id: 75d78713-5578-40d6-90aa-75a40cb32541
200 OK
```


```json
{
  "data": [
    {
      "id": "825692cd-ba3d-4d20-a31f-d99e9515c607",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/154fc2c1-2811-438e-8682-2c8eafcbd523"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/4678ee8e-5b3c-4d0a-a600-2b8a16231155"
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
GET /progress/fe6c2191-4f0c-477d-8aa9-89a29ecad671
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
X-Request-Id: 709221ec-e33f-4e68-ad3a-7a3218f978fa
200 OK
```


```json
{
  "data": {
    "id": "fe6c2191-4f0c-477d-8aa9-89a29ecad671",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/54836f34-5b10-45dd-8142-b85e8de14cf0"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/55835850-31b8-4cee-84ec-0f144088536c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/fe6c2191-4f0c-477d-8aa9-89a29ecad671"
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
DELETE /progress/2fceb072-8dc8-4797-b1b5-8aba93fd91a9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9f95d46c-7386-470c-9ac2-2795db24f520
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
          "id": "8855c4a1-ac50-4822-842b-65a8e346e6dc"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "eb7cfef9-425a-4d21-9fd3-1b761a9f830b"
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
X-Request-Id: 23b396dd-1a14-4242-8723-035c68e4fc38
201 Created
```


```json
{
  "data": {
    "id": "757e501f-f13b-42f9-8922-242336e5fd38",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/8855c4a1-ac50-4822-842b-65a8e346e6dc"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/eb7cfef9-425a-4d21-9fd3-1b761a9f830b"
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
X-Request-Id: 7efa13b3-e7a3-451a-b4d2-88ac1a35d6a7
200 OK
```


```json
{
  "data": [
    {
      "id": "d86ff2f9-663f-4d68-94ce-7e76a59e9cec",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "ef74d1ad-587e-4cd5-b695-ef16652eb9a1"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/ef74d1ad-587e-4cd5-b695-ef16652eb9a1"
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
GET /projects/7ab393ca-fcd4-4824-be67-579489ec649b/relationships/project_setting
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
X-Request-Id: 23029f0c-bc0e-455a-92b4-8f85bf6da6d4
200 OK
```


```json
{
  "data": {
    "id": "be7dc2d8-c8b9-4fe2-953e-151936e9ae7a",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "7ab393ca-fcd4-4824-be67-579489ec649b"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/7ab393ca-fcd4-4824-be67-579489ec649b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7ab393ca-fcd4-4824-be67-579489ec649b/relationships/project_setting"
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
PATCH /projects/ba8f948c-b8ed-4e49-aaf9-a9817aaa5f46/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "ba8f948c-b8ed-4e49-aaf9-a9817aaa5f46",
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
X-Request-Id: 6fe1a3ba-890b-4560-b3b2-66cfa02ca6d0
200 OK
```


```json
{
  "data": {
    "id": "c59a2a22-0277-4f39-9839-be2952783043",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "ba8f948c-b8ed-4e49-aaf9-a9817aaa5f46"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/ba8f948c-b8ed-4e49-aaf9-a9817aaa5f46"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/ba8f948c-b8ed-4e49-aaf9-a9817aaa5f46/relationships/project_setting"
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
X-Request-Id: 93d3c61c-d4e9-465f-b01c-6ab98a86cff0
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
X-Request-Id: 96b2de14-6d9a-497c-85d8-7ce6d4d92bc4
200 OK
```


```json
{
  "data": {
    "id": "4b0e33a8-3422-4c3f-a551-69924b8c3104",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "8a38fe0d-8040-498e-a81e-0453a8699d53"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/8a38fe0d-8040-498e-a81e-0453a8699d53"
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
X-Request-Id: aff14170-9481-4de1-905c-55d8cbcbd7a8
200 OK
```


```json
{
  "data": {
    "id": "3babcfa8-d23c-44f2-ac91-38742d2ba41a",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "be86345c-6866-4dc1-87fd-c6aaf15b841e"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/be86345c-6866-4dc1-87fd-c6aaf15b841e"
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

<aside class="warning">
  We only support this endpoint for <code>from_type</code> and <code>to_type</code> which are
  stored in the Neo4j database. We're currently working on making this available for all data
  types.
</aside>


## Look up path


### Request

#### Endpoint

```plaintext
GET /utils/path/from/object_occurrence/eee638f2-1ad6-4afa-90f9-02c082a5f66e/to/object_occurrence/31cba164-d415-4d99-a132-bf0df5705de2
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
X-Request-Id: 3fbee044-703d-49c0-a34a-7fa012126bbd
200 OK
```


```json
[
  {
    "id": "eee638f2-1ad6-4afa-90f9-02c082a5f66e",
    "type": "object_occurrence"
  },
  {
    "id": "91d65724-7172-42f5-8330-ad592060be43",
    "type": "object_occurrence"
  },
  {
    "id": "68ff950d-d44a-444f-b64f-9fa984d3f91e",
    "type": "object_occurrence"
  },
  {
    "id": "4177afd9-c3ca-4635-829e-d375f8ab8475",
    "type": "object_occurrence"
  },
  {
    "id": "d95a1cfe-e245-4f1f-9f03-ac696b3ec155",
    "type": "object_occurrence"
  },
  {
    "id": "e87bdfc3-0a9e-4ae6-8740-512ab8e1ec6c",
    "type": "object_occurrence"
  },
  {
    "id": "31cba164-d415-4d99-a132-bf0df5705de2",
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
X-Request-Id: 707fa4ea-6dba-4ce4-a150-76b818c95f01
200 OK
```


```json
{
  "data": [
    {
      "id": "c4131b83-940c-4406-9789-db1b6ccb74f9",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/682d5f38-a5d4-4ae1-8eee-4ed3a23cda5d"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/2e5109c0-d3fe-4fa5-a525-bed2a994bb21"
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
X-Request-Id: 70b90e80-e65e-4f2a-ad92-fa72d3781073
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



