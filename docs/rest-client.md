# REST Client

**Class:** `CLMDiscordRESTClient`  
**Header:** `REST/CLMDiscordRESTClient.h`

Covers all Discord REST v10 endpoints except voice audio transport.

## Configuration

```objc
@protocol CLMTokenProvider
- (NSString *)botToken;
@end

@interface CLMRESTConfiguration : NSObject
@property (nonatomic, copy) NSURL *baseURL;           // default: https://discord.com/api/v10/
@property (nonatomic, weak) id<CLMTokenProvider> tokenProvider;
@property (nonatomic, copy) NSString *botToken;       // convenience: auto-creates tokenProvider
@property (nonatomic) NSTimeInterval timeout;          // default: 30.0
@end
```

## Responses

```objc
@interface CLMRESTResponse : NSObject
@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong) id JSONObject;           // parsed JSON or nil
@property (nonatomic, strong) NSError *error;
@property (nonatomic, copy) NSDictionary *responseHeaders;
@property (nonatomic, readonly) BOOL isSuccess;        // 2xx and no error
@property (nonatomic, readonly) BOOL isError;
@property (nonatomic, readonly) BOOL isRateLimited;    // 429
@property (nonatomic, readonly) BOOL isUnauthorized;   // 401
@property (nonatomic, readonly) NSString *rateLimitBucket;
@property (nonatomic, readonly) NSNumber *rateLimitRemaining;
@property (nonatomic, readonly) NSNumber *rateLimitResetAfter;
@property (nonatomic, readonly) BOOL rateLimitGlobal;
@end

typedef void (^CLMRESTCompletion)(CLMRESTResponse *response);
```

## Endpoints

All methods take `CLMRESTCompletion` as the last parameter.

### Application

```objc
- (void)getCurrentApplication:(CLMRESTCompletion)completion;
- (void)editCurrentApplicationWithJSON:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
```

### Users

```objc
- (void)getCurrentUser:(CLMRESTCompletion)completion;
- (void)getUserWithID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)modifyCurrentUserWithJSON:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)getCurrentUserGuildsWithBefore:(NSString *)before after:(NSString *)after
                                 limit:(NSNumber *)limit withCounts:(NSNumber *)withCounts
                            completion:(CLMRESTCompletion)completion;
- (void)createDMWithRecipientID:(NSString *)recipientID completion:(CLMRESTCompletion)completion;
- (void)leaveGuildWithID:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getCurrentUserGuildMemberInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
```

### Channels

```objc
- (void)getChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID name:(NSString *)name topic:(NSString *)topic
                 completion:(CLMRESTCompletion)completion;
- (void)modifyChannelWithID:(NSString *)channelID json:(NSDictionary *)json
                 completion:(CLMRESTCompletion)completion;
- (void)deleteChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)triggerTypingInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)getMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                 completion:(CLMRESTCompletion)completion;
- (void)followNewsChannel:(NSString *)channelID targetChannelID:(NSString *)targetChannelID
               completion:(CLMRESTCompletion)completion;
```

### Messages

```objc
- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)sendMessageInChannel:(NSString *)channelID json:(NSDictionary *)json
                       files:(NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion;
- (void)listMessagesInChannel:(NSString *)channelID limit:(NSNumber *)limit
                       before:(NSString *)before after:(NSString *)after
                   completion:(CLMRESTCompletion)completion;
- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                  newContent:(NSString *)content completion:(CLMRESTCompletion)completion;
- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                        json:(NSDictionary *)json files:(NSArray<CLMRESTFilePart *> *)files
                  completion:(CLMRESTCompletion)completion;
- (void)deleteMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                    completion:(CLMRESTCompletion)completion;
- (void)crosspostMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                       completion:(CLMRESTCompletion)completion;
- (void)bulkDeleteMessagesInChannel:(NSString *)channelID messageIDs:(NSArray<NSString *> *)messageIDs
                         completion:(CLMRESTCompletion)completion;
```

### Reactions

```objc
- (void)addOwnReactionInChannel:(NSString *)channelID messageID:(NSString *)messageID
                          emoji:(NSString *)emoji completion:(CLMRESTCompletion)completion;
- (void)removeOwnReactionInChannel:(NSString *)channelID messageID:(NSString *)messageID
                             emoji:(NSString *)emoji completion:(CLMRESTCompletion)completion;
- (void)getReactionsInChannel:(NSString *)channelID messageID:(NSString *)messageID
                        emoji:(NSString *)emoji after:(NSString *)after limit:(NSNumber *)limit
                   completion:(CLMRESTCompletion)completion;
- (void)deleteAllReactionsInChannel:(NSString *)channelID messageID:(NSString *)messageID
                         completion:(CLMRESTCompletion)completion;
```

### Pins

```objc
- (void)listPinnedMessagesInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)pinMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                 completion:(CLMRESTCompletion)completion;
- (void)unpinMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                   completion:(CLMRESTCompletion)completion;
```

### Polls

```objc
- (void)sendMessageWithPollInChannel:(NSString *)channelID content:(NSString *)content
                            pollJSON:(NSDictionary *)pollJSON completion:(CLMRESTCompletion)completion;
- (void)getPollAnswerUsersInChannel:(NSString *)channelID messageID:(NSString *)messageID
                           answerID:(NSString *)answerID after:(NSString *)after limit:(NSNumber *)limit
                         completion:(CLMRESTCompletion)completion;
- (void)expirePollInChannel:(NSString *)channelID messageID:(NSString *)messageID
                 completion:(CLMRESTCompletion)completion;
```

### Threads

```objc
- (void)startThreadFromMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID
                                   name:(NSString *)name autoArchiveDuration:(NSNumber *)duration
                      rateLimitPerUser:(NSNumber *)rateLimit completion:(CLMRESTCompletion)completion;
- (void)startThreadInChannel:(NSString *)channelID name:(NSString *)name
          autoArchiveDuration:(NSNumber *)duration type:(NSNumber *)type
                   invitable:(NSNumber *)invitable rateLimitPerUser:(NSNumber *)rateLimit
                   completion:(CLMRESTCompletion)completion;
- (void)joinThread:(NSString *)threadID completion:(CLMRESTCompletion)completion;
- (void)leaveThread:(NSString *)threadID completion:(CLMRESTCompletion)completion;
- (void)addThreadMember:(NSString *)threadID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)removeThreadMember:(NSString *)threadID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)listPublicArchivedThreadsInChannel:(NSString *)channelID before:(NSString *)before
                                     limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion;
// listPrivateArchivedThreadsInChannel, listJoinedPrivateArchivedThreadsInChannel,
// listActiveThreadsInGuild, getThreadMember, listThreadMembers
```

### Permission Overwrites

```objc
- (void)setPermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID
                                  allow:(NSNumber *)allow deny:(NSNumber *)deny type:(NSNumber *)type
                             completion:(CLMRESTCompletion)completion;
- (void)deletePermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID
                                completion:(CLMRESTCompletion)completion;
```

### Invites

```objc
- (void)createInviteInChannel:(NSString *)channelID maxAge:(NSNumber *)maxAge maxUses:(NSNumber *)maxUses
                    temporary:(NSNumber *)temporary unique:(NSNumber *)unique
                   completion:(CLMRESTCompletion)completion;
- (void)getInviteWithCode:(NSString *)inviteCode completion:(CLMRESTCompletion)completion;
- (void)getInviteWithCode:(NSString *)inviteCode withCounts:(BOOL)withCounts
               completion:(CLMRESTCompletion)completion;
- (void)deleteInviteWithCode:(NSString *)inviteCode completion:(CLMRESTCompletion)completion;
- (void)listInvitesInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)listInvitesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
```

### Guilds

```objc
- (void)getGuildWithID:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getGuildPreview:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWithID:(NSString *)guildID name:(NSString *)name icon:(NSString *)icon
              description:(NSString *)description completion:(CLMRESTCompletion)completion;
- (void)listChannelsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)createChannelInGuild:(NSString *)guildID name:(NSString *)name type:(NSNumber *)type
                       topic:(NSString *)topic completion:(CLMRESTCompletion)completion;
- (void)modifyGuildChannelPositions:(NSString *)guildID positions:(NSArray<NSDictionary *> *)positions
                         completion:(CLMRESTCompletion)completion;
```

### Members

```objc
- (void)listMembersInGuild:(NSString *)guildID limit:(NSNumber *)limit after:(NSString *)after
                completion:(CLMRESTCompletion)completion;
- (void)searchMembersInGuild:(NSString *)guildID query:(NSString *)query limit:(NSNumber *)limit
                  completion:(CLMRESTCompletion)completion;
- (void)getMemberInGuild:(NSString *)guildID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)addGuildMember:(NSString *)guildID userID:(NSString *)userID accessToken:(NSString *)accessToken
                   nick:(NSString *)nick roles:(NSArray<NSString *> *)roles
                   mute:(NSNumber *)mute deaf:(NSNumber *)deaf completion:(CLMRESTCompletion)completion;
- (void)modifyMemberInGuild:(NSString *)guildID userID:(NSString *)userID nick:(NSString *)nick
                 completion:(CLMRESTCompletion)completion;
- (void)modifyCurrentMemberInGuild:(NSString *)guildID nick:(NSString *)nick
                        completion:(CLMRESTCompletion)completion;
- (void)kickMemberInGuild:(NSString *)guildID userID:(NSString *)userID
               completion:(CLMRESTCompletion)completion;
- (void)addRoleToMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID
                    completion:(CLMRESTCompletion)completion;
- (void)removeRoleFromMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID
                         completion:(CLMRESTCompletion)completion;
```

### Roles

```objc
- (void)listRolesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion;
- (void)createRoleInGuild:(NSString *)guildID name:(NSString *)name completion:(CLMRESTCompletion)completion;
- (void)modifyRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID json:(NSDictionary *)json
              auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)deleteRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID
               completion:(CLMRESTCompletion)completion;
- (void)bulkOverwriteRolesInGuild:(NSString *)guildID roles:(NSArray<NSDictionary *> *)roles
                  auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)getRoleMemberCountsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
```

### Bans

```objc
- (void)listBansInGuild:(NSString *)guildID limit:(NSNumber *)limit before:(NSString *)before
                  after:(NSString *)after completion:(CLMRESTCompletion)completion;
- (void)getBanInGuild:(NSString *)guildID userID:(NSString *)userID completion:(CLMRESTCompletion)completion;
- (void)banUserInGuild:(NSString *)guildID userID:(NSString *)userID
   deleteMessageSeconds:(NSNumber *)deleteMessageSeconds auditLogReason:(NSString *)reason
            completion:(CLMRESTCompletion)completion;
- (void)unbanUserInGuild:(NSString *)guildID userID:(NSString *)userID
         auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion;
- (void)bulkBanUsersInGuild:(NSString *)guildID userIDs:(NSArray<NSString *> *)userIDs
       deleteMessageSeconds:(NSNumber *)deleteMessageSeconds auditLogReason:(NSString *)reason
                 completion:(CLMRESTCompletion)completion;
```

### Guild Management

```objc
- (void)getGuildAuditLog:(NSString *)guildID userID:(NSString *)userID actionType:(NSNumber *)actionType
                  before:(NSString *)before limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion;
- (void)getPruneCountInGuild:(NSString *)guildID days:(NSNumber *)days
                includeRoles:(NSArray<NSString *> *)includeRoles completion:(CLMRESTCompletion)completion;
- (void)beginPruneInGuild:(NSString *)guildID days:(NSNumber *)days
             includeRoles:(NSArray<NSString *> *)includeRoles computeCount:(NSNumber *)computeCount
               completion:(CLMRESTCompletion)completion;
- (void)getGuildWidget:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWidget:(NSString *)guildID enabled:(NSNumber *)enabled
                channelID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)getGuildVanityURL:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)listGuildIntegrations:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)deleteGuildIntegration:(NSString *)guildID integrationID:(NSString *)integrationID
                    completion:(CLMRESTCompletion)completion;
- (void)getGuildMemberVerification:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildMemberVerification:(NSString *)guildID json:(NSDictionary *)json
                           completion:(CLMRESTCompletion)completion;
- (void)modifyGuildIncidentActions:(NSString *)guildID json:(NSDictionary *)json
                        completion:(CLMRESTCompletion)completion;
- (void)getGuildVoiceRegions:(NSString *)guildID completion:(CLMRESTCompletion)completion;
```

### Emojis

```objc
// Guild emojis
- (void)listEmojisInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion;
- (void)createEmojiInGuild:(NSString *)guildID name:(NSString *)name image:(NSString *)image
                     roles:(NSArray<NSString *> *)roles completion:(CLMRESTCompletion)completion;
- (void)modifyEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID name:(NSString *)name
                     roles:(NSArray<NSString *> *)roles completion:(CLMRESTCompletion)completion;
- (void)deleteEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID
                completion:(CLMRESTCompletion)completion;
// Application emojis
- (void)listApplicationEmojis:(NSString *)applicationID completion:(CLMRESTCompletion)completion;
- (void)getApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID
                 completion:(CLMRESTCompletion)completion;
- (void)createApplicationEmoji:(NSString *)applicationID name:(NSString *)name
                  imageDataURI:(NSString *)imageDataURI completion:(CLMRESTCompletion)completion;
- (void)modifyApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID name:(NSString *)name
                    completion:(CLMRESTCompletion)completion;
- (void)deleteApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID
                    completion:(CLMRESTCompletion)completion;
```

### Stickers

```objc
- (void)listStickerPacks:(CLMRESTCompletion)completion;
- (void)getStickerPackWithID:(NSString *)packID completion:(CLMRESTCompletion)completion;
- (void)getStickerWithID:(NSString *)stickerID completion:(CLMRESTCompletion)completion;
- (void)listStickersInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)createStickerInGuild:(NSString *)guildID name:(NSString *)name description:(NSString *)description
                        tags:(NSString *)tags image:(NSString *)image completion:(CLMRESTCompletion)completion;
- (void)getStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID
               completion:(CLMRESTCompletion)completion;
- (void)modifyStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID name:(NSString *)name
                 description:(NSString *)description tags:(NSString *)tags
                  completion:(CLMRESTCompletion)completion;
- (void)deleteStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID
                  completion:(CLMRESTCompletion)completion;
```

### Webhooks

```objc
- (void)listWebhooksInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)listWebhooksInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name
                    completion:(CLMRESTCompletion)completion;
- (void)getWebhookWithID:(NSString *)webhookID completion:(CLMRESTCompletion)completion;
- (void)getWebhookWithToken:(NSString *)webhookID token:(NSString *)token
                 completion:(CLMRESTCompletion)completion;
- (void)modifyWebhookWithID:(NSString *)webhookID name:(NSString *)name channelID:(NSString *)channelID
                 completion:(CLMRESTCompletion)completion;
- (void)modifyWebhookWithToken:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json
                    completion:(CLMRESTCompletion)completion;
- (void)deleteWebhookWithID:(NSString *)webhookID completion:(CLMRESTCompletion)completion;
- (void)deleteWebhookWithID:(NSString *)webhookID auditLogReason:(NSString *)reason
                 completion:(CLMRESTCompletion)completion;
- (void)deleteWebhookWithToken:(NSString *)webhookID token:(NSString *)token
                    completion:(CLMRESTCompletion)completion;
```

#### Webhook Execution

```objc
- (void)executeWebhookWithID:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json
                       files:(NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion;
- (void)executeWebhookWithID:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json
                    threadID:(NSString *)threadID wait:(NSNumber *)wait
                       files:(NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion;
- (void)executeSlackWebhookWithID:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json
                         threadID:(NSString *)threadID completion:(CLMRESTCompletion)completion;
- (void)executeGitHubWebhookWithID:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json
                          threadID:(NSString *)threadID completion:(CLMRESTCompletion)completion;
- (void)getWebhookMessage:(NSString *)webhookID token:(NSString *)token messageID:(NSString *)messageID
               completion:(CLMRESTCompletion)completion;
```

### Application Commands

```objc
// Global
- (void)listGlobalApplicationCommands:(NSString *)applicationID completion:(CLMRESTCompletion)completion;
- (void)getGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID
                         completion:(CLMRESTCompletion)completion;
- (void)createGlobalApplicationCommand:(NSString *)applicationID json:(NSDictionary *)json
                            completion:(CLMRESTCompletion)completion;
- (void)editGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID
                                json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID
                            completion:(CLMRESTCompletion)completion;
- (void)bulkOverwriteGlobalCommands:(NSString *)applicationID commands:(NSArray<NSDictionary *> *)commands
                         completion:(CLMRESTCompletion)completion;
// Guild
- (void)listGuildApplicationCommands:(NSString *)applicationID guildID:(NSString *)guildID
                          completion:(CLMRESTCompletion)completion;
- (void)getGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID
                         commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion;
- (void)createGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID
                                 json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)editGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID
                          commandID:(NSString *)commandID json:(NSDictionary *)json
                         completion:(CLMRESTCompletion)completion;
- (void)deleteGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID
                            commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion;
- (void)bulkOverwriteGuildCommands:(NSString *)applicationID guildID:(NSString *)guildID
                          commands:(NSArray<NSDictionary *> *)commands completion:(CLMRESTCompletion)completion;
```

#### Command Permissions

```objc
- (void)listGuildApplicationCommandPermissions:(NSString *)applicationID guildID:(NSString *)guildID
                                    completion:(CLMRESTCompletion)completion;
- (void)batchEditGuildCommandPermissions:(NSString *)applicationID guildID:(NSString *)guildID
                             permissions:(NSArray<NSDictionary *> *)permissions
                              completion:(CLMRESTCompletion)completion;
- (void)getApplicationCommandPermissions:(NSString *)applicationID guildID:(NSString *)guildID
                               commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion;
- (void)editApplicationCommandPermissions:(NSString *)applicationID guildID:(NSString *)guildID
                                commandID:(NSString *)commandID
                              permissions:(NSArray<NSDictionary *> *)permissions
                               completion:(CLMRESTCompletion)completion;
```

### Interactions

```objc
- (void)createInteractionCallbackWithID:(NSString *)interactionID token:(NSString *)token
                                   json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;

// Convenience helpers
- (void)replyToInteractionWithMessage:(NSString *)interactionID token:(NSString *)token
                                 json:(NSDictionary *)data completion:(CLMRESTCompletion)completion;  // type 4
- (void)deferUpdateForInteractionID:(NSString *)interactionID token:(NSString *)token
                         completion:(CLMRESTCompletion)completion;  // type 6
- (void)updateMessageForInteractionID:(NSString *)interactionID token:(NSString *)token
                                 json:(NSDictionary *)data completion:(CLMRESTCompletion)completion;  // type 7
- (void)presentModalForInteractionID:(NSString *)interactionID token:(NSString *)token
                                json:(NSDictionary *)data completion:(CLMRESTCompletion)completion;  // type 9

// Followups
- (void)createFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token
                                       json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)getOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token
                                          completion:(CLMRESTCompletion)completion;
- (void)editOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token
                                                  json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token
                                             completion:(CLMRESTCompletion)completion;
- (void)editFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token
                                messageID:(NSString *)messageID json:(NSDictionary *)json
                               completion:(CLMRESTCompletion)completion;
- (void)deleteFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token
                                  messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion;
```

### Scheduled Events

```objc
- (void)listGuildScheduledEvents:(NSString *)guildID withUsers:(NSNumber *)withUsers
                      completion:(CLMRESTCompletion)completion;
- (void)getGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID
                     withUsers:(NSNumber *)withUsers completion:(CLMRESTCompletion)completion;
- (void)createGuildScheduledEvent:(NSString *)guildID json:(NSDictionary *)json
                       completion:(CLMRESTCompletion)completion;
- (void)modifyGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID
                             json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)deleteGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID
                       completion:(CLMRESTCompletion)completion;
- (void)listGuildScheduledEventUsers:(NSString *)guildID eventID:(NSString *)eventID
                          withMember:(NSNumber *)withMember before:(NSString *)before
                               after:(NSString *)after limit:(NSNumber *)limit
                          completion:(CLMRESTCompletion)completion;
```

### Stage Instances

```objc
- (void)createStageInstanceWithChannelID:(NSString *)channelID topic:(NSString *)topic
                            privacyLevel:(NSNumber *)privacyLevel completion:(CLMRESTCompletion)completion;
- (void)getStageInstanceWithChannelID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
- (void)modifyStageInstanceWithChannelID:(NSString *)channelID topic:(NSString *)topic
                            privacyLevel:(NSNumber *)privacyLevel completion:(CLMRESTCompletion)completion;
- (void)deleteStageInstanceWithChannelID:(NSString *)channelID completion:(CLMRESTCompletion)completion;
```

### AutoMod

```objc
- (void)listAutoModRulesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID
                   completion:(CLMRESTCompletion)completion;
- (void)createAutoModRuleInGuild:(NSString *)guildID json:(NSDictionary *)json
                      completion:(CLMRESTCompletion)completion;
- (void)modifyAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID json:(NSDictionary *)json
                      completion:(CLMRESTCompletion)completion;
- (void)deleteAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID
                      completion:(CLMRESTCompletion)completion;
```

### Guild Templates

```objc
- (void)listGuildTemplates:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getGuildTemplateWithCode:(NSString *)code completion:(CLMRESTCompletion)completion;
- (void)createGuildTemplate:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion;
- (void)syncGuildTemplate:(NSString *)guildID code:(NSString *)code completion:(CLMRESTCompletion)completion;
- (void)modifyGuildTemplate:(NSString *)guildID code:(NSString *)code json:(NSDictionary *)json
                 completion:(CLMRESTCompletion)completion;
- (void)deleteGuildTemplate:(NSString *)guildID code:(NSString *)code completion:(CLMRESTCompletion)completion;
```

### Welcome Screen & Onboarding

```objc
- (void)getGuildWelcomeScreen:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildWelcomeScreen:(NSString *)guildID json:(NSDictionary *)json
                      completion:(CLMRESTCompletion)completion;
- (void)getGuildOnboarding:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)modifyGuildOnboarding:(NSString *)guildID json:(NSDictionary *)json
                   completion:(CLMRESTCompletion)completion;
```

### Voice State (non-audio)

```objc
- (void)getCurrentUserVoiceStateInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion;
- (void)getUserVoiceStateInGuild:(NSString *)guildID userID:(NSString *)userID
                      completion:(CLMRESTCompletion)completion;
- (void)modifyCurrentUserVoiceStateInGuild:(NSString *)guildID channelID:(NSString *)channelID
                                  suppress:(NSNumber *)suppress requestToSpeakTimestampISO8601:(NSString *)timestamp
                                completion:(CLMRESTCompletion)completion;
- (void)modifyUserVoiceStateInGuild:(NSString *)guildID userID:(NSString *)userID
                          channelID:(NSString *)channelID suppress:(NSNumber *)suppress
                         completion:(CLMRESTCompletion)completion;
```

### Gateway, OAuth2, Voice Regions, Role Connections

```objc
- (void)getGatewayWithCompletion:(CLMRESTCompletion)completion;
- (void)getGatewayBotWithCompletion:(CLMRESTCompletion)completion;
- (void)listVoiceRegionsWithCompletion:(CLMRESTCompletion)completion;
- (void)getOAuth2ApplicationWithCompletion:(CLMRESTCompletion)completion;
- (void)getOAuth2AuthorizationWithCompletion:(CLMRESTCompletion)completion;
- (void)getApplicationRoleConnectionMetadata:(NSString *)applicationID completion:(CLMRESTCompletion)completion;
- (void)updateApplicationRoleConnectionMetadata:(NSString *)applicationID json:(NSDictionary *)json
                                     completion:(CLMRESTCompletion)completion;
```

## Audit Log Reason

Many endpoints accept an optional `auditLogReason:` parameter. The reason is URL-encoded and sent as the `X-Audit-Log-Reason` header.

## File Uploads

Use `CLMRESTFilePart` to attach files:

```objc
CLMRESTFilePart *file = [CLMRESTFilePart partWithField:@"files[0]"
                                               filename:@"image.png"
                                               mimeType:@"image/png"
                                                   data:imageData];
```

Pass files to `sendMessageInChannel:json:files:completion:` or `executeWebhookWithID:token:json:files:completion:`.

## Paginators

```objc
@interface CLMMessagesPaginator : NSObject
- (instancetype)initWithClient:(CLMDiscordRESTClient *)client channelID:(NSString *)channelID limit:(NSInteger)limit;
- (void)loadMore:(CLMRESTCompletion)completion;
- (BOOL)hasMore;
@end

@interface CLMMembersPaginator : NSObject
- (instancetype)initWithClient:(CLMDiscordRESTClient *)client guildID:(NSString *)guildID limit:(NSInteger)limit;
- (void)loadMore:(CLMRESTCompletion)completion;
- (BOOL)hasMore;
@end
```
