/*!
    @header SimplePhysicsEngine
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "World.h"

@class Mask;

/** A simple world updates all the dynamic bodies inside with some gravity; and it handles
 * the collision with all other bodies
 *
 * SimpleWorld can handle all bodies, technically. But there's really no sense in managing
 * B2DBody with SimpleWorld for example (in fact B2DBody wouldn't allow that to happen)
 *
 * SimpleWorld relies on Mask to check for collision. If a collision takes place, it
 * would simulate some physical effect of bouncing off (to a limited extent)
 *
 * A problem is due to the generality of SimpleWorld - in fact, too many bodies can
 * be added to this world if it's not careful (almost all the nodes come with SimpleBody,
 * and SimpleBody would be added to a SimpleWorld automatically).
 * */

@interface SimpleWorld : World
@property(nonatomic) ccTime step;

- (id)initWithGravity:(CGPoint)gravity step:(ccTime)step;

+ (id)worldWithGravity:(CGPoint)gravity step:(ccTime)step;
@end
