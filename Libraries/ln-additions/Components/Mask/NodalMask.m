/*!
    @header ChildrenMask
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import "NodalMask.h"
#import "CompositeMask.h"
#import "RectMask.h"
#import "Body.h"

@interface NodalMask ()
@property(nonatomic, strong) CompositeMask *compositeMask;
@property(nonatomic, strong) RectMask *rectMask;
@property(nonatomic, readonly) Mask *currentMask;
@end

@implementation NodalMask {

}
- (BOOL)contains:(CGPoint)point {
    return [self.currentMask contains:point];
}

- (BOOL)intersectsOneSide:(Mask *)other {
    return [self.currentMask intersectsOneSide:other];
}

- (MaskIntersectComplexity)complexity {
    return self.currentMask.complexity;
}

- (MaskIntersectPolicy)intersectPolicy {
    return self.currentMask.intersectPolicy;
}

- (void)setBody:(Body *)body {
    [super setBody:body];
    self.rectMask.body = body;
    self.compositeMask.container = body.host.children;
}

- (RectMask *)rectMask {
    if (!_rectMask) {
        _rectMask = [RectMask mask];
        _rectMask.body = self.body;
    }
    return _rectMask;
}

- (CompositeMask *)compositeMask {
    if (!_compositeMask) {
        _compositeMask = [CompositeMask maskWithContainer:self.body.host.children];
    }
    return _compositeMask;
}

- (Mask *)currentMask {
    return self.body.host.children.count ? self.compositeMask : self.rectMask;
}

- (id)copyWithZone:(NSZone *)zone {
    NodalMask *copy = (NodalMask *)[super copyWithZone:zone];

    if (copy != nil) {
        copy.compositeMask = self.compositeMask.copy;
        copy.rectMask = self.rectMask.copy;
    }

    return copy;
}

@end