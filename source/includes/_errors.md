# Errors

```json
{
  "code": "1003.missing_name",
  "id": "59ac2363-a05b-423c-a71c-2622626d3116",
  "links": {
    "about": "https://docs.sec-hub.com/#1003-bad-request",
  },
  "status": 400,
  "title": "Name is missing"
}

[
  {
    "code": "1003.invalid_name",
    "id": "09b15736-759c-4369-83a5-9a97b2e41982",
    "links": {
      "about": "https://docs.sec-hub.com/#1003-bad-request",
    },
    "status": 400,
    "title": "Invalid name"
  },
  {
    "code": "1003.missing_description",
    "id": "420fd8dd-ed6e-42cc-b81c-45f3450ecf6b",
    "links": {
      "about": "https://docs.sec-hub.com/#1003-bad-request",
    },
    "status": 400,
    "title": "Description is missing"
  }
]
```

The Consumer API attemps to be JSON:API complient in regards to errors' HTTP statuses. You can read
more details about the individual HTTP status codes on the
[httpstatuses.com](https://httpstatuses.com) page.

As seen in the [JSON:API Errors specification](https://jsonapi.org/format/#errors) we make use of
the `code` property of an error response object.

If you want to raise a support ticket, because you believe that you're getting an error response
incorrectly, please include the `X-Request-Id` response header from the erroneous response in the
error report.

Some errors have an additional part to the error code separated by a full stop.
This could look something like this: `1003.missing_name`.



## (1001) Internal Server Error

HTTP Status: 500

This happens when we encounter an unresolvable and unhandles error.

Please wait a little while and then retry the request. We suggest building a progressive backoff
model into your retry strategy.



## (1002) Not Found

HTTP Status: 404

This occurs when the resource you're trying to access doesn't exist.

You should re-parse the API from the initial endpoint `/`.



## (1003) Bad Request

HTTP Status: 400

This occurs when the client sends an invalid or insuffient request, which the API expects that the
client can and should correct.

Once corrected the client should resend the request.



## (1004) Unauthorized

HTTP Status: 401

This occurs when the `Authentication` header is missing or invalid.

| Code | Description |
| ---- | ----------- |
| no_current_user | Unable to determine the user |
| no_current_account | Unable to determine the account |
| no_local_user | Unable to retrieve the user from the authentication provider |



## (1005) Forbidden

HTTP Status: 403

This occurs when the `Authentication` header is correct, but the client or user isn't allowed to
perform the action on the resource.



## (1101) Published, immutable resource

HTTP Status: 403

This occurs because published resources are immutable.

If you want a copy of the resource, which isn't published, and therefor is mutable, please see the
specific resource's endpoints and look for a copy option.



## (1103) Not Archived

HTTP Status: 403

This occurs when the client attempts to directly delete an archivable (but unarchived) resource.

A resource that can be archived must be archived before it can be deleted.



## (1104) Already published

HTTP Status: 403

This occurs when the client attempts to update a published resource.

Once a resource is published it becomes immutable in terms of directly updating first-class
properties on the resource. It is still possible to fx. archive a published resource.



## (1105) Archived resource unavailable

HTTP Status: 403

This occurs when a client attempts to associate or otherwise _use_ an archived resource.

Archived resources are only available to resources that assigned the archived resource prior to the
archiving date.

<!--

## (1003)  Parent resource published

This occurs when a client attempts to update a resource who's parent resource has been published.
This could happen if tryinng to update the class code of a Classificationn Entry, where the related
Classification Table has already been published.

Some resources does allow some properties to be manipulated after parenting resource has been
published, but in genera, resources are immutable after publication.

## (1005) Invalid authentication

This occurs when the request could not be verified, but the problem isn't with the Authorization
Header JWT token.

Please reveiw the [Authentication documentation](https://docs.sec-hub.com/#authentication), correct
the request and try again.

## (1008) Invalid permissions

This happens when you try to view or manipulate a resource that you don't have access to.

You should re-parse the API from the initial endpoint `/`.

## (1009) Not archived

This happens when you try to delete a resource which isn't archived.

It's strongly encouraged to archive resources for a while, to make sure that nobody in your
organization depends on them before deleting them.

## (1010) Already published

This happens when you try to manipulate a resource that has been published.

Published resources are immutable.

## (1011) Parent resource already archived

This happens when you try to manipulate a resource with a dependent resource which is arhived.

With a few exceptions, archived resources are immutable. Please see the documentation for the
specific resource.

## (1012) Invalid JWT token

The [JWT token](https://jwt.io/) in the `Authoriazation` cannot be verified.

Please read through the [authentication section of the
documentation](https://docs.sec-hub.com/#authentication) on how to correctly obtain a valid JWT
token.

## (1013) Malformatted JWT token

The JWT token in the `Authorization` header is malformatted.

Please read through the [authentication section of the
documentation](https://docs.sec-hub.com/#authentication) on how to correctly obtain a valid JWT
token.
 -->
