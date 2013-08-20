/*!
    @header Body
    @copyright LnStudio
    @updated 12/07/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>

@class World;


@interface Body : CCComponent
/** On-screen velocity */
@property(nonatomic) CGPoint velocity;
/**
* @abstract Connection to the physical world
* @discussion the world object is essentially a data object requried by the body,
* in the subtypes of body, this data object should be allowed to be a covariant
* (a more specific subtype)
*/
@property(nonatomic, weak) World *world;
/** gives back the class of the world attribute for this world obj*/
@property(nonatomic, readonly) Class worldClass;

+ (id)body;

- (void)worldChangedFrom:(World *)ow to:(World *)nw;

- (void)setClosestWorld:(World *)world;
@end