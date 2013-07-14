//
// Created by Lingnan Dai on 25/04/2013.
//


#import <Foundation/Foundation.h>

@interface CCSprite (LnAdditions)
+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName maskAlphaThreshold:(UInt8)alphaThreshold maskSuffix:(NSString *)suffix;

// convenience method used to quickly set a new frame w. mask (retrieve the mask if it already exists)
- (void)setDisplayFrameWithFrameName:(NSString *)name maskSuffix:(NSString *)suffix maskAlphaThreshold:(UInt8)alphaThreshold;

- (void)setDisplayFrameWithFrameName:(NSString *)spriteFrameName;
@end