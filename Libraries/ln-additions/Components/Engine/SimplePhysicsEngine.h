/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "PhysicsEngine.h"


@interface SimplePhysicsEngine : PhysicsEngine
/** The reference velocity for the the on-screen velocity */
@property(nonatomic) CGPoint referenceVelocity;

+ (id)engineWithReferenceVelocity:(CGPoint)vref;
@end