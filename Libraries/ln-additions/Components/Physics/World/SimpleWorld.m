/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "SimpleWorld.h"
#import "CCNode+LnAdditions.h"


@implementation SimpleWorld {

}

/** return the velocity from the host of the world */
- (CGPoint)referenceVelocity {
    return self.host.body.worldVelocity;
}

- (void)setReferenceVelocity:(CGPoint)referenceVelocity {
    self.host.body.velocity = referenceVelocity;
}

@end