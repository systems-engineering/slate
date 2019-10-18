---
title: SEC Hub Consumer API
language_tabs:
  - json: JSON
  - shell: cURL
---

This API exposes information that allowes an authenticated client to manipulate the CORE, SIMO, DOCU, DOMA, and STEM concepts.
# Account

The Account is the first entrypoint into the API. This represents the company (the account) that ultimately owns all the data. There is only a single account object.

## Show account information


### Request

#### Endpoint

```plaintext
GET /account
Content-Type: application/vnd.api+json
```

`GET /account`

#### Parameters


None known.


### Response

```plaintext
X-Request-Id: 96f00d9a-520a-4707-bf5e-6cfe7693a954
200 OK
```


```json
{
  "data": {
    "id": "80e3a6b3-bff9-4fac-9ccf-91a9abc450f0",
    "type": "account",
    "attributes": {
      "name": "Account 8065002f29f8"
    },
    "links": {
      "self": "/account"
    }
  },
  "jsonapi": {
    "version": "1.0"
  }
}
```



## Update account information


### Request

#### Endpoint

```plaintext
PATCH /account
Content-Type: application/vnd.api+json
```

`PATCH /account`

#### Parameters


```json
{
  "data": {
    "id": "3018a427-060d-449a-aca9-f5ab794c0cfc",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    }
  }
}
```

None known.


### Response

```plaintext
X-Request-Id: 92afc819-1a37-4e87-a5d3-9f01bee6adfa
200 OK
```


```json
{
  "data": {
    "id": "3018a427-060d-449a-aca9-f5ab794c0cfc",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    },
    "links": {
      "self": "/account"
    }
  },
  "jsonapi": {
    "version": "1.0"
  }
}
```



