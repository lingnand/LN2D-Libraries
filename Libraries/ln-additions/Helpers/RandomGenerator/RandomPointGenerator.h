//
// Created by knight on 18/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "InfiniteRandomGenerator.h"

@class RandomDoubleGenerator;


@interface RandomPointGenerator : InfiniteRandomGenerator
- (id)initWithPoint:(CGPoint)point;

- (id)initWithRect:(CGRect)rect;

+ (id)generatorWithRect:(CGRect)rect;

+ (id)generatorWithPoint:(CGPoint)point;
@end