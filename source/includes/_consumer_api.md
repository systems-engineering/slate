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
X-Request-Id: 221f393e-d0b0-4ea7-99b7-53b6a65b4607
200 OK
```


```json
{
  "data": {
    "id": "e32e0543-d945-4f2b-9298-444fe648b23b",
    "type": "account",
    "attributes": {
      "name": "Account dd66dd127f0a"
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
X-Request-Id: 6dc0ff36-a6d2-4367-856e-f49c08864bc2
200 OK
```


```json
{
  "data": {
    "id": "dc20deb1-4e98-408c-a37f-f2babe46756f",
    "type": "account",
    "attributes": {
      "name": "Account 2717a2db34a8"
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
    "id": "7eb48f2c-c89d-4131-917c-0a38331563f0",
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
X-Request-Id: 1eb8de2f-97df-4e09-906d-5a8fedc1e8fc
200 OK
```


```json
{
  "data": {
    "id": "7eb48f2c-c89d-4131-917c-0a38331563f0",
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
POST /projects/23e64566-5dd7-4692-b7db-e579bfcdcf35/relationships/tags
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
X-Request-Id: 428fc021-1313-424d-819d-cf18e99f292f
201 Created
```


```json
{
  "data": {
    "id": "de149a4f-9bee-4e7f-bf99-587fe6178c18",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/23e64566-5dd7-4692-b7db-e579bfcdcf35/relationships/tags"
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
POST /projects/78209aa6-58ff-4b8b-90fe-f720a4b25ce2/relationships/tags
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
    "id": "8e95fb39-8d90-483c-b8ce-a0791e5fa839"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ca6d495f-df7d-43a7-a0a8-bb6bced6dcb6
201 Created
```


```json
{
  "data": {
    "id": "8e95fb39-8d90-483c-b8ce-a0791e5fa839",
    "type": "tag",
    "attributes": {
      "value": "Tag value 1"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/projects/78209aa6-58ff-4b8b-90fe-f720a4b25ce2/relationships/tags"
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
DELETE /projects/cce33ea1-f4ed-4033-8689-9d37d06125dd/relationships/tags/96e37f8e-a880-4049-a619-0c82c72df299
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 5c74a4ce-63d7-47e1-b3b5-4db220bf32fd
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
X-Request-Id: 70f8dd46-6cac-4d0b-a7fa-17775454244a
200 OK
```


```json
{
  "data": [
    {
      "id": "340de851-6552-4217-884f-afecbe00bbf5",
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
            "related": "/tags?filter[target_id_eq]=340de851-6552-4217-884f-afecbe00bbf5&filter[target_type_eq]=project",
            "self": "/projects/340de851-6552-4217-884f-afecbe00bbf5/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "contexts": {
          "links": {
            "related": "/contexts?filter[project_id_eq]=340de851-6552-4217-884f-afecbe00bbf5",
            "self": "/projects/340de851-6552-4217-884f-afecbe00bbf5/relationships/contexts"
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
GET /projects/786bd7bd-ad98-461e-888f-276d49b1e32e
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
X-Request-Id: 5002d467-4d69-4ba2-8c4e-a243c8d4a949
200 OK
```


```json
{
  "data": {
    "id": "786bd7bd-ad98-461e-888f-276d49b1e32e",
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
          "related": "/tags?filter[target_id_eq]=786bd7bd-ad98-461e-888f-276d49b1e32e&filter[target_type_eq]=project",
          "self": "/projects/786bd7bd-ad98-461e-888f-276d49b1e32e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=786bd7bd-ad98-461e-888f-276d49b1e32e",
          "self": "/projects/786bd7bd-ad98-461e-888f-276d49b1e32e/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/786bd7bd-ad98-461e-888f-276d49b1e32e"
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
PATCH /projects/9f31e181-97e8-4b13-8aa2-2f5729eee664
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:id`

#### Parameters


```json
{
  "data": {
    "id": "9f31e181-97e8-4b13-8aa2-2f5729eee664",
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
X-Request-Id: db60326c-2d79-47c4-9fb8-6d175e2aa7e0
200 OK
```


```json
{
  "data": {
    "id": "9f31e181-97e8-4b13-8aa2-2f5729eee664",
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
          "related": "/tags?filter[target_id_eq]=9f31e181-97e8-4b13-8aa2-2f5729eee664&filter[target_type_eq]=project",
          "self": "/projects/9f31e181-97e8-4b13-8aa2-2f5729eee664/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=9f31e181-97e8-4b13-8aa2-2f5729eee664",
          "self": "/projects/9f31e181-97e8-4b13-8aa2-2f5729eee664/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/9f31e181-97e8-4b13-8aa2-2f5729eee664"
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
POST /projects/d7ad118f-a78e-4213-83d0-e75080f5d22e/archive
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
X-Request-Id: f3060b74-81cb-45be-95fc-c8d22d2fdd66
200 OK
```


```json
{
  "data": {
    "id": "d7ad118f-a78e-4213-83d0-e75080f5d22e",
    "type": "project",
    "attributes": {
      "archived": true,
      "archived_at": "2020-03-17T15:25:54.263Z",
      "description": "Project description",
      "name": "project 1"
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=d7ad118f-a78e-4213-83d0-e75080f5d22e&filter[target_type_eq]=project",
          "self": "/projects/d7ad118f-a78e-4213-83d0-e75080f5d22e/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "contexts": {
        "links": {
          "related": "/contexts?filter[project_id_eq]=d7ad118f-a78e-4213-83d0-e75080f5d22e",
          "self": "/projects/d7ad118f-a78e-4213-83d0-e75080f5d22e/relationships/contexts"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/d7ad118f-a78e-4213-83d0-e75080f5d22e/archive"
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
DELETE /projects/2dd67ca7-9d77-4836-b455-7746f0bf6301
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /projects/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 0abfa463-e302-4e6c-b625-5682f60a2725
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
POST /contexts/63d49c4c-7431-43db-955d-8aca661f3828/relationships/tags
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
X-Request-Id: 2fe66d86-c412-4d5b-b79e-865040591b55
201 Created
```


```json
{
  "data": {
    "id": "7ec9a4fb-2954-4df1-8dac-7046610514d4",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/63d49c4c-7431-43db-955d-8aca661f3828/relationships/tags"
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
POST /contexts/57ba24c9-1aa3-4f23-beff-792a5a59fd30/relationships/tags
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
    "id": "b9ea73ae-a734-4696-9781-d8d7f7e89526"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: f991ec2a-248c-489d-b988-c9f701f595f7
201 Created
```


```json
{
  "data": {
    "id": "b9ea73ae-a734-4696-9781-d8d7f7e89526",
    "type": "tag",
    "attributes": {
      "value": "Tag value 3"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/contexts/57ba24c9-1aa3-4f23-beff-792a5a59fd30/relationships/tags"
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
DELETE /contexts/b5605d5e-9863-4cb5-b2c1-bd762ad0b797/relationships/tags/31b65790-1ee0-4e0c-8eb4-d9d96ea71f45
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 06d8681d-5b2d-404a-b8e5-284d2acf65ce
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
X-Request-Id: f85a8171-172a-49eb-af78-e24949769f9c
200 OK
```


```json
{
  "data": [
    {
      "id": "9eca7f60-c234-4f9f-af10-397c697a25c2",
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
            "related": "/tags?filter[target_id_eq]=9eca7f60-c234-4f9f-af10-397c697a25c2&filter[target_type_eq]=context",
            "self": "/contexts/9eca7f60-c234-4f9f-af10-397c697a25c2/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/2fbd1477-cb37-49f5-a5c2-10a2baa11911"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/61461b3d-d0b4-46df-8618-d3f8d267a4b5"
          }
        }
      }
    },
    {
      "id": "7bb85c3b-0389-432d-b0e9-7663fab112cf",
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
            "related": "/tags?filter[target_id_eq]=7bb85c3b-0389-432d-b0e9-7663fab112cf&filter[target_type_eq]=context",
            "self": "/contexts/7bb85c3b-0389-432d-b0e9-7663fab112cf/relationships/tags"
          }
        },
        "project": {
          "links": {
            "related": "/projects/2fbd1477-cb37-49f5-a5c2-10a2baa11911"
          }
        },
        "root_object_occurrence": {
          "links": {
            "related": "/object_occurrences/1bd07168-a245-4c3e-88e4-e6a9acecedd8"
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


## Show


### Request

#### Endpoint

```plaintext
GET /contexts/c476ff4d-3ddb-4b75-82c0-fee22550ae62
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
X-Request-Id: d51a0768-fac4-471f-8f72-06b2b6362778
200 OK
```


```json
{
  "data": {
    "id": "c476ff4d-3ddb-4b75-82c0-fee22550ae62",
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
          "related": "/tags?filter[target_id_eq]=c476ff4d-3ddb-4b75-82c0-fee22550ae62&filter[target_type_eq]=context",
          "self": "/contexts/c476ff4d-3ddb-4b75-82c0-fee22550ae62/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/f26691ec-04c8-4a2b-acbc-4bb23eca2f1b"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/639e6bb3-f90b-42cd-aa33-d075b9ef70e9"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/c476ff4d-3ddb-4b75-82c0-fee22550ae62"
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
PATCH /contexts/e21f7f00-9b3e-4e76-abc3-48ba876a139a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /contexts/:id`

#### Parameters


```json
{
  "data": {
    "id": "e21f7f00-9b3e-4e76-abc3-48ba876a139a",
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
X-Request-Id: a7fd3a8e-4243-43eb-910d-5c610f8e5b80
200 OK
```


```json
{
  "data": {
    "id": "e21f7f00-9b3e-4e76-abc3-48ba876a139a",
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
          "related": "/tags?filter[target_id_eq]=e21f7f00-9b3e-4e76-abc3-48ba876a139a&filter[target_type_eq]=context",
          "self": "/contexts/e21f7f00-9b3e-4e76-abc3-48ba876a139a/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/8bc70f12-c51f-470a-a1fc-2938eac4b54d"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/600933af-8766-4bc6-af2d-3f89a6232a59"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/contexts/e21f7f00-9b3e-4e76-abc3-48ba876a139a"
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
POST /projects/baefd85a-cc37-4a60-860a-679155afa1fa/relationships/contexts
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
X-Request-Id: 78e97de2-2251-43fc-984a-5d86567f6d08
201 Created
```


```json
{
  "data": {
    "id": "1a6fd391-73c0-431d-a83f-0cfd92d3cbef",
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
          "related": "/tags?filter[target_id_eq]=1a6fd391-73c0-431d-a83f-0cfd92d3cbef&filter[target_type_eq]=context",
          "self": "/contexts/1a6fd391-73c0-431d-a83f-0cfd92d3cbef/relationships/tags"
        }
      },
      "project": {
        "links": {
          "related": "/projects/baefd85a-cc37-4a60-860a-679155afa1fa"
        }
      },
      "root_object_occurrence": {
        "links": {
          "related": "/object_occurrences/6494669e-81d5-4808-8019-db614fa4a9ff"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/baefd85a-cc37-4a60-860a-679155afa1fa/relationships/contexts"
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
POST /contexts/74bc8c12-a944-46f4-b70a-9d902be18876/revision
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /contexts/:id/revision`

#### Parameters


None known.


### Response

```plaintext
Location: http://example.org/polling/c3f3b99458b512755c4bee64
Content-Type: text/html; charset=utf-8
X-Request-Id: 73a83851-d1b8-4c50-838a-5358bf25d583
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/c3f3b99458b512755c4bee64">redirected</a>.</body></html>
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
DELETE /contexts/66b5680c-53cf-41f8-a4f6-a03eba0f4515
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /contexts/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: c884407d-0c56-4629-8cd1-8009ce00d099
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
POST /object_occurrences/10571372-f2fd-404b-9517-1cee52b7e566/relationships/tags
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
X-Request-Id: 9ace1adf-00cb-4fb1-8505-316b39fb9518
201 Created
```


```json
{
  "data": {
    "id": "594b0b5b-8c7e-48ee-8503-451ba08bb856",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/10571372-f2fd-404b-9517-1cee52b7e566/relationships/tags"
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
POST /object_occurrences/4570270d-dedc-47cf-99df-e21a3e6fbfd4/relationships/tags
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
    "id": "d80da2d1-6e13-4640-a35b-da1c12febf00"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: feeb123f-cf93-462d-b73c-efc338e430ec
201 Created
```


```json
{
  "data": {
    "id": "d80da2d1-6e13-4640-a35b-da1c12febf00",
    "type": "tag",
    "attributes": {
      "value": "Tag value 5"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/4570270d-dedc-47cf-99df-e21a3e6fbfd4/relationships/tags"
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
DELETE /object_occurrences/06f30b24-0441-49e9-826f-7d2309129fcd/relationships/tags/4be4b07f-a0a7-4490-8b98-73e5a3721365
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ab1d9617-a0f1-4980-ae56-b5e2e214f610
204 No Content
```




#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


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
X-Request-Id: e0ff2f67-f4cd-4e4c-b6b5-82dd1fc669db
200 OK
```


```json
{
  "data": [
    {
      "id": "a0c208e0-0646-41a6-ba99-db508c33f46e",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 2",
        "position": null,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "#",
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=a0c208e0-0646-41a6-ba99-db508c33f46e&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/a0c208e0-0646-41a6-ba99-db508c33f46e/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/844b0e53-528e-4088-862e-2ad0c2c138aa"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/38a53846-72ef-4d1c-ac3e-f88db7b91ae7",
            "self": "/object_occurrences/a0c208e0-0646-41a6-ba99-db508c33f46e/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/a0c208e0-0646-41a6-ba99-db508c33f46e/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=a0c208e0-0646-41a6-ba99-db508c33f46e"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=a0c208e0-0646-41a6-ba99-db508c33f46e"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=a0c208e0-0646-41a6-ba99-db508c33f46e"
          }
        }
      }
    },
    {
      "id": "e9662772-e8e8-404e-af4d-90060aac9ce1",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 2a",
        "position": null,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "#",
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=e9662772-e8e8-404e-af4d-90060aac9ce1&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/e9662772-e8e8-404e-af4d-90060aac9ce1/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/844b0e53-528e-4088-862e-2ad0c2c138aa"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/38a53846-72ef-4d1c-ac3e-f88db7b91ae7",
            "self": "/object_occurrences/e9662772-e8e8-404e-af4d-90060aac9ce1/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/e9662772-e8e8-404e-af4d-90060aac9ce1/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=e9662772-e8e8-404e-af4d-90060aac9ce1"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=e9662772-e8e8-404e-af4d-90060aac9ce1"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=e9662772-e8e8-404e-af4d-90060aac9ce1"
          }
        }
      }
    },
    {
      "id": "38a53846-72ef-4d1c-ac3e-f88db7b91ae7",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 1",
        "position": null,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "#",
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=38a53846-72ef-4d1c-ac3e-f88db7b91ae7&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/38a53846-72ef-4d1c-ac3e-f88db7b91ae7/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/844b0e53-528e-4088-862e-2ad0c2c138aa"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/7cb61911-db66-4e85-857d-8c2901a8f21e",
            "self": "/object_occurrences/38a53846-72ef-4d1c-ac3e-f88db7b91ae7/relationships/part_of"
          }
        },
        "components": {
          "data": [
            {
              "id": "e9662772-e8e8-404e-af4d-90060aac9ce1",
              "type": "object_occurrence"
            },
            {
              "id": "a0c208e0-0646-41a6-ba99-db508c33f46e",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/38a53846-72ef-4d1c-ac3e-f88db7b91ae7/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=38a53846-72ef-4d1c-ac3e-f88db7b91ae7"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=38a53846-72ef-4d1c-ac3e-f88db7b91ae7"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=38a53846-72ef-4d1c-ac3e-f88db7b91ae7"
          }
        }
      }
    },
    {
      "id": "7cb61911-db66-4e85-857d-8c2901a8f21e",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC c744d5dc0868",
        "position": null,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "#",
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=7cb61911-db66-4e85-857d-8c2901a8f21e&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/7cb61911-db66-4e85-857d-8c2901a8f21e/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/844b0e53-528e-4088-862e-2ad0c2c138aa"
          }
        },
        "components": {
          "data": [
            {
              "id": "38a53846-72ef-4d1c-ac3e-f88db7b91ae7",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/7cb61911-db66-4e85-857d-8c2901a8f21e/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7cb61911-db66-4e85-857d-8c2901a8f21e"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7cb61911-db66-4e85-857d-8c2901a8f21e"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=7cb61911-db66-4e85-857d-8c2901a8f21e"
          }
        }
      }
    },
    {
      "id": "c6ef350d-0eee-48e3-a0bb-323ff09c1563",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 266df22eb40c",
        "position": null,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "#",
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=c6ef350d-0eee-48e3-a0bb-323ff09c1563&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/c6ef350d-0eee-48e3-a0bb-323ff09c1563/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/06ece9db-63ad-44f7-96c5-b49028553493"
          }
        },
        "components": {
          "data": [
            {
              "id": "428c6bd7-5aa2-4274-9f0c-c329529e2bc4",
              "type": "object_occurrence"
            }
          ],
          "links": {
            "self": "/object_occurrences/c6ef350d-0eee-48e3-a0bb-323ff09c1563/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=c6ef350d-0eee-48e3-a0bb-323ff09c1563"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=c6ef350d-0eee-48e3-a0bb-323ff09c1563"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=c6ef350d-0eee-48e3-a0bb-323ff09c1563"
          }
        }
      }
    },
    {
      "id": "428c6bd7-5aa2-4274-9f0c-c329529e2bc4",
      "type": "object_occurrence",
      "attributes": {
        "classification_code": "A",
        "description": null,
        "name": "OOC 3",
        "position": null,
        "prefix": "=",
        "reference_designation": null,
        "type": "regular",
        "hex_color": "#",
        "number": "1",
        "validation_errors": [

        ]
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=428c6bd7-5aa2-4274-9f0c-c329529e2bc4&filter[target_type_eq]=object_occurrence",
            "self": "/object_occurrences/428c6bd7-5aa2-4274-9f0c-c329529e2bc4/relationships/tags"
          }
        },
        "context": {
          "links": {
            "related": "/contexts/06ece9db-63ad-44f7-96c5-b49028553493"
          }
        },
        "part_of": {
          "links": {
            "related": "/object_occurrences/c6ef350d-0eee-48e3-a0bb-323ff09c1563",
            "self": "/object_occurrences/428c6bd7-5aa2-4274-9f0c-c329529e2bc4/relationships/part_of"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/object_occurrences/428c6bd7-5aa2-4274-9f0c-c329529e2bc4/relationships/components"
          }
        },
        "allowed_children_syntax_nodes": {
          "links": {
            "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=428c6bd7-5aa2-4274-9f0c-c329529e2bc4"
          }
        },
        "allowed_children_syntax_elements": {
          "links": {
            "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=428c6bd7-5aa2-4274-9f0c-c329529e2bc4"
          }
        },
        "allowed_children_classification_tables": {
          "links": {
            "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=428c6bd7-5aa2-4274-9f0c-c329529e2bc4"
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
GET /object_occurrences/7a896903-82ef-4432-920e-1fbb78d033f0
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
X-Request-Id: 79b198cb-70fe-4ecd-9d9e-2ef4e7a002b0
200 OK
```


```json
{
  "data": {
    "id": "7a896903-82ef-4432-920e-1fbb78d033f0",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 1",
      "position": null,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=7a896903-82ef-4432-920e-1fbb78d033f0&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/7a896903-82ef-4432-920e-1fbb78d033f0/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/338949f5-2f58-4a13-bb10-a4737364e65c"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/b6035747-acd9-4cf3-a3cb-8638ea83745c",
          "self": "/object_occurrences/7a896903-82ef-4432-920e-1fbb78d033f0/relationships/part_of"
        }
      },
      "components": {
        "data": [
          {
            "id": "802b3678-f3c7-4878-b621-1cc27c56fed6",
            "type": "object_occurrence"
          },
          {
            "id": "817cba6a-f8ff-4579-a035-df8ffcc1d965",
            "type": "object_occurrence"
          }
        ],
        "links": {
          "self": "/object_occurrences/7a896903-82ef-4432-920e-1fbb78d033f0/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=7a896903-82ef-4432-920e-1fbb78d033f0"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=7a896903-82ef-4432-920e-1fbb78d033f0"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=7a896903-82ef-4432-920e-1fbb78d033f0"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/7a896903-82ef-4432-920e-1fbb78d033f0"
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
POST /object_occurrences/12da8590-c4ba-411a-bd9f-5e013b086f47/relationships/components
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

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 06de44d5-4897-46ca-a477-dc237f451dff
201 Created
```


```json
{
  "data": {
    "id": "43dfe1fe-3a13-4564-917f-d1459fd01010",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "XYZ",
      "description": null,
      "name": "ooc",
      "position": null,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=43dfe1fe-3a13-4564-917f-d1459fd01010&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/43dfe1fe-3a13-4564-917f-d1459fd01010/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/46432113-17fc-487e-9208-0e25feb5738f"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/12da8590-c4ba-411a-bd9f-5e013b086f47",
          "self": "/object_occurrences/43dfe1fe-3a13-4564-917f-d1459fd01010/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/43dfe1fe-3a13-4564-917f-d1459fd01010/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=43dfe1fe-3a13-4564-917f-d1459fd01010"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=43dfe1fe-3a13-4564-917f-d1459fd01010"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=43dfe1fe-3a13-4564-917f-d1459fd01010"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/12da8590-c4ba-411a-bd9f-5e013b086f47/relationships/components"
  }
}
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Create external


### Request

#### Endpoint

```plaintext
POST /object_occurrences/ca7d168f-13b0-42de-8caa-7a9fb538c251/relationships/components
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

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 8b909baa-0a3d-4e9d-a94a-1c333c4012bb
201 Created
```


```json
{
  "data": {
    "id": "b9940696-8851-426c-87de-6357625ab2e5",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": null,
      "description": null,
      "name": "external OOC",
      "position": null,
      "prefix": null,
      "reference_designation": null,
      "type": "external",
      "hex_color": "#",
      "number": "",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=b9940696-8851-426c-87de-6357625ab2e5&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/b9940696-8851-426c-87de-6357625ab2e5/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/6c1d484d-9388-4e41-8c12-c8a73dcd6afb"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/ca7d168f-13b0-42de-8caa-7a9fb538c251",
          "self": "/object_occurrences/b9940696-8851-426c-87de-6357625ab2e5/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/b9940696-8851-426c-87de-6357625ab2e5/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=b9940696-8851-426c-87de-6357625ab2e5"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=b9940696-8851-426c-87de-6357625ab2e5"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=b9940696-8851-426c-87de-6357625ab2e5"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/ca7d168f-13b0-42de-8caa-7a9fb538c251/relationships/components"
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
PATCH /object_occurrences/c7257450-1f46-4b17-9289-dfb016f07c0f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:id`

#### Parameters


```json
{
  "data": {
    "id": "c7257450-1f46-4b17-9289-dfb016f07c0f",
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
          "id": "bc21ddfb-8848-4247-9abc-cab5dfde23fb"
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
X-Request-Id: a0096dce-7d80-4ec9-80d3-9ca49953a1da
200 OK
```


```json
{
  "data": {
    "id": "c7257450-1f46-4b17-9289-dfb016f07c0f",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": "New description",
      "name": "New name",
      "position": 2,
      "prefix": "%",
      "reference_designation": null,
      "type": "external",
      "hex_color": "#ffa500",
      "number": "8",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=c7257450-1f46-4b17-9289-dfb016f07c0f&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/c7257450-1f46-4b17-9289-dfb016f07c0f/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/c119753f-5062-4836-99b4-2b85d5d3f67a"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/bc21ddfb-8848-4247-9abc-cab5dfde23fb",
          "self": "/object_occurrences/c7257450-1f46-4b17-9289-dfb016f07c0f/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/c7257450-1f46-4b17-9289-dfb016f07c0f/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=c7257450-1f46-4b17-9289-dfb016f07c0f"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=c7257450-1f46-4b17-9289-dfb016f07c0f"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=c7257450-1f46-4b17-9289-dfb016f07c0f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c7257450-1f46-4b17-9289-dfb016f07c0f"
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
POST /object_occurrences/a7530222-c1e6-4ee0-a01b-94c3c84189e9/copy
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`POST /object_occurrences/:id/copy`

#### Parameters


```json
{
  "data": {
    "id": "0f6a268d-3e5b-4dae-b8d0-a1db2cf017a4",
    "type": "object_occurrence"
  }
}
```


| Name | Description |
|:-----|:------------|
| data[id]  | ID of copied OOC |



### Response

```plaintext
Location: http://example.org/polling/45e65e1a8b1397c509800bb2
Content-Type: text/html; charset=utf-8
X-Request-Id: cf39f992-b69c-4f08-a7a7-0d638dec364d
202 Accepted
```


```json
<html><body>You are being <a href="http://example.org/polling/45e65e1a8b1397c509800bb2">redirected</a>.</body></html>
```



#### Fields

| Name       | Description         |
|:-----------|:--------------------|
| data[attributes][name] | Object Occurrence name |


## Delete


### Request

#### Endpoint

```plaintext
DELETE /object_occurrences/e8acbb6b-ae95-4f73-a585-3796c0e8529b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f38730e5-a35a-4e41-bcff-95231c243071
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
PATCH /object_occurrences/c95deb52-9fbf-46f5-b01d-7544e6e2f15c/relationships/part_of
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /object_occurrences/:object_occurrence_id/relationships/part_of`

#### Parameters


```json
{
  "data": {
    "id": "acc0712b-2d09-43e6-aa90-356d69070b26",
    "type": "object_occurrence"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ccc4922d-3512-4f83-9da8-dc1ac94a994e
200 OK
```


```json
{
  "data": {
    "id": "c95deb52-9fbf-46f5-b01d-7544e6e2f15c",
    "type": "object_occurrence",
    "attributes": {
      "classification_code": "A",
      "description": null,
      "name": "OOC 2",
      "position": null,
      "prefix": "=",
      "reference_designation": null,
      "type": "regular",
      "hex_color": "#",
      "number": "1",
      "validation_errors": [

      ]
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=c95deb52-9fbf-46f5-b01d-7544e6e2f15c&filter[target_type_eq]=object_occurrence",
          "self": "/object_occurrences/c95deb52-9fbf-46f5-b01d-7544e6e2f15c/relationships/tags"
        }
      },
      "context": {
        "links": {
          "related": "/contexts/cf1c4eab-932d-4435-b100-2dbe40ffb710"
        }
      },
      "part_of": {
        "links": {
          "related": "/object_occurrences/acc0712b-2d09-43e6-aa90-356d69070b26",
          "self": "/object_occurrences/c95deb52-9fbf-46f5-b01d-7544e6e2f15c/relationships/part_of"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/object_occurrences/c95deb52-9fbf-46f5-b01d-7544e6e2f15c/relationships/components"
        }
      },
      "allowed_children_syntax_nodes": {
        "links": {
          "related": "/syntax_nodes?filter%5Ballowed_for_object_occurrence_id_eq%5D=c95deb52-9fbf-46f5-b01d-7544e6e2f15c"
        }
      },
      "allowed_children_syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter%5Ballowed_for_object_occurrence_id_eq%5D=c95deb52-9fbf-46f5-b01d-7544e6e2f15c"
        }
      },
      "allowed_children_classification_tables": {
        "links": {
          "related": "/classification_tables?filter%5Ballowed_for_object_occurrence_id_eq%5D=c95deb52-9fbf-46f5-b01d-7544e6e2f15c"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/c95deb52-9fbf-46f5-b01d-7544e6e2f15c/relationships/part_of"
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
POST /classification_tables/8054ae9c-a5d6-4700-beda-853faa8453d0/relationships/tags
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
X-Request-Id: 64170349-abcd-4681-9fac-b66cad281921
201 Created
```


```json
{
  "data": {
    "id": "c2b70279-abc7-479f-b80b-c42a64212349",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/8054ae9c-a5d6-4700-beda-853faa8453d0/relationships/tags"
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
POST /classification_tables/c1402d47-928c-4727-ac33-69b2ed15d693/relationships/tags
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
    "id": "81451b7a-c7fe-457c-bdb8-754f81a3094c"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ae659ea0-43da-4110-bd10-ceb6b59a7e53
201 Created
```


```json
{
  "data": {
    "id": "81451b7a-c7fe-457c-bdb8-754f81a3094c",
    "type": "tag",
    "attributes": {
      "value": "Tag value 7"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/c1402d47-928c-4727-ac33-69b2ed15d693/relationships/tags"
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
DELETE /classification_tables/bf22716b-3356-4530-9ee6-25f0873e33e9/relationships/tags/83e5a6bf-e436-43b1-ae3b-1c139cce6b2a
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 44719a5b-a85d-4452-bf58-436921bb7292
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
X-Request-Id: f3eaface-9e85-4795-b561-912adb7c198c
200 OK
```


```json
{
  "data": [
    {
      "id": "5355bf23-073a-4e65-b387-696159546c16",
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
            "related": "/tags?filter[target_id_eq]=5355bf23-073a-4e65-b387-696159546c16&filter[target_type_eq]=classification_table",
            "self": "/classification_tables/5355bf23-073a-4e65-b387-696159546c16/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=5355bf23-073a-4e65-b387-696159546c16",
            "self": "/classification_tables/5355bf23-073a-4e65-b387-696159546c16/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "1c782bd4-6985-4548-a740-a679a497d30d",
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
            "related": "/tags?filter[target_id_eq]=1c782bd4-6985-4548-a740-a679a497d30d&filter[target_type_eq]=classification_table",
            "self": "/classification_tables/1c782bd4-6985-4548-a740-a679a497d30d/relationships/tags"
          }
        },
        "account": {
          "links": {
            "related": "/"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_table_id_eq]=1c782bd4-6985-4548-a740-a679a497d30d",
            "self": "/classification_tables/1c782bd4-6985-4548-a740-a679a497d30d/relationships/classification_entries",
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
GET /classification_tables/cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4
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
X-Request-Id: ca5524be-dd74-463f-9a5e-7937e0a9cd7b
200 OK
```


```json
{
  "data": {
    "id": "cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4",
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
          "related": "/tags?filter[target_id_eq]=cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4",
          "self": "/classification_tables/cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/cb6bef44-8aa5-4181-b9f7-e2cd0fc91bd4"
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
PATCH /classification_tables/9bf42a40-3a4a-4ef8-8709-85f4939fb625
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_tables/:id`

#### Parameters


```json
{
  "data": {
    "id": "9bf42a40-3a4a-4ef8-8709-85f4939fb625",
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
X-Request-Id: 8f86059c-58e0-4a15-9c27-9f30c626dad2
200 OK
```


```json
{
  "data": {
    "id": "9bf42a40-3a4a-4ef8-8709-85f4939fb625",
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
          "related": "/tags?filter[target_id_eq]=9bf42a40-3a4a-4ef8-8709-85f4939fb625&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/9bf42a40-3a4a-4ef8-8709-85f4939fb625/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=9bf42a40-3a4a-4ef8-8709-85f4939fb625",
          "self": "/classification_tables/9bf42a40-3a4a-4ef8-8709-85f4939fb625/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/9bf42a40-3a4a-4ef8-8709-85f4939fb625"
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
DELETE /classification_tables/b6107ee8-c5ec-4ece-9afe-84d3af7d42f7
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_tables/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 9cd494d6-9bac-40e4-a302-e5ede4b50244
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
POST /classification_tables/30fd7efd-78c1-4db3-91ac-a25a7009042d/publish
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
X-Request-Id: d45eada3-9c98-4158-87e1-2a7effda4c32
200 OK
```


```json
{
  "data": {
    "id": "30fd7efd-78c1-4db3-91ac-a25a7009042d",
    "type": "classification_table",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "description": null,
      "name": "CT 1",
      "published": true,
      "published_at": "2020-03-17T15:26:19.972Z",
      "type": "core",
      "max_classification_entries_depth": 3
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=30fd7efd-78c1-4db3-91ac-a25a7009042d&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/30fd7efd-78c1-4db3-91ac-a25a7009042d/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=30fd7efd-78c1-4db3-91ac-a25a7009042d",
          "self": "/classification_tables/30fd7efd-78c1-4db3-91ac-a25a7009042d/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/30fd7efd-78c1-4db3-91ac-a25a7009042d/publish"
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
POST /classification_tables/dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a/archive
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
X-Request-Id: a9219fb4-d166-4f29-89a4-45489d27617b
200 OK
```


```json
{
  "data": {
    "id": "dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a",
    "type": "classification_table",
    "attributes": {
      "archived": true,
      "archived_at": "2020-03-17T15:26:20.579Z",
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
          "related": "/tags?filter[target_id_eq]=dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a",
          "self": "/classification_tables/dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/dbcbbf51-1b5d-48d6-9866-45c91f0f3a1a/archive"
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
X-Request-Id: 364f8126-10e8-430b-8532-a807df9f6749
201 Created
```


```json
{
  "data": {
    "id": "775775a7-c8c0-4ac0-9138-1a65e54ec231",
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
          "related": "/tags?filter[target_id_eq]=775775a7-c8c0-4ac0-9138-1a65e54ec231&filter[target_type_eq]=classification_table",
          "self": "/classification_tables/775775a7-c8c0-4ac0-9138-1a65e54ec231/relationships/tags"
        }
      },
      "account": {
        "links": {
          "related": "/"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_table_id_eq]=775775a7-c8c0-4ac0-9138-1a65e54ec231",
          "self": "/classification_tables/775775a7-c8c0-4ac0-9138-1a65e54ec231/relationships/classification_entries",
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
POST /classification_entries/7ce76a15-e420-493e-ae94-dcc39f0b72c5/relationships/tags
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
X-Request-Id: f50c1481-96a6-4e12-90b1-372e202a1866
201 Created
```


```json
{
  "data": {
    "id": "99ff38f6-ca2b-429f-8e74-dcc58812c90b",
    "type": "tag",
    "attributes": {
      "value": "New tag value"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/7ce76a15-e420-493e-ae94-dcc39f0b72c5/relationships/tags"
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
POST /classification_entries/c46d469c-a965-4a10-802d-5ef100502948/relationships/tags
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
    "id": "e764185c-7014-429c-a40c-0f47946e91ad"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: c1619c1a-d60d-4196-8da4-8b1c6483582f
201 Created
```


```json
{
  "data": {
    "id": "e764185c-7014-429c-a40c-0f47946e91ad",
    "type": "tag",
    "attributes": {
      "value": "Tag value 9"
    },
    "relationships": {
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/c46d469c-a965-4a10-802d-5ef100502948/relationships/tags"
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
DELETE /classification_entries/8ca8a838-28ff-4251-80a9-aa0feaa06dd7/relationships/tags/2c41f187-6f8a-4ef3-a7b9-cfd4d80f178c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id/relationships/tags/:tag_id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: ca19cad8-ed61-4ed1-9cd1-c5b6b7ad35f2
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
X-Request-Id: 950dcc27-5262-4ec5-b36c-1bcb78ca352d
200 OK
```


```json
{
  "data": [
    {
      "id": "11cb5174-40de-44e7-af41-ad4abde0f2c2",
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
            "related": "/tags?filter[target_id_eq]=11cb5174-40de-44e7-af41-ad4abde0f2c2&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/11cb5174-40de-44e7-af41-ad4abde0f2c2/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=11cb5174-40de-44e7-af41-ad4abde0f2c2",
            "self": "/classification_entries/11cb5174-40de-44e7-af41-ad4abde0f2c2/relationships/classification_entries",
            "meta": {
              "count": 1
            }
          }
        }
      }
    },
    {
      "id": "d3a7e18f-83ae-457b-adc7-269a240d771c",
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
            "related": "/tags?filter[target_id_eq]=d3a7e18f-83ae-457b-adc7-269a240d771c&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/d3a7e18f-83ae-457b-adc7-269a240d771c/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "11cb5174-40de-44e7-af41-ad4abde0f2c2",
            "type": "classification_entry"
          },
          "links": {
            "self": "/classification_entries/d3a7e18f-83ae-457b-adc7-269a240d771c"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=d3a7e18f-83ae-457b-adc7-269a240d771c",
            "self": "/classification_entries/d3a7e18f-83ae-457b-adc7-269a240d771c/relationships/classification_entries",
            "meta": {
              "count": 0
            }
          }
        }
      }
    },
    {
      "id": "a3af4b6e-ac6b-4475-ab5e-a9b262863816",
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
            "related": "/tags?filter[target_id_eq]=a3af4b6e-ac6b-4475-ab5e-a9b262863816&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/a3af4b6e-ac6b-4475-ab5e-a9b262863816/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=a3af4b6e-ac6b-4475-ab5e-a9b262863816",
            "self": "/classification_entries/a3af4b6e-ac6b-4475-ab5e-a9b262863816/relationships/classification_entries",
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
GET /classification_entries/52f630d7-08c7-4c69-a4e2-e5604cb2863a
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
X-Request-Id: 54b347d6-d8f9-4546-a4c8-bc9541a687b0
200 OK
```


```json
{
  "data": {
    "id": "52f630d7-08c7-4c69-a4e2-e5604cb2863a",
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
          "related": "/tags?filter[target_id_eq]=52f630d7-08c7-4c69-a4e2-e5604cb2863a&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/52f630d7-08c7-4c69-a4e2-e5604cb2863a/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=52f630d7-08c7-4c69-a4e2-e5604cb2863a",
          "self": "/classification_entries/52f630d7-08c7-4c69-a4e2-e5604cb2863a/relationships/classification_entries",
          "meta": {
            "count": 1
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/52f630d7-08c7-4c69-a4e2-e5604cb2863a"
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
PATCH /classification_entries/d7aa191d-353a-48c5-8e7d-eb86675dc49c
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /classification_entries/:id`

#### Parameters


```json
{
  "data": {
    "id": "d7aa191d-353a-48c5-8e7d-eb86675dc49c",
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
X-Request-Id: 7d47e36b-1b8a-49fb-aeec-42f382faf388
200 OK
```


```json
{
  "data": {
    "id": "d7aa191d-353a-48c5-8e7d-eb86675dc49c",
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
          "related": "/tags?filter[target_id_eq]=d7aa191d-353a-48c5-8e7d-eb86675dc49c&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/d7aa191d-353a-48c5-8e7d-eb86675dc49c/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "ef9bbbc2-ab49-4046-8ed0-6305cfd2d0c9",
          "type": "classification_entry"
        },
        "links": {
          "self": "/classification_entries/d7aa191d-353a-48c5-8e7d-eb86675dc49c"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=d7aa191d-353a-48c5-8e7d-eb86675dc49c",
          "self": "/classification_entries/d7aa191d-353a-48c5-8e7d-eb86675dc49c/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_entries/d7aa191d-353a-48c5-8e7d-eb86675dc49c"
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
DELETE /classification_entries/4b724593-9132-4475-b7a5-a44341c95e14
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /classification_entries/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: f32c8602-bddc-430d-95c7-baaee0f9a9c0
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
POST /classification_tables/cf79ae19-643e-4871-b32f-82a898251863/relationships/classification_entries
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
X-Request-Id: 16e54a63-db50-499b-bc6a-d741a0c7940d
201 Created
```


```json
{
  "data": {
    "id": "6bf7045e-17a9-4df0-93b4-311e165d0754",
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
          "related": "/tags?filter[target_id_eq]=6bf7045e-17a9-4df0-93b4-311e165d0754&filter[target_type_eq]=classification_entry",
          "self": "/classification_entries/6bf7045e-17a9-4df0-93b4-311e165d0754/relationships/tags"
        }
      },
      "classification_entries": {
        "links": {
          "related": "/classification_entries?filter[classification_entry_id_eq]=6bf7045e-17a9-4df0-93b4-311e165d0754",
          "self": "/classification_entries/6bf7045e-17a9-4df0-93b4-311e165d0754/relationships/classification_entries",
          "meta": {
            "count": 0
          }
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/classification_tables/cf79ae19-643e-4871-b32f-82a898251863/relationships/classification_entries"
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
X-Request-Id: 25439170-4ff2-4cf8-8139-eee238f5fb67
200 OK
```


```json
{
  "data": [
    {
      "id": "25c98ee2-9570-4aa7-972e-cb1d2b0c49d9",
      "type": "syntax",
      "attributes": {
        "account_id": "334a17aa-dd17-4e51-83d6-70dc7ad12e04",
        "archived": false,
        "archived_at": null,
        "description": "Description",
        "name": "Syntax 02b20da5cd3f",
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
            "related": "/syntax_elements?filter[syntax_id_eq]=25c98ee2-9570-4aa7-972e-cb1d2b0c49d9",
            "self": "/syntaxes/25c98ee2-9570-4aa7-972e-cb1d2b0c49d9/relationships/syntax_elements"
          }
        },
        "root_syntax_node": {
          "links": {
            "related": "/syntax_nodes/65659521-91bc-41b3-a3a3-e26416fdca5c",
            "self": "/syntax_nodes/65659521-91bc-41b3-a3a3-e26416fdca5c/relationships/components"
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
GET /syntaxes/9fa0b66f-c935-4b0a-9cad-06e18b988e77
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
X-Request-Id: 58803c5c-0961-4165-aa45-74ad5a588f00
200 OK
```


```json
{
  "data": {
    "id": "9fa0b66f-c935-4b0a-9cad-06e18b988e77",
    "type": "syntax",
    "attributes": {
      "account_id": "345ced55-eeaa-4030-8213-fea8d7ec57ff",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 63cfbcba13b3",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=9fa0b66f-c935-4b0a-9cad-06e18b988e77",
          "self": "/syntaxes/9fa0b66f-c935-4b0a-9cad-06e18b988e77/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/80382fa9-17f3-4116-b69a-ff21e0e6a387",
          "self": "/syntax_nodes/80382fa9-17f3-4116-b69a-ff21e0e6a387/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/9fa0b66f-c935-4b0a-9cad-06e18b988e77"
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
X-Request-Id: 4b044183-ba04-411c-84c0-0a177d0a97ee
201 Created
```


```json
{
  "data": {
    "id": "e1b01bec-3902-44cf-b87b-8d28e4df54e2",
    "type": "syntax",
    "attributes": {
      "account_id": "46114ab8-1b8e-4296-962b-2d02d8e4549a",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=e1b01bec-3902-44cf-b87b-8d28e4df54e2",
          "self": "/syntaxes/e1b01bec-3902-44cf-b87b-8d28e4df54e2/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/6eaef15a-bbb8-42d4-8996-7f48e819e850",
          "self": "/syntax_nodes/6eaef15a-bbb8-42d4-8996-7f48e819e850/relationships/components"
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
PATCH /syntaxes/91baaf2f-de87-42e7-8abb-d2d926f687d8
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntaxes/:id`

#### Parameters


```json
{
  "data": {
    "id": "91baaf2f-de87-42e7-8abb-d2d926f687d8",
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
X-Request-Id: 118a5e45-8c56-4952-b4a0-9a98d51991a9
200 OK
```


```json
{
  "data": {
    "id": "91baaf2f-de87-42e7-8abb-d2d926f687d8",
    "type": "syntax",
    "attributes": {
      "account_id": "bedea1a5-728c-4e8f-a3b3-1ca627670871",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=91baaf2f-de87-42e7-8abb-d2d926f687d8",
          "self": "/syntaxes/91baaf2f-de87-42e7-8abb-d2d926f687d8/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/0ff3d618-3fb3-42a1-99ec-dd42049ba413",
          "self": "/syntax_nodes/0ff3d618-3fb3-42a1-99ec-dd42049ba413/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/91baaf2f-de87-42e7-8abb-d2d926f687d8"
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
DELETE /syntaxes/489d3cba-b182-410e-bc54-a28588c66a2f
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntaxes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 701ebb3b-756d-43c9-8abd-00e454084f1d
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
POST /syntaxes/743f0d1e-f9cb-4d86-98a5-0b3e77236b16/publish
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
X-Request-Id: 013461f5-26f1-4d55-9831-c20c47325087
200 OK
```


```json
{
  "data": {
    "id": "743f0d1e-f9cb-4d86-98a5-0b3e77236b16",
    "type": "syntax",
    "attributes": {
      "account_id": "a993cf22-1e9e-4c34-86b9-ace3a19ab493",
      "archived": false,
      "archived_at": null,
      "description": "Description",
      "name": "Syntax 224da3cc2c2d",
      "published": true,
      "published_at": "2020-03-17T15:26:31.987Z"
    },
    "relationships": {
      "account": {
        "links": {
          "related": "/"
        }
      },
      "syntax_elements": {
        "links": {
          "related": "/syntax_elements?filter[syntax_id_eq]=743f0d1e-f9cb-4d86-98a5-0b3e77236b16",
          "self": "/syntaxes/743f0d1e-f9cb-4d86-98a5-0b3e77236b16/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/07df0cba-8f05-4a2d-a235-a7762b69b740",
          "self": "/syntax_nodes/07df0cba-8f05-4a2d-a235-a7762b69b740/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/743f0d1e-f9cb-4d86-98a5-0b3e77236b16/publish"
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
POST /syntaxes/319db887-91a4-4146-b54c-1c5506b4149c/archive
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
X-Request-Id: a0e5e538-bb3c-4772-baf9-a6dbec040c58
200 OK
```


```json
{
  "data": {
    "id": "319db887-91a4-4146-b54c-1c5506b4149c",
    "type": "syntax",
    "attributes": {
      "account_id": "10bea9d3-63aa-49e6-85d0-cee561d94e7c",
      "archived": true,
      "archived_at": "2020-03-17T15:26:32.523Z",
      "description": "Description",
      "name": "Syntax c58d572782af",
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
          "related": "/syntax_elements?filter[syntax_id_eq]=319db887-91a4-4146-b54c-1c5506b4149c",
          "self": "/syntaxes/319db887-91a4-4146-b54c-1c5506b4149c/relationships/syntax_elements"
        }
      },
      "root_syntax_node": {
        "links": {
          "related": "/syntax_nodes/4551c0a3-0f6d-4c86-985e-4a2e18468b38",
          "self": "/syntax_nodes/4551c0a3-0f6d-4c86-985e-4a2e18468b38/relationships/components"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/319db887-91a4-4146-b54c-1c5506b4149c/archive"
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
X-Request-Id: 52b54b8f-2524-435c-9cf7-11c968dfac47
200 OK
```


```json
{
  "data": [
    {
      "id": "48659f31-598e-4289-895f-2a908a1290ad",
      "type": "syntax_element",
      "attributes": {
        "aspect": "=",
        "classification_table_id": "c99165a4-fabb-4132-95fa-73a21d43aa88",
        "hex_color": "784784",
        "max_number": 9,
        "min_number": 1,
        "name": "Syntax element 6481394dd540"
      },
      "relationships": {
        "syntax": {
          "links": {
            "related": "/syntaxes/e6e1eb32-3c8c-4665-948c-60a47e5d2c1d"
          }
        },
        "classification_table": {
          "links": {
            "related": "/classification_tables/c99165a4-fabb-4132-95fa-73a21d43aa88",
            "self": "/syntax_elements/48659f31-598e-4289-895f-2a908a1290ad/relationships/classification_table"
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
GET /syntax_elements/3f1547d3-103a-4fd8-9776-ad7b6cbe8ced
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
X-Request-Id: 984deec0-9c47-4544-8e76-a9dc39b438db
200 OK
```


```json
{
  "data": {
    "id": "3f1547d3-103a-4fd8-9776-ad7b6cbe8ced",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "1c4490c8-6098-44b5-ad82-60034649c423",
      "hex_color": "1d071d",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element a30c8cd21dbf"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/5430fe9f-85d7-4222-bc39-38e57fb694d4"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/1c4490c8-6098-44b5-ad82-60034649c423",
          "self": "/syntax_elements/3f1547d3-103a-4fd8-9776-ad7b6cbe8ced/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/3f1547d3-103a-4fd8-9776-ad7b6cbe8ced"
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
POST /syntaxes/fadce4cd-60c3-45d8-8303-cfd032815686/relationships/syntax_elements
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
          "id": "5f03c857-65a3-40e1-b970-49b359c9354f"
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
X-Request-Id: 89c10eb7-6711-4812-889c-3005cd3cea18
201 Created
```


```json
{
  "data": {
    "id": "72971150-27f8-4e65-98d9-b64a8e18bbaf",
    "type": "syntax_element",
    "attributes": {
      "aspect": "#",
      "classification_table_id": "5f03c857-65a3-40e1-b970-49b359c9354f",
      "hex_color": "001122",
      "max_number": 5,
      "min_number": 1,
      "name": "Element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/fadce4cd-60c3-45d8-8303-cfd032815686"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/5f03c857-65a3-40e1-b970-49b359c9354f",
          "self": "/syntax_elements/72971150-27f8-4e65-98d9-b64a8e18bbaf/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntaxes/fadce4cd-60c3-45d8-8303-cfd032815686/relationships/syntax_elements"
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
PATCH /syntax_elements/f2975d0a-e69b-4b61-a85f-7b56705b7d1b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:id`

#### Parameters


```json
{
  "data": {
    "id": "f2975d0a-e69b-4b61-a85f-7b56705b7d1b",
    "type": "syntax_element",
    "attributes": {
      "name": "New element"
    },
    "relationships": {
      "classification_table": {
        "data": {
          "type": "classification_table",
          "id": "bd8d2cf0-33a4-4dbe-94a9-d2f868aa8b52"
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
X-Request-Id: ea456081-6a53-4d25-b085-9ddd382b3339
200 OK
```


```json
{
  "data": {
    "id": "f2975d0a-e69b-4b61-a85f-7b56705b7d1b",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "bd8d2cf0-33a4-4dbe-94a9-d2f868aa8b52",
      "hex_color": "ffc4f5",
      "max_number": 9,
      "min_number": 1,
      "name": "New element"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/e5e1afb0-9a36-4f72-9ee9-baf04e8fb7d9"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/bd8d2cf0-33a4-4dbe-94a9-d2f868aa8b52",
          "self": "/syntax_elements/f2975d0a-e69b-4b61-a85f-7b56705b7d1b/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/f2975d0a-e69b-4b61-a85f-7b56705b7d1b"
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
DELETE /syntax_elements/b5f3e40c-5123-4332-a3d5-d2de380f8f38
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 991b6d36-95a1-4fc8-ae61-fb19047a98c8
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
PATCH /syntax_elements/0e043fa4-bce4-4d07-8230-fb2ecd458ba3/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


```json
{
  "data": {
    "id": "54caf16a-d3f7-48ce-a6b3-652d7952ec3c",
    "type": "classification_table"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: cc9328c2-7d92-443f-b7ce-1b396d2334b1
200 OK
```


```json
{
  "data": {
    "id": "0e043fa4-bce4-4d07-8230-fb2ecd458ba3",
    "type": "syntax_element",
    "attributes": {
      "aspect": "=",
      "classification_table_id": "54caf16a-d3f7-48ce-a6b3-652d7952ec3c",
      "hex_color": "c8487c",
      "max_number": 9,
      "min_number": 1,
      "name": "Syntax element 294b53acc4b1"
    },
    "relationships": {
      "syntax": {
        "links": {
          "related": "/syntaxes/576be461-aea1-42fd-b7e9-0fcd02bc11e4"
        }
      },
      "classification_table": {
        "links": {
          "related": "/classification_tables/54caf16a-d3f7-48ce-a6b3-652d7952ec3c",
          "self": "/syntax_elements/0e043fa4-bce4-4d07-8230-fb2ecd458ba3/relationships/classification_table"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_elements/0e043fa4-bce4-4d07-8230-fb2ecd458ba3/relationships/classification_table"
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
DELETE /syntax_elements/c80487ef-54d9-4f81-bcef-f095f58e64d1/relationships/classification_table
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_elements/:syntax_element_id/relationships/classification_table`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 3b7df598-991f-48dd-b1d8-bd2d63fe8183
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
X-Request-Id: bc6cf04a-a151-4aa4-8a44-c805e838b39d
200 OK
```


```json
{
  "data": [
    {
      "id": "e77033c2-4036-4f6a-88e8-34ab477716d6",
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
              "id": "aa3185c0-98a3-4f99-8776-b8930c0224e1",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/e77033c2-4036-4f6a-88e8-34ab477716d6/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e77033c2-4036-4f6a-88e8-34ab477716d6/relationships/parent",
            "related": "/syntax_nodes/e77033c2-4036-4f6a-88e8-34ab477716d6"
          }
        }
      }
    },
    {
      "id": "819d1bf5-afdd-4afe-b19c-20c145fb8f16",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fa58206d-2eee-4a26-8222-599d98c149b5"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/819d1bf5-afdd-4afe-b19c-20c145fb8f16/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/819d1bf5-afdd-4afe-b19c-20c145fb8f16/relationships/parent",
            "related": "/syntax_nodes/819d1bf5-afdd-4afe-b19c-20c145fb8f16"
          }
        }
      }
    },
    {
      "id": "a2d229f0-aa2b-4a44-b0ba-2af870c8c220",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fa58206d-2eee-4a26-8222-599d98c149b5"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/a2d229f0-aa2b-4a44-b0ba-2af870c8c220/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/a2d229f0-aa2b-4a44-b0ba-2af870c8c220/relationships/parent",
            "related": "/syntax_nodes/a2d229f0-aa2b-4a44-b0ba-2af870c8c220"
          }
        }
      }
    },
    {
      "id": "fccc7cb6-0efc-494f-90e7-262fd38bf6e0",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fa58206d-2eee-4a26-8222-599d98c149b5"
          }
        },
        "components": {
          "data": [
            {
              "id": "a2d229f0-aa2b-4a44-b0ba-2af870c8c220",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/fccc7cb6-0efc-494f-90e7-262fd38bf6e0/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/fccc7cb6-0efc-494f-90e7-262fd38bf6e0/relationships/parent",
            "related": "/syntax_nodes/fccc7cb6-0efc-494f-90e7-262fd38bf6e0"
          }
        }
      }
    },
    {
      "id": "aa3185c0-98a3-4f99-8776-b8930c0224e1",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/fa58206d-2eee-4a26-8222-599d98c149b5"
          }
        },
        "components": {
          "data": [
            {
              "id": "fccc7cb6-0efc-494f-90e7-262fd38bf6e0",
              "type": "syntax_node"
            },
            {
              "id": "819d1bf5-afdd-4afe-b19c-20c145fb8f16",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/aa3185c0-98a3-4f99-8776-b8930c0224e1/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/aa3185c0-98a3-4f99-8776-b8930c0224e1/relationships/parent",
            "related": "/syntax_nodes/aa3185c0-98a3-4f99-8776-b8930c0224e1"
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
GET /syntax_nodes/a4e5e6ca-b04e-48ba-a910-8940b188617f?depth=2
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
X-Request-Id: 4fddfe5b-c3a3-4aa2-a540-fd68f969cdb0
200 OK
```


```json
{
  "data": {
    "id": "a4e5e6ca-b04e-48ba-a910-8940b188617f",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/b886e001-cf4c-4b85-87f2-82647a471d61"
        }
      },
      "components": {
        "data": [
          {
            "id": "e3a43f09-255e-4d88-9ae3-dd36d7d543bd",
            "type": "syntax_node"
          },
          {
            "id": "11e17662-1632-4374-b4c8-b7513b350813",
            "type": "syntax_node"
          }
        ],
        "links": {
          "self": "/syntax_nodes/a4e5e6ca-b04e-48ba-a910-8940b188617f/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/a4e5e6ca-b04e-48ba-a910-8940b188617f/relationships/parent",
          "related": "/syntax_nodes/a4e5e6ca-b04e-48ba-a910-8940b188617f"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/a4e5e6ca-b04e-48ba-a910-8940b188617f?depth=2"
  },
  "included": [
    {
      "id": "11e17662-1632-4374-b4c8-b7513b350813",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/b886e001-cf4c-4b85-87f2-82647a471d61"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/11e17662-1632-4374-b4c8-b7513b350813/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/11e17662-1632-4374-b4c8-b7513b350813/relationships/parent",
            "related": "/syntax_nodes/11e17662-1632-4374-b4c8-b7513b350813"
          }
        }
      }
    },
    {
      "id": "e3a43f09-255e-4d88-9ae3-dd36d7d543bd",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/b886e001-cf4c-4b85-87f2-82647a471d61"
          }
        },
        "components": {
          "data": [
            {
              "id": "07e0bc8a-274e-4f5f-9237-d82a6ebacc4e",
              "type": "syntax_node"
            }
          ],
          "links": {
            "self": "/syntax_nodes/e3a43f09-255e-4d88-9ae3-dd36d7d543bd/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/e3a43f09-255e-4d88-9ae3-dd36d7d543bd/relationships/parent",
            "related": "/syntax_nodes/e3a43f09-255e-4d88-9ae3-dd36d7d543bd"
          }
        }
      }
    },
    {
      "id": "07e0bc8a-274e-4f5f-9237-d82a6ebacc4e",
      "type": "syntax_node",
      "attributes": {
        "max_depth": 9,
        "min_depth": 1,
        "position": 1
      },
      "relationships": {
        "syntax_element": {
          "links": {
            "related": "/syntax_elements/b886e001-cf4c-4b85-87f2-82647a471d61"
          }
        },
        "components": {
          "data": [

          ],
          "links": {
            "self": "/syntax_nodes/07e0bc8a-274e-4f5f-9237-d82a6ebacc4e/relationships/components"
          }
        },
        "syntax_node": {
          "links": {
            "self": "/syntax_nodes/07e0bc8a-274e-4f5f-9237-d82a6ebacc4e/relationships/parent",
            "related": "/syntax_nodes/07e0bc8a-274e-4f5f-9237-d82a6ebacc4e"
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
POST /syntax_nodes/a21f9b4c-1a84-47e1-b3ab-e256a08b708f/relationships/components
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
          "id": "b6ee7d18-505d-4ae0-a0f9-ee0423a493a1"
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
X-Request-Id: dfc5c8bc-a1b7-4eaa-aff0-bdeb7f9ff4bc
201 Created
```


```json
{
  "data": {
    "id": "7397aa87-b7d3-44be-adb8-6ac160471651",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 5,
      "min_depth": 1,
      "position": 9
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/b6ee7d18-505d-4ae0-a0f9-ee0423a493a1"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/7397aa87-b7d3-44be-adb8-6ac160471651/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/7397aa87-b7d3-44be-adb8-6ac160471651/relationships/parent",
          "related": "/syntax_nodes/7397aa87-b7d3-44be-adb8-6ac160471651"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/a21f9b4c-1a84-47e1-b3ab-e256a08b708f/relationships/components"
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
PATCH /syntax_nodes/fa38d0fe-67fd-45f4-95cb-160396725e5b/relationships/parent
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
    "id": "2fbc3575-d443-4899-8bfa-77d9f08cf156"
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: abc44fcb-6e49-47d8-b2e3-a7b610e1027b
200 OK
```


```json
{
  "data": {
    "id": "fa38d0fe-67fd-45f4-95cb-160396725e5b",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 9,
      "min_depth": 1,
      "position": 1
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/92021f9a-d4c0-4658-b819-1f5373a46355"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/fa38d0fe-67fd-45f4-95cb-160396725e5b/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/fa38d0fe-67fd-45f4-95cb-160396725e5b/relationships/parent",
          "related": "/syntax_nodes/fa38d0fe-67fd-45f4-95cb-160396725e5b"
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
PATCH /syntax_nodes/bb7c4908-4fc4-49c3-bf49-3bb60a39405b
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /syntax_nodes/:id`

#### Parameters


```json
{
  "data": {
    "id": "bb7c4908-4fc4-49c3-bf49-3bb60a39405b",
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
X-Request-Id: be5cbb6d-3882-4b2a-adc6-b245eabc2670
200 OK
```


```json
{
  "data": {
    "id": "bb7c4908-4fc4-49c3-bf49-3bb60a39405b",
    "type": "syntax_node",
    "attributes": {
      "max_depth": 2,
      "min_depth": 1,
      "position": 5
    },
    "relationships": {
      "syntax_element": {
        "links": {
          "related": "/syntax_elements/b450ad6c-faab-4408-9c47-e93d0e2aef6d"
        }
      },
      "components": {
        "data": [

        ],
        "links": {
          "self": "/syntax_nodes/bb7c4908-4fc4-49c3-bf49-3bb60a39405b/relationships/components"
        }
      },
      "syntax_node": {
        "links": {
          "self": "/syntax_nodes/bb7c4908-4fc4-49c3-bf49-3bb60a39405b/relationships/parent",
          "related": "/syntax_nodes/bb7c4908-4fc4-49c3-bf49-3bb60a39405b"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/syntax_nodes/bb7c4908-4fc4-49c3-bf49-3bb60a39405b"
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
DELETE /syntax_nodes/37b9d98c-ec40-4ffa-9889-d84542b0efa3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /syntax_nodes/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 2077ec35-f185-478c-91de-397eb83ee4a1
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
X-Request-Id: 008e1418-4196-4c04-acad-60c1f68e6bc0
200 OK
```


```json
{
  "data": [
    {
      "id": "de951f2e-ee5b-46f2-a080-dda7c1481616",
      "type": "progress_model",
      "attributes": {
        "archived": false,
        "archived_at": null,
        "name": "pm 1",
        "order": 1,
        "published": true,
        "published_at": "2020-03-17T15:26:42.375Z",
        "type": "ObjectOccurrence"
      },
      "relationships": {
        "progress_steps": {
          "links": {
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=de951f2e-ee5b-46f2-a080-dda7c1481616",
            "self": "/progress_models/de951f2e-ee5b-46f2-a080-dda7c1481616/relationships/progress_steps"
          }
        }
      }
    },
    {
      "id": "dc87e1f1-40ad-4949-9f19-fe6460c05137",
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
            "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=dc87e1f1-40ad-4949-9f19-fe6460c05137",
            "self": "/progress_models/dc87e1f1-40ad-4949-9f19-fe6460c05137/relationships/progress_steps"
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
GET /progress_models/bc3f018b-8722-4ff5-a502-78000de2daaa
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
X-Request-Id: 73f3d261-2127-4c8b-88fe-fe9146e79785
200 OK
```


```json
{
  "data": {
    "id": "bc3f018b-8722-4ff5-a502-78000de2daaa",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 1",
      "order": 3,
      "published": true,
      "published_at": "2020-03-17T15:26:43.123Z",
      "type": "ObjectOccurrence"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=bc3f018b-8722-4ff5-a502-78000de2daaa",
          "self": "/progress_models/bc3f018b-8722-4ff5-a502-78000de2daaa/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/bc3f018b-8722-4ff5-a502-78000de2daaa"
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
PATCH /progress_models/1762c13a-4a24-47ba-90a7-1cee8c37bd8d
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_models/:id`

#### Parameters


```json
{
  "data": {
    "id": "1762c13a-4a24-47ba-90a7-1cee8c37bd8d",
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
X-Request-Id: 6f171d87-5f92-4eb1-96a4-91284adfdd9a
200 OK
```


```json
{
  "data": {
    "id": "1762c13a-4a24-47ba-90a7-1cee8c37bd8d",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=1762c13a-4a24-47ba-90a7-1cee8c37bd8d",
          "self": "/progress_models/1762c13a-4a24-47ba-90a7-1cee8c37bd8d/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/1762c13a-4a24-47ba-90a7-1cee8c37bd8d"
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
DELETE /progress_models/176db922-d0d7-4ef2-b96f-c9453435afd4
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_models/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 636e8b90-610c-4da4-a0bb-bde72b292c7e
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
POST /progress_models/cf32ad79-5cee-4ce7-b978-be519beeb70e/publish
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
X-Request-Id: 3264e52c-bfba-474e-ac55-eb807775098c
200 OK
```


```json
{
  "data": {
    "id": "cf32ad79-5cee-4ce7-b978-be519beeb70e",
    "type": "progress_model",
    "attributes": {
      "archived": false,
      "archived_at": null,
      "name": "pm 2",
      "order": 10,
      "published": true,
      "published_at": "2020-03-17T15:26:45.628Z",
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=cf32ad79-5cee-4ce7-b978-be519beeb70e",
          "self": "/progress_models/cf32ad79-5cee-4ce7-b978-be519beeb70e/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/cf32ad79-5cee-4ce7-b978-be519beeb70e/publish"
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
POST /progress_models/945d6b1b-56e7-495f-88d7-0be602c5667e/archive
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
X-Request-Id: 221c6b95-4870-47bb-820a-6fc5e30561bb
200 OK
```


```json
{
  "data": {
    "id": "945d6b1b-56e7-495f-88d7-0be602c5667e",
    "type": "progress_model",
    "attributes": {
      "archived": true,
      "archived_at": "2020-03-17T15:26:46.283Z",
      "name": "pm 2",
      "order": 12,
      "published": false,
      "published_at": null,
      "type": "ObjectOccurrenceRelation"
    },
    "relationships": {
      "progress_steps": {
        "links": {
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=945d6b1b-56e7-495f-88d7-0be602c5667e",
          "self": "/progress_models/945d6b1b-56e7-495f-88d7-0be602c5667e/relationships/progress_steps"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/945d6b1b-56e7-495f-88d7-0be602c5667e/archive"
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
X-Request-Id: 8e0a378a-7da6-4607-877c-1b2f2f03d84b
201 Created
```


```json
{
  "data": {
    "id": "3471e627-39e1-4d39-a459-5f4ff60f1b79",
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
          "related": "/progress_steps?filter%5Bprogress_model_id_eq%5D=3471e627-39e1-4d39-a459-5f4ff60f1b79",
          "self": "/progress_models/3471e627-39e1-4d39-a459-5f4ff60f1b79/relationships/progress_steps"
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
X-Request-Id: 3d7006f2-26e1-4de0-a2b1-b23a039949e3
200 OK
```


```json
{
  "data": [
    {
      "id": "cfeade48-bf47-4d1e-b9b9-24470c932a25",
      "type": "progress_step",
      "attributes": {
        "name": "ps 1",
        "order": 1
      },
      "relationships": {
        "progress_model": {
          "links": {
            "related": "/progress_models/954f8ae5-760c-46d8-842e-e5bb3445c399"
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
GET /progress_steps/973b648b-2c0f-49ca-9a8c-cb1601d68131
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
X-Request-Id: adc7cdee-6ea6-4a7a-875c-7406921d4016
200 OK
```


```json
{
  "data": {
    "id": "973b648b-2c0f-49ca-9a8c-cb1601d68131",
    "type": "progress_step",
    "attributes": {
      "name": "ps 1",
      "order": 2
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/4ee96d60-7222-4a9f-8b66-d2ba99b88b1a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/973b648b-2c0f-49ca-9a8c-cb1601d68131"
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
PATCH /progress_steps/88dd3c93-e528-4350-9734-bfd6581983a3
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /progress_steps/:id`

#### Parameters


```json
{
  "data": {
    "id": "88dd3c93-e528-4350-9734-bfd6581983a3",
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
X-Request-Id: 493c5580-d0e1-4359-b53b-f31151c41bb1
200 OK
```


```json
{
  "data": {
    "id": "88dd3c93-e528-4350-9734-bfd6581983a3",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 3
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/92820c30-d056-4802-8f57-7e7cf49e0599"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_steps/88dd3c93-e528-4350-9734-bfd6581983a3"
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
DELETE /progress_steps/c21a4850-b420-4797-90cb-45c17833a8db
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress_steps/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 35ce5f28-63b6-4712-83e4-bf9cbcf0327b
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
POST /progress_models/c6d9e2bc-b66c-4736-849e-8485df8fbb17/relationships/progress_steps
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
X-Request-Id: 5a846c76-636b-447b-966a-d29bcf7aa88a
201 Created
```


```json
{
  "data": {
    "id": "23bc030b-5062-489b-9997-42cee850c4aa",
    "type": "progress_step",
    "attributes": {
      "name": "New progress step name",
      "order": 999
    },
    "relationships": {
      "progress_model": {
        "links": {
          "related": "/progress_models/c6d9e2bc-b66c-4736-849e-8485df8fbb17"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress_models/c6d9e2bc-b66c-4736-849e-8485df8fbb17/relationships/progress_steps"
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
X-Request-Id: 557db276-8876-43f3-8bf9-4f5e5f803fd6
200 OK
```


```json
{
  "data": [
    {
      "id": "a284a232-4312-4a3c-802e-a8ddccf67eb2",
      "type": "progress_step_checked",
      "relationships": {
        "progress_step": {
          "links": {
            "related": "/progress_steps/822b177b-4834-42d2-8207-4a12307491f0"
          }
        },
        "target": {
          "links": {
            "related": "/object_occurrences/b24f068f-1ced-42bc-9124-0012240fc521"
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
GET /progress/6b41644b-4bc7-4b59-9392-753e44f09f7f
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
X-Request-Id: adc5364b-a028-4e16-a6d9-fe6f1d568a7c
200 OK
```


```json
{
  "data": {
    "id": "6b41644b-4bc7-4b59-9392-753e44f09f7f",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/b35aafb9-f607-4f1e-9e30-d793cbd074de"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/abd1a514-6c5d-4420-ad4a-32ac9eb5b939"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/progress/6b41644b-4bc7-4b59-9392-753e44f09f7f"
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
DELETE /progress/66a45400-13be-43d3-8430-88dd2d53bbff
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /progress/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 11116e8d-dea6-400a-aad1-91f5048a34fc
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
          "id": "689c7424-af74-46ff-b31d-0a2004150040"
        }
      },
      "target": {
        "data": {
          "type": "object_occurrence",
          "id": "de229422-7295-493d-bf9a-0f3a6009977c"
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
X-Request-Id: 91eeba22-3f5b-49ee-9944-af0f4294bad5
201 Created
```


```json
{
  "data": {
    "id": "d6d722b0-e655-473d-a53f-460531bb84b0",
    "type": "progress_step_checked",
    "relationships": {
      "progress_step": {
        "links": {
          "related": "/progress_steps/689c7424-af74-46ff-b31d-0a2004150040"
        }
      },
      "target": {
        "links": {
          "related": "/object_occurrences/de229422-7295-493d-bf9a-0f3a6009977c"
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
X-Request-Id: 35ae996f-95ba-49a0-bdaa-26613ceb7102
200 OK
```


```json
{
  "data": [
    {
      "id": "4fc108f3-76fc-45d0-8256-f7da78af31bb",
      "type": "project_setting",
      "attributes": {
        "context_revisions_to_keep": 5,
        "contexts_limit": 10,
        "project_id": "4b1b9f69-136f-4e44-a850-7aaf29409f9d"
      },
      "relationships": {
        "project": {
          "links": {
            "related": "/projects/4b1b9f69-136f-4e44-a850-7aaf29409f9d"
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
GET /projects/db000100-38b9-439b-baed-06b21ff8e856/relationships/project_setting
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
X-Request-Id: 4c361e61-a0e8-4b5c-84d4-b08f54caf69a
200 OK
```


```json
{
  "data": {
    "id": "bebc7946-288e-464c-a9b9-0ed0e15ce81c",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 5,
      "contexts_limit": 10,
      "project_id": "db000100-38b9-439b-baed-06b21ff8e856"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/db000100-38b9-439b-baed-06b21ff8e856"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/db000100-38b9-439b-baed-06b21ff8e856/relationships/project_setting"
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
PATCH /projects/7ea72933-8562-48f2-8cc5-1d723681435a/relationships/project_setting
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`PATCH /projects/:project_id/relationships/project_setting`

#### Parameters


```json
{
  "data": {
    "project_id": "7ea72933-8562-48f2-8cc5-1d723681435a",
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
X-Request-Id: 4fb9481f-dd8c-4892-9660-ec997c5e3553
200 OK
```


```json
{
  "data": {
    "id": "3cdd2a33-9038-4523-901d-d8d745f460dc",
    "type": "project_setting",
    "attributes": {
      "context_revisions_to_keep": 1,
      "contexts_limit": 2,
      "project_id": "7ea72933-8562-48f2-8cc5-1d723681435a"
    },
    "relationships": {
      "project": {
        "links": {
          "related": "/projects/7ea72933-8562-48f2-8cc5-1d723681435a"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/projects/7ea72933-8562-48f2-8cc5-1d723681435a/relationships/project_setting"
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
X-Request-Id: a719c7d4-fa79-4254-a79b-65ed34c7fe47
200 OK
```


```json
{
  "data": [
    {
      "id": "c1bc4e83-c335-4974-b327-304052c75ab1",
      "type": "system_element",
      "attributes": {
        "name": "C1-D1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/c1bc4e83-c335-4974-b327-304052c75ab1"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/c1bc4e83-c335-4974-b327-304052c75ab1"
          }
        }
      }
    },
    {
      "id": "5ae63824-c489-4413-a4f5-4d800fd0124e",
      "type": "system_element",
      "attributes": {
        "name": "OOC c99ce840380b-A1",
        "description": null
      },
      "relationships": {
        "ambiguous_components": {
          "links": {
            "self": "/object_occurrences/5ae63824-c489-4413-a4f5-4d800fd0124e"
          }
        },
        "unambiguous_components": {
          "links": {
            "self": "/object_occurrences/5ae63824-c489-4413-a4f5-4d800fd0124e"
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
GET /system_elements/6005e9ac-eee3-4c17-8f0f-58e2d4b3363e
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
X-Request-Id: 047b4c50-4123-446d-899c-6a3a429c8aa7
200 OK
```


```json
{
  "data": {
    "id": "6005e9ac-eee3-4c17-8f0f-58e2d4b3363e",
    "type": "system_element",
    "attributes": {
      "name": "OOC db3fc45b9564-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/6005e9ac-eee3-4c17-8f0f-58e2d4b3363e"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/6005e9ac-eee3-4c17-8f0f-58e2d4b3363e"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/system_elements/6005e9ac-eee3-4c17-8f0f-58e2d4b3363e"
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
POST /object_occurrences/f36eb7e9-361a-4277-a972-c029912cf655/relationships/system_elements
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
      "target_id": "2a56fafd-31cb-4205-8e4b-dbb139699b61"
    }
  }
}
```

None known.


### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: ffddda2a-b1ae-4efa-b103-a0ff9c4520ed
201 Created
```


```json
{
  "data": {
    "id": "791655d5-cde3-4c47-a94f-e61a7446f757",
    "type": "system_element",
    "attributes": {
      "name": "OOC 7bc33e328f80-A1",
      "description": null
    },
    "relationships": {
      "ambiguous_components": {
        "links": {
          "self": "/object_occurrences/791655d5-cde3-4c47-a94f-e61a7446f757"
        }
      },
      "unambiguous_components": {
        "links": {
          "self": "/object_occurrences/791655d5-cde3-4c47-a94f-e61a7446f757"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrences/f36eb7e9-361a-4277-a972-c029912cf655/relationships/system_elements"
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
DELETE /object_occurrences/b164c35e-33d8-4e89-8be3-e9d59eea5646/relationships/system_elements/9296d0d5-f73e-4d24-a701-9288be2482cf
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`DELETE /object_occurrences/:object_occurrence_id/relationships/system_elements/:id`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 62201a23-2b3d-442c-8d10-d67dbd5dd70c
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
X-Request-Id: af08b473-c7a6-43d2-a58a-c4a2f5b798ee
200 OK
```


```json
{
  "data": {
    "id": "ba0d0d54-c147-4679-9dd3-ca167b46c89c",
    "type": "user_setting",
    "attributes": {
      "newsletter": false,
      "user_id": "001bc59f-b7f5-43a0-bc48-7b3ab0aa1696"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/001bc59f-b7f5-43a0-bc48-7b3ab0aa1696"
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
X-Request-Id: 4823e5ef-6652-4f7a-a9c6-6e822863f15e
200 OK
```


```json
{
  "data": {
    "id": "7009052f-c540-4f19-966b-db2e88e796f2",
    "type": "user_setting",
    "attributes": {
      "newsletter": true,
      "user_id": "9dab81f1-26ec-4114-8c30-1b4f4eb15d33"
    },
    "relationships": {
      "user": {
        "links": {
          "related": "/projects/9dab81f1-26ec-4114-8c30-1b4f4eb15d33"
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
X-Request-Id: 1a40822c-bb4d-4f9d-87bb-a7a32b87f593
200 OK
```


```json
{
  "data": [
    {
      "id": "9f3f3756-a4e9-4371-8524-26b285fb5fa9",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 0d13ba315a0d",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=9f3f3756-a4e9-4371-8524-26b285fb5fa9&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/9f3f3756-a4e9-4371-8524-26b285fb5fa9/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "b614bb5f-680d-4d87-a1f9-f8d95f319569",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/b614bb5f-680d-4d87-a1f9-f8d95f319569",
            "self": "/object_occurrence_relations/9f3f3756-a4e9-4371-8524-26b285fb5fa9/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "71c89582-6018-4d13-a067-e265323c7311",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/71c89582-6018-4d13-a067-e265323c7311",
            "self": "/object_occurrence_relations/9f3f3756-a4e9-4371-8524-26b285fb5fa9/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "8428e055-af8c-4188-9c8c-43cf64bf7746",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/8428e055-af8c-4188-9c8c-43cf64bf7746",
            "self": "/object_occurrence_relations/9f3f3756-a4e9-4371-8524-26b285fb5fa9/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "b614bb5f-680d-4d87-a1f9-f8d95f319569",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 72dcae7ef3d8",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=b614bb5f-680d-4d87-a1f9-f8d95f319569&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/b614bb5f-680d-4d87-a1f9-f8d95f319569/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=b614bb5f-680d-4d87-a1f9-f8d95f319569",
            "self": "/classification_entries/b614bb5f-680d-4d87-a1f9-f8d95f319569/relationships/classification_entries",
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
GET /object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=12364bd5-9284-4e5a-b7d8-aff01de835a1&amp;filter[object_occurrence_source_ids_cont][]=913841d3-ccf9-48c2-8cba-05b27aabfb0e&amp;filter[object_occurrence_target_ids_cont][]=6125167d-b90e-4ff4-8f5a-d32765b6e7b1
Content-Type: application/vnd.api+json
Accept: application/vnd.api+json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.e30.ZRrHA1JJJW8opsbCGfG_HACGpVUMN_a9IV7pAx_Zmeo
```

`GET /object_occurrence_relations`

#### Parameters


```json
filter: {&quot;object_occurrence_source_ids_cont&quot;=&gt;[&quot;12364bd5-9284-4e5a-b7d8-aff01de835a1&quot;, &quot;913841d3-ccf9-48c2-8cba-05b27aabfb0e&quot;], &quot;object_occurrence_target_ids_cont&quot;=&gt;[&quot;6125167d-b90e-4ff4-8f5a-d32765b6e7b1&quot;]}
```


| Name | Description |
|:-----|:------------|
| filter[object_occurrence_source_ids_cont]  | Filter object occurrence source ids cont |
| filter[object_occurrence_target_ids_cont]  | Filter object occurrence target ids cont |



### Response

```plaintext
Content-Type: application/vnd.api+json; charset=utf-8
X-Request-Id: 00ffe152-c801-4254-b8a5-e2cb4a87673a
200 OK
```


```json
{
  "data": [
    {
      "id": "216b2d82-36f8-4b43-aafc-c27214ea72e4",
      "type": "object_occurrence_relation",
      "attributes": {
        "description": null,
        "name": "OOR 0b897281657b",
        "no_relations": false,
        "number": 1,
        "unknown_relations": false
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=216b2d82-36f8-4b43-aafc-c27214ea72e4&filter[target_type_eq]=object_occurrence_relation",
            "self": "/object_occurrence_relations/216b2d82-36f8-4b43-aafc-c27214ea72e4/relationships/tags"
          }
        },
        "classification_entry": {
          "data": {
            "id": "72a13fc3-0e84-4576-adb9-bf4ffc2f19ec",
            "type": "classification_entry"
          },
          "links": {
            "related": "/classification_entries/72a13fc3-0e84-4576-adb9-bf4ffc2f19ec",
            "self": "/object_occurrence_relations/216b2d82-36f8-4b43-aafc-c27214ea72e4/relationships/classification_entry"
          }
        },
        "target": {
          "data": {
            "id": "6125167d-b90e-4ff4-8f5a-d32765b6e7b1",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/6125167d-b90e-4ff4-8f5a-d32765b6e7b1",
            "self": "/object_occurrence_relations/216b2d82-36f8-4b43-aafc-c27214ea72e4/relationships/target"
          }
        },
        "source": {
          "data": {
            "id": "12364bd5-9284-4e5a-b7d8-aff01de835a1",
            "type": "object_occurrence"
          },
          "links": {
            "related": "/object_occurrences/12364bd5-9284-4e5a-b7d8-aff01de835a1",
            "self": "/object_occurrence_relations/216b2d82-36f8-4b43-aafc-c27214ea72e4/relationships/source"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "72a13fc3-0e84-4576-adb9-bf4ffc2f19ec",
      "type": "classification_entry",
      "attributes": {
        "code": "R",
        "definition": "Alarm signal",
        "name": "Alarm 12ea22c9a306",
        "reciprocal_name": "Alarm reciprocal"
      },
      "relationships": {
        "tags": {
          "links": {
            "related": "/tags?filter[target_id_eq]=72a13fc3-0e84-4576-adb9-bf4ffc2f19ec&filter[target_type_eq]=classification_entry",
            "self": "/classification_entries/72a13fc3-0e84-4576-adb9-bf4ffc2f19ec/relationships/tags"
          }
        },
        "classification_entries": {
          "links": {
            "related": "/classification_entries?filter[classification_entry_id_eq]=72a13fc3-0e84-4576-adb9-bf4ffc2f19ec",
            "self": "/classification_entries/72a13fc3-0e84-4576-adb9-bf4ffc2f19ec/relationships/classification_entries",
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
    "self": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=12364bd5-9284-4e5a-b7d8-aff01de835a1&filter[object_occurrence_source_ids_cont][]=913841d3-ccf9-48c2-8cba-05b27aabfb0e&filter[object_occurrence_target_ids_cont][]=6125167d-b90e-4ff4-8f5a-d32765b6e7b1",
    "current": "http://example.org/object_occurrence_relations?filter[object_occurrence_source_ids_cont][]=12364bd5-9284-4e5a-b7d8-aff01de835a1&filter[object_occurrence_source_ids_cont][]=913841d3-ccf9-48c2-8cba-05b27aabfb0e&filter[object_occurrence_target_ids_cont][]=6125167d-b90e-4ff4-8f5a-d32765b6e7b1&include=classification_entry&page[number]=1&sort=name,number"
  }
}
```



## Show


### Request

#### Endpoint

```plaintext
GET /object_occurrence_relations/f89efe59-38e1-4777-b00f-9339711d834d
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
X-Request-Id: ab9850de-fc01-4a41-b863-2fa4308dee4b
200 OK
```


```json
{
  "data": {
    "id": "f89efe59-38e1-4777-b00f-9339711d834d",
    "type": "object_occurrence_relation",
    "attributes": {
      "description": null,
      "name": "OOR cc7b216ed8fc",
      "no_relations": false,
      "number": 1,
      "unknown_relations": false
    },
    "relationships": {
      "tags": {
        "links": {
          "related": "/tags?filter[target_id_eq]=f89efe59-38e1-4777-b00f-9339711d834d&filter[target_type_eq]=object_occurrence_relation",
          "self": "/object_occurrence_relations/f89efe59-38e1-4777-b00f-9339711d834d/relationships/tags"
        }
      },
      "classification_entry": {
        "data": {
          "id": "f5690b00-87be-4244-8529-64835188b290",
          "type": "classification_entry"
        },
        "links": {
          "related": "/classification_entries/f5690b00-87be-4244-8529-64835188b290",
          "self": "/object_occurrence_relations/f89efe59-38e1-4777-b00f-9339711d834d/relationships/classification_entry"
        }
      },
      "target": {
        "data": {
          "id": "4d85dab7-6067-4bd5-8599-68065518556c",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/4d85dab7-6067-4bd5-8599-68065518556c",
          "self": "/object_occurrence_relations/f89efe59-38e1-4777-b00f-9339711d834d/relationships/target"
        }
      },
      "source": {
        "data": {
          "id": "9698ac10-3515-4c91-838d-3e08d27b0067",
          "type": "object_occurrence"
        },
        "links": {
          "related": "/object_occurrences/9698ac10-3515-4c91-838d-3e08d27b0067",
          "self": "/object_occurrence_relations/f89efe59-38e1-4777-b00f-9339711d834d/relationships/source"
        }
      }
    }
  },
  "links": {
    "self": "http://example.org/object_occurrence_relations/f89efe59-38e1-4777-b00f-9339711d834d"
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
X-Request-Id: bdb88889-656c-478f-8684-a4e80d5c8451
200 OK
```


```json
{
  "data": [
    {
      "id": "ed7d2a3f-362a-456f-86d4-cb3d5e548014",
      "type": "tag",
      "attributes": {
        "value": "Tag value 11"
      },
      "relationships": {
      }
    },
    {
      "id": "b1d3fca4-5151-4412-96a5-ca36a3a4f533",
      "type": "tag",
      "attributes": {
        "value": "Tag value 12"
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
X-Request-Id: 9e60b7b9-a055-4f24-a3da-3772c8e9eacf
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
GET /utils/path/from/object_occurrence/d4bea1cd-7022-4ce5-b206-7cd0914b431b/to/object_occurrence/34067d67-75fb-4de8-a84a-c830f360dd9a
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
X-Request-Id: c893572d-d102-4ef2-861f-877e23db3949
200 OK
```


```json
[
  {
    "id": "d4bea1cd-7022-4ce5-b206-7cd0914b431b",
    "type": "object_occurrence"
  },
  {
    "id": "0b58bf84-8341-4a07-a38a-6ef4e3bcd2c8",
    "type": "object_occurrence"
  },
  {
    "id": "d44b327f-5234-40fa-b8f9-6651a65ba600",
    "type": "object_occurrence"
  },
  {
    "id": "7862e578-6940-4418-8138-0f8da74e4ad0",
    "type": "object_occurrence"
  },
  {
    "id": "00416f6c-8da4-4561-a265-8212be0aade0",
    "type": "object_occurrence"
  },
  {
    "id": "d612095f-237b-4f8b-a214-1e7208a6ebf4",
    "type": "object_occurrence"
  },
  {
    "id": "34067d67-75fb-4de8-a84a-c830f360dd9a",
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
X-Request-Id: f55420b0-6257-4da7-8ba9-b2ef5c2cd244
200 OK
```


```json
{
  "data": [
    {
      "id": "fa433a6f-c458-4a49-8fa0-d7755b2022e0",
      "type": "event",
      "attributes": {
        "event": "create"
      },
      "relationships": {
        "user": {
          "links": {
            "related": "/users/a7e32682-e72d-4f28-890e-13f95d439b93"
          }
        },
        "item": {
          "links": {
            "related": "/contexts/764170fc-eee3-4c49-b2b0-717e97f20ae1"
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
X-Request-Id: 2d390745-d676-4a44-b220-5886dc8b9721
200 OK
```


```json
default: PASSED Application is running (0.000s)
```



