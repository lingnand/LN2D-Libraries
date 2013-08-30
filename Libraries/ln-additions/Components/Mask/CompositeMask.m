//
// Created by Lingnan Dai on 23/04/2013.
//


#import "CompositeMask.h"
#import "CCNode+LnAdditions.h"


@implementation CompositeMask {

}

+ (id)maskWithContainer:(id <NSFastEnumeration>)container {
    return [[self alloc] initWithContainer:container];
}

- (id)initWithContainer:(id <NSFastEnumeration>)container {
    if (self = [super init]) {
        self.container = container;
    }
    return self;
}

- (BOOL)contains:(CGPoint)point {
    for (id child in self.container) {
        if ([child conformsToProtocol:@protocol(Masked)] && [((id<Masked>)child).mask contains:point])
                return YES;
    }
    return NO;
}

- (BOOL)intersectsOneSide:(Mask *)other{
    for (id child in self.container) {
        if ([child conformsToProtocol:@protocol(Masked)] && [((id<Masked>)child).mask intersects:other])
                return YES;
    }
    return NO;
}

- (MaskIntersectComplexity)complexity {
    return ComplexityUltraHigh;
}

- (MaskIntersectPolicy)intersectPolicy {
    return IntersectOR;
}

- (id)copyWithZone:(NSZone *)zone {
    CompositeMask *copy = (CompositeMask *) [super copyWithZone:zone];

    if (copy != nil) {
        copy.container = self.container;
    }

    return copy;
}


@end