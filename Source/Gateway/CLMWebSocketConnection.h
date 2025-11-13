#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol CLMWebSocketConnectionDelegate <NSObject>
@optional
- (void)webSocketDidOpen;
- (void)webSocketDidCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason;
- (void)webSocketDidReceiveJSONObject:(id)json;
- (void)webSocketDidError:(NSError *)error;
@end

@interface CLMWebSocketConnection : NSObject
@property (nonatomic, weak, nullable) id<CLMWebSocketConnectionDelegate> delegate;
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;
- (void)connectWithURL:(NSURL *)url headers:(nullable NSDictionary<NSString*, NSString*> *)headers;
- (void)sendJSONObject:(id)obj;
- (void)close;
@end
NS_ASSUME_NONNULL_END
