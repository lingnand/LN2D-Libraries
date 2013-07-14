//
// Created by knight on 30/01/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "Mask.h"

@class BitMaskData;


@interface BitMask:Mask

- (id)initWithData:(BitMaskData *)maskData;

- (id)copyWithZone:(NSZone *)zone;

+ (id)maskWithData:(BitMaskData *)maskData;

@end
