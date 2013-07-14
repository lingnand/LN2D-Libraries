/*!
    @header Mover
    @copyright LnStudio
    @updated 03/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "Body.h"

@class SimplePhysicsEngine;


@interface SimpleBody : Body
@property(nonatomic) CGPoint acceleration;
@property(nonatomic,readonly) CGPoint actualVelocity;
/** Convariant PhysicsEngine */
@property(nonatomic,assign) SimplePhysicsEngine *world;

+ (id)bodyWithPhysicsEngine:(SimplePhysicsEngine *)world;
@end
