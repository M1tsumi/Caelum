# Getting Started

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/M1tsumi/Caelum.git", from: "0.2.0")
],
targets: [
    .target(
        name: "YourBot",
        dependencies: [
            .product(name: "Caelum", package: "Caelum")
        ]
    )
]
```

### Import

```objc
#import <Caelum/Caelum.h>
```

## Basic Setup

### With bot token (simple)

```objc
CLMClientConfiguration *config = [CLMClientConfiguration defaultConfiguration];
config.restConfiguration.botToken = @"your-bot-token";
config.gatewayConfiguration.intents = CLMIntentGuilds | CLMIntentGuildMessages;

CLMDiscordClient *client = [[CLMDiscordClient alloc] initWithConfiguration:config];
[client.gateway connect];
```

### With token provider protocol

```objc
@interface MyTokenProvider : NSObject <CLMTokenProvider>
@end
@implementation MyTokenProvider
- (NSString *)botToken { return @"your-bot-token"; }
@end

CLMRESTConfiguration *restCfg = [CLMRESTConfiguration defaultConfiguration];
restCfg.tokenProvider = [MyTokenProvider new];

CLMClientConfiguration *config = [CLMClientConfiguration defaultConfiguration];
config.restConfiguration = restCfg;
```

### Logger setup

```objc
client.logger = [CLMDefaultLogger new]; // or your own id<CLMLogger>
```

## Sending a Message

```objc
[client.rest sendMessage:@"Hello!" toChannel:@"123456789"
              completion:^(CLMRESTResponse *resp) {
    if (resp.isError) {
        NSLog(@"Failed: %@", resp.error.localizedDescription);
        return;
    }
    NSString *messageId = resp.JSONObject[@"id"];
}];
```

## Gateway Events

```objc
// Subscribe to dispatch events
[[CLMEventCenter shared] addListenerForEvent:@"MESSAGE_CREATE"
                                       queue:dispatch_get_main_queue()
                                       block:^(NSDictionary *payload) {
    NSLog(@"Message: %@", payload[@"content"]);
}];

// Or use the delegate
client.gateway.delegate = self;
// Implement gatewayDidReceiveDispatch:payload:
```
