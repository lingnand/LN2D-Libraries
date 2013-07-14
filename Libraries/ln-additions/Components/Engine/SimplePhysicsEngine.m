/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import "SimplePhysicsEngine.h"


@implementation SimplePhysicsEngine {

}

+(id)engineWithReferenceVelocity:(CGPoint)vref {
    SimplePhysicsEngine *engine = [self engine];
    engine.referenceVelocity = vref;
    return engine;
}

@end