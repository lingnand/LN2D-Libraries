/*!
    @header Mover
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Body.h"
#import "BodilyMask.h"

@class SimpleSpace;


/** A simpleBody is the simplest implementation that fulfills the requirement
 * of Body - using an update method that updates the position of the node
  * through velocity and acceleration increments
  * A simpleBody is also designed to be able to operate without a proper world.
  * In this situation the worldPosition/Velocity return the same thing as
  * absolutePosition/Velocity
  * */

 @interface TranslationalBody : Body <Masked>
/** The acceleration attribute is added to allow more precise control (steady) */
@property(nonatomic) CGPoint acceleration;
@property(nonatomic) CGPoint spaceAcceleration;
@property(nonatomic) CGFloat restitution;
/** The mask property must be set for it to be checked against in the world */
@property (nonatomic, strong) Mask *mask;
@property(nonatomic, weak) SimpleSpace *space;

- (id)copyWithZone:(NSZone *)zone;
@end
