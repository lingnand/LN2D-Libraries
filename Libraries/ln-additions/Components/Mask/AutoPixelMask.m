/*!
    @header AutoPixelMask
    @copyright LnStudio
    @updated 01/09/2013
    @author lingnan
*/

#import "AutoPixelMask.h"
#import "CCSpriteFrameCache+LnAdditions.h"
#import "MaskDataCache.h"
#import "PixelMaskData.h"


static int AutoPixelMaskMonitoringContext;
@implementation AutoPixelMask {

}

/** We should give a few frequently used transformations for ease of use */
+ (SpriteFrameToPixelMaskDataTransformation)transformationWithMaskSuffix:(NSString *)suffix alphaThreshold:(UInt8)alphaThreshold {
    return ^PixelMaskData *(CCSpriteFrame *frame) {
        // first get the name of the mask frame
        return frame ? [[MaskDataCache sharedCache] dataForSpriteFrame:frame maskDataGenerator:^MaskData *(CCSpriteFrame *frame) {
            return [PixelMaskData dataWithFrameName:[[CCSpriteFrameCache sharedSpriteFrameCache]nameOfSpriteFrame:frame] alphaThreshold:alphaThreshold maskSuffix:suffix];
             ;
        }] : nil;
    };
}

+ (id)maskWithTransformation:(SpriteFrameToPixelMaskDataTransformation)transformation {
    AutoPixelMask *m = [self mask];
    m.transformation = transformation;
    return m;
}

- (void)componentActivated {
    [super componentActivated];
    // we should add the observer for the sprite
    [self.host addObserver:self
                forKeyPath:@"displayFrame"
                   options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                   context:&AutoPixelMaskMonitoringContext];
}

- (void)componentDeactivated {
    [super componentDeactivated];
    [self.host removeObserver:self forKeyPath:@"displayFrame" context:&AutoPixelMaskMonitoringContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &AutoPixelMaskMonitoringContext) {
        if ([keyPath isEqualToString:@"displayFrame"]) {
            // we should apply the transformation
            CCSpriteFrame *of = change[NSKeyValueChangeOldKey];
            CCSpriteFrame *nf = change[NSKeyValueChangeNewKey];
            if (nf != of)
                self.maskData = self.transformation(nf);
        }
    } else
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end