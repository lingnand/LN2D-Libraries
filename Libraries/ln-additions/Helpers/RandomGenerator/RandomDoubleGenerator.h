//
// Created by knight on 04/02/2013.
//
// Contact me via Email(dlnathos321@gmail.com) or Twitter(@dailingnan)
//


#import <Foundation/Foundation.h>
#import "RandomGenerator.h"
#import "InfiniteRandomGenerator.h"


@interface RandomDoubleGenerator : InfiniteRandomGenerator


+ (id)generatorWithLowDouble:(double)low highDouble:(double)high;

- (id)initWithLowDouble:(double)low highDouble:(double)high;


@end