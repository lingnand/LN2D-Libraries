/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@class PhysicsEngine;


@interface Body : CCComponent
/** On-screen velocity */
@property(nonatomic) CGPoint velocity;
/**
* @abstract Connection to the physical world
* @discussion the world object is essentially a data object requried by the body,
* in the subtypes of body, this data object should be allowed to be a covariant
* (a more specific subtype)
*/
@property(nonatomic,assign) PhysicsEngine *world;

+ (id)bodyWithPhysicsEngine:(PhysicsEngine *)world;

+ (id)body;
@end