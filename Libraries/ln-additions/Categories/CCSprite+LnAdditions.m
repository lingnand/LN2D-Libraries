//
// Created by Lingnan Dai on 25/04/2013.
//


#import "CCSprite+LnAdditions.h"
#import "NSObject+LnAdditions.h"
#import "CCNode+LnAdditions.h"
#import "MaskDataCache.h"
#import "PixelMask.h"
#import "PixelMaskData.h"


@implementation CCSprite (LnAdditions)

+(id)spriteWithSpriteFrameName:(NSString *)spriteFrameName maskAlphaThreshold:(UInt8)alphaThreshold maskSuffix:(NSString *)suffix {
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteFrameName];
    sprite.mask = [PixelMask maskWithData:[[MaskDataCache sharedCache] dataForFrameName:spriteFrameName
                                                                      maskDataGenerator:^MaskData *(NSString *f) {
                                                                          return [PixelMaskData dataWithFrameName:f alphaThreshold:alphaThreshold maskSuffix:suffix];
                                                                      }]];
    return sprite;
}

- (void)setDisplayFrameWithFrameName:(NSString *)name maskSuffix:(NSString *)suffix maskAlphaThreshold:(UInt8)alphaThreshold {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
    [self setDisplayFrame:frame];
    self.mask = [PixelMask maskWithData:[[MaskDataCache sharedCache] dataForFrameName:name
                                                                    maskDataGenerator:^MaskData *(NSString *f) {
                                                                        return [PixelMaskData dataWithFrameName:f alphaThreshold:alphaThreshold maskSuffix:suffix];
                                                                    }]];
}

-(void)setDisplayFrameWithFrameName:(NSString *)spriteFrameName {
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName]];
}


@end

