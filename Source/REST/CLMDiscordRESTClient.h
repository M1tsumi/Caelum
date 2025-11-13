#import <Foundation/Foundation.h>
#import "CLMRESTConfiguration.h"
#import "CLMRESTRequest.h"
#import "CLMRESTResponse.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^CLMRESTCompletion)(CLMRESTResponse *response);

@interface CLMDiscordRESTClient : NSObject
@property (nonatomic, strong, readonly) CLMRESTConfiguration *configuration;
@property (nonatomic, strong, readonly) NSURLSession *session;

- (instancetype)initWithConfiguration:(CLMRESTConfiguration *)configuration;
- (void)performRequest:(CLMRESTRequest *)request completion:(CLMRESTCompletion)completion;
- (void)getCurrentApplication:(CLMRESTCompletion)completion;
// Users
- (void)getCurrentUser:(CLMRESTCompletion)completion;

// Channels
- (void)getChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID name:(nullable NSString *)name topic:(nullable NSString *)topic completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID name:(nullable NSString *)name topic:(nullable NSString *)topic auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)deleteChannelWithID:(NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)triggerTypingInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)triggerTypingInChannel:(NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)listWebhooksInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name completion:(CLMRESTCompletion)completion;
- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Messages
- (void)listMessagesInChannel:(NSString *)channelID
                         limit:(nullable NSNumber *)limit
                        before:(nullable NSString *)before
                         after:(nullable NSString *)after
                       completion:(CLMRESTCompletion)completion;
- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID newContent:(NSString *)content completion:(CLMRESTCompletion)completion;
- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID newContent:(NSString *)content auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion;
- (void)deleteMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;

// Guilds
- (void)getGuildWithID:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)listChannelsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)listMembersInGuild:(NSString *)guildID limit:(nullable NSNumber *)limit after:(nullable NSString *)after completion:(CLMRESTCompletion)completion;
@end
NS_ASSUME_NONNULL_END
