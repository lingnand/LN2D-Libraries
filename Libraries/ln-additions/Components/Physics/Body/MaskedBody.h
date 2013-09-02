/*!
    @header MaskedBody
    @copyright LnStudio
    @updated 31/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "TranslationalBody.h"

@class PhysicsSpace;

typedef NS_ENUM(NSUInteger, MaskedBodyType)
{
    /** Similar to the counterpart in B2D, a kinematic body can move but doesn't react to collisions */
    MaskedBodyKinematic,
    /** Similar to the counterpart in B2D, a dynamic body reacts to collisions */
    MaskedBodyDynamic
};

@interface MaskedBody : TranslationalBody

/** The type information is needed by spaces to update the bodies correctly */
@property(nonatomic) MaskedBodyType type;
@property(nonatomic) CGFloat restitution;
/** The mask property must be set for it to be checked against in the PhysicsSpace */
@property (nonatomic, strong) Mask *mask;
/** a dedicated contact listener that handles the collision on this body
* this property is implemented on the basis of lazy initialization so
* you can be safe to call methods directly on it */
@property(nonatomic) ContactListener *contactListener;

@property(nonatomic, weak) PhysicsSpace *space;

+ (id)bodyWithMask:(Mask *)mask;
- (id)copyWithZone:(NSZone *)zone;

@end