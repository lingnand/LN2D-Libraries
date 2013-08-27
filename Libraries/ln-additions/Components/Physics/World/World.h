/*!
    @header PhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "CCComponent.h"
@class Body;

@interface World : CCComponent
+(id)world;

- (void)addBody:(Body *)body;

- (void)removeBody:(Body *)body;

- (NSSet *)allBodies;
@end
