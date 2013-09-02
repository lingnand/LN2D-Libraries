//
// Created by knight on 30/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//
// TODO: optimise the code and clean up the signatures
// ideas: using a NSCache instead of a NSMutableDictionary
// 1. use the pair **<frameName, alphaThreshold>** of the mask as the key#import "MaskData.h"
// 2. multithreaded mask creation may NOT be necessary (remove that)
// questions:


#import "MaskDataCache.h"
#import "NSString+LnAddition.h"
#import "Mask.h"
#import "PixelMask.h"
#import "MaskData.h"

@implementation MaskDataCache {

}

+ (MaskDataCache *)sharedCache {
    static MaskDataCache *cache = nil;
    if (!cache) {
        cache = [[self alloc] init];
    }
    return cache;
}

- (id)dataForSpriteFrame:(CCSpriteFrame *)f maskDataGenerator:(MaskData *(^)(CCSpriteFrame *frame))generator {
    return [self objectForKey:f valueGenerator:generator];
}

@end
