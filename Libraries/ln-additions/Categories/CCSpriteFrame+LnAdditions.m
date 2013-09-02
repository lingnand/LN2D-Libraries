/*!
    @header CCSpriteFrame(LnAdditions)
    @copyright LnStudio
    @updated 02/09/2013
    @author lingnan
*/

#import "CCSpriteFrame+LnAdditions.h"


@implementation CCSpriteFrame (LnAdditions)
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[CCSpriteFrame class]]) {
        CCSpriteFrame *f = object;
        return self.texture.name == f.texture.name
                && CGRectEqualToRect(self.rect, f.rect)
                && self.rotated == f.rotated
                && CGPointEqualToPoint(self.offset, f.offset)
                && CGSizeEqualToSize(self.originalSize, f.originalSize);
}
    return NO;
}
@end