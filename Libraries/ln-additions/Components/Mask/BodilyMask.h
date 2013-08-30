/*!
    @header NodalMask
    @copyright LnStudio
    @updated 30/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Mask.h"

@class Body;


/** This group of masks are characterized by attaching to a body,
 * They are concerned about how to compute intersection in the body / world
  * system*/

@interface BodilyMask : Mask
@property (nonatomic, weak) Body *body;
@end