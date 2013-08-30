/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "CCComponent.h"

@class Space;
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
    __weak Space *_space;
}

/** The type information is needed by spaces to update the bodies correctly */
@property(nonatomic) BodyType type;

/** These properties need to be overriden in the immediate subclass to
 * provide the correct implementation! */
 /** relative to the immediate parent */
@property(nonatomic) CGPoint position;
@property(nonatomic) CGPoint velocity;
/** relative to the space */
@property(nonatomic) CGPoint spacePosition;
@property(nonatomic) CGPoint spaceVelocity;

/** the absolute position and velocity have been implemented, so no need to override */
/** relative to the whole application */
@property(nonatomic) CGPoint worldPosition;
@property(nonatomic) CGPoint worldVelocity;

/**
* Space is an object that represents the outermost container to the
* bodies. The positioning etc. might closely relate to which node the
* space component is attached to
*
* Note that the subclass might want to override the type of this property
* to be attached to more specific implementation of space.
* In that case MAKE SURE that the specific implementation of space does
* have the capacity of managing that body type
*/
@property(nonatomic, weak) Space *space;
/** gives back the class of the space attribute for this space obj*/
@property(nonatomic, readonly) Class spaceClass;

/** a dedicated contact listener that handles the collision on this body
* this property is implemented on the basis of lazy initialization so
* you can be safe to call methods directly on it */
@property(nonatomic) ContactListener *contactListener;

+ (id)body;

/** When the space is invalid (nil or not attached to any host or not attached
 * to a host in the outer layers) these transforms will be equivalent to the
  * world version */
- (CGAffineTransform)hostParentToSpaceTransform;

- (CGAffineTransform)spaceToHostParentTransform;

- (CGAffineTransform)hostToSpaceTransform;

- (CGAffineTransform)spaceToHostTransform;

- (CGRect)hostContentBoxInSpace;

- (CGRect)hostUnionBoxInSpace;

- (void)setClosestSpace;

- (id)copyWithZone:(NSZone *)zone;
@end