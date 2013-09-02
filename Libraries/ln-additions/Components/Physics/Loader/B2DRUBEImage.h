/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#include "b2dJsonImage.h"
#include "b2dJson.h"

@class B2DBody;


/** A wrapper around b2dJsonImage */
/**
* NOTICE:
* After adding this component a sprite woould be initiated and added
* to the delegate to simulate the effects as in RUBE
*
*/
@interface B2DRUBEImage : CCComponent

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *filename;
/** height of the image in physical unit */
@property (nonatomic, readonly) float physicalScale;
@property (nonatomic, readonly) float rotation;
@property (nonatomic, readonly) GLubyte opacity;
@property (nonatomic, readonly) ccColor3B color;
@property (nonatomic, readonly) BOOL flipX;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) int zOrder;
@property (nonatomic, readonly, strong) CCSprite *image;
@property (nonatomic, readonly, assign) b2Body *attachedBody;
/** The attached body for this image. NOTE: if the body is
 *  not created before it won't get created automatically (...OK)
 *  Think about this: body is at a higher hierarchy than an image,
 *  and therefore if there's a RUBEImage then there should already be
 *  a B2DBody for it.
 * */
@property (nonatomic, readonly) B2DBody *associatedBody;

+ (id)imageWithJsonImage:(b2dJsonImage *)image;
@end
