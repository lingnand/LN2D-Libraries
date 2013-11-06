/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import "CCComponent.h"
#import "B2DRUBEImage.h"
#import "B2DSpace.h"
#import "B2DBody.h"

@implementation B2DRUBEImage {
    b2Vec2 _b2_center;
    CCSprite *_image;
}

+ (id)imageWithJsonImage:(b2dJsonImage *)image {
    return [[self alloc] initWithJsonImage:image];
}

// we shouldn't allocate memory for image from the start
- (id)initWithJsonImage:(b2dJsonImage *)image {
    self = [super init];
    if (self) {
        _attachedBody = image->body;
        _name = [NSString stringWithUTF8String:image->name.c_str()];
        _filename = [NSString stringWithUTF8String:image->file.c_str()];
        _physicalScale = image->scale;
        _flipX = image->flip;
        _color = ccc3(image->colorTint[0], image->colorTint[1], image->colorTint[2]);
        _opacity = (GLubyte) (image->opacity * 255);
        // angle and more
        _b2_center = image->center;
        _rotation = CC_RADIANS_TO_DEGREES(-image->angle);
        _zOrder = (int) image->renderOrder;
    }

    return self;
}

- (CGPoint)center {
    return CGPointFromb2Vec2(_b2_center, self.associatedBody.space);
}

- (B2DBody *)associatedBody {
    return [B2DBody bodyFromB2Body:self.attachedBody];
}


- (CCSprite *)image {
    if (!_image) {
        // initiating a new ccsprite instance
        _image = [CCSprite spriteWithSpriteFrameName:self.filename];
        // we can now set up all the sprite details
        // these will not change during simulation so we can set them now
        // this scale is the height of the image in WORLD units
        // scale / PTM_RATIO / sprite.contentSize.height
        _image.scale = CGLengthFromb2Length(self.physicalScale, self.associatedBody.space) / _image.contentSize.height;
        _image.flipX = self.flipX;
        _image.color = self.color;
        _image.opacity = self.opacity;
        // angle and more
        _image.rotation = self.rotation;
        // anchorPoint
        _image.anchorPoint = ccp(0.5, 0.5);
        _image.zOrder = self.zOrder;
    }
    return _image;
}

- (void)componentActivated {
    [super componentActivated];
    // positioning
    // this might not be very good (as it might not be querying the real ptmRatio
    // on the world (the world's ptm ratio might get changed at anytime
    // we need to take account of the anchor point of the host
    // the center property is essentially the displacement from the ANCHOR, not the lower-left corner
    self.image.position = ccpAdd(self.host.anchorPointInPoints, self.center);
    [self.host addChild:self.image];
}

- (void)componentDeactivated {
    [super componentDeactivated];
    [self.host removeChild:self.image cleanup:YES];
}


@end