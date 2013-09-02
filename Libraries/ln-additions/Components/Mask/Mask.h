//
// Created by knight on 10/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "CCComponent.h"
#import "Body.h"

@class Mask;

typedef NS_ENUM(NSUInteger, MaskIntersectComplexity) {
    ComplexityLow,
    ComplexityMedium,
    ComplexityHigh,
    ComplexityUltraHigh
};

typedef NS_ENUM(NSUInteger, MaskIntersectPolicy) {
    IntersectAND,
    IntersectOR
};


@interface Mask : CCComponent <NSCopying>

/** By attaching to the body mask can access information regarding world / body */
@property (nonatomic, weak, readonly) Body *parent;

+ (id)mask;

/**
    Check if a WORLD point is inside the delegate of the current mask
    Note that the world USUALLY follows the definition of the world in the body
    that the mask is attached to. To a virtual mask this might involve one or multiple
    worlds (tricky).
    @param point
        A point in the world coordinate
*/
- (BOOL)contains:(CGPoint)point;

/**
    @abstract if the two nodes are considered to overlap
    @discussion Note that the intersectsNode method should take account the implementation of both of the masks
    on the two nodes. Two possible solutions

    1. OR: if either the two masks return YES, then return YES
    2. AND: only when both the two masks return YES

    In most cases 2 should make more sense - a basic mask implementation involves checking through all the areas
    of the nodes and only return NO if none of the area is considered be to overlapped -- this means the basic
    mask operation is an OR operation; which is easy to get YES and hard to get NO. And when one of the masks
    returns YES and the other returns NO, that means (most probably) the second one has checked for more cases
    than 1 and should be taken more seriously.

    To save performance though the subclass may wish to only uses one of the implementations.
*/
- (BOOL)intersects:(Mask *)other;

/** Overriden by subclass to provide the implementation (checked by one side) */
- (BOOL)intersectsOneSide:(Mask *)other;

- (MaskIntersectComplexity)complexity;

- (MaskIntersectPolicy)intersectPolicy;

- (id)copyWithZone:(NSZone *)zone;

@end