# Errors

We use the following errors explicitly, but you may still want to reference the
[HTTP Statuses page](https://httpstatuses.com/) for any additional details about HTTP errors you may
encounter while using this API.

Error Code | Meaning
---------- | -------
400 | Bad Request -- Your request is malformatted. Please ensure that your request JSON conforms to the [JSON:API standard](https://jsonapi.org/format/) and try again.
401 | Unauthorized -- Your Bearer or Proxy-Authorization header is either malformatted or missing
403 | Forbidden -- You're authenticated, but not authorized to perform this action on this resource
409 | Conflict -- Some error upstream is preventing us from committing the resouece changes
422 | Unprocessable Entity -- The resource information you're sending is invalid
500 | Internal Server Error -- Our servers are misbehaving. Please retry your request later.
