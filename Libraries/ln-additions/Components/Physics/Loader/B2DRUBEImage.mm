/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DRUBEImage.h"
#import "B2DWorld.h"
#import "CCNode+LnAdditions.h"


@implementation B2DRUBEImage {
    b2Vec2 _b2_center;
}

+ (id)bodyWithJsonImage:(b2dJsonImage *)image {
    return [[self alloc] initWithB2dJsonImage:image];
}

- (id)initWithB2dJsonImage:(b2dJsonImage *)image {
    self = [super init];
    if (self) {
        _attachedBody = [B2DBody bodyWithB2Body:image->body];
        // initiating a new ccsprite instance
        _image = [CCSprite spriteWithSpriteFrameName:[NSString stringWithUTF8String:image->name.c_str()]];
        // we can now set up all the sprite details
        // these will not change during simulation so we can set them now
        // this scale is the height of the image in WORLD units
        // scale / PTM_RATIO / sprite.contentSize.height
        self.image.scale = image->scale / self.attachedBody.world.ptmRatio / self.image.contentSize.height;
        self.image.flipX = image->flip;
        self.image.color = ccc3(image->colorTint[0], image->colorTint[1], image->colorTint[2]);
        self.image.opacity = (GLubyte) (image->opacity * 255);
        // angle and more
        self.image.rotation = CC_RADIANS_TO_DEGREES(-image->angle);
        // anchorPoint
        self.image.anchorPoint = ccp(0.5, 0.5);
        // positioning
        // this might not be very good (as it might not be querying the real ptmRatio
        // on the world (the world's ptm ratio might get changed at anytime
        self.image.position = [self.attachedBody.world CGPointFromb2Vec2:_b2_center];
        self.image.zOrder = (int) image->renderOrder;
    }

    return self;
}

- (void)onAddComponent {
    [super onAddComponent];
    [self.delegate addChild:self.image];
    // add the body if it's not present
    self.delegate.body = self.attachedBody;
}


@end