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
// Additional Users
- (void)getUserWithID:(NSString *)userID completion:(CLMRESTCompletion)completion;

// Channels
- (void)getChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID name:(nullable NSString *)name topic:(nullable NSString *)topic completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID name:(nullable NSString *)name topic:(nullable NSString *)topic auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID json:(NSDictionary *)json auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)deleteChannelWithID:(NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)triggerTypingInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)triggerTypingInChannel:(NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)listWebhooksInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name completion:(CLMRESTCompletion)completion;
- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Channel Messages (additional)
- (void)addOwnReactionInChannel:(NSString *)channelID messageID:(NSString *)messageID emoji:(NSString *)emoji completion:(CLMRESTCompletion)completion;
- (void)removeOwnReactionInChannel:(NSString *)channelID messageID:(NSString *)messageID emoji:(NSString *)emoji completion:(CLMRESTCompletion)completion;
- (void)bulkDeleteMessagesInChannel:(NSString *)channelID messageIDs:(NSArray<NSString *> *)messageIDs completion:(CLMRESTCompletion)completion;
- (void)listPinnedMessagesInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)pinMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion;
- (void)unpinMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion;
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
// Messages with attachments
- (void)sendMessageInChannel:(NSString *)channelID json:(NSDictionary *)json files:(nullable NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion;
- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID json:(NSDictionary *)json files:(nullable NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion;
// Polls
- (void)sendMessageWithPollInChannel:(NSString *)channelID content:(nullable NSString *)content pollJSON:(NSDictionary *)pollJSON completion:(CLMRESTCompletion)completion;
- (void)getPollAnswerUsersInChannel:(NSString *)channelID messageID:(NSString *)messageID answerID:(NSString *)answerID after:(nullable NSString *)after limit:(nullable NSNumber *)limit completion:(CLMRESTCompletion)completion;

// Guilds
- (void)getGuildWithID:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)listChannelsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)listMembersInGuild:(NSString *)guildID limit:(nullable NSNumber *)limit after:(nullable NSString *)after completion:(CLMRESTCompletion)completion;
// Guild Members
- (void)getMemberInGuild:(NSString *)guildID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)modifyMemberInGuild:(NSString *)guildID userID:(NSString *)userID nick:(nullable NSString *)nick completion:(CLMRESTCompletion)completion;
- (void)modifyMemberInGuild:(NSString *)guildID userID:(NSString *)userID nick:(nullable NSString *)nick auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)kickMemberInGuild:(NSString *)guildID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)kickMemberInGuild:(NSString *)guildID userID:(NSString *)userID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)addRoleToMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion;
- (void)addRoleToMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)removeRoleFromMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion;
- (void)removeRoleFromMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)searchMembersInGuild:(NSString *)guildID query:(NSString *)query limit:(nullable NSNumber *)limit completion:(CLMRESTCompletion)completion;
// Guild Channels (create)
- (void)createChannelInGuild:(NSString *)guildID name:(NSString *)name type:(nullable NSNumber *)type topic:(nullable NSString *)topic completion:(CLMRESTCompletion)completion;
- (void)createChannelInGuild:(NSString *)guildID name:(NSString *)name type:(nullable NSNumber *)type topic:(nullable NSString *)topic auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Forum helper
- (void)createForumPostInChannel:(NSString *)channelID title:(NSString *)title messageJSON:(NSDictionary *)message appliedTagIds:(nullable NSArray<NSString*> *)tagIds completion:(CLMRESTCompletion)completion;
// Guild Roles
- (void)listRolesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)createRoleInGuild:(NSString *)guildID name:(NSString *)name completion:(CLMRESTCompletion)completion;
- (void)createRoleInGuild:(NSString *)guildID name:(NSString *)name auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion;
- (void)deleteRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Guild Bans
- (void)banUserInGuild:(NSString *)guildID userID:(NSString *)userID deleteMessageSeconds:(nullable NSNumber *)deleteMessageSeconds auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)unbanUserInGuild:(NSString *)guildID userID:(NSString *)userID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Webhooks
- (void)modifyWebhookWithID:(NSString *)webhookID name:(nullable NSString *)name channelID:(nullable NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)modifyWebhookWithID:(NSString *)webhookID name:(nullable NSString *)name channelID:(nullable NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteWebhookWithID:(NSString *)webhookID completion:(CLMRESTCompletion)completion;
- (void)deleteWebhookWithID:(NSString *)webhookID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Webhook execute
- (void)executeWebhookWithID:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json files:(nullable NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion;
// Invites
- (void)createInviteInChannel:(NSString *)channelID maxAge:(nullable NSNumber *)maxAge maxUses:(nullable NSNumber *)maxUses temporary:(nullable NSNumber *)temporary unique:(nullable NSNumber *)unique completion:(CLMRESTCompletion)completion;
- (void)createInviteInChannel:(NSString *)channelID maxAge:(nullable NSNumber *)maxAge maxUses:(nullable NSNumber *)maxUses temporary:(nullable NSNumber *)temporary unique:(nullable NSNumber *)unique auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteInviteWithCode:(NSString *)inviteCode completion:(CLMRESTCompletion)completion;
- (void)deleteInviteWithCode:(NSString *)inviteCode auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Application Commands
- (void)listGlobalApplicationCommands:(NSString *)applicationID completion:(CLMRESTCompletion)completion;
- (void)createGlobalApplicationCommand:(NSString *)applicationID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)editGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion;
- (void)listGuildApplicationCommands:(NSString *)applicationID guildID:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)createGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)editGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID commandID:(NSString *)commandID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion;
// Channel Permission Overwrites
- (void)setPermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID allow:(nullable NSNumber *)allow deny:(nullable NSNumber *)deny type:(NSNumber *)type completion:(CLMRESTCompletion)completion;
- (void)setPermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID allow:(nullable NSNumber *)allow deny:(nullable NSNumber *)deny type:(NSNumber *)type auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deletePermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID completion:(CLMRESTCompletion)completion;
- (void)deletePermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Guild Emojis
- (void)listEmojisInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion;
- (void)createEmojiInGuild:(NSString *)guildID name:(NSString *)name image:(NSString *)image roles:(nullable NSArray<NSString *> *)roles completion:(CLMRESTCompletion)completion;
- (void)createEmojiInGuild:(NSString *)guildID name:(NSString *)name image:(NSString *)image roles:(nullable NSArray<NSString *> *)roles auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)modifyEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID name:(nullable NSString *)name roles:(nullable NSArray<NSString *> *)roles completion:(CLMRESTCompletion)completion;
- (void)modifyEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID name:(nullable NSString *)name roles:(nullable NSArray<NSString *> *)roles auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion;
- (void)deleteEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Application Emojis
- (void)listApplicationEmojis:(NSString *)applicationID completion:(CLMRESTCompletion)completion;
- (void)getApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion;
- (void)createApplicationEmoji:(NSString *)applicationID name:(NSString *)name imageDataURI:(NSString *)imageDataURI completion:(CLMRESTCompletion)completion;
- (void)modifyApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID name:(nullable NSString *)name completion:(CLMRESTCompletion)completion;
- (void)deleteApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion;
// Stickers
- (void)listStickersInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID completion:(CLMRESTCompletion)completion;
- (void)getStickerWithID:(NSString *)stickerID completion:(CLMRESTCompletion)completion;
- (void)createStickerInGuild:(NSString *)guildID name:(NSString *)name description:(nullable NSString *)description tags:(NSString *)tags image:(NSString *)image completion:(CLMRESTCompletion)completion;
- (void)createStickerInGuild:(NSString *)guildID name:(NSString *)name description:(nullable NSString *)description tags:(NSString *)tags image:(NSString *)image auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)modifyStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID name:(nullable NSString *)name description:(nullable NSString *)description tags:(nullable NSString *)tags completion:(CLMRESTCompletion)completion;
- (void)modifyStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID name:(nullable NSString *)name description:(nullable NSString *)description tags:(nullable NSString *)tags auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID completion:(CLMRESTCompletion)completion;
- (void)deleteStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
// Guild Management
- (void)modifyGuildWithID:(NSString *)guildID name:(nullable NSString *)name icon:(nullable NSString *)icon description:(nullable NSString *)description completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWithID:(NSString *)guildID name:(nullable NSString *)name icon:(nullable NSString *)icon description:(nullable NSString *)description auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)getPruneCountInGuild:(NSString *)guildID days:(nullable NSNumber *)days includeRoles:(nullable NSArray<NSString *> *)includeRoles completion:(CLMRESTCompletion)completion;
- (void)beginPruneInGuild:(NSString *)guildID days:(nullable NSNumber *)days includeRoles:(nullable NSArray<NSString *> *)includeRoles computeCount:(nullable NSNumber *)computeCount completion:(CLMRESTCompletion)completion;
- (void)beginPruneInGuild:(NSString *)guildID days:(nullable NSNumber *)days includeRoles:(nullable NSArray<NSString *> *)includeRoles computeCount:(nullable NSNumber *)computeCount auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)getGuildWidget:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWidget:(NSString *)guildID enabled:(nullable NSNumber *)enabled channelID:(nullable NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWidget:(NSString *)guildID enabled:(nullable NSNumber *)enabled channelID:(nullable NSString *)channelID auditLogReason:(nullable NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)getGuildVanityURL:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)listGuildIntegrations:(NSString *)guildID completion:(CLMRESTCompletion)completion;
// Threads
- (void)startThreadFromMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID name:(NSString *)name autoArchiveDuration:(nullable NSNumber *)autoArchiveDuration rateLimitPerUser:(nullable NSNumber *)rateLimitPerUser completion:(CLMRESTCompletion)completion;
- (void)startThreadInChannel:(NSString *)channelID name:(NSString *)name autoArchiveDuration:(nullable NSNumber *)autoArchiveDuration type:(nullable NSNumber *)type invitable:(nullable NSNumber *)invitable rateLimitPerUser:(nullable NSNumber *)rateLimitPerUser completion:(CLMRESTCompletion)completion;
- (void)joinThread:(NSString *)threadID completion:(CLMRESTCompletion)completion;
- (void)leaveThread:(NSString *)threadID completion:(CLMRESTCompletion)completion;
- (void)addThreadMember:(NSString *)threadID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)removeThreadMember:(NSString *)threadID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)listPublicArchivedThreadsInChannel:(NSString *)channelID before:(nullable NSString *)before limit:(nullable NSNumber *)limit completion:(CLMRESTCompletion)completion;
- (void)listPrivateArchivedThreadsInChannel:(NSString *)channelID before:(nullable NSString *)before limit:(nullable NSNumber *)limit completion:(CLMRESTCompletion)completion;
- (void)listJoinedPrivateArchivedThreadsInChannel:(NSString *)channelID before:(nullable NSString *)before limit:(nullable NSNumber *)limit completion:(CLMRESTCompletion)completion;
- (void)listActiveThreadsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
// Interaction Followups (webhooks)
- (void)getOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token completion:(CLMRESTCompletion)completion;
- (void)editOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token completion:(CLMRESTCompletion)completion;
- (void)createFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)editFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token messageID:(NSString *)messageID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion;
// Interaction Initial Response (callbacks)
- (void)createInteractionCallbackWithID:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
// Convenience helpers
- (void)deferUpdateForInteractionID:(NSString *)interactionID token:(NSString *)token completion:(CLMRESTCompletion)completion; // type 6
- (void)updateMessageForInteractionID:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)data completion:(CLMRESTCompletion)completion; // type 7
- (void)replyToInteractionWithMessage:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)data completion:(CLMRESTCompletion)completion; // type 4
- (void)presentModalForInteractionID:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)data completion:(CLMRESTCompletion)completion; // type 9
// Audit Log
- (void)getGuildAuditLog:(NSString *)guildID userID:(nullable NSString *)userID actionType:(nullable NSNumber *)actionType before:(nullable NSString *)before limit:(nullable NSNumber *)limit completion:(CLMRESTCompletion)completion;
// Scheduled Events
- (void)listGuildScheduledEvents:(NSString *)guildID withUsers:(nullable NSNumber *)withUsers completion:(CLMRESTCompletion)completion;
- (void)createGuildScheduledEvent:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)modifyGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID completion:(CLMRESTCompletion)completion;
// Stage Instances
- (void)createStageInstanceWithChannelID:(NSString *)channelID topic:(NSString *)topic privacyLevel:(nullable NSNumber *)privacyLevel completion:(CLMRESTCompletion)completion;
- (void)modifyStageInstanceWithChannelID:(NSString *)channelID topic:(nullable NSString *)topic privacyLevel:(nullable NSNumber *)privacyLevel completion:(CLMRESTCompletion)completion;
- (void)deleteStageInstanceWithChannelID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
// Auto Moderation Rules
- (void)listAutoModRulesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID completion:(CLMRESTCompletion)completion;
- (void)createAutoModRuleInGuild:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)modifyAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID completion:(CLMRESTCompletion)completion;
// Voice State
- (void)modifyCurrentUserVoiceStateInGuild:(NSString *)guildID channelID:(NSString *)channelID suppress:(nullable NSNumber *)suppress requestToSpeakTimestampISO8601:(nullable NSString *)timestamp completion:(CLMRESTCompletion)completion;
- (void)modifyUserVoiceStateInGuild:(NSString *)guildID userID:(NSString *)userID channelID:(NSString *)channelID suppress:(nullable NSNumber *)suppress completion:(CLMRESTCompletion)completion;
// Guild Templates
- (void)listGuildTemplates:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getGuildTemplateWithCode:(NSString *)code completion:(CLMRESTCompletion)completion;
- (void)createGuildTemplate:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)syncGuildTemplate:(NSString *)guildID code:(NSString *)code completion:(CLMRESTCompletion)completion;
- (void)modifyGuildTemplate:(NSString *)guildID code:(NSString *)code json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteGuildTemplate:(NSString *)guildID code:(NSString *)code completion:(CLMRESTCompletion)completion;
// Welcome Screen
- (void)getGuildWelcomeScreen:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWelcomeScreen:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
// Onboarding
- (void)getGuildOnboarding:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildOnboarding:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
@end
NS_ASSUME_NONNULL_END
