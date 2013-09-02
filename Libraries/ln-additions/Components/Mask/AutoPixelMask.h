/*!
    @header AutoPixelMask
    @copyright LnStudio
    @updated 01/09/2013
    @author lingnan
*/

#import <Foundation/Foundation.h>
#import "PixelMask.h"


typedef PixelMaskData *(^SpriteFrameToPixelMaskDataTransformation) (CCSpriteFrame *);
/** Provides automatic syncing of pixel mask with the host sprite */
/** We provides a basic property:
*    frame name -> pixelMaskData transformation
* */
@interface AutoPixelMask : PixelMask
@property (nonatomic, weak) CCSprite *host;
@property (nonatomic, copy) SpriteFrameToPixelMaskDataTransformation transformation;

+ (SpriteFrameToPixelMaskDataTransformation)transformationWithMaskSuffix:(NSString *)suffix alphaThreshold:(UInt8)alphaThreshold;

+ (id)maskWithTransformation:(SpriteFrameToPixelMaskDataTransformation)transformation;
@end
