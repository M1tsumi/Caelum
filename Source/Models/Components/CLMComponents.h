#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLMComponentType) {
    CLMComponentTypeActionRow = 1,
    CLMComponentTypeButton = 2,
    CLMComponentTypeTextInput = 4,
    CLMComponentTypeSelectString = 3,
    CLMComponentTypeSelectUser = 5,
    CLMComponentTypeSelectRole = 6,
    CLMComponentTypeSelectMentionable = 7,
    CLMComponentTypeSelectChannel = 8,
};

typedef NS_ENUM(NSInteger, CLMButtonStyle) {
    CLMButtonStylePrimary = 1,
    CLMButtonStyleSecondary = 2,
    CLMButtonStyleSuccess = 3,
    CLMButtonStyleDanger = 4,
    CLMButtonStyleLink = 5,
};

FOUNDATION_EXPORT NSErrorDomain const CLMComponentsErrorDomain;

typedef NS_ERROR_ENUM(CLMComponentsErrorDomain, CLMComponentsErrorCode) {
    CLMComponentsErrorInvalidLayout = 1,
    CLMComponentsErrorInvalidField = 2,
    CLMComponentsErrorOutOfRange = 3,
    CLMComponentsErrorSerialization = 4,
};
