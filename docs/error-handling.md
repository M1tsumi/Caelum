# Error Handling

**Header:** `Core/CLMErrors.h`

## Error Domain

```objc
FOUNDATION_EXPORT NSErrorDomain const CLMErrorDomain;
// Value: @"com.caelum.discord"
```

## Error Codes

```objc
typedef NS_ERROR_ENUM(CLMErrorDomain, CLMErrorCode) {
    CLMErrorUnknown       = 0,  // catch-all
    CLMErrorNetwork       = 1,  // NSURLSession transport error
    CLMErrorDecode        = 2,  // JSON deserialization failure
    CLMErrorUnauthorized  = 3,  // HTTP 401
    CLMErrorRateLimited   = 4,  // HTTP 429
    CLMErrorBadRequest    = 5,  // HTTP 400
    CLMErrorForbidden     = 6,  // HTTP 403
    CLMErrorServer        = 7,  // HTTP 5xx
    CLMErrorNotFound      = 8,  // HTTP 404
    CLMErrorWebSocket     = 9,  // Gateway WebSocket close
};
```

## Error Factory

```objc
NSError *CLMErrorMake(CLMErrorCode code, NSString *description, NSDictionary *extraUserInfo);
```

Creates an NSError in `CLMErrorDomain` with the given code, description (set as `NSLocalizedDescriptionKey`), and any additional userInfo entries.

## HTTP Status Mapping

```objc
CLMErrorCode CLMErrorCodeForHTTPStatus(NSInteger statusCode);
```

Maps HTTP status codes to the appropriate `CLMErrorCode`:
- 400 -> `CLMErrorBadRequest`
- 401 -> `CLMErrorUnauthorized`
- 403 -> `CLMErrorForbidden`
- 404 -> `CLMErrorNotFound`
- 429 -> `CLMErrorRateLimited`
- 5xx -> `CLMErrorServer`
- Other -> `CLMErrorUnknown`

## Error UserInfo Keys

Errors from the REST client include these keys in `userInfo`:

| Key | Type | Description |
|-----|------|-------------|
| `@"endpoint"` | NSString | The request route (e.g., `channels/123/messages`) |
| `@"statusCode"` | NSNumber | HTTP status code |
| `NSUnderlyingErrorKey` | NSError | Original error (network errors, JSON decode errors) |
| `@"retry_after"` | NSNumber | Retry-After header value (429 only) |
| `@"x-ratelimit-bucket"` | NSString | Rate limit bucket (429 only) |
| `@"x-ratelimit-remaining"` | NSString | Remaining requests (429 only) |
| `@"x-ratelimit-reset-after"` | NSString | Seconds until reset (429 only) |
| `@"x-ratelimit-global"` | NSString | Present if global rate limit (429 only) |

## Checking Errors

```objc
[client.rest sendMessage:@"hello" toChannel:id completion:^(CLMRESTResponse *resp) {
    if (resp.isSuccess) {
        // 2xx
    } else if (resp.isRateLimited) {
        // 429 specifically
        NSNumber *retryAfter = resp.error.userInfo[@"retry_after"];
    } else if ([resp.error.domain isEqualToString:CLMErrorDomain]) {
        switch ((CLMErrorCode)resp.error.code) {
            case CLMErrorUnauthorized:
                // token issue
                break;
            case CLMErrorNotFound:
                // channel doesn't exist
                break;
            case CLMErrorForbidden:
                // missing permissions
                break;
            default:
                break;
        }
    }
}];
```

## Creating Your Own Errors

```objc
NSError *err = CLMErrorMake(CLMErrorBadRequest, @"Invalid embed", @{
    @"field": @"description",
    @"reason": @"exceeds 4096 characters"
});
```

## Gateway Errors

Gateway errors are delivered via the delegate:

```objc
- (void)gatewayDidDisconnectWithError:(NSError *)error {
    if ([error.domain isEqualToString:CLMErrorDomain]) {
        if (error.code == CLMErrorWebSocket) {
            // WebSocket closed unexpectedly
        }
    }
}
```
