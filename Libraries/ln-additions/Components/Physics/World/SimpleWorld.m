/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "SimpleWorld.h"


@implementation SimpleWorld {

}

+(id)worldWithReferenceVelocity:(CGPoint)vref {
    SimpleWorld *engine = [self world];
    engine.referenceVelocity = vref;
    return engine;
}

@end