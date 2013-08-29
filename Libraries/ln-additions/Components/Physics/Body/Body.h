/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "CCComponent.h"

@class World;
@class ContactListener;

typedef NS_ENUM(NSUInteger, BodyType)
{
    BodyTypeStatic,
    BodyTypeKinematic,
    BodyTypeDynamic
};

/**
* A virtual class that defines a common interface to the body component
* A body is like an actuator of the host, controls the position, velocity, etc.
* of the host
*/
@interface Body : CCComponent {
    __weak World *_world;
}

/** The type information is needed by worlds to update the bodies correctly */
@property(nonatomic) BodyType type;

/** These properties need to be overriden in the immediate subclass to
 * provide the correct implementation! */
 /** relative to the immediate parent */
@property(nonatomic) CGPoint position;
@property(nonatomic) CGPoint velocity;
/** relative to the world */
@property(nonatomic) CGPoint worldPosition;
@property(nonatomic) CGPoint worldVelocity;

/** the absolute position and velocity have been implemented, so no need to override */
/** relative to the whole application */
@property(nonatomic) CGPoint absolutePosition;
@property(nonatomic) CGPoint absoluteVelocity;

/**
* world is an object that represents the outermost container to the
* bodies. The positioning etc. might closely relate to which node the
* world component is attached to
*
* Note that the subclass might want to override the type of this property
* to be attached to more specific implementation of world.
* In that case MAKE SURE that the specific implementation of world does
* have the capacity of managing that body type
*/
@property(nonatomic, weak) World *world;
/** gives back the class of the world attribute for this world obj*/
@property(nonatomic, readonly) Class worldClass;

/** a dedicated contact listener that handles the collision on this body
* this property is implemented on the basis of lazy initialization so
* you can be safe to call methods directly on it */
@property(nonatomic) ContactListener *contactListener;

+ (id)body;

- (CGAffineTransform)hostParentToWorldTransform;

- (CGAffineTransform)worldToHostParentTransform;

- (void)setClosestWorld;

- (id)copyWithZone:(NSZone *)zone;
@end