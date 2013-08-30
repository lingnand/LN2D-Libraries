//
// Created by knight on 10/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import "Mask.h"
#import "CCNode+LnAdditions.h"


@interface Mask()
@end

@implementation Mask {

}

+(id)mask {
    return [self new];
}

- (BOOL)contains:(CGPoint)point {
    return NO;
}

/**
    This method will attempt to resolve around the implementations of the two masks to make sure
    that [this intersects:other] and [other intersects:this] gives back the same result

    There are two policies considered: AND, OR
    AND mask: a restrictive mask - a common example is that the current mask has tried its best to
    obtain the result but it's still unsure whether there's any overlap even if it gives back YES,
    thus seeking answer from the other mask as well: this is suitable for masks built for general cases,
    that is to say, the mask uses an algorithm that understates results (if the two nodes don't overlap,
    it still might return YES, but if it returns NO then (most) definitely the two don't overlap)
    OR mask: an expansive mask - the current mask is confident that if it detects an overlap there must
    be an overlap, even if the other mask says there isn't: this is suitable for masks built for specific
    purposes or masks that don't rely on the delegate property for detecting collision e.g. Composite masks

    The resolution process is as follows:
    AND with AND mask: use AND operation with help from complexity
    OR with OR mask: use OR operation with help from complexity
    AND with OR mask:
        AND mask is confident that if it detects no overlap, there's definitely NO overlap
        OR mask is confident that if it detects an overlap, there's definitely An overlap
        resolution: if AND mask --> YES && OR mask --> NO => both masks are unsure => pick OR mask because it's usually more specific
                    if AND mask --> NO && OR mask --> YES => both mask are sure => pick OR mask because it's usually more specific
        The verdict: prefer OR mask when resolving two masks of different types
*/
- (BOOL)intersects:(Mask *)other {
    // if it's nil or the same mask is passed along then just return false
    if (!other || other == self)
        return NO;
    // if the two belong to the same class then essentially they are of the same implementation and the result
    // should be the same; if they aren't same then there's something wrong with that implementation! (consistency
    // broken)
    if (self.class == other.class) {
        return [self intersectsOneSide:other];
    } else if (self.intersectPolicy == IntersectAND && other.intersectPolicy == IntersectAND) {
        return self.complexity < other.complexity ?
                [self intersectsOneSide:other] && [other intersectsOneSide:self]
                : [other intersectsOneSide:self] && [self intersectsOneSide:other];
    } else if (self.intersectPolicy == IntersectOR && other.intersectPolicy == IntersectOR) {
        return self.complexity < other.complexity ?
                [self intersectsOneSide:other] || [other intersectsOneSide:self]
                : [other intersectsOneSide:self] || [self intersectsOneSide:other];
    } else {
        // get the OR mask
        return self.intersectPolicy == IntersectOR ? [self intersectsOneSide:other] : [other intersectsOneSide:self];
    }
}

/**
    This is the method every subclass should override with the appropriate implementation. It will be called within
    the intersectsNode method
*/
- (BOOL)intersectsOneSide:(Mask *)other {
    return NO;
}

/**
    Subclass should also override this to provide info about how expensive the intersection method is. The less
    expensive method will be executed first
*/
- (MaskIntersectComplexity)complexity {
    return ComplexityLow;
}

-(MaskIntersectPolicy)intersectPolicy {
    return IntersectAND;
}


@end