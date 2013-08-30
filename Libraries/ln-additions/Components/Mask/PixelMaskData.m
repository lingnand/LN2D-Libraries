//
// Created by Lingnan Dai on 28/06/2013.
//


#import "PixelMaskData.h"
#import "NSString+LnAddition.h"


@implementation PixelMaskData {

}

-(id)initWithImage:(UIImage *)image alphaThreshold:(UInt8)alphaThreshold {
    if (self = [super init]) {
        NSUInteger width = (NSUInteger) (CC_CONTENT_SCALE_FACTOR() * image.size.width);
        NSUInteger height = (NSUInteger) (CC_CONTENT_SCALE_FACTOR() * image.size.height);
        NSUInteger size = width * height;

        // set up the bit vector
        CFMutableBitVectorRef oriBitVector = CFBitVectorCreateMutable(CFAllocatorGetDefault(), size);
        CFBitVectorSetCount(oriBitVector, size);
        // get the pixel data (more correctly: pixels) as 32-Bit unsigned integers
        CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider([image CGImage]));
        const UInt32 *imagePixels = (const UInt32 *) CFDataGetBytePtr(imageData);

//        NSLog(@"image pixel size = %ld", CFDataGetLength(imageData));

        UInt8 alphaValue = 0;

        // going to determine the smallest rect to hold the content
        NSUInteger minX = width, minY = height, maxX = 0, maxY = 0;

        for (NSUInteger x = 0; x < width; x++) {
            for (NSUInteger y = 0; y < height; y++) {

                alphaValue = (UInt8) ((imagePixels[x + width * (height - 1 - y)] & 0xff000000) >> 24);
//            NSLog(@"alpha value = %i", alphaValue);
                if (alphaValue >= alphaThreshold) {
                    minX = MIN(x, minX);
                    minY = MIN(y, minY);
                    maxX = MAX(x, maxX);
                    maxY = MAX(y, maxY);
                    // a set bit
                    CFBitVectorSetBitAtIndex(oriBitVector, x + width * y, 1);
                } else
                    CFBitVectorSetBitAtIndex(oriBitVector, x + width * y, 0);
            }
        }
        CFRelease(imageData);

        NSUInteger w_width = maxX - minX + 1, w_height = maxY - minY + 1, w_size = w_width * w_height;

        _window = CGRectMake(minX, minY, w_width, w_height);
        _bitset = CFBitVectorCreateMutable(CFAllocatorGetDefault(), w_size);
        CFBitVectorSetCount(self.bitset, w_size);
        for (NSUInteger x = 0; x < w_width; x++) {
            for (NSUInteger y = 0; y < w_height; y++) {
                CFBitVectorSetBitAtIndex(self.bitset, x + y * w_width, CFBitVectorGetBitAtIndex(oriBitVector, minX + x + (minY + y) * w_width));
            }
        }
        CFRelease(oriBitVector);
    }
    return self;
}

- (void)dealloc {
    CFRelease(self.bitset);
}

+ (UIImage *)convertSpriteToImage:(CCSprite *)sprite {
    CGPoint p = sprite.anchorPoint;
    sprite.anchorPoint = ccp(0, 0);

    CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:(int) sprite.contentSize.width height:(int) sprite.contentSize.height];

    [renderer begin];
    [sprite visit];
    [renderer end];

    sprite.anchorPoint = p;
    UIImage *image = renderer.getUIImage;
    return image;
}

+ (id)dataWithSprite:(CCSprite *)sprite alphaThreshold:(UInt8)alphaThreshold {
    return [self dataWithImage:[self convertSpriteToImage:sprite] alphaThreshold:alphaThreshold];
}

+ (id)dataWithSprite:(CCSprite *)sprite {
    return [self dataWithSprite:sprite alphaThreshold:200];
}


+ (id)dataWithFrameName:(NSString *)name alphaThreshold:(UInt8)alphaThreshold {
    return [self dataWithSprite:[CCSprite spriteWithSpriteFrameName:name] alphaThreshold:alphaThreshold];
}

+ (id)dataWithFrame:(CCSpriteFrame *)frame alphaThreshold:(UInt8)threshold {
    return [self dataWithSprite:[CCSprite spriteWithSpriteFrame:frame] alphaThreshold:threshold];
}


+ (id)dataWithFrameName:(NSString *)name alphaThreshold:(UInt8)alphaThreshold maskSuffix:(NSString *)suffix {
    if (!suffix)
        return [self dataWithFrameName:name alphaThreshold:alphaThreshold];
    else {
        CCSpriteFrame *maskFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[name stringByAppendingFileSuffix:suffix]];
        if (!maskFrame) {
//            CCLOG(@"cannot find a mask with the given suffix, reverting to the original frame instead");
            maskFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
        }
        return [self dataWithFrame:maskFrame alphaThreshold:alphaThreshold];
    }
}


+ (id)dataWithImage:(UIImage *)image alphaThreshold:(UInt8)alphaThreshold {
    return [[self alloc] initWithImage:image alphaThreshold:alphaThreshold];
}


@end