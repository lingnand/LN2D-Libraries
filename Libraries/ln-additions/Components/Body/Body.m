/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "Body.h"
#import "PhysicsEngine.h"


@implementation Body {

}
+(id)bodyWithPhysicsEngine:(PhysicsEngine *)world {
    Body *b = [self body];
    b.world = world;
    return b;
}

+ (id)body {
    return [self component];
}
@end