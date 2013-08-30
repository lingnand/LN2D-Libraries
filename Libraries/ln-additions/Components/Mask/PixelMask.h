//
// Created by knight on 30/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "BodilyMask.h"

@class PixelMaskData;


@interface PixelMask : BodilyMask
@property (nonatomic, strong) PixelMaskData *maskData;

- (id)initWithData:(PixelMaskData *)maskData;

- (id)copyWithZone:(NSZone *)zone;

+ (id)maskWithData:(PixelMaskData *)maskData;

@end
