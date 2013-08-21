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
* The world object is read as a readonly property because it is strictly
* defined as *THE CLOSEST ASSIGNABLE WORLD* that fits into slot. There
* in fact isn't any sort of manual tinkering required by the user (the
* user shouldn't as well)
*/
@property(nonatomic, readonly, weak) World *world;
/** gives back the class of the world attribute for this world obj*/
@property(nonatomic, readonly) Class worldClass;

+ (id)body;

- (void)worldChangedFrom:(World *)ow to:(World *)nw;

- (void)setClosestWorld:(World *)world;
@end