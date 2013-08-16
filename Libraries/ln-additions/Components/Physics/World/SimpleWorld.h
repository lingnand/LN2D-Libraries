/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "World.h"


@interface SimpleWorld : World
/** The reference velocity for the the on-screen velocity */
@property(nonatomic) CGPoint referenceVelocity;

+ (id)worldWithReferenceVelocity:(CGPoint)vref;
@end