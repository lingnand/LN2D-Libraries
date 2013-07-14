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
	return CGRectContainsPoint(self.delegate.canvasBox, point);
}

- (BOOL)intersectsOneSide:(Mask *)other {
	CGRect cbox1 = self.delegate.canvasBox;
	CGRect cbox2 = other.delegate.canvasBox;
	return CGRectIntersectsRect(cbox1, cbox2);
}

- (MaskIntersectComplexity)complexity {
    return ComplexityLow;
}

- (MaskIntersectPolicy)intersectPolicy {
    return IntersectAND;
}
@end