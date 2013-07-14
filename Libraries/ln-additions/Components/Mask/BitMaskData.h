//
// Created by Lingnan Dai on 28/06/2013.
//


#import <Foundation/Foundation.h>
#import "MaskData.h"


@interface BitMaskData : MaskData
@property (nonatomic) CGRect window;
@property (nonatomic) CFMutableBitVectorRef bitset;

+ (UIImage *)convertSpriteToImage:(CCSprite *)sprite;

+ (id)dataWithSprite:(CCSprite *)sprite alphaThreshold:(UInt8)alphaThreshold;

+ (id)dataWithSprite:(CCSprite *)sprite;

+ (id)dataWithFrameName:(NSString *)name alphaThreshold:(UInt8)alphaThreshold;

+ (id)dataWithFrame:(CCSpriteFrame *)frame alphaThreshold:(UInt8)threshold;

+ (id)dataWithFrameName:(NSString *)name alphaThreshold:(UInt8)alphaThreshold maskSuffix:(NSString *)suffix;

+ (id)dataWithImage:(UIImage *)image alphaThreshold:(UInt8)alphaThreshold;
@end