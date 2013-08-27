/*!
    @header Mover
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Body.h"


/** A simpleBody is the simplest implementation that fulfills the requirement
 * of Body - using an update method that updates the position of the node
  * through velocity and acceleration increments*/

 @interface SimpleBody : Body
/** The acceleration attribute is added to allow more precise control (steady) */
@property(nonatomic) CGPoint acceleration;
@end
