/*!
    @header ChildrenMask
    @copyright LnStudio
    @updated 28/08/2013
    @author lingnan
*/

#import "NodeMask.h"
#import "CCComponentManager.h"
#import "CompositeMask.h"
#import "RectMask.h"

#define rectMaskKey @"rect"
#define compositeMaskKey @"composite"
@interface NodeMask ()
@property(nonatomic, strong) CCComponentManager *masks;
@property(nonatomic, readonly) CompositeMask *compositeMask;
@property(nonatomic, readonly) RectMask *rectMask;
@property(nonatomic, readonly) Mask *currentMask;
@end

@implementation NodeMask {

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

- (CCComponentManager *)masks {
    if (!_masks)
        _masks = [CCComponentManager manager];
    return _masks;
}

- (RectMask *)rectMask {
    RectMask *m = self.masks[rectMaskKey];
    if (!m)
        self.masks[rectMaskKey] = m = [RectMask mask];
    return m;
}

- (CompositeMask *)compositeMask {
    CompositeMask *m = self.masks[compositeMaskKey];
    if (!m)
        self.masks[compositeMaskKey] = m = [CompositeMask maskWithNodeContainer:self.host.children];
    return m;
}

- (Mask *)currentMask {
    return self.host.children.count ? self.compositeMask : self.rectMask;
}

- (void)activate {
    self.masks.delegate = self.host;
}

- (void)deactivate {
    self.masks.delegate = nil;
}

@end