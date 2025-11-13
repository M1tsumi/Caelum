#import "CLMWebSocketConnection.h"

@interface CLMWebSocketConnection () <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong, nullable) NSURLSessionWebSocketTask *task;
@end

@implementation CLMWebSocketConnection

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    if ((self = [super init])) {
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return self;
}

- (void)connectWithURL:(NSURL *)url headers:(NSDictionary<NSString *,NSString *> *)headers {
    if (self.task) { [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil]; self.task = nil; }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop){
        [request setValue:obj forHTTPHeaderField:key];
    }];
    self.task = [self.session webSocketTaskWithRequest:request];
    [self.task resume];
    if ([self.delegate respondsToSelector:@selector(webSocketDidOpen)]) {
        [self.delegate webSocketDidOpen];
    }
    [self startReceiveLoop];
}

- (void)startReceiveLoop {
    __weak typeof(self) weakSelf = self;
    [self.task receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        if (error) {
            if ([self.delegate respondsToSelector:@selector(webSocketDidError:)]) {
                [self.delegate webSocketDidError:error];
            }
            return;
        }
        if (message) {
            if (message.type == NSURLSessionWebSocketMessageTypeString) {
                NSData *data = [message.string dataUsingEncoding:NSUTF8StringEncoding];
                NSError *jsonErr = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonErr];
                if (jsonErr) {
                    if ([self.delegate respondsToSelector:@selector(webSocketDidError:)]) {
                        [self.delegate webSocketDidError:jsonErr];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(webSocketDidReceiveJSONObject:)]) {
                        [self.delegate webSocketDidReceiveJSONObject:json];
                    }
                }
            }
        }
        // Continue loop
        [self startReceiveLoop];
    }];
}

- (void)sendJSONObject:(id)obj {
    if (!self.task) return;
    if (![NSJSONSerialization isValidJSONObject:obj]) return;
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:&err];
    if (err) {
        if ([self.delegate respondsToSelector:@selector(webSocketDidError:)]) {
            [self.delegate webSocketDidError:err];
        }
        return;
    }
    NSURLSessionWebSocketMessage *msg = [[NSURLSessionWebSocketMessage alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    [self.task sendMessage:msg completionHandler:^(NSError * _Nullable error) {
        if (error && [self.delegate respondsToSelector:@selector(webSocketDidError:)]) {
            [self.delegate webSocketDidError:error];
        }
    }];
}

- (void)close {
    if (self.task) {
        [self.task cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
        self.task = nil;
        if ([self.delegate respondsToSelector:@selector(webSocketDidCloseWithCode:reason:)]) {
            [self.delegate webSocketDidCloseWithCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
        }
    }
}

@end
