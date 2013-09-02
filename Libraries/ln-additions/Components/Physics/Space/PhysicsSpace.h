/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Space.h"


@class Mask;

/** A physics space updates all the dynamic bodies inside with some gravity; and it handles
 * the collision with all other bodies
 *
 * PhysicsSpace relies on Mask to check for collision. If a collision takes place, it
 * would simulate some physical effect of bouncing off (to a limited extent)
 *
 * */

@interface PhysicsSpace : Space
@property(nonatomic) ccTime step;

- (id)initWithGravity:(CGPoint)gravity step:(ccTime)step;

+ (id)spaceWithGravity:(CGPoint)gravity step:(ccTime)step;
@end
