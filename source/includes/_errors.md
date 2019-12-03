# Errors

The Consumer API attemps to be JSON:API complient in regards to errors' HTTP statuses. You can read
more details about the individual HTTP status codes on the
[httpstatuses.com](https://httpstatuses.com) page.

As seen in the [JSON:API Errors specification](https://jsonapi.org/format/#errors) we make use of
the `code` property of an error response object.

Codes will only be removed or added. Once an error has been assigned a code, that will not change,
and no other error will reuse that code. This makes codes a great way for clients to programatically
identify and localize errors.

Code | Status | Short description
---------------------------------
1001 | 500 | Internal Server Error
1002 | 404 | Not found
1003 | 403 | Parent resource published
1005 | 401 | Invalid authentication
1008 | 403 | Invalid permissions
1009 | 403 | Not archived
1010 | 403 | Already published
1011 | 403 | Parent resource already archived
1012 | 401 | Invaild JWT token
1013 | 401 | Malformatted JWT token

If you want to raise a support ticket, because you believe that you're getting an error response
incorrectly, please include the `X-Request-Id` response header from the erroneous response in the
error report.

## (1001) Internal Server Error

HTTP Status: 500

This happens when we encounter an unresolvable and unhandles error.

Please wait a little while and then retry the request. We suggest building a progressive backoff
model into your retry strategy.

## (1002) Not Found

This occurs when the resource you're trying to access doesn't exist.

You should re-parse the API from the initial endpoint `/`.

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
