#import <Foundation/Foundation.h>
#import "Models/Components/CLMActionRow.h"
#import "Models/Components/CLMTextInput.h"

@interface CLMModal : NSObject
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<CLMActionRow *> *components; // rows with one CLMTextInput each
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON; // for interaction callback type 9 data
@end

@interface CLMModalBuilder : NSObject
- (instancetype)customId:(NSString *)customId;
- (instancetype)title:(NSString *)title;
- (instancetype)addTextInput:(CLMTextInput *)textInput; // adds as its own row
- (CLMModal *)build:(NSError **)error;
@end
