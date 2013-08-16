/*!
    @header PhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "CCComponent.h"

extern NSString *BodyWorldRequestNotification;
extern NSString *WorldAddedNotification;
extern NSString *WorldRemovedNotification;

@interface World : CCComponent
+(id)world;

+ (NSString *)worldAddedNotificationName;

+ (NSString *)worldRemovedNotificationName;

+ (NSString *)bodyWorldRequestNotificationName;
@end