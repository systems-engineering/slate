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
X-Request-Id: 45c0c072-9e61-4d95-ac7e-349d5661ebfa
200 OK
```


```json
{
  "data": {
    "id": "269e2268-892e-48a7-be67-af701352d59d",
    "type": "account",
    "attributes": {
      "name": "Account 5ccd07b2a9b2"
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
    "id": "80c51562-132b-4046-adf3-5525a9bb076b",
    "type": "account",
    "attributes": {
      "name": "New Account Name"
    }
  }
}
```


| Name | Description |
|:-----|:------------|
| attributes[name] *required* | Account name |



### Response

```plaintext
X-Request-Id: 71d0d6be-4bd6-49ec-9f4a-f09fbe960443
200 OK
```


```json
{
  "data": {
    "id": "80c51562-132b-4046-adf3-5525a9bb076b",
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



