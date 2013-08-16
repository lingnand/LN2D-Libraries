/*!
    @header RUBEImage
    @copyright LnStudio
    @updated 01/08/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#include "b2dJsonImage.h"

@class B2DBody;


/** A wrapper around b2dJsonImage */
@interface RUBEImage : NSObject
/** the name is the name of the image file; which usually is the same as the name of
 * the spriteFrame */
@property (nonatomic, readonly) NSString *name;
/** file is usually not applicable as we'd be using CCSpriteFrame all the
 * time, but it is still there for information */
//@property (nonatomic, readonly) NSString *file;
@property (nonatomic, readonly) B2DBody *body;
@property (nonatomic, readonly) float scale;
@property (nonatomic, readonly) float angle;
@property (nonatomic, readonly) GLubyte opacity;
@property (nonatomic, readonly) ccColor3B colorTint;
@property (nonatomic, readonly) BOOL flip;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) int zOrder;

+ (id)imageWithB2dJsonImage:(b2dJsonImage *)image;
@end
