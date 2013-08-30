/**
    @header RectMask
    @copyright LnStudio
    @updated 30/06/2013
    @author lingnan
*/

#import "RectMask.h"
#import "CCNode+LnAdditions.h"


@implementation RectMask {

}
- (BOOL)contains:(CGPoint)point {
	return [super contains:point] && CGRectContainsPoint(self.body.host.unionBoxInParent, point);
}

- (BOOL)intersectsOneSide:(Mask *)other {
    return [super intersectsOneSide:other] && CGRectIntersectsRect(self.body.hostUnionBoxInSpace, ((BodilyMask *)other).body.hostUnionBoxInSpace);
}

- (MaskIntersectComplexity)complexity {
    return ComplexityLow;
}

- (MaskIntersectPolicy)intersectPolicy {
    return IntersectAND;
}
@end