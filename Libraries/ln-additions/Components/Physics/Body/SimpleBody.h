/*!
    @header Mover
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Body.h"

@class SimpleWorld;


@interface SimpleBody : Body
@property(nonatomic) CGPoint acceleration;
@property(nonatomic,readonly) CGPoint actualVelocity;
@end
