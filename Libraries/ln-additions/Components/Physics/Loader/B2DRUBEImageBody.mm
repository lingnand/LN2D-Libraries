/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DRUBEImageBody.h"
#import "B2DWorld.h"


@implementation B2DRUBEImageBody {
}

+ (id)bodyWithJsonImage:(b2dJsonImage *)image {
    return [[self alloc] initWithB2dJsonImage:image];
}

- (id)initWithB2dJsonImage:(b2dJsonImage *)image {
    self = [super initWithB2Body:image->body];
    if (self) {
        // if the self is not a b2drubeimagebody, we'd need to replace
        // that with a valid instance
        self.image = image;
    }

    return self;
}

#define SAFE_IMAGE_PROPERTY(property, fallback) (self.image ? property : fallback)

- (NSString *)imgName {
    return SAFE_IMAGE_PROPERTY([NSString stringWithUTF8String:self.image->name.c_str()], nil);
}

- (float)imgScale {
    return SAFE_IMAGE_PROPERTY(self.image->scale, 0);
}

- (float)imgAngle {
    return SAFE_IMAGE_PROPERTY(self.image->angle, 0);
}

- (int)imgZOrder {
    return SAFE_IMAGE_PROPERTY((int) self.image->renderOrder, 0);
}

- (GLubyte)imgOpacity {
    return SAFE_IMAGE_PROPERTY((GLubyte) (self.image->opacity * 255), 0);
}

- (ccColor3B)imgColorTint {
    return SAFE_IMAGE_PROPERTY(ccc3(self.image->colorTint[0], self.image->colorTint[1], self.image->colorTint[2]), ccc3(0,0,0));
}

- (BOOL)imgFlip {
    return SAFE_IMAGE_PROPERTY(self.image->flip, NO);
}

- (CGPoint)imgCenter {
    return [self.world CGPointFromb2Vec2:self.image->center];
}

- (void)onAddComponent {
    [super onAddComponent];
    NSAssert([self.delegate isKindOfClass:[CCSprite class]], @"This component only supports CCSprite and its subclasses");
    CCSprite *d = (CCSprite *) self.delegate;
    // we can now set up all the sprite details
    // these will not change during simulation so we can set them now
    // this scale is the height of the image in WORLD units
    // scale / PTM_RATIO / sprite.contentSize.height
    d.scale = self.imgScale / self.world.ptmRatio / self.delegate.contentSize.height;
    d.flipX = self.imgFlip;
    d.color = self.imgColorTint;
    d.opacity = self.imgOpacity;
}

- (void)update:(ccTime)step {
    if (self.activated) {
        CGPoint pos = self.imgCenter;
        float angle = -self.imgAngle;
        //need to rotate image local center by body angle
        b2Vec2 localPos( pos.x, pos.y );
        b2Rot rot(self.angle);
        localPos = b2Mul(rot, localPos) + self.position;
        pos.x = localPos.x;
        pos.y = localPos.y;
        angle += -self.angle;
        self.delegate.rotation = CC_RADIANS_TO_DEGREES(angle);
        self.delegate.position = pos;
    }
}




@end