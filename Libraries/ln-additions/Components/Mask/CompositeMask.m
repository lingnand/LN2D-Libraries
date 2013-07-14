//
// Created by Lingnan Dai on 23/04/2013.
//


#import "CompositeMask.h"
#import "CCNode+LnAdditions.h"


@implementation CompositeMask {

}

+ (id)maskWithNodeContainer:(id <NSFastEnumeration>)container {
    return [[self alloc] initWithNodeContainer:container];
}

- (id)initWithNodeContainer:(id <NSFastEnumeration>)container {
    if (self = [super init]) {
        self.nodeContainer = container;
    }
    return self;
}

- (BOOL)contains:(CGPoint)point {
    for (id child in self.nodeContainer) {
        if ([child conformsToProtocol:@protocol(Masked)]) {
            id<Masked> maskOwner = child;
            if ([maskOwner.mask contains:point]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)intersectsOneSide:(Mask *)other{
    for (id child in self.nodeContainer) {
        if ([child conformsToProtocol:@protocol(Masked)]) {
            id<Masked> maskOwner = child;
            if ([maskOwner.mask intersects:other]) {
                return YES;
            }
        }
    }
    return NO;
}

- (MaskIntersectComplexity)complexity {
    return ComplexityUltraHigh;
}

- (MaskIntersectPolicy)intersectPolicy {
    return IntersectOR;
}


@end