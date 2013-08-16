/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#include <c++/4.2.1/bits/basic_string.h>
#import "RUBEImage.h"
#import "CCComponent.h"
#import "B2DBody.h"


@implementation RUBEImage {

}

+ (id)imageWithB2dJsonImage:(b2dJsonImage *)image {
    return [[self alloc] initWithB2dJsonImage:image];
}

- (id)initWithB2dJsonImage:(b2dJsonImage *)image {
    self = [super init];
    if (self) {
        _name = [NSString stringWithUTF8String:image->name.c_str()];
        _body = [B2DBody bodyWithB2Body:image->body];
        _scale = image->scale;
        _angle = image->angle;
        // convert float into glubyte 0-255
        _opacity = (GLubyte) (image->opacity * 255);
        _colorTint = ccc3(image->colorTint[0], image->colorTint[1], image->colorTint[2]);
        _flip = image->flip;
        _center = ccp(image->center.x, image->center.y);
        _zOrder = (int) image->renderOrder;
    }

    return self;
}

@end