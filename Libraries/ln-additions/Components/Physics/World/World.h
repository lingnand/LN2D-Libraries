/*!
    @header PhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "CCComponent.h"

@interface World : CCComponent
+(id)world;

+ (NSString *)worldAddedNotificationName;

+ (NSString *)worldRemovedNotificationName;

+ (NSString *)bodyWorldRequestNotificationName;
@end