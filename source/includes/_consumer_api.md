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
X-Request-Id: f4b13e1a-7c54-4659-b989-949c980190b4
200 OK
```


```json
{
  "data": {
    "id": "be6f0122-f999-4f32-8840-ead5085ffd79",
    "type": "account",
    "attributes": {
      "name": "Account f2d2ac93b5c4"
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
X-Request-Id: 63bb58c1-abb1-42d1-bc11-e803e1bb88f5
200 OK
```


```json
{
  "data": {
    "id": "843cb303-415c-4c26-94c4-08bfcb09a49c",
    "type": "account",
    "attributes": {
      "name": "Account 08179aea658a"
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
    "id": "61342e1e-445b-4c20-b94d-ac196cf39dea",
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
X-Request-Id: 1b8f452a-b9a9-4aa8-9214-4d9471c5b453
200 OK
```


```json
{
  "data": {
    "id": "61342e1e-445b-4c20-b94d-ac196cf39dea",
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


## Add new tag

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /projects/accc8c50-2079-4806-936d-2a22f878bb9d/relationships/tags
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


| Name | Description |
|:-----|:------------|
| data[attributes][value] *required* | Tag value |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: d9f43e66-b016-4623-8a83-ad4d2df8ffc3
201 Created
```


```json
{
  "data": {
    "id": "b8847c3e-6778-4a4b-b389-770a197e85b0",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/accc8c50-2079-4806-936d-2a22f878bb9d/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Add existing tag

Adds an existing tag to the resource


### Request

#### Endpoint

```plaintext
POST /projects/8cb26768-450e-4541-aa2a-769460e8368e/relationships/tags
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
    "id": "4b453f7b-d63f-42da-852e-625496c0be60"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: a9ee0c1e-47a4-42aa-a1bd-ff6aedd168e5
201 Created
```


```json
{
  "data": {
    "id": "4b453f7b-d63f-42da-852e-625496c0be60",
    "type": "tag",
    "attributes": {
      "value": "tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/8cb26768-450e-4541-aa2a-769460e8368e/relationships/tags"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Project name |
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /projects/2395cf9e-f997-4f37-98ae-1d12e7a90f78/relationships/tags/4da4d78b-978d-4bb1-ac61-50e288a53efe
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 92dce269-b77a-44a1-b62c-40e7e33fb44e
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
X-Request-Id: bcc3e1a7-9b98-4609-b8b2-e0ea73e24fff
200 OK
```


```json
{
  "data": [
    {
      "id": "b41b2b1b-7626-49df-84be-e53c36f7df56",
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
            "related": "/tags?filter[target_id_eq]=b41b2b1b-7626-49df-84be-e53c36f7df56&filter[target_type_eq]=project",
            "self": "/projects/b41b2b1b-7626-49df-84be-e53c36f7df56/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=b41b2b1b-7626-49df-84be-e53c36f7df56",
            "self": "/projects/b41b2b1b-7626-49df-84be-e53c36f7df56/relationships/contexts"
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
GET /projects/c3eb58ce-a974-4737-9921-abab9b8908a3
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
X-Request-Id: fa2a96cc-2fbb-4756-a1ea-048bf8f7ede2
200 OK
```


```json
{
  "data": {
    "id": "c3eb58ce-a974-4737-9921-abab9b8908a3",
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
          "related": "/tags?filter[target_id_eq]=c3eb58ce-a974-4737-9921-abab9b8908a3&filter[target_type_eq]=project",
          "self": "/projects/c3eb58ce-a974-4737-9921-abab9b8908a3/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=c3eb58ce-a974-4737-9921-abab9b8908a3",
          "self": "/projects/c3eb58ce-a974-4737-9921-abab9b8908a3/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/c3eb58ce-a974-4737-9921-abab9b8908a3"
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
PATCH /projects/394d2523-66bb-4971-b9eb-9fbb0a876c0c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "394d2523-66bb-4971-b9eb-9fbb0a876c0c",
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
X-Request-Id: 9a96512f-1df5-4b73-96dc-dcd893d5061c
200 OK
```


```json
{
  "data": {
    "id": "394d2523-66bb-4971-b9eb-9fbb0a876c0c",
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
          "related": "/tags?filter[target_id_eq]=394d2523-66bb-4971-b9eb-9fbb0a876c0c&filter[target_type_eq]=project",
          "self": "/projects/394d2523-66bb-4971-b9eb-9fbb0a876c0c/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=394d2523-66bb-4971-b9eb-9fbb0a876c0c",
          "self": "/projects/394d2523-66bb-4971-b9eb-9fbb0a876c0c/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/394d2523-66bb-4971-b9eb-9fbb0a876c0c"
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
POST /projects/756312c5-2b76-4792-bece-5b517d919608/archive
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
X-Request-Id: 289cf80e-2d65-4e83-8722-55d06d83b69f
200 OK
```


```json
{
  "data": {
    "id": "756312c5-2b76-4792-bece-5b517d919608",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-03-23T19:03:39.748Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=756312c5-2b76-4792-bece-5b517d919608&filter[target_type_eq]=project",
          "self": "/projects/756312c5-2b76-4792-bece-5b517d919608/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=756312c5-2b76-4792-bece-5b517d919608",
          "self": "/projects/756312c5-2b76-4792-bece-5b517d919608/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/756312c5-2b76-4792-bece-5b517d919608/archive"
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
DELETE /projects/fa60df54-33ae-40bc-86c6-95f8eef67bb6
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 36268dee-b7c7-4aba-96c7-c910936a8add
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

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /contexts/25ed1933-d396-4eb0-8572-2f8be70cbd16/relationships/tags
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


| Name | Description |
|:-----|:------------|
| data[attributes][value] *required* | Tag value |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 96d3e5ba-a59a-4956-b924-b84e14678535
201 Created
```


```json
{
  "data": {
    "id": "51d02770-9cda-43e5-ad52-8e79f83c469d",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/25ed1933-d396-4eb0-8572-2f8be70cbd16/relationships/tags"
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
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Add existing tag

Adds an existing tag to the resource


### Request

#### Endpoint

```plaintext
POST /contexts/b241bb00-032c-4d28-9bc2-2c8d78c750f3/relationships/tags
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
    "id": "ee7b2231-933d-45ab-bf7b-e9ce20d527a8"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 4c6f5558-1844-4a84-bd76-18ec4d4d2a2d
201 Created
```


```json
{
  "data": {
    "id": "ee7b2231-933d-45ab-bf7b-e9ce20d527a8",
    "type": "tag",
    "attributes": {
      "value": "tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/b241bb00-032c-4d28-9bc2-2c8d78c750f3/relationships/tags"
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
| data[type] | Resource type |
| data[id] | Resource ID |
| data[attributes][value] | tag value (always lowercase) |


## Remove existing tag


### Request

#### Endpoint

```plaintext
DELETE /contexts/56e66e79-f368-4f4b-9aa9-dd2beabcaf06/relationships/tags/98a0e117-7d3a-4dd7-bc90-d7256359fa4c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: b47c7286-2a56-47be-9539-980cc0701376
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
X-Request-Id: bd78eeed-be31-4818-93ac-b8f68bb9e620
200 OK
```


```json
{
  "data": [
    {
      "id": "ed76b2e2-ee52-4050-930d-7df4ef6ff384",
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
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=ed76b2e2-ee52-4050-930d-7df4ef6ff384&filter[target_type_eq]=context",
            "self": "/contexts/ed76b2e2-ee52-4050-930d-7df4ef6ff384/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/6e8a0dcc-2ea4-4ebb-a806-33724044ab05"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/ae398fd0-e66d-4e0e-a42f-90f1cd1ada96"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/3e2a1a49-111e-4a1b-b5e4-7aaf398ad24a"
          }
        }
      }
    },
    {
      "id": "1743f483-0ef5-4bbd-aeeb-7b97fa4b1a25",
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
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=1743f483-0ef5-4bbd-aeeb-7b97fa4b1a25&filter[target_type_eq]=context",
            "self": "/contexts/1743f483-0ef5-4bbd-aeeb-7b97fa4b1a25/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/6e8a0dcc-2ea4-4ebb-a806-33724044ab05"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/73f29002-45f7-476e-8383-4e3447071ce4"
          }
        },
        "syntax": {
          "links": {
            "related": "/syntaxes/3e2a1a49-111e-4a1b-b5e4-7aaf398ad24a"
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
GET /contexts/4d9b0b2d-9974-4f4c-a7db-278d2d99c419
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
X-Request-Id: bc9b0ce3-bd11-48ff-ae29-d63273e7a4f1
200 OK
```


```json
{
  "data": {
    "id": "4d9b0b2d-9974-4f4c-a7db-278d2d99c419",
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
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=4d9b0b2d-9974-4f4c-a7db-278d2d99c419&filter[target_type_eq]=context",
          "self": "/contexts/4d9b0b2d-9974-4f4c-a7db-278d2d99c419/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/b3220b34-4d6e-4587-8291-c18c90829321"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/fde677d9-b1d2-40d5-9beb-82a5a8f85274"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/d305e98f-40c7-4c1f-a6c3-def8870d2f82"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/4d9b0b2d-9974-4f4c-a7db-278d2d99c419"
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
PATCH /contexts/a2a29aff-ab4c-44c0-891d-627eab755d14
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "a2a29aff-ab4c-44c0-891d-627eab755d14",
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
X-Request-Id: 9f5351c0-8601-4e78-bdfe-7c297f96fac4
200 OK
```


```json
{
  "data": {
    "id": "a2a29aff-ab4c-44c0-891d-627eab755d14",
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
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=a2a29aff-ab4c-44c0-891d-627eab755d14&filter[target_type_eq]=context",
          "self": "/contexts/a2a29aff-ab4c-44c0-891d-627eab755d14/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/55a43f28-d065-4dd8-9902-53acc26ed3d2"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/41a534e7-0c7b-43ac-b298-d02c6697d7da"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/8e3f19bd-2676-437e-9246-136fa93707f6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/a2a29aff-ab4c-44c0-891d-627eab755d14"
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
POST /projects/53f64a19-1d50-4256-9272-aa4f1730f026/relationships/contexts
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
          "id": "4687b542-6b35-4c76-a41b-7090b5eaf2e8"
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
X-Request-Id: dc19a1af-9c1d-4eb5-988c-5c2e30aad927
201 Created
```


```json
{
  "data": {
    "id": "81cdeca1-ebcd-4b19-9dce-aad3e16d35c2",
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
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=81cdeca1-ebcd-4b19-9dce-aad3e16d35c2&filter[target_type_eq]=context",
          "self": "/contexts/81cdeca1-ebcd-4b19-9dce-aad3e16d35c2/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/53f64a19-1d50-4256-9272-aa4f1730f026"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/b31e7fc0-f6f7-4a7c-beae-732beccfffee"
        }
      },
      "syntax": {
        "links": {
          "related": "/syntaxes/4687b542-6b35-4c76-a41b-7090b5eaf2e8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/53f64a19-1d50-4256-9272-aa4f1730f026/relationships/contexts"
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
POST /contexts/0bb2352e-d171-42a3-9cab-7bb9c29915fa/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/e3ba4d75e3e6c11b45583f89
Content-Type: text/html; charset=utf-8
X-Request-Id: 15e53fc7-2b62-4b90-9afe-3a3a5f00d835
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/e3ba4d75e3e6c11b45583f89">redirected</a>.</body></html>
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
DELETE /contexts/af6cc064-35a5-422d-8bfd-8e8ab458b081
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 65d996b1-22c1-4d8c-a251-0b8bf9ad7a1c
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
POST /object_occurrences/d2b48b4d-45c9-4f78-ad0c-752f824b44e6/relationships/tags
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
X-Request-Id: b1abf0dd-9d80-4d89-9d2e-2089c1229cda
201 Created
```


```json
{
  "data": {
    "id": "c6bfbdc9-b5bf-497e-841c-ea925c181fdc",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/d2b48b4d-45c9-4f78-ad0c-752f824b44e6/relationships/tags"
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
POST /object_occurrences/f1ea1af2-cae9-47f6-a953-bfb3737fb1b2/relationships/tags
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
    "id": "584dd2db-5d31-43d1-9366-5133237038c7"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 3e9e050d-b696-4070-a14d-aceb7f6a00ce
201 Created
```


```json
{
  "data": {
    "id": "584dd2db-5d31-43d1-9366-5133237038c7",
    "type": "tag",
    "attributes": {
      "value": "tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f1ea1af2-cae9-47f6-a953-bfb3737fb1b2/relationships/tags"
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
DELETE /object_occurrences/e7d0d4db-ff05-4a73-97b4-58947749da08/relationships/tags/81302b7c-ca91-476d-9e75-42f3833d539c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: df326815-b1ff-4b9c-b034-a4e547ef5953
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



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 16bf043a-e449-47ba-b606-a7c2d73b6818
200 OK
```


```json
{
  "data": [
    {
      "id": "22b53ef6-7941-4050-81f6-4196c5442b14",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=22b53ef6-7941-4050-81f6-4196c5442b14&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/22b53ef6-7941-4050-81f6-4196c5442b14/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/5debdf4a-e9ad-47d4-ad97-771a786fd718"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/e4562c35-5233-4bb2-96fc-9cb6c053d0ee",
            "self": "/object_occurrences/22b53ef6-7941-4050-81f6-4196c5442b14/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/22b53ef6-7941-4050-81f6-4196c5442b14/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=22b53ef6-7941-4050-81f6-4196c5442b14"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=22b53ef6-7941-4050-81f6-4196c5442b14"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=22b53ef6-7941-4050-81f6-4196c5442b14"
          }
        }
      }
    },
    {
      "id": "0428762f-bf5a-41d2-aa2e-e4291daa0915",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=0428762f-bf5a-41d2-aa2e-e4291daa0915&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/0428762f-bf5a-41d2-aa2e-e4291daa0915/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/5debdf4a-e9ad-47d4-ad97-771a786fd718"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/e4562c35-5233-4bb2-96fc-9cb6c053d0ee",
            "self": "/object_occurrences/0428762f-bf5a-41d2-aa2e-e4291daa0915/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/0428762f-bf5a-41d2-aa2e-e4291daa0915/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=0428762f-bf5a-41d2-aa2e-e4291daa0915"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=0428762f-bf5a-41d2-aa2e-e4291daa0915"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=0428762f-bf5a-41d2-aa2e-e4291daa0915"
          }
        }
      }
    },
    {
      "id": "8b33c52a-6589-42bc-b8c6-2835fcc32734",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 8811a3c3a438",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=8b33c52a-6589-42bc-b8c6-2835fcc32734&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/8b33c52a-6589-42bc-b8c6-2835fcc32734/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/7815633b-1b70-49d3-8dfb-c2a3ec130dad"
          }
        },
        "components": {
          "data": [
            {
              "id": "5bc3616b-55e7-4647-8414-8088354b0c81",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/8b33c52a-6589-42bc-b8c6-2835fcc32734/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=8b33c52a-6589-42bc-b8c6-2835fcc32734"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=8b33c52a-6589-42bc-b8c6-2835fcc32734"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=8b33c52a-6589-42bc-b8c6-2835fcc32734"
          }
        }
      }
    },
    {
      "id": "2d3b915b-1714-466c-9a9b-44468a155ebe",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 57c5128fcd37",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=2d3b915b-1714-466c-9a9b-44468a155ebe&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/2d3b915b-1714-466c-9a9b-44468a155ebe/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/5debdf4a-e9ad-47d4-ad97-771a786fd718"
          }
        },
        "components": {
          "data": [
            {
              "id": "e4562c35-5233-4bb2-96fc-9cb6c053d0ee",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/2d3b915b-1714-466c-9a9b-44468a155ebe/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=2d3b915b-1714-466c-9a9b-44468a155ebe"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=2d3b915b-1714-466c-9a9b-44468a155ebe"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=2d3b915b-1714-466c-9a9b-44468a155ebe"
          }
        }
      }
    },
    {
      "id": "e4562c35-5233-4bb2-96fc-9cb6c053d0ee",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=e4562c35-5233-4bb2-96fc-9cb6c053d0ee&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e4562c35-5233-4bb2-96fc-9cb6c053d0ee/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/5debdf4a-e9ad-47d4-ad97-771a786fd718"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/2d3b915b-1714-466c-9a9b-44468a155ebe",
            "self": "/object_occurrences/e4562c35-5233-4bb2-96fc-9cb6c053d0ee/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "0428762f-bf5a-41d2-aa2e-e4291daa0915",
              "type": "object_occurrence"
            },
            {
              "id": "22b53ef6-7941-4050-81f6-4196c5442b14",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/e4562c35-5233-4bb2-96fc-9cb6c053d0ee/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e4562c35-5233-4bb2-96fc-9cb6c053d0ee"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e4562c35-5233-4bb2-96fc-9cb6c053d0ee"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e4562c35-5233-4bb2-96fc-9cb6c053d0ee"
          }
        }
      }
    },
    {
      "id": "5bc3616b-55e7-4647-8414-8088354b0c81",
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
          "links": {
            "related": "/tags?filter[target_id_eq]=5bc3616b-55e7-4647-8414-8088354b0c81&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/5bc3616b-55e7-4647-8414-8088354b0c81/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/7815633b-1b70-49d3-8dfb-c2a3ec130dad"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/8b33c52a-6589-42bc-b8c6-2835fcc32734",
            "self": "/object_occurrences/5bc3616b-55e7-4647-8414-8088354b0c81/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/5bc3616b-55e7-4647-8414-8088354b0c81/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=5bc3616b-55e7-4647-8414-8088354b0c81"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=5bc3616b-55e7-4647-8414-8088354b0c81"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=5bc3616b-55e7-4647-8414-8088354b0c81"
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 6
  },
  "links": {
    "self": "http://example.org/object_occurrences",
    "current": "http://example.org/object_occurrences?page[number]=1"
  }
}
```



## Show

Display a single Object Occurrence.

To include additional, nested object occurrences, supply the <code>depth</code> parameter.


### Request

#### Endpoint

```plaintext
GET /object_occurrences/083a4a0c-b9c0-4b9f-beb0-c30ea1329e51
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
X-Request-Id: a1689187-ca0d-48fb-9385-d5c090e61250
200 OK
```


```json
{
  "data": {
    "id": "083a4a0c-b9c0-4b9f-beb0-c30ea1329e51",
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
        "links": {
          "related": "/tags?filter[target_id_eq]=083a4a0c-b9c0-4b9f-beb0-c30ea1329e51&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/083a4a0c-b9c0-4b9f-beb0-c30ea1329e51/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/be3f928e-05f6-405c-ab6e-2714d15492f4"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/e2cd63c1-b6ae-4b9f-a932-4348343330ad",
          "self": "/object_occurrences/083a4a0c-b9c0-4b9f-beb0-c30ea1329e51/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "cd202265-c912-4a20-bf4e-b108ba764d28",
            "type": "object_occurrence"
          },
          {
            "id": "4009edc5-f955-4320-bc05-de23f8cb6ba4",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/083a4a0c-b9c0-4b9f-beb0-c30ea1329e51/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=083a4a0c-b9c0-4b9f-beb0-c30ea1329e51"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=083a4a0c-b9c0-4b9f-beb0-c30ea1329e51"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=083a4a0c-b9c0-4b9f-beb0-c30ea1329e51"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/083a4a0c-b9c0-4b9f-beb0-c30ea1329e51"
  }
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
POST /object_occurrences/55975016-1507-492f-adc9-77ba61baee02/relationships/components
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
X-Request-Id: b38d3312-e3dd-4901-a463-090dc7d9dff2
201 Created
```


```json
{
  "data": {
    "id": "b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
      "description": null,
      "name": "ooc",
      "position": null,
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
        "links": {
          "related": "/tags?filter[target_id_eq]=b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/c4276e07-0ea2-4767-96e9-f1dc2bcdcd26"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/55975016-1507-492f-adc9-77ba61baee02",
          "self": "/object_occurrences/b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b6ab35fc-fee3-4e68-ba3b-d86983d4f2bd"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/55975016-1507-492f-adc9-77ba61baee02/relationships/components"
  }
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

Create a single Object Occurrence.


### Request

#### Endpoint

```plaintext
POST /object_occurrences/fdb488fe-3d9d-4e2e-b049-aa950fe6fa8d/relationships/components
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
X-Request-Id: e2ae4750-a383-44d5-b90e-95e5c98dd3ae
201 Created
```


```json
{
  "data": {
    "id": "4c39a209-53df-4d49-9ac5-acb62ab40eb1",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "name": "external OOC",
      "position": null,
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
        "links": {
          "related": "/tags?filter[target_id_eq]=4c39a209-53df-4d49-9ac5-acb62ab40eb1&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/4c39a209-53df-4d49-9ac5-acb62ab40eb1/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/67b61d4d-90e3-40a6-aea9-b9beb3ca8c75"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/fdb488fe-3d9d-4e2e-b049-aa950fe6fa8d/relationships/components"
  }
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
PATCH /object_occurrences/8efac6b1-7586-445e-88e7-bb4e8e3d2cac
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "8efac6b1-7586-445e-88e7-bb4e8e3d2cac",
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
          "id": "6ec4b4c2-383a-4b02-b73e-3c6913f4daf7"
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
X-Request-Id: eef123d7-aee0-403e-85fb-fa88a7eaa3a2
200 OK
```


```json
{
  "data": {
    "id": "8efac6b1-7586-445e-88e7-bb4e8e3d2cac",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "#ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=8efac6b1-7586-445e-88e7-bb4e8e3d2cac&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/8efac6b1-7586-445e-88e7-bb4e8e3d2cac/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/6f73df51-8bb2-40ca-8db6-8ff7a974bdf5"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/6ec4b4c2-383a-4b02-b73e-3c6913f4daf7",
          "self": "/object_occurrences/8efac6b1-7586-445e-88e7-bb4e8e3d2cac/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/8efac6b1-7586-445e-88e7-bb4e8e3d2cac/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=8efac6b1-7586-445e-88e7-bb4e8e3d2cac"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=8efac6b1-7586-445e-88e7-bb4e8e3d2cac"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=8efac6b1-7586-445e-88e7-bb4e8e3d2cac"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/8efac6b1-7586-445e-88e7-bb4e8e3d2cac"
  }
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
POST /object_occurrences/a896afc7-326e-4fd3-9a3a-57c97c8db905/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "6fcf955a-5ebf-4217-be65-12d2aeac450a",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | Object Occurrence Resource ID to copy |



### Response

```plaintext
Location: http://example.org/polling/c8ab9eb0981327b9208ac89d
Content-Type: text/html; charset=utf-8
X-Request-Id: 8af6b6f9-c09f-4c48-8f74-9a8f8f373c70
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/c8ab9eb0981327b9208ac89d">redirected</a>.</body></html>
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
DELETE /object_occurrences/e7889a81-bf9a-431a-ab71-f682c68b963d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: edafb957-8fcb-4f44-95c4-e95c3e562916
204 No Content
```




## Update part_of


### Request

#### Endpoint

```plaintext
PATCH /object_occurrences/22f1ae7b-b405-42d7-9fd8-d7089731d687/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "b0d389c0-841d-4c98-96e4-425d804c83cb",
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
X-Request-Id: 98bbc40c-2d5a-4295-ad6a-f37125394a75
200 OK
```


```json
{
  "data": {
    "id": "22f1ae7b-b405-42d7-9fd8-d7089731d687",
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
        "links": {
          "related": "/tags?filter[target_id_eq]=22f1ae7b-b405-42d7-9fd8-d7089731d687&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/22f1ae7b-b405-42d7-9fd8-d7089731d687/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/4ee75b14-5f58-4533-9d84-3f36c2b3fb62"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/b0d389c0-841d-4c98-96e4-425d804c83cb",
          "self": "/object_occurrences/22f1ae7b-b405-42d7-9fd8-d7089731d687/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/22f1ae7b-b405-42d7-9fd8-d7089731d687/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=22f1ae7b-b405-42d7-9fd8-d7089731d687"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=22f1ae7b-b405-42d7-9fd8-d7089731d687"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=22f1ae7b-b405-42d7-9fd8-d7089731d687"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/22f1ae7b-b405-42d7-9fd8-d7089731d687/relationships/part_of"
  }
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
POST /classification_tables/a02c285b-4867-4c49-a9d9-67354c0c3837/relationships/tags
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
X-Request-Id: 5e029c1f-e408-4555-8c58-28ad8304ef9b
201 Created
```


```json
{
  "data": {
    "id": "883f98a0-bb49-4150-b1e9-3c41927274bb",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/a02c285b-4867-4c49-a9d9-67354c0c3837/relationships/tags"
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
POST /classification_tables/c716cbda-de2a-443c-a18b-c9c2a47b3408/relationships/tags
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
    "id": "f926f9e5-107d-4c60-a56c-5259d56df132"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 0c27513a-fa04-4abc-8334-d7f7f2bc6343
201 Created
```


```json
{
  "data": {
    "id": "f926f9e5-107d-4c60-a56c-5259d56df132",
    "type": "tag",
    "attributes": {
      "value": "tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/c716cbda-de2a-443c-a18b-c9c2a47b3408/relationships/tags"
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
DELETE /classification_tables/273f2d81-3018-46b5-8250-fae3d5f61982/relationships/tags/5ee37ab9-c558-485f-bd61-f8511bfbf030
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: e32703c1-0e15-4fd8-b755-f775bd96e272
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
X-Request-Id: 47a78531-5b89-4ec6-94ca-0cdbb81a8e67
200 OK
```


```json
{
  "data": [
    {
      "id": "c3ffb4fd-8d4a-48ad-9531-9ee7c20b27ce",
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
            "related": "/tags?filter[target_id_eq]=c3ffb4fd-8d4a-48ad-9531-9ee7c20b27ce&filter[target_type_eq]=classification_table",
            "self": "/classification_tables/c3ffb4fd-8d4a-48ad-9531-9ee7c20b27ce/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=c3ffb4fd-8d4a-48ad-9531-9ee7c20b27ce",
            "self": "/classification_tables/c3ffb4fd-8d4a-48ad-9531-9ee7c20b27ce/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "96fa9aa3-2b89-4db0-a823-b7e197e01f3e",
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
            "related": "/tags?filter[target_id_eq]=96fa9aa3-2b89-4db0-a823-b7e197e01f3e&filter[target_type_eq]=classification_table",
            "self": "/classification_tables/96fa9aa3-2b89-4db0-a823-b7e197e01f3e/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=96fa9aa3-2b89-4db0-a823-b7e197e01f3e",
            "self": "/classification_tables/96fa9aa3-2b89-4db0-a823-b7e197e01f3e/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 2
  },
  "links": {
    "self": "http://example.org/classification_tables",
    "current": "http://example.org/classification_tables?page[number]=1&sort=name"
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
GET /classification_tables/0634f519-40d3-488a-afd6-add6ce032c07
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
X-Request-Id: 9ccb3e73-7d6a-4016-b22a-461cc26f5178
200 OK
```


```json
{
  "data": {
    "id": "0634f519-40d3-488a-afd6-add6ce032c07",
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
          "related": "/tags?filter[target_id_eq]=0634f519-40d3-488a-afd6-add6ce032c07&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/0634f519-40d3-488a-afd6-add6ce032c07/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=0634f519-40d3-488a-afd6-add6ce032c07",
          "self": "/classification_tables/0634f519-40d3-488a-afd6-add6ce032c07/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0634f519-40d3-488a-afd6-add6ce032c07"
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
PATCH /classification_tables/c8d0b51e-da51-407f-a29c-ddc02d2bf961
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "c8d0b51e-da51-407f-a29c-ddc02d2bf961",
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
X-Request-Id: 0b995812-3604-4262-89d2-9e1c8a0abedf
200 OK
```


```json
{
  "data": {
    "id": "c8d0b51e-da51-407f-a29c-ddc02d2bf961",
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
          "related": "/tags?filter[target_id_eq]=c8d0b51e-da51-407f-a29c-ddc02d2bf961&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/c8d0b51e-da51-407f-a29c-ddc02d2bf961/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=c8d0b51e-da51-407f-a29c-ddc02d2bf961",
          "self": "/classification_tables/c8d0b51e-da51-407f-a29c-ddc02d2bf961/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/c8d0b51e-da51-407f-a29c-ddc02d2bf961"
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
DELETE /classification_tables/505b3440-ac54-4f79-8d9c-69c6318f1fba
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5e8ec37b-ef74-4520-a056-30a94197091d
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
POST /classification_tables/d94e6632-fdc6-479a-9ce2-980b48e3ab09/publish
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
X-Request-Id: c176ab5f-32e3-4467-9239-0da958127986
200 OK
```


```json
{
  "data": {
    "id": "d94e6632-fdc6-479a-9ce2-980b48e3ab09",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-03-23T19:04:05.195Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=d94e6632-fdc6-479a-9ce2-980b48e3ab09&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/d94e6632-fdc6-479a-9ce2-980b48e3ab09/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=d94e6632-fdc6-479a-9ce2-980b48e3ab09",
          "self": "/classification_tables/d94e6632-fdc6-479a-9ce2-980b48e3ab09/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/d94e6632-fdc6-479a-9ce2-980b48e3ab09/publish"
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
POST /classification_tables/0901639b-9df1-4aa2-abbc-9f601bd1d317/archive
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
X-Request-Id: c8c9317d-17de-425c-abe3-9d0402bb673a
200 OK
```


```json
{
  "data": {
    "id": "0901639b-9df1-4aa2-abbc-9f601bd1d317",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-03-23T19:04:05.729Z",
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
          "related": "/tags?filter[target_id_eq]=0901639b-9df1-4aa2-abbc-9f601bd1d317&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/0901639b-9df1-4aa2-abbc-9f601bd1d317/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=0901639b-9df1-4aa2-abbc-9f601bd1d317",
          "self": "/classification_tables/0901639b-9df1-4aa2-abbc-9f601bd1d317/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/0901639b-9df1-4aa2-abbc-9f601bd1d317/archive"
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
X-Request-Id: d5802162-1e09-4e7b-896f-42cff82f01a7
201 Created
```


```json
{
  "data": {
    "id": "e3fc8362-6f11-495f-947f-5ffba3e2605c",
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
          "related": "/tags?filter[target_id_eq]=e3fc8362-6f11-495f-947f-5ffba3e2605c&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/e3fc8362-6f11-495f-947f-5ffba3e2605c/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=e3fc8362-6f11-495f-947f-5ffba3e2605c",
          "self": "/classification_tables/e3fc8362-6f11-495f-947f-5ffba3e2605c/relationships/classification_entries",
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

Adds a new tag to the resource


### Request

#### Endpoint

```plaintext
POST /classification_entries/fa65aadc-985b-4614-8ffb-6e9d61b40a10/relationships/tags
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
X-Request-Id: 07956eea-59c4-41fc-81d8-acba8812f9a7
201 Created
```


```json
{
  "data": {
    "id": "d7270934-a897-4fb3-b7e0-3fabea03518d",
    "type": "tag",
    "attributes": {
      "value": "new tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/fa65aadc-985b-4614-8ffb-6e9d61b40a10/relationships/tags"
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
POST /classification_entries/78433897-ce78-491c-b104-aea69710343f/relationships/tags
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
    "id": "89643646-1c47-4be5-acb6-53c18d91233e"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id] *required* | Existing tag ID |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 819e7860-8dbd-471f-a3e0-25064c7af1cd
201 Created
```


```json
{
  "data": {
    "id": "89643646-1c47-4be5-acb6-53c18d91233e",
    "type": "tag",
    "attributes": {
      "value": "tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/78433897-ce78-491c-b104-aea69710343f/relationships/tags"
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
DELETE /classification_entries/68e9e7ff-435a-470c-8e6b-c65e3c0f1492/relationships/tags/44e028b9-30fc-44af-a508-4ab59b7910fa
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ee285b9b-008b-4490-990b-961101209bf3
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
X-Request-Id: 9c1bb3bf-3341-421c-9c02-9eed1e63b70a
200 OK
```


```json
{
  "data": [
    {
      "id": "2d09ffeb-42d4-4ef6-a4d9-044fb530d3a9",
      "type": "classification_entry",
      "attributes": {
        "code": "A",
        "definition": "Alarm signal",
        "name": "CE 1",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=2d09ffeb-42d4-4ef6-a4d9-044fb530d3a9&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/2d09ffeb-42d4-4ef6-a4d9-044fb530d3a9/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=2d09ffeb-42d4-4ef6-a4d9-044fb530d3a9",
            "self": "/classification_entries/2d09ffeb-42d4-4ef6-a4d9-044fb530d3a9/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "20fee577-0567-4a1a-b5e9-25a83a04f5a4",
      "type": "classification_entry",
      "attributes": {
        "code": "AA",
        "definition": "Alarm signal",
        "name": "CE 11",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=20fee577-0567-4a1a-b5e9-25a83a04f5a4&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/20fee577-0567-4a1a-b5e9-25a83a04f5a4/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "2d09ffeb-42d4-4ef6-a4d9-044fb530d3a9",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/20fee577-0567-4a1a-b5e9-25a83a04f5a4"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=20fee577-0567-4a1a-b5e9-25a83a04f5a4",
            "self": "/classification_entries/20fee577-0567-4a1a-b5e9-25a83a04f5a4/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "7c675941-49da-472d-8cfe-8e71dd80c888",
      "type": "classification_entry",
      "attributes": {
        "code": "B",
        "definition": "Alarm signal",
        "name": "CE 2",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=7c675941-49da-472d-8cfe-8e71dd80c888&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/7c675941-49da-472d-8cfe-8e71dd80c888/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=7c675941-49da-472d-8cfe-8e71dd80c888",
            "self": "/classification_entries/7c675941-49da-472d-8cfe-8e71dd80c888/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    }
  ],
  "meta": {
    "total_count": 3
  },
  "links": {
    "self": "http://example.org/classification_entries",
    "current": "http://example.org/classification_entries?page[number]=1&sort=code"
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
GET /classification_entries/a28d00d7-860e-4e73-8aac-b2c02e3f14bc
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
X-Request-Id: 5bc41ec0-7019-415c-84c7-73a38ee6d498
200 OK
```


```json
{
  "data": {
    "id": "a28d00d7-860e-4e73-8aac-b2c02e3f14bc",
    "type": "classification_entry",
    "attributes": {
      "code": "A",
      "definition": "Alarm signal",
      "name": "CE 1",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=a28d00d7-860e-4e73-8aac-b2c02e3f14bc&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/a28d00d7-860e-4e73-8aac-b2c02e3f14bc/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=a28d00d7-860e-4e73-8aac-b2c02e3f14bc",
          "self": "/classification_entries/a28d00d7-860e-4e73-8aac-b2c02e3f14bc/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/a28d00d7-860e-4e73-8aac-b2c02e3f14bc"
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
PATCH /classification_entries/a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5",
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
X-Request-Id: 7a9ebbca-cfdd-4be3-9c16-8e1c25b6f254
200 OK
```


```json
{
  "data": {
    "id": "a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5",
    "type": "classification_entry",
    "attributes": {
      "code": "AA",
      "definition": "Alarm signal",
      "name": "New classification entry name",
      "reciprocal_name": "Alarm reciprocal"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "80a744c9-04e9-40ad-8c1e-10b7378909c7",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5",
          "self": "/classification_entries/a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/a2fcaffa-8f0e-4b79-b1f7-51d63e1d47c5"
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
DELETE /classification_entries/1279e421-ee11-4ade-b98c-d7340c608788
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3cc6b672-728b-4f03-912e-909900e89a9e
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
POST /classification_tables/e2350d0e-b2f8-499b-a3e8-8c2ae5ddf686/relationships/classification_entries
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
X-Request-Id: ff8e9d0b-27bc-449c-9f1c-b5c3de71d2f7
201 Created
```


```json
{
  "data": {
    "id": "1542a19c-7ac8-4e7b-a198-031103354bb9",
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
          "related": "/tags?filter[target_id_eq]=1542a19c-7ac8-4e7b-a198-031103354bb9&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/1542a19c-7ac8-4e7b-a198-031103354bb9/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=1542a19c-7ac8-4e7b-a198-031103354bb9",
          "self": "/classification_entries/1542a19c-7ac8-4e7b-a198-031103354bb9/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/e2350d0e-b2f8-499b-a3e8-8c2ae5ddf686/relationships/classification_entries"
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
X-Request-Id: 554791f8-9be7-44ff-bbbb-cd24fbc2dcb2
200 OK
```


```json
{
  "data": [
    {
      "id": "db8e25a3-2ce8-4b3d-bf29-8fbaed8ce38b",
      "type": "syntax",
      "attributes": {
        "account_id": "d811258a-81d3-4071-94a4-3f24a8817c99",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 882d0ec6e26f",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=db8e25a3-2ce8-4b3d-bf29-8fbaed8ce38b",
            "self": "/syntaxes/db8e25a3-2ce8-4b3d-bf29-8fbaed8ce38b/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/031ea286-ea89-4530-a312-a7b7fe3f662a",
            "self": "/syntax_nodes/031ea286-ea89-4530-a312-a7b7fe3f662a/relationships/components"
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
GET /syntaxes/450c5fe9-89e9-48c3-9a75-254e3a228fba
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
X-Request-Id: c03fa7ba-6c06-4e3a-903e-5104a7b3bdd1
200 OK
```


```json
{
  "data": {
    "id": "450c5fe9-89e9-48c3-9a75-254e3a228fba",
    "type": "syntax",
    "attributes": {
      "account_id": "d9610e68-cd36-4036-a103-1bf0e2bb1aa7",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 983bf763cee9",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=450c5fe9-89e9-48c3-9a75-254e3a228fba",
          "self": "/syntaxes/450c5fe9-89e9-48c3-9a75-254e3a228fba/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/5a22a8d3-8e5f-48c4-bd5b-e94bf17c0203",
          "self": "/syntax_nodes/5a22a8d3-8e5f-48c4-bd5b-e94bf17c0203/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/450c5fe9-89e9-48c3-9a75-254e3a228fba"
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
X-Request-Id: d026a688-ea6a-4999-9272-4805f07c5481
201 Created
```


```json
{
  "data": {
    "id": "f2fd9771-67ee-4c36-b9d5-702163702302",
    "type": "syntax",
    "attributes": {
      "account_id": "c2239bbf-9d79-4421-bd75-0a76f54ed7e1",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=f2fd9771-67ee-4c36-b9d5-702163702302",
          "self": "/syntaxes/f2fd9771-67ee-4c36-b9d5-702163702302/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/688f0607-06de-4f23-8680-24c115c4fa01",
          "self": "/syntax_nodes/688f0607-06de-4f23-8680-24c115c4fa01/relationships/components"
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
PATCH /syntaxes/d63b7699-f793-4ed0-b5b1-bd0e95a56f64
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "d63b7699-f793-4ed0-b5b1-bd0e95a56f64",
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
X-Request-Id: fe4e7556-cf4f-44a4-845e-c938d570423d
200 OK
```


```json
{
  "data": {
    "id": "d63b7699-f793-4ed0-b5b1-bd0e95a56f64",
    "type": "syntax",
    "attributes": {
      "account_id": "be188f5d-0167-40f6-a708-843ffd34ff4c",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=d63b7699-f793-4ed0-b5b1-bd0e95a56f64",
          "self": "/syntaxes/d63b7699-f793-4ed0-b5b1-bd0e95a56f64/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/da2b42ab-91a8-46c5-bedc-e96e49b34e96",
          "self": "/syntax_nodes/da2b42ab-91a8-46c5-bedc-e96e49b34e96/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/d63b7699-f793-4ed0-b5b1-bd0e95a56f64"
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
DELETE /syntaxes/d7bc2bc2-b19a-4c6f-893f-67590a43188a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: db4e5a14-1b44-4dd9-814c-e9a6a6aaab24
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
POST /syntaxes/2edf822b-f14e-45a1-a95e-b3510ecea3a3/publish
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
X-Request-Id: 1fac9d2c-ab50-4bbe-8b5d-427f8b71bf14
200 OK
```


```json
{
  "data": {
    "id": "2edf822b-f14e-45a1-a95e-b3510ecea3a3",
    "type": "syntax",
    "attributes": {
      "account_id": "52267518-00ea-4763-874e-5560694782ea",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax e1cf95de33f6",
      "published": true,
      "published_at": "2020-03-23T19:04:16.068Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=2edf822b-f14e-45a1-a95e-b3510ecea3a3",
          "self": "/syntaxes/2edf822b-f14e-45a1-a95e-b3510ecea3a3/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/6744fcc0-4863-42bb-99ef-76ffb76e4d8a",
          "self": "/syntax_nodes/6744fcc0-4863-42bb-99ef-76ffb76e4d8a/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/2edf822b-f14e-45a1-a95e-b3510ecea3a3/publish"
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
POST /syntaxes/364b4e90-54bc-43a2-90f5-70e91cde662f/archive
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
X-Request-Id: be9a0d93-f0e5-40fa-8eac-c9795d6bd6b5
200 OK
```


```json
{
  "data": {
    "id": "364b4e90-54bc-43a2-90f5-70e91cde662f",
    "type": "syntax",
    "attributes": {
      "account_id": "940375f2-35c5-417d-a01f-5c53c6b55cac",
      "archived": true,
      "archived_at": "2020-03-23T19:04:16.730Z",
      "description": "Description",
      "name": "Syntax 2ca5f94039ac",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=364b4e90-54bc-43a2-90f5-70e91cde662f",
          "self": "/syntaxes/364b4e90-54bc-43a2-90f5-70e91cde662f/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/17a3e453-9d0c-4c2d-ac9e-37336e8731b2",
          "self": "/syntax_nodes/17a3e453-9d0c-4c2d-ac9e-37336e8731b2/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/364b4e90-54bc-43a2-90f5-70e91cde662f/archive"
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
X-Request-Id: 4a37e288-c026-49f0-bfc3-6ff9bd224d17
200 OK
```


```json
{
  "data": [
    {
      "id": "6a2dbed3-aade-4bd4-8863-e7deaeaf21b7",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "060cbcdc-ee49-4a55-8818-6991c05b0a94",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 8250bb2b95a5",
        "hex_color": "#c0622e"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/da1d1571-a26e-437d-949b-0ebf9b1ddee0"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/060cbcdc-ee49-4a55-8818-6991c05b0a94",
            "self": "/syntax_elements/6a2dbed3-aade-4bd4-8863-e7deaeaf21b7/relationships/classification_table"
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
GET /syntax_elements/9215c364-6705-4d5e-9b78-e9d96a242281
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
X-Request-Id: b44badd6-6e7e-4ac1-be0c-263b28808242
200 OK
```


```json
{
  "data": {
    "id": "9215c364-6705-4d5e-9b78-e9d96a242281",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "99e142ba-dba6-4035-89b1-685b26165055",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 52758de9849a",
      "hex_color": "#abe462"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/fb76cc8e-ef26-43bf-8642-aacdb933d6cd"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/99e142ba-dba6-4035-89b1-685b26165055",
          "self": "/syntax_elements/9215c364-6705-4d5e-9b78-e9d96a242281/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/9215c364-6705-4d5e-9b78-e9d96a242281"
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
POST /syntaxes/f4bbec78-5414-40b8-8167-2356fb1f0f45/relationships/syntax_elements
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
          "id": "b404016e-1b4a-4608-9a1a-7cb1acb0dd7d"
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
X-Request-Id: 115b3219-32fb-4d7a-a484-df3eb3fcd0c0
201 Created
```


```json
{
  "data": {
    "id": "63469f7b-c16d-4b72-9442-3dad5a0287ea",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "b404016e-1b4a-4608-9a1a-7cb1acb0dd7d",
      "max_number": 5,
      "min_number": 1,
      "name": "Element",
      "hex_color": "#001122"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/f4bbec78-5414-40b8-8167-2356fb1f0f45"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/b404016e-1b4a-4608-9a1a-7cb1acb0dd7d",
          "self": "/syntax_elements/63469f7b-c16d-4b72-9442-3dad5a0287ea/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/f4bbec78-5414-40b8-8167-2356fb1f0f45/relationships/syntax_elements"
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
PATCH /syntax_elements/2d5cf954-e8dc-4b18-8571-33d24722e3ef
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "2d5cf954-e8dc-4b18-8571-33d24722e3ef",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "d9137c31-2c63-409f-a036-7f36fcf481ff"
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
X-Request-Id: aacfef54-f007-4ef4-a88b-2100632ab83c
200 OK
```


```json
{
  "data": {
    "id": "2d5cf954-e8dc-4b18-8571-33d24722e3ef",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "d9137c31-2c63-409f-a036-7f36fcf481ff",
      "max_number": 9,
      "min_number": 1,
      "name": "New element",
      "hex_color": "#dee236"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/15f19a46-48e9-4884-aca6-ced23ddc6075"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/d9137c31-2c63-409f-a036-7f36fcf481ff",
          "self": "/syntax_elements/2d5cf954-e8dc-4b18-8571-33d24722e3ef/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/2d5cf954-e8dc-4b18-8571-33d24722e3ef"
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
DELETE /syntax_elements/10418f19-fba2-4bbe-a2b6-11261e7778a9
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7a95fce2-a386-4d78-af91-f20f3153ad46
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
PATCH /syntax_elements/5ecdb019-3c97-49f4-9755-cc1d85e26998/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "de1f307d-595f-440c-b0e2-b96cf0065b9d",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: fd02b2dd-fb1e-4085-8741-b5dbf478f9f7
200 OK
```


```json
{
  "data": {
    "id": "5ecdb019-3c97-49f4-9755-cc1d85e26998",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "de1f307d-595f-440c-b0e2-b96cf0065b9d",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 0f7128c2eba1",
      "hex_color": "#ef955e"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e1c3dc47-d6aa-4c2a-b24d-97faa499610f"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/de1f307d-595f-440c-b0e2-b96cf0065b9d",
          "self": "/syntax_elements/5ecdb019-3c97-49f4-9755-cc1d85e26998/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/5ecdb019-3c97-49f4-9755-cc1d85e26998/relationships/classification_table"
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
DELETE /syntax_elements/48536802-c8bf-43e2-90d9-2d796951097d/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 7f6fa607-94af-4219-96bf-bc7d48e1e08c
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
X-Request-Id: 78dba52b-83df-4183-a7af-e8eab8cccefc
200 OK
```


```json
{
  "data": [
    {
      "id": "1a09b222-9642-485d-b16e-0956a3e0843a",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c68e646a-68d0-4309-8de4-9dfa4e919703"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/1a09b222-9642-485d-b16e-0956a3e0843a/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/1a09b222-9642-485d-b16e-0956a3e0843a/relationships/parent",
            "related": "/syntax_nodes/1a09b222-9642-485d-b16e-0956a3e0843a"
          }
        }
      }
    },
    {
      "id": "a4c38e0f-c82c-42b1-a5d5-954ec124dcd9",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c68e646a-68d0-4309-8de4-9dfa4e919703"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/a4c38e0f-c82c-42b1-a5d5-954ec124dcd9/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/a4c38e0f-c82c-42b1-a5d5-954ec124dcd9/relationships/parent",
            "related": "/syntax_nodes/a4c38e0f-c82c-42b1-a5d5-954ec124dcd9"
          }
        }
      }
    },
    {
      "id": "2bed07ef-c1dd-4598-8a28-4fbf41f4fdc5",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c68e646a-68d0-4309-8de4-9dfa4e919703"
          }
        },
        "components": {
          "data": [
            {
              "id": "a4c38e0f-c82c-42b1-a5d5-954ec124dcd9",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/2bed07ef-c1dd-4598-8a28-4fbf41f4fdc5/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/2bed07ef-c1dd-4598-8a28-4fbf41f4fdc5/relationships/parent",
            "related": "/syntax_nodes/2bed07ef-c1dd-4598-8a28-4fbf41f4fdc5"
          }
        }
      }
    },
    {
      "id": "38623b59-b618-4df3-aaa9-2c8c4d779017",
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
              "id": "507cb11f-6f26-42d8-83c2-8ab635bde0f1",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/38623b59-b618-4df3-aaa9-2c8c4d779017/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/38623b59-b618-4df3-aaa9-2c8c4d779017/relationships/parent",
            "related": "/syntax_nodes/38623b59-b618-4df3-aaa9-2c8c4d779017"
          }
        }
      }
    },
    {
      "id": "507cb11f-6f26-42d8-83c2-8ab635bde0f1",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/c68e646a-68d0-4309-8de4-9dfa4e919703"
          }
        },
        "components": {
          "data": [
            {
              "id": "2bed07ef-c1dd-4598-8a28-4fbf41f4fdc5",
              "type": "syntax_node"
            },
            {
              "id": "1a09b222-9642-485d-b16e-0956a3e0843a",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/507cb11f-6f26-42d8-83c2-8ab635bde0f1/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/507cb11f-6f26-42d8-83c2-8ab635bde0f1/relationships/parent",
            "related": "/syntax_nodes/507cb11f-6f26-42d8-83c2-8ab635bde0f1"
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
GET /syntax_nodes/ddee29b8-6c79-4ded-b259-ddc644d79b61?depth=2
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
X-Request-Id: 0ff9fa9b-7d35-4fa8-8a04-70a3a2a5264d
200 OK
```


```json
{
  "data": {
    "id": "ddee29b8-6c79-4ded-b259-ddc644d79b61",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/75adeaf6-55dc-4e23-b557-dab48153b709"
        }
      },
      "components": {
        "data": [
          {
            "id": "e50f6b9a-cf54-4407-9706-5d79d34620e1",
            "type": "syntax_node"
          },
          {
            "id": "be25d91e-c942-482c-9e31-0effd32ac7cd",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/ddee29b8-6c79-4ded-b259-ddc644d79b61/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/ddee29b8-6c79-4ded-b259-ddc644d79b61/relationships/parent",
          "related": "/syntax_nodes/ddee29b8-6c79-4ded-b259-ddc644d79b61"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/ddee29b8-6c79-4ded-b259-ddc644d79b61?depth=2"
  },
  "included": [
    {
      "id": "be25d91e-c942-482c-9e31-0effd32ac7cd",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/75adeaf6-55dc-4e23-b557-dab48153b709"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/be25d91e-c942-482c-9e31-0effd32ac7cd/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/be25d91e-c942-482c-9e31-0effd32ac7cd/relationships/parent",
            "related": "/syntax_nodes/be25d91e-c942-482c-9e31-0effd32ac7cd"
          }
        }
      }
    },
    {
      "id": "e50f6b9a-cf54-4407-9706-5d79d34620e1",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/75adeaf6-55dc-4e23-b557-dab48153b709"
          }
        },
        "components": {
          "data": [
            {
              "id": "e01206a0-7fd5-4db9-a8c0-3d9236d89a06",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/e50f6b9a-cf54-4407-9706-5d79d34620e1/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e50f6b9a-cf54-4407-9706-5d79d34620e1/relationships/parent",
            "related": "/syntax_nodes/e50f6b9a-cf54-4407-9706-5d79d34620e1"
          }
        }
      }
    },
    {
      "id": "e01206a0-7fd5-4db9-a8c0-3d9236d89a06",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/75adeaf6-55dc-4e23-b557-dab48153b709"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/e01206a0-7fd5-4db9-a8c0-3d9236d89a06/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e01206a0-7fd5-4db9-a8c0-3d9236d89a06/relationships/parent",
            "related": "/syntax_nodes/e01206a0-7fd5-4db9-a8c0-3d9236d89a06"
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
POST /syntax_nodes/a5101401-0030-4b14-b19e-fbe5e541838d/relationships/components
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
          "id": "49560b17-3675-4155-b5fa-44d6f98550f6"
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
X-Request-Id: 963de2ae-a542-4d42-8431-0f919129bc30
201 Created
```


```json
{
  "data": {
    "id": "fb5a2e2a-f353-499f-9f15-625359eb3383",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/49560b17-3675-4155-b5fa-44d6f98550f6"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/fb5a2e2a-f353-499f-9f15-625359eb3383/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/fb5a2e2a-f353-499f-9f15-625359eb3383/relationships/parent",
          "related": "/syntax_nodes/fb5a2e2a-f353-499f-9f15-625359eb3383"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/a5101401-0030-4b14-b19e-fbe5e541838d/relationships/components"
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
PATCH /syntax_nodes/7923f1ee-f9f1-441a-9074-e158b03a9524/relationships/parent
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
    "id": "e17b6ede-13ff-46b7-96c2-b199fbdfc668"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: b4c5fb63-97a1-4175-8774-0a589c21e343
200 OK
```


```json
{
  "data": {
    "id": "7923f1ee-f9f1-441a-9074-e158b03a9524",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/4d7b2859-1350-471f-8c63-f7c3984d10c4"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/7923f1ee-f9f1-441a-9074-e158b03a9524/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/7923f1ee-f9f1-441a-9074-e158b03a9524/relationships/parent",
          "related": "/syntax_nodes/7923f1ee-f9f1-441a-9074-e158b03a9524"
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
PATCH /syntax_nodes/25c24197-9389-4e43-911d-4301d87354a8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "25c24197-9389-4e43-911d-4301d87354a8",
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
X-Request-Id: 5cf3b4e3-5a6e-4a09-a23a-d4440df6316f
200 OK
```


```json
{
  "data": {
    "id": "25c24197-9389-4e43-911d-4301d87354a8",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/0a488c4a-9d3d-4c4b-a8c8-c97ecd5f9c69"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/25c24197-9389-4e43-911d-4301d87354a8/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/25c24197-9389-4e43-911d-4301d87354a8/relationships/parent",
          "related": "/syntax_nodes/25c24197-9389-4e43-911d-4301d87354a8"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/25c24197-9389-4e43-911d-4301d87354a8"
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
DELETE /syntax_nodes/c0589f22-92d6-4f2a-ae66-8089352ae071
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 839063db-120b-4210-9679-457f0a92e28d
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
X-Request-Id: 2af25823-4c15-4b95-8cf6-0d30cbd5542e
200 OK
```


```json
{
  "data": [
    {
      "id": "7a4ac9ab-78d8-4a9a-a1f8-cac66b551202",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-03-23T19:04:25.988Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=7a4ac9ab-78d8-4a9a-a1f8-cac66b551202",
            "self": "/progress_models/7a4ac9ab-78d8-4a9a-a1f8-cac66b551202/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "43630224-f105-4598-b458-5a067cd98414",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=43630224-f105-4598-b458-5a067cd98414",
            "self": "/progress_models/43630224-f105-4598-b458-5a067cd98414/relationships/progress_steps"
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
GET /progress_models/41d224c1-ce33-49c4-a8ef-6fcb9e99416b
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
X-Request-Id: 43641467-7b96-4ead-8a1c-cd460100bd22
200 OK
```


```json
{
  "data": {
    "id": "41d224c1-ce33-49c4-a8ef-6fcb9e99416b",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-03-23T19:04:26.703Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=41d224c1-ce33-49c4-a8ef-6fcb9e99416b",
          "self": "/progress_models/41d224c1-ce33-49c4-a8ef-6fcb9e99416b/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/41d224c1-ce33-49c4-a8ef-6fcb9e99416b"
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
PATCH /progress_models/d98bf73b-6e5b-4ed5-a7a1-332039a5f59d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "d98bf73b-6e5b-4ed5-a7a1-332039a5f59d",
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
X-Request-Id: 9bafd1d6-c108-4b71-a6dd-82870bf37226
200 OK
```


```json
{
  "data": {
    "id": "d98bf73b-6e5b-4ed5-a7a1-332039a5f59d",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=d98bf73b-6e5b-4ed5-a7a1-332039a5f59d",
          "self": "/progress_models/d98bf73b-6e5b-4ed5-a7a1-332039a5f59d/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/d98bf73b-6e5b-4ed5-a7a1-332039a5f59d"
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
DELETE /progress_models/bc2ac724-e4af-4392-ad7a-78dbc32c3d85
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 30b772ab-a458-4404-84bf-d84338f25e7d
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
POST /progress_models/309c07a7-d51b-415f-a880-fce863136ce7/publish
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
X-Request-Id: 6b7922d3-9318-4933-a772-223f6410c4b3
200 OK
```


```json
{
  "data": {
    "id": "309c07a7-d51b-415f-a880-fce863136ce7",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-03-23T19:04:29.122Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=309c07a7-d51b-415f-a880-fce863136ce7",
          "self": "/progress_models/309c07a7-d51b-415f-a880-fce863136ce7/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/309c07a7-d51b-415f-a880-fce863136ce7/publish"
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
POST /progress_models/4521e38f-79de-4ddc-8a1d-6f9bb4c4d156/archive
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
X-Request-Id: 2995948f-de4c-4f39-8ae6-cc4715a5907c
200 OK
```


```json
{
  "data": {
    "id": "4521e38f-79de-4ddc-8a1d-6f9bb4c4d156",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-03-23T19:04:29.937Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=4521e38f-79de-4ddc-8a1d-6f9bb4c4d156",
          "self": "/progress_models/4521e38f-79de-4ddc-8a1d-6f9bb4c4d156/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/4521e38f-79de-4ddc-8a1d-6f9bb4c4d156/archive"
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
X-Request-Id: 1932e332-c080-4c66-9ae8-80d89646474e
201 Created
```


```json
{
  "data": {
    "id": "e4b5c12f-a4ce-4c64-a2bd-760f2946c5f0",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=e4b5c12f-a4ce-4c64-a2bd-760f2946c5f0",
          "self": "/progress_models/e4b5c12f-a4ce-4c64-a2bd-760f2946c5f0/relationships/progress_steps"
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
X-Request-Id: 8bfa14fa-840b-45be-87a7-4891e39ea002
200 OK
```


```json
{
  "data": [
    {
      "id": "7ec6a76d-bd66-4c42-bd0b-882bc9f53811",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/f25486db-7b2d-4fa4-9c56-9c38fb8d3849"
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
GET /progress_steps/79c12185-6a51-4e42-a330-e0bd01bfe8a2
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
X-Request-Id: 6ace2d09-9ec8-4328-83c4-c5f00986d244
200 OK
```


```json
{
  "data": {
    "id": "79c12185-6a51-4e42-a330-e0bd01bfe8a2",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/c05dacae-3aa7-4761-a276-c0846f5c0bcc"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/79c12185-6a51-4e42-a330-e0bd01bfe8a2"
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
PATCH /progress_steps/60ef79c5-584e-4e6f-b33e-c384494db5a8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "60ef79c5-584e-4e6f-b33e-c384494db5a8",
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
X-Request-Id: 9bbe6453-d83b-49f0-86b5-0035fb164271
200 OK
```


```json
{
  "data": {
    "id": "60ef79c5-584e-4e6f-b33e-c384494db5a8",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/cfb80aee-4811-4ff7-974f-78ff0938790e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/60ef79c5-584e-4e6f-b33e-c384494db5a8"
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
DELETE /progress_steps/9307ee02-8ac6-409a-9680-10c579c85b79
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3d49d53e-ebd2-46cc-a14a-acf427247d61
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
POST /progress_models/d25dd506-d909-42fb-9834-73a0baf386e6/relationships/progress_steps
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
X-Request-Id: 518a9a62-5a4b-44bb-945d-ea8578789e92
201 Created
```


```json
{
  "data": {
    "id": "0464fd2f-cb32-41ac-847d-c065eccea8eb",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/d25dd506-d909-42fb-9834-73a0baf386e6"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/d25dd506-d909-42fb-9834-73a0baf386e6/relationships/progress_steps"
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
X-Request-Id: d9cd78c5-1323-42c0-b7a1-2afaf550984a
200 OK
```


```json
{
  "data": [
    {
      "id": "38f094ce-1808-4ec9-adee-88a02aaedcb2",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/105dee85-46a1-4f92-a5f6-d96b54af6f6a"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/cd4c1a8a-cb50-4bcf-9f03-b6c59710490d"
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
GET /progress/15e77518-37ce-401d-9c3d-0d9b74faaf5f
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
X-Request-Id: c9266911-002f-4140-8015-38da6e330f5f
200 OK
```


```json
{
  "data": {
    "id": "15e77518-37ce-401d-9c3d-0d9b74faaf5f",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/8de4577e-696b-4e60-846c-98f800972e69"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/832d2bfa-254b-493e-b745-55571a52f08e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/15e77518-37ce-401d-9c3d-0d9b74faaf5f"
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
DELETE /progress/a1e76b4e-6d71-40c4-9172-7a93a11c346e
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 62aa6486-d2a7-485c-842b-1d0d2ba21d5b
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
          "id": "3a3e28a6-6cb9-43ec-b5b4-d09387ecd718"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "4b8bb5fe-5f37-4344-8e85-3f57cf07bd54"
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
X-Request-Id: 165f7aaf-d5a8-4d46-a512-95b847a4ae1a
201 Created
```


```json
{
  "data": {
    "id": "d49c6ec2-1b0a-410a-a359-fa0c75878eb8",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/3a3e28a6-6cb9-43ec-b5b4-d09387ecd718"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/4b8bb5fe-5f37-4344-8e85-3f57cf07bd54"
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
X-Request-Id: a8f7c4a3-715f-42f6-8dd6-9a22f9c30163
200 OK
```


```json
{
  "data": [
    {
      "id": "f0b98e38-2398-4c0b-978a-d86033cbc988",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "b07cad71-354d-4c34-857d-ac37addb361d"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/b07cad71-354d-4c34-857d-ac37addb361d"
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
GET /projects/bb5d6d48-ad44-4d54-9be8-0b273392cd5b/relationships/project_setting
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
X-Request-Id: 90d6d52e-fb15-4819-81a9-36e72f94bcaa
200 OK
```


```json
{
  "data": {
    "id": "a355f9b5-bf91-40ea-ac5c-7d418abfe671",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "bb5d6d48-ad44-4d54-9be8-0b273392cd5b"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/bb5d6d48-ad44-4d54-9be8-0b273392cd5b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/bb5d6d48-ad44-4d54-9be8-0b273392cd5b/relationships/project_setting"
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
PATCH /projects/8d9f9ecf-887a-4e91-9aca-f5244ecd704e/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "8d9f9ecf-887a-4e91-9aca-f5244ecd704e",
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
X-Request-Id: 514d17f7-387e-4e48-a500-a45e67d34b12
200 OK
```


```json
{
  "data": {
    "id": "cdaf7787-094d-4526-9670-83d724f1189b",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "8d9f9ecf-887a-4e91-9aca-f5244ecd704e"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/8d9f9ecf-887a-4e91-9aca-f5244ecd704e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/8d9f9ecf-887a-4e91-9aca-f5244ecd704e/relationships/project_setting"
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
X-Request-Id: bae33bab-6a99-424c-af1f-38fbfa98e778
200 OK
```


```json
{
  "data": [
    {
      "id": "89cb076a-d0a3-479a-838a-1debaceccbdb",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/89cb076a-d0a3-479a-838a-1debaceccbdb"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/89cb076a-d0a3-479a-838a-1debaceccbdb"
          }
        }
      }
    },
    {
      "id": "290a7dea-cd58-4793-bcd2-7e8956d9b36f",
      "type": "system_element",
      "attributes": {
        "name": "OOC e2e21554546b-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/290a7dea-cd58-4793-bcd2-7e8956d9b36f"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/290a7dea-cd58-4793-bcd2-7e8956d9b36f"
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
GET /system_elements/bc375d69-fd8f-4014-b2ba-a6090f1aa358
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
X-Request-Id: 37b50483-5b0a-46d9-b801-e5d7a116fd93
200 OK
```


```json
{
  "data": {
    "id": "bc375d69-fd8f-4014-b2ba-a6090f1aa358",
    "type": "system_element",
    "attributes": {
      "name": "OOC b698666fcebb-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/bc375d69-fd8f-4014-b2ba-a6090f1aa358"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/bc375d69-fd8f-4014-b2ba-a6090f1aa358"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/bc375d69-fd8f-4014-b2ba-a6090f1aa358"
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
POST /object_occurrences/13b50a2d-0fbb-42e7-9bdf-4667d7d16f6c/relationships/system_elements
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
      "target_id": "9eb4db78-f94f-4434-9760-a239d73cbafc"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 92fb40bc-25f3-4aa7-ba8e-7becb76166b1
201 Created
```


```json
{
  "data": {
    "id": "6ffe596b-d2f2-424f-bd79-237209142e48",
    "type": "system_element",
    "attributes": {
      "name": "OOC 2b4c604cf49e-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/6ffe596b-d2f2-424f-bd79-237209142e48"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/6ffe596b-d2f2-424f-bd79-237209142e48"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/13b50a2d-0fbb-42e7-9bdf-4667d7d16f6c/relationships/system_elements"
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
DELETE /object_occurrences/88bb88a9-0522-4699-8bce-2eaaac1abe68/relationships/system_elements/c370f9b5-0ef6-4bad-8c20-4f49f6dc2073
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: cfe9efbb-4105-425f-9932-155f50479821
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
X-Request-Id: 4d27f9af-0c73-4e32-8fcb-a455f670b17c
200 OK
```


```json
{
  "data": {
    "id": "a16c91e2-a7a2-4022-aec1-5ee7bd444189",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "e70ba0e6-ec42-42e7-94f9-1d4971ec99fe"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/e70ba0e6-ec42-42e7-94f9-1d4971ec99fe"
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
X-Request-Id: 0c8e1171-f414-4a9c-b5fa-96633e42b244
200 OK
```


```json
{
  "data": {
    "id": "47bf1abf-1cf5-4fe9-b895-aedf56864d43",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "15839f1b-26ca-4d23-8821-cb638974a968"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/15839f1b-26ca-4d23-8821-cb638974a968"
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
X-Request-Id: 62054b8b-04e4-4dde-a6ad-9fe36781e6cf
200 OK
```


```json
{
  "data": [
    {
      "id": "71166cea-587e-443d-9677-977fc694aaa2",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR c40f6fd37fae",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=71166cea-587e-443d-9677-977fc694aaa2&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/71166cea-587e-443d-9677-977fc694aaa2/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "458b428a-2584-49b8-9add-fbc7c81e1b37",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/458b428a-2584-49b8-9add-fbc7c81e1b37",
            "self": "/object_occurrence_relations/71166cea-587e-443d-9677-977fc694aaa2/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "c85542df-a59f-4886-8b7b-9bd4df3eca57",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/c85542df-a59f-4886-8b7b-9bd4df3eca57",
            "self": "/object_occurrence_relations/71166cea-587e-443d-9677-977fc694aaa2/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "bdc5a84b-a590-49be-b45f-0d6c240c4612",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/bdc5a84b-a590-49be-b45f-0d6c240c4612",
            "self": "/object_occurrence_relations/71166cea-587e-443d-9677-977fc694aaa2/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "458b428a-2584-49b8-9add-fbc7c81e1b37",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 00fff4075c87",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=458b428a-2584-49b8-9add-fbc7c81e1b37&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/458b428a-2584-49b8-9add-fbc7c81e1b37/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=458b428a-2584-49b8-9add-fbc7c81e1b37",
            "self": "/classification_entries/458b428a-2584-49b8-9add-fbc7c81e1b37/relationships/classification_entries",
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
    "current": "http://example.org/object_occurrence_relations?include=classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Filter by object_occurrence_source_ids_cont and object_occurrence_target_ids_cont


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=976707f3-d774-45b3-aaa2-c771142d1f8f&amp;filter[object_occurrence_source_ids_cont][]=66b3f65f-aaf2-4539-b1f5-c600fb029aa4&amp;filter[object_occurrence_target_ids_cont][]=1dd16fec-e677-4521-a682-1aae4b33837c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;976707f3-d774-45b3-aaa2-c771142d1f8f&quot;, &quot;66b3f65f-aaf2-4539-b1f5-c600fb029aa4&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;1dd16fec-e677-4521-a682-1aae4b33837c&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f08f49cb-3d02-41bc-8e92-3412684f55d6
200 OK
```


```json
{
  "data": [
    {
      "id": "906691c0-95ca-4ea8-979e-2d23bd1e7d00",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 305b1a692364",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=906691c0-95ca-4ea8-979e-2d23bd1e7d00&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/906691c0-95ca-4ea8-979e-2d23bd1e7d00/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "e8ae972a-dcb3-4814-9b31-8cb076774e24",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/e8ae972a-dcb3-4814-9b31-8cb076774e24",
            "self": "/object_occurrence_relations/906691c0-95ca-4ea8-979e-2d23bd1e7d00/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "1dd16fec-e677-4521-a682-1aae4b33837c",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/1dd16fec-e677-4521-a682-1aae4b33837c",
            "self": "/object_occurrence_relations/906691c0-95ca-4ea8-979e-2d23bd1e7d00/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "976707f3-d774-45b3-aaa2-c771142d1f8f",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/976707f3-d774-45b3-aaa2-c771142d1f8f",
            "self": "/object_occurrence_relations/906691c0-95ca-4ea8-979e-2d23bd1e7d00/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "e8ae972a-dcb3-4814-9b31-8cb076774e24",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm fb180793b688",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=e8ae972a-dcb3-4814-9b31-8cb076774e24&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/e8ae972a-dcb3-4814-9b31-8cb076774e24/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=e8ae972a-dcb3-4814-9b31-8cb076774e24",
            "self": "/classification_entries/e8ae972a-dcb3-4814-9b31-8cb076774e24/relationships/classification_entries",
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
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=976707f3-d774-45b3-aaa2-c771142d1f8f&filter[object_occurrence_source_ids_cont][]=66b3f65f-aaf2-4539-b1f5-c600fb029aa4&filter[object_occurrence_target_ids_cont][]=1dd16fec-e677-4521-a682-1aae4b33837c",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=976707f3-d774-45b3-aaa2-c771142d1f8f&filter[object_occurrence_source_ids_cont][]=66b3f65f-aaf2-4539-b1f5-c600fb029aa4&filter[object_occurrence_target_ids_cont][]=1dd16fec-e677-4521-a682-1aae4b33837c&include=classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/a3f9c503-e344-4d29-82e3-261e661f86f5
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
X-Request-Id: 4d805f28-e9a1-4371-ac38-92c5ffb7bf6e
200 OK
```


```json
{
  "data": {
    "id": "a3f9c503-e344-4d29-82e3-261e661f86f5",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "OOR f2be169602db",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=a3f9c503-e344-4d29-82e3-261e661f86f5&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/a3f9c503-e344-4d29-82e3-261e661f86f5/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "b2865918-e578-4ef8-b978-3c676e1db521",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/b2865918-e578-4ef8-b978-3c676e1db521",
          "self": "/object_occurrence_relations/a3f9c503-e344-4d29-82e3-261e661f86f5/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "467398f5-e851-4670-b72c-d37168ad9985",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/467398f5-e851-4670-b72c-d37168ad9985",
          "self": "/object_occurrence_relations/a3f9c503-e344-4d29-82e3-261e661f86f5/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "0d5e605e-4a75-4eb1-90cb-36465a03a12e",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/0d5e605e-4a75-4eb1-90cb-36465a03a12e",
          "self": "/object_occurrence_relations/a3f9c503-e344-4d29-82e3-261e661f86f5/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/a3f9c503-e344-4d29-82e3-261e661f86f5"
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
| filter  | available filters: target_id_eq, target_type_eq |
| query  | search query |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 92e79f8d-ec54-446c-9f06-83a6f2efa2c9
200 OK
```


```json
{
  "data": [
    {
      "id": "03d5fb22-8790-4845-b119-3f5f1b57c786",
      "type": "tag",
      "attributes": {
        "value": "tag value 11"
      },
      "relationships": {
      }
    },
    {
      "id": "4d54b1f0-5415-4b82-8aa3-3b47d1398b66",
      "type": "tag",
      "attributes": {
        "value": "tag value 12"
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
X-Request-Id: 27023a26-d667-4459-bb00-cfbf97fdb5a7
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
GET /utils/path/from/object_occurrence/e54ea614-3e78-499f-bacd-77bbcb69b8f7/to/object_occurrence/aec4484d-5868-4a5b-8712-e50b34f3304a
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
X-Request-Id: 460393ae-2c72-4d71-9900-c55935304ff2
200 OK
```


```json
[
  {
    "id": "e54ea614-3e78-499f-bacd-77bbcb69b8f7",
    "type": "object_occurrence"
  },
  {
    "id": "5f5b47d9-7269-4ebb-adff-8afdcdce89c3",
    "type": "object_occurrence"
  },
  {
    "id": "e9893cfd-6adc-4da5-9233-c4fc26c09616",
    "type": "object_occurrence"
  },
  {
    "id": "126a01b4-6ece-43af-961c-8553183ee6b0",
    "type": "object_occurrence"
  },
  {
    "id": "3372b976-b3b3-4c8f-bd04-bab6cee6025c",
    "type": "object_occurrence"
  },
  {
    "id": "a3fd0e92-d00b-4bda-8e97-14ca90f78300",
    "type": "object_occurrence"
  },
  {
    "id": "aec4484d-5868-4a5b-8712-e50b34f3304a",
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
X-Request-Id: 9acf1b16-bcd7-4f28-a461-abe72cbffb84
200 OK
```


```json
{
  "data": [
    {
      "id": "094fadd1-38e3-4564-b5f9-33f81f903eb0",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/f644da19-99a8-4386-8885-15afe1a065da"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/bf09624a-18e0-4737-9fbe-95df0e28d13c"
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
X-Request-Id: 4fa3651e-cf02-4074-8c86-cdd192feb7c4
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



