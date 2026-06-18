# Events

**Class:** `CLMEventCenter`  
**Header:** `Core/CLMEventCenter.h`

Block-based event listener/dispatcher. Thread-safe with concurrent dispatch.

## Singleton

```objc
+ (instancetype)shared; // app-wide event bus
```

Or create your own instance for scoped event handling.

## Listening

```objc
- (CLMEventToken)addListenerForEvent:(NSString *)eventName
                                queue:(dispatch_queue_t)queue
                                block:(void (^)(id payload))block;
- (void)removeListenerWithToken:(CLMEventToken)token;
```

Returns a token you use to unregister the listener. The block is dispatched asynchronously on the specified queue.

## Dispatching

```objc
- (void)postEvent:(NSString *)eventName payload:(id)payload;
```

All registered listeners for the event name receive the payload. The gateway client automatically dispatches all gateway events to `[CLMEventCenter shared]`.

## Example

```objc
// Subscribe
id token = [[CLMEventCenter shared] addListenerForEvent:@"MESSAGE_CREATE"
                                                   queue:dispatch_get_main_queue()
                                                   block:^(NSDictionary *msg) {
    NSLog(@"Message: %@", msg[@"content"]);
}];

// Unsubscribe later
[[CLMEventCenter shared] removeListenerWithToken:token];
```

Gateway dispatch events automatically go through the event center, so you can listen to `MESSAGE_CREATE`, `GUILD_CREATE`, `INTERACTION_CREATE`, or any Discord gateway event.
