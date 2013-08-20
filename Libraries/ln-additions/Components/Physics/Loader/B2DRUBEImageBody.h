/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#include "b2dJsonImage.h"
#import "B2DBody.h"


/** A wrapper around b2dJsonImage */
/**
* Problem of this approach:
* 1. each b2Body * will only be able to bind to one RUBEImageBody, while each one
* of RUBEImageBody only records the information about one image;
* therefore each RUBEImage will only be able to bind to one body
*
*/
@interface B2DRUBEImageBody : B2DBody
/** the name is the name of the image file; which usually is the same as the name of
 * the spriteFrame */
@property (nonatomic, readonly) NSString *imgName;
/** file is usually not applicable as we'd be using CCSpriteFrame all the
 * time, but it is still there for information */
//@property (nonatomic, readonly) NSString *file;
@property (nonatomic, readonly) float imgScale;
@property (nonatomic, readonly) float imgAngle;
@property (nonatomic, readonly) GLubyte imgOpacity;
@property (nonatomic, readonly) ccColor3B imgColorTint;
@property (nonatomic, readonly) BOOL imgFlip;
@property (nonatomic, readonly) CGPoint imgCenter;
@property (nonatomic, readonly) int imgZOrder;

@property (nonatomic, assign) b2dJsonImage *image;

+ (id)bodyWithJsonImage:(b2dJsonImage *)image;
@end
